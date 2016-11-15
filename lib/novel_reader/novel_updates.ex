defmodule NovelReader.NovelUpdates do
  use GenServer
  require Logger

  alias NovelReader.NovelUpdates.ChapterUpdate

  @moduledoc """
  Handles scraping the NovelUpdates feed to return a list of information about
  chapter updates.

  Stores the feed URL and a list of chapter updates as state.

  Able to search chapter updates based on attribute.
  """

  # TODO should I add a timer/{:error, :timeout} to get_updates?

  @feed "http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=read"

  @name {:global, __MODULE__}


  ## Client

  @doc """
  Return the feed URL.
  """
  @spec feed() :: String.t
  def feed do
    GenServer.call(@name, :feed)
  end

  @doc """
  Filter chapters by attribute; defaults to :title.
  """
  @spec filter(atom, String.t) :: [%ChapterUpdate{}]
  def filter(attr \\ :title, term) do
    GenServer.call(@name, {:filter, attr, term})
  end

  @doc """
  Retrieve chapter updates from feed.
  """
  @spec get_updates(atom) :: [%ChapterUpdate{}]
  def get_updates(opt \\ :parse) do
    GenServer.call(@name, {:get_updates, opt})
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
  Return the list of chapter updates last retrieved.
  """
  @spec updates() :: [%ChapterUpdate{}]
  def updates do
    GenServer.call(@name, :updates)
  end

  @doc """
  Used for debugging.
  """
  def parse_feed(list) do
    list |> parse_feed([])
  end

  ## Server

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

  def init({feed_url, chapters}) do
    {_, _, state} = handle_call({:get_updates, :parse},
                                self(),
                                {feed_url, chapters}
                              )
    {:ok, state}
  end

  def handle_call({:get_updates, :no_parse}, _from, {feed_url, _chapters}) do
    updates = feed_url
    |> Scrape.feed
    {:reply, updates, {feed_url, updates}}
  end

  def handle_call({:get_updates, :parse}, _from, {feed_url, _chapters}) do
    updates = feed_url
    |> Scrape.feed
    |> parse_feed([])
    {:reply, updates, {feed_url, updates}}
  end

  def handle_call({:filter, attr, term}, _from, {_feed, chapters} = state) do
    {:ok, pattern} = Regex.compile(term, "i")
    results = chapters
              |> Enum.filter(fn chapter ->
                Regex.match?(pattern, chapter[attr])
              end)
    {:reply, results, state}
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

  ## Private

  @spec parse_feed([%{}], [%{}]) :: [%ChapterUpdate{}]
  defp parse_feed([], feed), do: feed
  defp parse_feed([head|tail], feed) do
    parse_feed(tail, feed ++ [ChapterUpdate.parse_chapter(head)])
  end
end

