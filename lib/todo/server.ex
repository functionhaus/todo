defmodule Todo.Server do
  use GenServer

  def start(name \\ "default") do
    GenServer.start(__MODULE__, name)
  end

  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new}}
  end

  def get_entries(server_pid, {_year, _month, _day} = date) do
    GenServer.call(server_pid, {:get_entries, date})
  end

  def get_list(server_pid) do
    GenServer.call(server_pid, {:get_list})
  end

  def clear_list(server_pid) do
    GenServer.cast(server_pid, {:clear_list})
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

  def handle_call({:get_entries, date}, _, {name, current_list}) do
    {:reply, Todo.List.entries(current_list, date), {name, current_list}}
  end

  def handle_call({:get_list}, _, {name, current_list}) do
    {:reply, current_list, {name, current_list}}
  end

  def handle_cast({:clear_list}, {name, current_list}) do
    new_state = Todo.List.new
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:add_entry, new_entry}, {name, current_list}) do
    new_state = Todo.List.add_entry(current_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, {name, current_list}) do
    new_state = Todo.List.update_entry(current_list, entry_id, updater_fun)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  def handle_cast({:delete_entry, entry_id}, {name, current_list}) do
    new_state = Todo.List.delete_entry(current_list, entry_id)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end
end
