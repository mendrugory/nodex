defmodule Nodex.Node do
  @moduledoc """
  Module which will define a struct that will be used by `Nodex.NodesWatcher`

  ```elixir
  iex> remote_procedure = fn(node_name) -> my_function(node_name) end
  iex> Nodex.connect(%Nodex.Node{app_name: :app, host_address: "my.host", fun: remote_procedure, reconnection_time: 10_000})
  ```

  If no `reconnection_time` time is specified (in millis) it will take the default value, 10 seconds.

  `fun` is a function that will be executed just after the connection with the node is done.
  It will receive an input, the name of the node.
  """
  @reconnection_time 10000
  @enforce_keys [:app_name, :host_address]
  defstruct [
              :app_name,
              :host_address,
              {:reconnection_time, @reconnection_time},
              :fun,
            ]
end
