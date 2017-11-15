defmodule NetworkTest do
  use ExUnit.Case

  alias Nodex.Utilities.Network

  test "get node atom using IP" do
    {:ok, result} = Network.get_node_atom(:my_app, {127,0,0,1})
    assert result == :"my_app@127.0.0.1"
  end

end
