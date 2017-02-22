defmodule Todo.CacheTest do
  use ExUnit.Case, async: true

  test "start the cache" do
    {:ok, pid} = Todo.Cache.start
    assert is_pid(pid)
  end

  test "init" do
    {:ok, initial_state} = Todo.Cache.init("ignored")
    assert is_map(initial_state)
  end

  test "create and recall a server pid by name" do
    {:ok, cache_pid} = Todo.Cache.start

    server_pid = Todo.Cache.server_process(cache_pid, "Miko")
    assert is_pid(server_pid)

    cached_server_pid = Todo.Cache.server_process(cache_pid, "Miko")
    assert server_pid == cached_server_pid

    another_server_pid = Todo.Cache.server_process(cache_pid, "Kranhaus")
    refute server_pid == another_server_pid
  end
end
