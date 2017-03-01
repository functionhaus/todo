defmodule Todo.ProcessRegistry do
  use GenServer
  import Kernel, except: [send: 2]

  def start_link
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def init(_) do
    IO.puts "Starting process registry."
    {:ok, %{}}
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
    GenServer.call(process_registry, {:whereis_name, process_key})
  end

  def handle_call({:register_name, process_key, pid}, registry) do
    case Map.get(registry, process_key) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(registry, process_key, pid)}
      _ ->
        {:reply, :no, registry}
    end
  end

  def handle_cast({:unregister_name, process_key}, registry) do
    {:noreply, Map.delete(registry, process_key)}
  end

  def handle_call({:whereis_name, process_key}, registry) do
    {:reply, Map.get(registry, process_key, :undefined), registry}
  end

  def handle_info({:DOWN, _, :process, pid, _}, registry) do
    {:noreply, deregister_pid(registry, pid)}
  end

  defp deregister_pid(registry, pid) do
    # We'll walk through each {key, value} item, and delete those elements whose
    # value is identical to the provided pid.
    Enum.reduce(
      registry,
      registry,
      fn
        ({registered_alias, registered_process}, registry_acc) when registered_process == pid ->
          HashDict.delete(registry_acc, registered_alias)

        (_, registry_acc) -> registry_acc
      end
    )
  end
end
