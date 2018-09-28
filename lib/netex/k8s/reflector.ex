defmodule Netex.K8s.Reflector do
  use GenServer
  require Logger

  alias Kazan.Models.Apimachinery.Meta.V1.WatchEvent

  defmodule State do
    defstruct conn: nil, mod: nil, params: nil, watcher_pid: nil, mod_state: nil
  end

  def start_link(mod, conn, opts) do
    GenServer.start_link(__MODULE__, {mod, conn, opts}, opts)
  end

  def init({mod, conn, opts}) do
    params = Keyword.get(opts, :params, [])

    mod_opts = opts
      |> Keyword.merge([conn: conn])
      |> mod.init()

    case mod_opts do
      {:ok, mod_state} ->
        {:ok,
         %State{
           mod: mod,
           mod_state: mod_state,
           conn: conn,
           params: params,
           watcher_pid: nil
         }, {:continue, :ok}}

      {:error, _error} ->
        {:stop, :normal, :error}
    end
  end

  def handle_continue(_, state) do
    {:noreply, do_sync(state)}
  end

  def handle_cast(:sync, %State{} = state) do
    {:noreply, state}
  end

  def handle_info(
        %WatchEvent{type: type} = event,
        %State{mod: mod, mod_state: mod_state} = state
      ) do
    type =
      type
      |> String.downcase()
      |> String.to_atom()

    new_mod_state = process_event({type, event}, mod, mod_state)
    {:noreply, %{state | mod_state: new_mod_state}}
  end

  defp do_sync(%State{conn: conn, mod: mod, mod_state: mod_state, params: params} = state) do
    case Netex.K8s.Client.list_and_watch(conn, &mod.list_fn/1, &mod.watch_fn/2, params) do
      {:ok, resource, pid} ->
        new_mod_state = mod.handle_sync(resource, mod_state)

        %{state | watcher_pid: pid, mod_state: new_mod_state}
      _err ->
        state
    end
  end

  defp process_event({:added, event}, mod, mod_state), do: mod.handle_added(event, mod_state)

  defp process_event({:modified, event}, mod, mod_state),
    do: mod.handle_modified(event, mod_state)

  defp process_event({:deleted, event}, mod, mod_state), do: mod.handle_deleted(event, mod_state)
end
