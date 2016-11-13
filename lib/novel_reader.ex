defmodule NovelReader do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: NovelReader.TaskSupervisor]]),

      # worker that handles socket requests to the API?
      # worker(NovelReader.RequestHandler, [socket]) ?

      # worker that handles chapter processing operations: pull, process, return?
      # or should I send it to the TaskSupervisor?
      # worker(NovelReader.ReaderServer, []) ?

      # worker to keep persistent state?
      # e.g. user settings, cached "retrieved" chapters

      worker(NovelReader.NovelUpdates, [])
    ]

    opts = [strategy: :one_for_one, name: NovelReader.Supervisor]
    Supervisor.start_link(children, opts)
  end

  ## Interface

  # Feed
  defdelegate get_updates, to: NovelReader.NovelUpdates, as: :get_updates
  defdelegate feed, to: NovelReader.NovelUpdates, as: :feed
  defdelegate filter(attr \\ :title, term), to: NovelReader.NovelUpdates, as: :filter
  defdelegate updates, to: NovelReader.NovelUpdates, as: :updates
  defdelegate update_feed(feed), to: NovelReader.NovelUpdates, as: :update_feed

  # Client // RequestHandler
end
