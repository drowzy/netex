defmodule Netex.Controller do
  alias Kazan.Models.Apimachinery.Meta.V1.WatchEvent

  @callback watch_fn(resource :: any, config :: Keyword.t()) :: (any -> any)
  @callback list_fn(config :: Keyword.t()) :: (any -> any)

  @callback init(any) :: {:ok, any()} | {:error, term}
  @callback handle_sync(any, any) :: {:ok, any} | {:error, term}
  @callback handle_added(WatchEvent.t(), any) :: {:ok, any} | {:error, term}
  @callback handle_modified(WatchEvent.t(), any) :: {:ok, any} | {:error, term}
  @callback handle_deleted(WatchEvent.t(), any) :: {:ok, any} | {:error, term}

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Netex.Controller

      def child_spec(arg) do
        default = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, arg}
        }

        Supervisor.child_spec(default, unquote(Macro.escape(opts)))
      end

      def start_link(conn, opts) do
        Netex.K8s.Reflector.start_link(__MODULE__, conn, opts)
      end

      def stop(server) do
        GenServer.stop(server)
      end

      def sync_now(server) do
        GenServer.cast(server, :sync)
      end
    end
  end
end
