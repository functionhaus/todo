defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def init(_) do
    {:ok, %Todo.List{}}
  end

  def get_entries(server_pid, {_year, _month, _day} = date) do
    GenServer.call(server_pid, {:get_entries, date})
  end

  def get_list(server_pid) do
    GenServer.call(server_pid, {:get_list})
  end

  def add_entry(server_pid, entry) do
    GenServer.cast(server_pid, {:add_entry, entry})
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    GenServer.cast(server_pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(server_pid, entry_id) do
    GenServer.cast(server_pid, {:delete_entry, entry_id})
  end

  def handle_call({:get_entries, date}, _, current_list) do
    {:reply, Todo.List.entries(current_list, date), current_list}
  end

  def handle_call({:get_list}, _, current_list) do
    {:reply, current_list, current_list}
  end

  def handle_cast({:add_entry, entry}, current_list) do
    {:noreply, Todo.List.add_entry(current_list, entry)}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, current_list) do
    {:noreply, Todo.List.update_entry(current_list, entry_id, updater_fun)}
  end

  def handle_cast({:delete_entry, entry_id}, current_list) do
    {:noreply, Todo.List.delete_entry(current_list, entry_id)}
  end
end
