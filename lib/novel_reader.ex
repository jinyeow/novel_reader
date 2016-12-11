defmodule NovelReader do
  @moduledoc false

  use Application

  alias NovelReader.Model.ChapterUpdate

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: NovelReader.TaskSupervisor]]),

      # Cache
      worker(NovelReader.Cache, []),

      # Controls communication between Elixir application and Electron GUI
      worker(NovelReader.Controller, []),

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
  defdelegate get(arg), to: NovelReader.Retriever, as: :get
end

