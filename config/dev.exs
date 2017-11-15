use Mix.Config

config :nodex,
  nodes: %{
    nodes_watcher1: [
      %{ app_name: :test,
      host_address: "127.0.0.1",
      fun: fn(node_name) -> IO.puts "Hola #{node_name}!!" end
      }
    ],
    nodes_watcher2: [
      %{ app_name: :test,
      host_address: "127.0.0.1",
      fun: fn(node_name) -> IO.puts "Hello #{node_name}!!" end,
      reconnection_time: 2_000
      }
    ]                        
  }

