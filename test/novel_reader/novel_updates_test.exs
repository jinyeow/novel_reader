defmodule NovelReader.NovelUpdatesTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias NovelReader.NovelUpdates

  setup_all do
    HTTPoison.start
  end

  # TODO check that ExVCR is being used correctly

  test "it is initialized with the default feed url" do
    assert NovelUpdates.feed == \
      "http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=read"
  end

  test "it is initialized with a list of updates" do
    assert NovelUpdates.updates |> Enum.count == \
      NovelUpdates.feed |> Scrape.feed(:minimal) |> Enum.count

    assert NovelUpdates.updates |> is_list
  end

  test "each item in the updates is a ChapterUpdate" do
    assert NovelUpdates.updates
            |> are_all?(fn update ->
              %{__struct__: struct} = update
              struct == NovelReader.NovelUpdates.ChapterUpdate
            end)
  end

  test "feed is a URL string starting with 'http://www.noveludpates.com/rss.php?'" do
    assert feed_url_valid?
  end

  test "update feed changes the feed URL to another valid feed URL" do
    s_tier_url = \
      "http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=1&lid=local"
    NovelUpdates.update_feed(s_tier_url)
    assert feed_url_valid?
  end

  # TODO add tests for NovelReader.NovelUpdates.filter

  ## Helpers

  defp feed_url_valid? do
    NovelUpdates.feed =~ ~r/^http:\/\/www.novelupdates.com\/rss.php\?\S+$/
  end

  defp are_all?([], _fun), do: true
  defp are_all?([head|tail], fun) do
    case fun.(head) do
      true -> are_all?(tail, fun)
      _ -> false
    end
  end
end
