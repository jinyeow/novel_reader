defmodule NovelReader.NovelUpdatesTest do
  @moduledoc """
  Tests NovelUpdates API.
  Except for get_updates/0, get_updates/1, and parse_feed/1

  """

  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias NovelReader.NovelUpdates
  alias NovelReader.ChapterUpdate

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

  test "each item in updates/0 is a ChapterUpdate" do
    assert NovelUpdates.updates
            |> are_all?(fn %{__struct__: struct} = _update ->
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
    assert feed_url_valid?
    assert NovelUpdates.feed == @feed
  end

  test "filter/1 searches ChapterUpdate titles successfully and returns a list" do
    search_terms = ["heaven", "god", "asura", "marti", "immort"]
    for term <- search_terms do
      results = NovelUpdates.filter(term)
      case results  do
        [] -> assert results == []
        _list ->
          are_all?(results, fn result ->
            assert Regex.match?(~r/#{term}/i, result[:title])
          end)
      end
    end
  end

  test "filter/1 searches ChapterUpdate titles unsuccessfully and returns an empty list" do
    assert NovelUpdates.filter("term that will never match") == []
  end

  test "filter/2 searches translators successfully and returns a list of ChapterUpdates" do
    translators = ["wuxiaworld", "gravity tales", "xianxiaworld", "volare", "subudai11"]
    for translator <- translators do
      results = NovelUpdates.filter(:translator, translator)
      case results  do
        [] -> assert results == []
        _list ->
          are_all?(results, fn result ->
            assert Regex.match?(~r/#{translator}/i, result[:translator])
          end)
      end
    end
  end

  test "filter/2 returns an empty list on unsuccessful searches" do
    invalid_term = "some term that will never match"

    assert NovelUpdates.filter(:translator, invalid_term) == []
    assert NovelUpdates.filter(:tags, invalid_term) == []
  end

  test "filter/2 can only search on tags and translator" do
    some_search_term = "some search term"

    assert NovelUpdates.filter(:chapters, some_search_term) ==
      {:error, "Attribute unsearchable."}
    assert NovelUpdates.filter(:chapter_url, some_search_term) ==
      {:error, "Attribute unsearchable."}
    assert NovelUpdates.filter(:part, some_search_term) ==
      {:error, "Attribute unsearchable."}
    assert NovelUpdates.filter(:volume, some_search_term) ==
      {:error, "Attribute unsearchable."}
    assert NovelUpdates.filter(:pubdate, some_search_term) ==
      {:error, "Attribute unsearchable."}
    assert NovelUpdates.filter(:series_url, some_search_term) ==
      {:error, "Attribute unsearchable."}
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
