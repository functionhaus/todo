defmodule Todo.SystemSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    db_path = Path.join(__DIR__, "../../db/#{node_name()}")

    processes = [
      supervisor(Todo.Database, [db_path]),
      supervisor(Todo.Server.Supervisor, []),
      worker(Todo.Cache, [])
    ]

    supervise(processes, strategy: :one_for_one)
  end

  defp node_name do
    node()
    |> Atom.to_string
    |> String.split("@")
    |> List.first

    # alternatively (needs load testing):
    # host = Atom.to_string(node())
    # node_name = Regex.run(~r/(^.*)@/, host, capture: :all_but_first)
    # List.first(node_name)
  end
end
