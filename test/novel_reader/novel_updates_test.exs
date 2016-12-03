defmodule NovelReader.NovelUpdatesTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias NovelReader.NovelUpdates
  alias NovelReader.Model.ChapterUpdate

  @feed "http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=read"
  @s_tier_feed \
      "http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=1&lid=local"

  # setup_all do
  #   HTTPoison.start
  # end

  test "it is initialized with the default feed url" do
    assert NovelUpdates.feed == @feed
  end

  test "it is initialized with a list of updates" do
    assert NovelUpdates.updates
          |> Enum.count == NovelUpdates.feed
                          |> Scrape.feed(:minimal)
                          |> Enum.count

    assert NovelUpdates.updates |> is_list
  end

  test "each item in the updates is a ChapterUpdate" do
    assert NovelUpdates.updates
            |> are_all?(fn update ->
              %{__struct__: struct} = update
              struct == ChapterUpdate
            end)
  end

  test "feed is a URL string starting with 'http://www.noveludpates.com/rss.php?'" do
    assert feed_url_valid?
  end

  test "update feed changes the feed URL to another valid feed URL" do
    NovelUpdates.update_feed(@s_tier_feed)

    assert feed_url_valid?
    assert NovelUpdates.feed == @s_tier_feed

    NovelUpdates.update_feed(@feed)
  end

  # TODO add tests for NovelReader.NovelUpdates.filter

  test "filter/1 searches ChapterUpdate titles successfully" do
    search_terms = ["heaven", "god", "asura", "marti", "immort"]
    for term <- search_terms do
      first_result = NovelUpdates.filter(term) |> hd
      assert Regex.match?(~r/#{term}/i, first_result[:title])
    end
  end

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
