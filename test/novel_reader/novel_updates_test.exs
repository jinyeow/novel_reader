defmodule NovelReader.NovelUpdatesTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "it is initialized with the default feed url" do
    assert NovelReader.NovelUpdates.feed == "http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=read"
  end

  test "it is initialized with a non-empty list of updates" do
    use_cassette "novel_updates/updates#1" do
      refute NovelReader.NovelUpdates.updates == []
    end
  end

  # TODO add more tests for NovelReader.NovelUpdates
  # TODO check that ExVCR is being used correctly

end
