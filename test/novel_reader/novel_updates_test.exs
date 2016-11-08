defmodule NovelReader.NovelUpdatesTest do
  use ExUnit.Case, async: true

  # TODO add tests for the GenServer.handle_[call|cast] functions.
  # This should work fine as the "API" just passes thru to these functions.
  # Use a Mocking library to test other functionality?

  test "it is initialized with the default feed url" do
    assert NovelReader.NovelUpdates.feed == "http://www.novelupdates.com/rss.php?uid=12590&unq=571077742187a&type=read"
  end

  test "it is initialized with an empty list of updates" do
    assert NovelReader.NovelUpdates.updates == []
  end
end
