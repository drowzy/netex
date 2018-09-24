defmodule Netex.K8s.Reflector do
  use GenServer
  require Logger

  alias Kazan.Models.Apimachinery.Meta.V1.WatchEvent

  defmodule State do
    defstruct conn: nil, controller: nil, params: nil, watcher_pid: nil
  end

  def start_link(controller, conn, opts) do
    params = Keyword.get(opts, :params, [])

    GenServer.start_link(__MODULE__, {controller, conn, params}, opts)
  end

  def init({controller, conn, params}) do
    {:ok,
     %State{
       controller: controller,
       conn: conn,
       params: params,
       watcher_pid: nil
     }, {:continue, :ok}}
  end

  def handle_continue(_, state) do
    {:noreply, do_sync(state)}
  end

  def handle_cast(:sync, %State{} = state) do
    {:noreply, state}
  end

  def handle_info(
        %WatchEvent{object: object, type: type} = event,
        %State{controller: ctrl} = state
      ) do

    type =
      type
      |> String.downcase()
      |> String.to_atom()

    _ = process_event(type, ctrl, event)
    {:noreply, state}
  end

  defp do_sync(%State{conn: conn, controller: ctrl, params: params} = state) do
    case Netex.K8s.Client.list_and_watch(conn, &ctrl.list_fn/1, &ctrl.watch_fn/1, params) do
      {:ok, resource, pid} ->
        ctrl.handle_sync(resource)
        Logger.debug("#{__MODULE__} :: SYNC Ok! Resource: #{inspect(resource)}")
        %{state | watcher_pid: pid}

      err ->
        Logger.error("#{__MODULE__} :: SYNC Failed. Error: #{inspect(err)}")
        state
    end
  end

  defp process_event(:added, controller, event), do: controller.handle_added(event)
  defp process_event(:modified, controller, event), do: controller.handle_modified(event)
  defp process_event(:deleted, controller, event), do: controller.handle_deleted(event)
end
