defmodule NovelReader.NovelUpdates.ChapterUpdateTest do
  use ExUnit.Case, async: true
  doctest NovelReader.NovelUpdates.ChapterUpdate

  alias NovelReader.NovelUpdates.ChapterUpdate

  # TODO add more tests

  test "is able to update ChapterUpdate attributes" do
    updated_chapter = chapter
    |> NovelReader.NovelUpdates.ChapterUpdate.update(
      :tags,
      chapter[:tags] ++ ["immortal"]
    )

    assert updated_chapter[:tags] == ["immortal"]
  end

  defp chapter do
    %ChapterUpdate{
      chapter_url: "http://www.novelupdates.com/extnu/340123/",
      chapters: [163],
      part: nil,
      series_url: "http://www.noveludpates.com/series/spirit-realm/",
      tags: [],
      title: "Spirit Realm", translator: "Alyschu", volume: nil
    }
  end
end
