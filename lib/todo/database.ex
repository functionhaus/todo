defmodule Todo.Database do
  use GenServer

  def start(db_folder, total_workers \\ 3) do
    GenServer.start(__MODULE__, {db_folder, total_workers}, name: :database_server)
  end

  def init({db_folder, total_workers}) do
    File.mkdir_p(db_folder)
    {:ok, start_workers(db_folder, total_workers)}
  end

  def store(list_name, list) do
    list_name
    |> choose_worker
    |> Todo.Database.Worker.store(list_name, list)
  end

  def get(list_name) do
    list_name
    |> choose_worker
    |> Todo.Database.Worker.get(list_name)
  end

  def choose_worker(list_name) do
    GenServer.call(:database_server, {:choose_worker, list_name})
  end

  def handle_call({:choose_worker, list_name}, _, workers) do
    total_workers = workers |> Map.keys |> Enum.count
    worker_index = :erlang.phash2(list_name, total_workers)
    worker_pid = Map.get(workers, worker_index)
    {:reply, worker_pid, workers}
  end

  defp start_workers(db_folder, total) do
    Enum.reduce(0..(total - 1), %{}, fn(index, workers) ->
      {:ok, worker_pid} = Todo.Database.Worker.start(db_folder)
      Map.put(workers, index, worker_pid)
    end)
  end
end
