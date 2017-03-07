defmodule Todo.ProcessRegistry do
  use GenServer
  import Kernel, except: [send: 2]

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def init(_) do
    IO.puts "Starting process registry."
    IO.puts "Starting ETS table."
    :ets.new(:registry_table, [:set, :named_table, :protected])
    {:ok, nil}
  end

  def send(process_key, message) do
    case whereis_name(process_key) do
      :undefined -> {:badarg, {process_key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def register_name(process_key, pid) do
    GenServer.call(:process_registry, {:register_name, process_key, pid})
  end

  def unregister_name(process_key) do
    GenServer.cast(:process_registry, {:unregister_name, process_key})
  end

  def whereis_name(process_key) do
    case :ets.lookup(:registry_table, process_key) do
      [{^process_key, pid}] -> pid
      [] -> :undefined
    end
  end

  def handle_call({:register_name, process_key, pid}, _, state) do
    response = case whereis_name(process_key) do
      :undefined ->
        Process.monitor(pid)
        :ets.insert(:registry_table, {process_key, pid})
        :yes

      _ -> :no
    end

    {:reply, response, state}
  end

  def handle_cast({:unregister_name, process_key}, state) do
    :ets.delete(:registry_table, process_key)
    {:noreply, state}
  end

  def handle_info({:DOWN, _, :process, pid, _}, state) do
    :ets.match_delete(:registry_table, pid)
    {:noreply, state}
  end
end
