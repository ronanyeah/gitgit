defmodule Gitgit do
  @moduledoc """
  Scraping github profiles from gitter.
  """

  use GenServer

  @name GW

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: GW])
  end

  def get_usernames do
    GenServer.call(@name, {:usernames})
  end

  def add_results(data) do
    GenServer.call(@name, {:add_results, data})
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:add_results, data}, _from, state) do
    {:reply, :ok, data ++ state}
  end

  def handle_call({:usernames}, _from, state) do
    {:reply, Gitgit.Helpers.go, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def terminate(reason, state) do
    IO.puts "server terminated because of #{inspect reason}"
    File.write("data.json", JSON.encode!(state))
    :ok
  end

end
