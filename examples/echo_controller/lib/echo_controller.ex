defmodule EchoController do
  use Netex.Controller
  require Logger

  def init(opts) do
    {:ok, %{conn: Keyword.get(opts, :conn)}}
  end

  def watch_fn(opts \\ [])
  defdelegate watch_fn(config),
    to: Kazan.Apis.Core.V1, as: :watch_service_list_for_all_namespaces!

  def list_fn(opts \\ [])
  defdelegate list_fn(config),
    to: Kazan.Apis.Core.V1, as: :list_service_for_all_namespaces!

  @impl true
  def handle_added(event, state) do
    Logger.info("#{__MODULE__} ADDED :: #{inspect event} STATE: #{inspect state}")
    :ok
  end

  @impl true
  def handle_deleted(event, state) do
    Logger.info("#{__MODULE__} DELETED :: #{inspect event} STATE: #{inspect state}")
    :ok
  end

  @impl true
  def handle_modified(event, state) do
    Logger.info("#{__MODULE__} MODIFIED :: #{inspect event} STATE: #{inspect state}")
    :ok
  end

  @impl true
  def handle_sync(event, state) do
    Logger.info("#{__MODULE__} SYNC :: #{inspect event} STATE: #{inspect state}")
    :ok
  end
end
