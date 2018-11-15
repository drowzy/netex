defmodule Netex.K8s.Client do
  def list_and_watch(mod, req_runner, %Kazan.Server{} = conn, list_fn, watch_fn, opts) do
    with req <- list_fn.(opts),
         {:ok, resource} <- req_runner.run(req, server: conn),
         {:ok, pid} <- start_watcher(mod, conn, watch_fn, resource, opts) do
      {:ok, resource, pid}
    else
      err ->
        err
    end
  end

  defp start_watcher(mod, %Kazan.Server{} = conn, watch_fn, resource, opts) do
    mod.start_link(
      watch_fn.(resource, opts),
      server: conn,
      resource_version: resource.metadata.resource_version,
      send_to: self()
    )
  end
end
