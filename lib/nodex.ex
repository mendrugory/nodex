defmodule Nodex do
  @moduledoc"""
  `Nodex` is a __OTP Application__ which will take care of your connected nodes.

  `Nodex` can launch `Nodex.NodesWatcher`s which will be the responsibles of taking care of 
  the connected nodes. By default there is a `Nodex.NodesWatcher` already launched.

  start a `Nodex.NodesWatcher`
  ```elixir
  iex> Nodex.start_nodes_watcher(:my_nodes_watcher)
  ```

  and stop it later:
  ```elixir
  iex> Nodex.stop_nodes_watcher(:my_nodes_watcher)
  ```

  In order to connect to a node we only have to do the following:
  ```elixir
  iex> Nodex.connect(nodo, :my_nodes_watcher) #specific nodes_watcher
  iex> Nodex.connect(nodo) #default nodes_watcher
  ```
  A node is specified using `Nodex.Node` and the simplest example would be:
  ```elixir
  iex> Nodex.connect(%Nodex.Node{app_name: :app, host_address: "my.host"})
  ```
  """

  @doc"""
  It starts a new `Nodex.NodesWatcher`. The input has to be a term() because it will be used
  as name of the process.
  """
  def start_nodes_watcher(name) do
    Nodex.NodesWatcherSupervisor.start_child(%{name: name})
  end

  @doc"""
  It stops the `Nodex.NodesWatcher` whose name is given.
  """
  def stop_nodes_watcher(name) do
    Nodex.NodesWatcherSupervisor.terminate_child(name)
  end

  @doc"""
  It connects to a node using an active `Nodex.NodesWatcher`. If no `Nodex.NodesWatcher` is 
  given, it will used the default one.
  The node has to be specified using a `Nodex.Node`.
  """  
  defdelegate connect(nodo, nodes_watcher \\ :nodes_watcher_default), to: Nodex.NodesWatcher
end