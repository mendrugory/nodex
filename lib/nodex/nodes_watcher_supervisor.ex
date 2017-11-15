defmodule Nodex.NodesWatcherSupervisor do
  use Supervisor

  alias Nodex.NodesWatcher

  require Logger

  @wait_time_to_connect_default_nodes_watcher 200
  def start_link() do
    Supervisor.start_link __MODULE__, [], name: __MODULE__
  end


  def init([]) do
    start_default_nodes_watcher()
    children = [worker(NodesWatcher, [], restart: :transient)]
    supervise children, strategy: :simple_one_for_one
  end


  def start_child(arguments) do
    name = Map.get(arguments, :name)
    Logger.info "Starting NodesWatcher: #{inspect(name)} ..."
    Supervisor.start_child __MODULE__, [%NodesWatcher{name: name}]
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


  defp start_default_nodes_watcher() do
    Task.start fn ->
                 Process.sleep(@wait_time_to_connect_default_nodes_watcher)
                 Nodex.NodesWatcherSupervisor.start_child(%{
                                                            name: :nodes_watcher_default,
                                                          })
               end
  end
end
