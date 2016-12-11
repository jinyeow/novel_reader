defmodule NovelReader.NovelUpdates do
  @moduledoc """
  Handles scraping the NovelUpdates feed to return a list of information about
  chapter updates.

  Stores the feed URL and a list of chapter updates as state.

  Able to search chapter updates based on attribute.

  """

  use GenServer

  alias NovelReader.ChapterUpdate

  require Logger

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
  @spec filter(atom, String.t) :: {:ok, [%ChapterUpdate{}]}
                                | {:ok, []}
                                | {:error, String.t}
  def filter(attr \\ :title, term) do
    valid = [:title, :translator, :tags]
    case valid |> Enum.member?(attr) do
      true -> GenServer.call(@name, {:filter, attr, term})
      false -> {:error, "Attribute unsearchable."}
    end
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
  def update_feed(feed_url) do
    GenServer.cast(@name, {:update_feed, feed_url})
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
    chapter_updates = feed_url
    |> Scrape.feed
    {:reply, chapter_updates, {feed_url, chapter_updates}}
  end

  def handle_call({:get_updates, :parse}, _from, {feed_url, _chapters}) do
    chapter_updates = feed_url
    |> Scrape.feed
    |> parse_feed([])
    {:reply, chapter_updates, {feed_url, chapter_updates}}
  end

  def handle_call({:filter, attr, term}, _from, {_feed, chapters} = state) do
    {:ok, pattern} = Regex.compile(term, "i")
    results = chapters
              |> Enum.filter(fn chapter ->
                  cond do
                    chapter[attr] |> is_list ->
                      case list = chapter[attr] do
                        [] -> false
                        _ ->
                          for thing <- list do
                            Regex.match?(pattern, thing)
                          end
                      end
                    chapter[attr] |> is_binary -> Regex.match?(pattern, chapter[attr])
                  end
              end)
    {:reply, results, state}
  end

  def handle_call(:feed, _from, {feed_url, _chapters} = state) do
    {:reply, feed_url, state}
  end

  def handle_call(:updates, _from, {_feed_url, chapters} = state) do
    {:reply, chapters, state}
  end

  def handle_cast({:update_feed, feed_url}, {_feed_url, chapters}) do
    {:noreply, {feed_url, chapters}}
  end

  ## Private

  @spec parse_feed([%{}], [%{}]) :: [%ChapterUpdate{}]
  defp parse_feed([], chapter_updates), do: chapter_updates
  defp parse_feed([head|tail], chapter_updates) do
    parse_feed(tail, chapter_updates ++ [ChapterUpdate.parse_chapter(head)])
  end
end

