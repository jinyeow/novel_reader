defmodule NovelReader.Model.ChapterUpdateTest do
  use ExUnit.Case, async: true
  doctest NovelReader.Model.ChapterUpdate

  alias NovelReader.Model.ChapterUpdate

  # TODO test parse_chapter_info parses correctly for:
  #   v8c9,10,11 <- comma separated,
  #   v8c9-11    <- hyphen,
  #   c9 part 10 <- has 'part',
  #   v8c9       <- has 'volume',
  #   c9         <- simple 'chapter'

  test "is able to update ChapterUpdate attributes" do
    updated_chapter =
      chapter
      |> ChapterUpdate.update(:tags, chapter[:tags] ++ ["immortal"])

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
