defmodule Todo.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    db_path = Path.join(__DIR__, "../../db")

    processes = [
      worker(Todo.ProcessRegistry, []),
      supervisor(Todo.Database, [db_path]),
      worker(Todo.Cache, [])
    ]

    supervise(processes, strategy: :one_for_one)
  end
end
