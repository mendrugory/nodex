defmodule Nodex.NodesWatcher do
  @moduledoc """
  `Nodex.NodesWatcher` is the a `GenServer` which will be in charge of supervising 
  its connected nodes and try to reconnect if the node is down.

  By Default there is a default `Nodex.NodesWatcher` but it is possible to start 
  different `Nodex.NodesWatcher` in order to have better structure.

  ```elixir
  iex> Nodex.NodesWatcher.start_link(%Nodex.NodesWatcher{name: :my_nodes_watcher})
  ```

  To connect to a node you have to:
  ```elixir
  iex> Nodex.connect(%Nodex.Node{app_name: :app, host_address: "my.host"}, node_watcher)
  # or Using the default nodes watcher
  iex> Nodex.connect(%Nodex.Node{app_name: :app, host_address: "my.host"})
  ```

  When you need to do execute anything in the remote code just after the connection:
  ```elixir
  iex> remote_procedure = fn(node_name) -> my_function(node_name) end
  iex> Nodex.connect(%Nodex.Node{app_name: :app, host_address: "my.host", fun: remote_procedure})
  ```

  A reconnection time can be specified in `Nodex.Node`: 
  ```elixir
  iex> %Nodex.Node{app_name: :app, host_address: "my.host", reconnection_time: 10_000}
  ```
  """
  use GenServer
  alias Nodex.Utilities.Network
  require Logger

  @nodes_watcher_default      :nodes_watcher_default

  defstruct [:name]
  
  def start_link(%Nodex.NodesWatcher{name: name}) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end


  @doc"""
    It will use the given `Nodex.NodesWatcher` in order handle the connection to the 
    given `Nodex.Node`
  """
  def connect(node_arguments, nodes_watcher \\ @nodes_watcher_default) do
    GenServer.cast(nodes_watcher, {:connect, node_arguments})
  end

  def init(_) do
    {:ok, %{nodes: %{}}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end


  def handle_cast({:connect, nodo}, state) do
    async_do_connect(nodo)
    {:noreply, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end


  def handle_info({:connect, nodo}, state) do
    async_do_connect(nodo)
    {:noreply, state}
  end

  def handle_info({:register_node, {node_name, nodo}},
                  %{nodes: nodes} = state) do
    Node.monitor(node_name, true)
    {:noreply, %{state | nodes: Map.put(nodes, node_name, nodo)}}
  end

  def handle_info({:nodedown, node_down_name}, %{nodes: nodes} = state) do
    if node_down_name in Map.keys(nodes) do
      Logger.info("Node #{node_down_name} is down.")
      {nodo, new_nodes} = Map.pop(nodes, node_down_name)
      async_do_connect(nodo)
      {:noreply, %{state | nodes: new_nodes}}
    else
      {:noreply, state}
    end
  end


  defp async_do_connect(nodo) do
    nodes_watcher = self()
    Task.start(fn -> do_connect(nodo, nodes_watcher) end)
  end


  defp do_connect(%Nodex.Node{app_name: app_name, host_address: host_address} = nodo,
                  nodes_watcher) do
    case Network.get_node_atom(app_name, host_address) do
      {:error, error} ->
        Logger.error("Error #{inspect nodes_watcher} #{__MODULE__}.connect(): #{inspect(error)}")
        Process.send_after(nodes_watcher, {:connect, nodo}, nodo.reconnection_time)

      {:ok, node_name} ->
        unless Node.connect(node_name) do
          Process.send_after(nodes_watcher, {:connect, nodo}, nodo.reconnection_time)
        else
          Logger.info "Connected to #{node_name}."
          case Map.get(nodo, :fun_after_conn) do
            {mod, func} -> apply(mod, func, [node_name])
            f when is_function(f) -> f.(node_name)
            _ -> :nothing
          end
          send(nodes_watcher, {:register_node, {node_name, nodo}})
        end

      error -> 
        Logger.error("Error #{inspect nodes_watcher} #{__MODULE__}.connect(): #{inspect(error)}")
        Process.send_after(nodes_watcher, {:connect, nodo}, nodo.reconnection_time)
    end
  end
end
