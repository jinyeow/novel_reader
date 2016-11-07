defmodule NovelReader.NovelUpdates do
  use GenServer
  require Logger

  @moduledoc """
  Gets chapter updates from Novel Updates feed.
  """

  @feed "http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=read"

  @name {:global, __MODULE__}

  ## Callbacks

  def start_link(feed_url \\ @feed) do
    case GenServer.start_link(__MODULE__, {feed_url, []}, name: @name) do
      {:ok, pid} ->
        Logger.info "Started #{__MODULE__}"
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        Logger.info "#{__MODULE__} already started"
        {:ok, pid}
    end
  end

  @doc """
  Retrieve chapter updates from feed.
  """
  def get_updates do
    GenServer.call(@name, :get_updates)
  end

  @doc """
  Filter updates by title.
  """
  def filter_updates(title) do
    GenServer.call(@name, {:filter_updates, title})
  end

  @doc """
  Asynchronously update the feed URL.
  Then pull the chapter updates for the new feed.
  """
  def update_feed(feed) do
    GenServer.cast(@name, {:update_feed, feed})
    get_updates
  end

  @doc """
  Return the feed URL.
  """
  def feed do
    GenServer.call(@name, :feed)
  end

  @doc """
  Return the list of chapter updates last retrieved.
  """
  def updates do
    GenServer.call(@name, :updates)
  end

  ## Server

  def handle_call(:get_updates, _from, {feed_url, _chapters}) do
    updates = feed_url
    |> Scrape.feed
    {:reply, updates, {feed_url, updates}}
  end

  def handle_call({:filter_updates, title}, _from, {_feed_url, chapters} = state) do
    {:ok, pattern} = Regex.compile(title, "i")
    filtered_chapters = chapters
                        |> Enum.filter(fn chapter ->
                          Regex.match?(pattern, chapter[:title])
                        end)
    {:reply, filtered_chapters, state}
  end

  def handle_call(:feed, _from, {feed_url, _chapters} = state) do
    {:reply, feed_url, state}
  end

  def handle_call(:updates, _from, {_feed_url, chapters} = state) do
    {:reply, chapters, state}
  end

  def handle_cast({:update_feed, feed}, {_feed_url, chapters}) do
    {:noreply, {feed, chapters}}
  end
end

