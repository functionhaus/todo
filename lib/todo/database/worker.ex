defmodule Todo.Database.Worker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def init(db_folder) do
    IO.puts "Starting database worker."
    File.mkdir_p(db_folder)
    {:ok, db_folder}
  end

  def store(worker_pid, list_name, list) do
    GenServer.cast(worker_pid, {:store, list_name, list})
  end

  def get(worker_pid, list_name) do
    GenServer.call(worker_pid, {:get, list_name})
  end

  def handle_cast({:store, list_name, list}, db_folder) do
    file_name(db_folder, list_name)
    |> File.write!(:erlang.term_to_binary(list))

    {:noreply, db_folder}
  end

  def handle_call({:get, list_name}, _, db_folder) do
    list = case File.read(file_name(db_folder, list_name)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    {:reply, list, db_folder}
  end

  # Needed for testing purposes
  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}

  defp file_name(db_folder, list_name), do: "#{db_folder}/#{list_name}"
end
