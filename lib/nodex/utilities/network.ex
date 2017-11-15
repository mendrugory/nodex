defmodule Nodex.Utilities.Network do
  @moduledoc "Utilities Module to help you when some network issues.\n"

  @address_familiy_inet :inet
  @address_familiy_inet6 :inet6
  @address_familiy_local :local

  @doc"""
  It returns the name of the node as :atom given the name of the app, the address of the host
  and the family address:
  * :inet
  * :inet6
  * :local
  """
  def get_node_atom(app_name, address, address_family \\ @address_familiy_inet)

  def get_node_atom(app_name, address, _address_family)
      when is_tuple(address) do
    {:ok, String.to_atom("#{app_name}@#{tuple_ip_to_str(address)}")}
  end

  def get_node_atom(app_name, address, address_family)
      when is_binary(address) do
    case get_ip(address, address_family) do
      {:ok, ip} ->
        {:ok, String.to_atom("#{app_name}@#{ip}")}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc"""
  It returns ip address in string mode given a host address and a family address
  * :inet
  * :inet6
  * :local
  """
  def get_ip(host_name, address_family \\ @address_familiy_inet)


  def get_ip(host_name, address_family) when is_binary(host_name) do
    get_ip String.to_charlist(host_name), address_family
  end

  def get_ip(host_name, address_family) when is_list(host_name) do
    case :inet.getaddr(host_name, address_family) do
      {:ok, {:local, address}} ->
        {:ok, address}

      {:ok, address} when is_tuple(address) ->
        {:ok, tuple_ip_to_str(address)}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, "Error getting IP of #{host_name}"}
    end
  end


  defp tuple_ip_to_str(ip) do
    Enum.join Tuple.to_list(ip), "."
  end
end
