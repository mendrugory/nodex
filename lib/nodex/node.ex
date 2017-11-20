defmodule Nodex.Node do
  @moduledoc """
  Module which will define a struct that will be used by `Nodex.NodesWatcher`

  ```elixir
  iex> remote_procedure = fn(node_name) -> my_function(node_name) end
  iex> Nodex.connect(%Nodex.Node{app_name: :app, host_address: "my.host", fun_after_conn: remote_procedure, reconnection_time: 10_000})
  ```

  If no `reconnection_time` time is specified (in millis) it will take the default value, 10 seconds.

  `fun_after_conn` is a function or a a tuple with the module and the function {MyModule, :my_func} 
  that will be executed just after the connection with the node is done.
  It will receive an input, the name of the node.
  """
  @reconnection_time 10000
  @enforce_keys [:app_name, :host_address]
  defstruct [
              :app_name,
              :host_address,
              :fun_after_conn,
              {:reconnection_time, @reconnection_time},
            ]
end
