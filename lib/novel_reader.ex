defmodule NovelReader do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: NovelReader.TaskSupervisor]]),

      # worker that handles socket requests to the API? or comms with RabbitMQ
      # Delegates to an ongoing socket connection handler; or a MQ conn ?
      # worker(NovelReader.RequestHandler, [socket]) ?

      # worker that handles chapter processing operations: pull, process, return?
      # or should I send it to the TaskSupervisor?
      # worker(NovelReader.ReaderServer, []) ?

      # worker to keep persistent state?
      # e.g. user settings, cached "retrieved" chapters
      worker(NovelReader.CacheServer, []),

      worker(NovelReader.NovelUpdates, [])
    ]

    opts = [strategy: :one_for_one, name: NovelReader.Supervisor]
    Supervisor.start_link(children, opts)
  end

  ## Interface ##

  ## Feed

  # Returns the feed url being used
  defdelegate feed, to: NovelReader.NovelUpdates, as: :feed

  # Filter/Search function based on ChapterUpdate.t attribute
  defdelegate filter(attr \\ :title, term), to: NovelReader.NovelUpdates, as: :filter

  # Refresh the list of updates
  defdelegate refresh(opts \\ :parse), to: NovelReader.NovelUpdates, as: :get_updates

  # Return the list of updates
  defdelegate updates, to: NovelReader.NovelUpdates, as: :updates

  # Change the feed url being used.
  defdelegate update_feed(feed), to: NovelReader.NovelUpdates, as: :update_feed

  ## Retrieve

  # Get the chapter content.
  # defdelegate get(chapter_update), to: NovelReader.Retriever, as: :get_from_update
  # NOTE we are expecting thing to either be a URL or a ChapterUpdate
  # TODO test these changes
  def get(thing) do
    case String.valid? thing do
      true -> NovelReader.Retriever.get_from_url thing
      _ -> NovelReader.Retriever.get_from_update thing
    end
  end

  ## Client // RequestHandler
end
