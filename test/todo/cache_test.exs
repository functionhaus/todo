defmodule Todo.CacheTest do
  use ExUnit.Case, async: true

  setup_all do
    {:ok, pid} = Todo.Cache.start_link
    on_exit fn -> Process.exit(pid, :kill) end
    :ok
  end

  test "init" do
    {:ok, initial_state} = Todo.Cache.init("ignored")
    assert is_map(initial_state)
  end

  test "create and recall a server pid by name" do
    server_pid = Todo.Cache.server_process("Miko")
    assert is_pid(server_pid)

    cached_server_pid = Todo.Cache.server_process("Miko")
    assert server_pid == cached_server_pid

    another_server_pid = Todo.Cache.server_process("Kranhaus")
    refute server_pid == another_server_pid
  end
end
