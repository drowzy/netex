defmodule Netex.K8s.Client do
  def list_and_watch(%Kazan.Server{} = conn, list_fn, watch_fn, opts) do
    with req <- list_fn.(opts),
         {:ok, resource} <- Kazan.run(req, server: conn),
         {:ok, pid} <- start_watcher(conn, watch_fn, resource.metadata.resource_version, opts) do
      {:ok, resource, pid}
    else
      err ->
        err
    end
  end

  defp start_watcher(%Kazan.Server{} = conn, watch_fn, resource_version, opts) do
    Kazan.Watcher.start_link(
      watch_fn.(opts),
      server: conn,
      resource_version: resource_version,
      send_to: self()
    )
  end
end
