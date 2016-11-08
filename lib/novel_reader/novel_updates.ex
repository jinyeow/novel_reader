defmodule NovelReader.NovelUpdates do
  use GenServer
  require Logger

  alias NovelReader.NovelUpdates.ChapterUpdate

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

  def parse_feed do
    updates
    |> parse_feed([])
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

  ## Private

  # description == "(TRANSLATOR) Series Information: novelupdates url"
  defp parse_description(description) do
    Regex.named_captures(
      ~r/\((?<translator>.+)\) Series Information: (?<series_url>.*)$/,
      description
    )
  end

  defp parse_chapter_info(title) do
    %{
      "chapter"     => chapter,
      "chapter_end" => chapter_end,
      "part"        => part,
      "vol"         => vol
    } = Regex.named_captures(
      ~r/(v(?<vol>[0-9]+))?c(?<chapter>[0-9]+)(\-(?<chapter_end>[0-9]*))?\
      ( part(?<part>[0-9]+))?$/,
      title
    )
    %{
      "chapter"     => chapter,
      "chapter_end" => nil_if_empty(chapter_end),
      "part"        => nil_if_empty(part),
      "vol"         => nil_if_empty(vol)
    }
  end

  defp nil_if_empty(str) do
    case str do
      "" -> nil
      _ -> str
    end
  end

  # %{description: description, title: title, url: url, pubdate: <DateTime>, tags: []}
  defp parse_feed([], feed), do: feed
  defp parse_feed([head|tail], feed) do
    # TODO move all the chapter parsing functions into ChapterUpdate module
    %{
      description: description,
      title: title,
      url: url,
      pubdate: date, # TODO parse DateTime into human readable format?
      tags: tags
    } = head

    %{
      "translator" => translator,
      "series_url" => series_url
    } = parse_description(description)

    %{
      "chapter"     => chapter,
      "chapter_end" => chapter_end,
      "part"        => part,
      "vol"         => volume
    } = parse_chapter_info(title)

    # TODO create a range from chapter to chapter_end; and
    # TODO change :chapter field to :chapterS @type List
    parse_feed(tail, feed ++ [
      %ChapterUpdate{
        chapter: chapter |> String.to_integer,
        chapter_url: url,
        part: part,
        pubdate: date,
        series_url: series_url,
        tags: tags,
        title: title,
        translator: translator,
        volume: volume
      }
    ])
  end
end

