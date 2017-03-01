defmodule Todo.DatabaseTest do
  use ExUnit.Case, async: true

  setup_all do
    dir_path = Path.join(__DIR__, "../tmp/some_folder")
    Process.whereis(:database_server) |> Process.exit(:kill)
    {:ok, server_pid} = Todo.Database.start(dir_path)

    on_exit fn ->
      # remove the created directory
      File.rm_rf(dir_path)
      Process.exit(server_pid, :kill)
    end

    {:ok, %{dir_path: dir_path}}
  end

  test "storing and getting data", context do
    dir_path = context.dir_path

    # was the dir created?
    assert File.exists?(dir_path)

    # do the store/get operations work?
    Todo.Database.store(:name, "Jared")
    assert Todo.Database.get(:name) == "Jared"
  end
end
