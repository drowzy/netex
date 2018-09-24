defmodule Netex.Controller do
  alias Kazan.Models.Apimachinery.Meta.V1.WatchEvent

  @callback watch_fn(config :: Keyword.t()) :: (any -> any)
  @callback list_fn(config :: Keyword.t()) :: (any -> any)

  @callback handle_sync(any) :: {:ok, any} | {:error, term}

  @callback handle_added(WatchEvent.t()) :: {:ok, any} | {:error, term}
  @callback handle_modified(WatchEvent.t()) :: {:ok, any} | {:error, term}
  @callback handle_deleted(WatchEvent.t()) :: {:ok, any} | {:error, term}

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Netex.Controller

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, opts}
        }
      end

      def start_link(opts) do
        %Kazan.Server{} = conn = Keyword.fetch!(opts, :conn)
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
