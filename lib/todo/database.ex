defmodule Todo.Database do
  @pool_size 3

  def start_link(db_folder) do
    Todo.Database.WorkerSupervisor.start_link(db_folder, @pool_size)
  end

  def store_local(list_name, list) do
    list_name
    |> worker_id
    |> Todo.Database.Worker.store(list_name, list)
  end

  def store(key, data) do
    {_results, bad_nodes} = 
      :rpc.multicall(
        __MODULE__, :store_local, [key, data],
        :timer.seconds(5)
      )

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))

    :ok
  end

  def get(list_name) do
    list_name
    |> worker_id
    |> Todo.Database.Worker.get(list_name)
  end

  def worker_id(list_name) do
    :erlang.phash2(list_name, @pool_size) + 1
  end
end
