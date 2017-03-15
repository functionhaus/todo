defmodule Todo.Cache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def init(_) do
    IO.puts "Starting todo cache."
    {:ok, nil}
  end

  def server_process(list_name) do
    case Todo.Server.whereis(list_name) do
      :undefined -> create_server(list_name)
      pid -> pid
      pid -> pid
    end
  end

  defp create_server(list_name) do
    case Todo.Server.Supervisor.start_child(list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  # Needed for testing purposes
  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}
end
