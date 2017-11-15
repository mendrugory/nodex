# Nodex

`Nodex` is a __OTP Application__ which will take care of your connected nodes. It will
connect to a given node, reconnect if the connection is lost and will help you with some
some issues like ip resolution or launching custom functions just after the connection 
with the node is done.


## Installation
  * Add `nodex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
       [{:nodex, git: "git: "https://github.com/mendrugory/nodex.git"}]
    end
    ```
# Connection
  ```elixir
  iex> Nodex.connect(%Nodex.Node{app_name: :app, host_address: "my.host"})
  ```
  In `Nodex.Node` can be also specified the reconnection time and a function 
  that will be executed just after the connection with the node is done. This function is very 
  useful if you need to log or save some information in the local node or execute any function, like a registration, in the connected node. This function will receive the name of the connected node as argument.
  ```elixir
  iex> remote_procedure = fn(node_name) -> my_function(node_name) end
  iex> Nodex.connect(%Nodex.Node{app_name: :app, host_address: "my.host", fun: remote_procedure, reconnection_time: 10_000})
  ```

  `Nodex.NodesWatcher`s are the processes that deal with the connected nodes. If you don't specify any, it will work with the default one.
  ```elixir
  iex> Nodex.connect(%Nodex.Node{app_name: :app, host_address: "my.host"}, :my_nodes_watcher)
  ```
  
## Start a NodesWatcher
  Altough `Nodex` could work with only one `Nodex.NodesWatcher` (the default one is up and running after the app is initialized) and it would be enough for most of the distributed applications, some of them with a lot of connected nodes need a better structure. This improvement can be achieved groping the nodes in different `Nodex.NodesWatcher`
  ```elixir
  iex> Nodex.start_nodes_watcher(:my_nodes_watcher)
  ```

## Stop a NodesWatcher
  ```elixir
  iex> Nodex.stop_nodes_watcher(:my_nodes_watcher)
  ```

## Test
  * Run the tests.
  ```bash
  mix test
  ```

## Test
  * Create documentation.
  ```bash
  mix docs
  ```  
  
  
