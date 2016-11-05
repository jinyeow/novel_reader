defmodule NovelReader do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # supervisor(Task.Supervisor, [[name: NovelReader.TaskSupervisor]]),
      worker(NovelReader.NovelUpdates, [])
    ]

    opts = [strategy: :one_for_one, name: NovelReader.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
