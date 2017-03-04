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
      :undefined ->
        GenServer.call(:todo_cache, {:server_process, list_name})

      pid -> pid
    end
  end

  def handle_call({:server_process, list_name}, _, state) do
    todo_pid = case Todo.Server.whereis(list_name) do
      :undefined ->
        {:ok, new_pid} = Todo.Server.Supervisor.start_child(list_name)
        new_pid

      pid -> pid
    end

    {:reply, todo_pid, state}
  end

  # Needed for testing purposes
  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}
end
