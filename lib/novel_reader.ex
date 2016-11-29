defmodule NovelReader do
  use Application

  alias NovelReader.NovelUpdates.ChapterUpdate

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: NovelReader.TaskSupervisor]]),

      # worker that handles socket requests to the API? or comms with RabbitMQ
      # Delegates to an ongoing socket connection handler; or a MQ conn ?
      worker(NovelReader.Controller, []),

      # worker that handles chapter processing operations: pull, process, return?
      # or should I send it to the TaskSupervisor?
      # worker(NovelReader.ReaderServer, []) ?

      # Cache
      worker(NovelReader.CacheServer, []),

      # Feed
      worker(NovelReader.NovelUpdates, [])
    ]

    opts = [strategy: :one_for_one, name: NovelReader.Supervisor]
    Supervisor.start_link(children, opts)
  end

  ## Interface ##

  ## Feed

  @doc """
  Returns the feed url being used.
  """
  defdelegate feed, to: NovelReader.NovelUpdates, as: :feed

  @doc """
  Filter/Search function based on ChapterUpdate.t attribute.
  """
  defdelegate filter(attr \\ :title, term), to: NovelReader.NovelUpdates, as: :filter

  @doc """
  Refresh the list of updates
  """
  defdelegate refresh(opts \\ :parse), to: NovelReader.NovelUpdates, as: :get_updates

  @doc """
  Return the list of updates
  """
  defdelegate updates, to: NovelReader.NovelUpdates, as: :updates

  @doc """
  Change the feed url being used.
  """
  defdelegate update_feed(feed), to: NovelReader.NovelUpdates, as: :update_feed

  ## Retrieve

  @doc """
  Gets the chapter content.
  We are expecting input to either be a URL or a %ChapterUpdate{}
  """
  @spec get(String.t|ChapterUpdate.t) :: {:ok, String.t} | {:error, atom}
  def get(%ChapterUpdate{} = thing), do: NovelReader.Retriever.get_from_update(thing)
  def get(url), do: NovelReader.Retriever.get_from_url(url)

  ## Client // RequestHandler

  # TODO
end
