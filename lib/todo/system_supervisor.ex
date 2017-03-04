defmodule Todo.SystemSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    db_path = Path.join(__DIR__, "../../db")

    processes = [
      supervisor(Todo.Database, [db_path]),
      supervisor(Todo.Server.Supervisor, []),
      worker(Todo.Cache, [])
    ]

    supervise(processes, strategy: :one_for_one)
  end
end
