defmodule Nodex.NodesWatcherSupervisor do
  use Supervisor

  alias Nodex.NodesWatcher

  require Logger

  @wait_time_to_connect_default_nodes_watcher 200
  def start_link() do
    Supervisor.start_link __MODULE__, [], name: __MODULE__
  end


  def init(_) do
    start_configuration_nodes_watcher()
    children = [worker(NodesWatcher, [], restart: :transient)]
    supervise children, strategy: :simple_one_for_one
  end


  def start_child(arguments) do
    Logger.info "Starting NodesWatcher: #{inspect(arguments.name)} ..."
    Supervisor.start_child(__MODULE__, [struct(NodesWatcher, arguments)])
  end


  def terminate_child(name) when name == :nodes_watcher_default do
    Logger.error "The default NodesWatcher should not been shut down."
  end


  def terminate_child(name) do
    Logger.info "Terminating NodesWatcher: #{inspect(name)} ..."
    pid = :erlang.whereis(name)
    if is_pid(pid) do
      Supervisor.terminate_child __MODULE__, pid
    else
      Logger.info "The PID of the NodesWatcher #{inspect(name)} has not been resolved."
    end
  end

  defp start_configuration_nodes_watcher() do
    Task.start(
      fn ->
        Process.sleep(@wait_time_to_connect_default_nodes_watcher)
        start_nodes_watcher(:nodes_watcher_default)
        case Application.get_env(:nodex, :nodes) do
          nodes when is_map(nodes) ->
            Enum.each(
              nodes, 
              fn {nodes_watcher_name, nodos} -> 
                start_nodes_watcher(nodes_watcher_name)
                Enum.each(nodos, fn nodo -> connect_to_node(nodes_watcher_name, nodo) end)
              end
            )
          _ ->
            nil
        end
      end
    )
  end

  defp start_nodes_watcher(nodes_watcher_name) do
    case :erlang.whereis(nodes_watcher_name) do
      :undefined ->
        start_child(%{name: nodes_watcher_name})    
      pid when is_pid(pid) ->
        Logger.info("NodesWatcher #{nodes_watcher_name} is already running.")
      msg ->
        Logger.error("Error starting NodesWatcher #{nodes_watcher_name}")
    end
  end

  defp connect_to_node(nodes_watcher, arguments) do
    Nodex.connect(struct(Nodex.Node, arguments), nodes_watcher)
  end

end
