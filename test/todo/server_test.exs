defmodule Todo.ServerTest do
  use ExUnit.Case, async: true

  test "starting the server" do
    {:ok, cache_pid} = Todo.Cache.start
    server_pid = Todo.Cache.server_process(cache_pid, "some_list")
    Todo.Server.clear_list(server_pid)

    assert is_pid(server_pid)
    assert Todo.Server.get_list(server_pid) == %Todo.List{}
  end

  test "adding and getting entries" do
    {:ok, cache_pid} = Todo.Cache.start
    server_pid = Todo.Cache.server_process(cache_pid, "some_list")
    Todo.Server.clear_list(server_pid)

    entries = [
      %{title: "Stuff", date: {2000, 01, 01}},
      %{title: "Junk", date: {3000, 12, 31}}
    ]

    Enum.each(entries, fn(entry) ->
      Todo.Server.add_entry(server_pid, entry)
    end)

    assert [%{title: "Stuff", date: {2000, 01, 01}}] =
      Todo.Server.get_entries(server_pid, {2000, 01, 01})
  end

  test "updating an entry" do
    {:ok, cache_pid} = Todo.Cache.start
    server_pid = Todo.Cache.server_process(cache_pid, "some_list")
    Todo.Server.clear_list(server_pid)

    Todo.Server.add_entry(
      server_pid,
      %{title: "Stuff", date: {2000, 01, 01}}
    )

    updater_fun = &Map.put(&1, :title, "Hermann")

    Todo.Server.update_entry(server_pid, 1, updater_fun)
    assert [%{title: "Hermann", date: {2000, 01, 01}}] =
      Todo.Server.get_entries(server_pid, {2000, 01, 01})
  end

  test "delete an entry" do
    {:ok, cache_pid} = Todo.Cache.start
    server_pid = Todo.Cache.server_process(cache_pid, "some_list")
    Todo.Server.clear_list(server_pid)

    Todo.Server.add_entry(
      server_pid,
      %{title: "Stuff", date: {2000, 01, 01}}
    )

    Todo.Server.delete_entry(server_pid, 1)
    assert Todo.Server.get_entries(server_pid, {2000, 01, 01}) == []
  end
end
