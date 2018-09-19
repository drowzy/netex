defmodule EchoController do
  use Netex.Controller
  require Logger

  def watch_fn(opts \\ [])
  defdelegate watch_fn(config),
    to: Kazan.Apis.Core.V1, as: :watch_service_list_for_all_namespaces!

  def list_fn(opts \\ [])
  defdelegate list_fn(config),
    to: Kazan.Apis.Core.V1, as: :list_service_for_all_namespaces!

  @impl true
  def handle_added(event) do
    Logger.info("#{__MODULE__} ADDED :: #{inspect event}")
    :ok
  end

  @impl true
  def handle_deleted(event) do
    Logger.info("#{__MODULE__} DELETED :: #{inspect event}")
    :ok
  end

  @impl true
  def handle_modified(event) do
    Logger.info("#{__MODULE__} MODIFIED :: #{inspect event}")
    :ok
  end

  @impl true
  def handle_sync(event) do
    Logger.info("#{__MODULE__} SYNC :: #{inspect event}")
    :ok
  end
end
