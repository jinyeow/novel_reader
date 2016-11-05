defmodule NovelReader.NovelUpdates do
  use GenServer
  require Logger

  @moduledoc """
  Gets chapter updates from Novel Updates feed.
  """

  @feed "http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=read"

  @name {:global, __MODULE__}

  # Callbacks

  def start_link(feed_url \\ @feed) do
    GenServer.start_link(__MODULE__, {feed_url, []}, name: @name)
  end

  def get_updates do
    GenServer.call(@name, :get_updates)
  end

  # Server

  def handle_call(:get_updates, _from, {feed_url, _chapter_updates}) do
    updates = feed_url
    |> Scrape.feed
    {:reply, updates, {feed_url, updates}}
  end
end

