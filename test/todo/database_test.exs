defmodule Todo.DatabaseTest do
  use ExUnit.Case, async: true

  test "storing and getting data" do
    dir_path = Path.join(__DIR__, "../tmp/some_folder")

    # start the server
    {:ok, server_pid} = Todo.Database.start(dir_path)
    assert is_pid(server_pid)

    # was the dir created?
    assert File.exists?(dir_path)

    # do the store/get operations work?
    Todo.Database.store(:name, "Jared")
    assert Todo.Database.get(:name) == "Jared"

    # remove the created directory
    File.rm_rf(dir_path)

    # Exit the process because the server uses a registered name
    Process.exit(server_pid, :kill)
  end
end
