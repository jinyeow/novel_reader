defmodule NovelReader.NovelUpdates.ChapterUpdate do
  @behaviour Access

  alias NovelReader.NovelUpdates.ChapterUpdate

  defstruct [
    :chapters,
    :chapter_url,
    :part,
    :pubdate,
    :series_url,
    :tags,
    :title,
    :translator,
    :volume
  ]

  @type t :: %ChapterUpdate{
    chapters:    [non_neg_integer],
    chapter_url: String.t,
    part:        non_neg_integer | nil,
    pubdate:     DateTime,
    series_url:  String.t,
    tags:        [String.t] | [],
    title:       String.t,
    translator:  String.t,
    volume:      non_neg_integer | nil
  }

  ## Interface

  @doc """
  Updates the ChapterUpdate. Delegates to Map.put/3
  """
  defdelegate update(chapter, key, value), to: Map, as: :put

  # %{description: description, title: title, url: url, pubdate: <DateTime>, tags: []}
  def parse_chapter(chapter) do
    %{
      description: description,
      title:       title,
      url:         url,
      pubdate:     date, # TODO parse DateTime into human readable format?
      tags:        tags
    } = chapter

    with %{
            "translator" => translator,
            "series_url" => series_url
          } <- parse_description(description),
          %{
            "chapter"     => chapter,
            "chapter_end" => chapter_end,
            "part"        => part,
            "title"       => title,
            "vol"         => volume
          } <- parse_chapter_info(title),
      do: %ChapterUpdate{
            chapters:    chapter..chapter_end |> Enum.to_list,
            chapter_url: url,
            part:        part,
            pubdate:     date,
            series_url:  series_url,
            tags:        tags,
            title:       title,
            translator:  translator,
            volume:      volume
          }
  end

  ## PRIVATE

  # description == "(TRANSLATOR) Series Information: novelupdates url"
  defp parse_description(description) do
    Regex.named_captures(
      ~r/\((?<translator>.+)\) Series Information: (?<series_url>.*)$/,
      description
    )
  end

  defp parse_chapter_info(title) do
    captures = Regex.named_captures(
      ~r/^(?<title>.*) (v(?<vol>[0-9]+))?c(?<chapter>[0-9]+)(\-(?<chapter_end>[0-9]*))?( part(?<part>[0-9]+))?$/,
      title
    )
    %{
      "chapter"     => captures["chapter"] |> String.to_integer,
      "chapter_end" => nil_if_empty(captures["chapter_end"]) ||
                         captures["chapter"] |> String.to_integer,
      "part"        => nil_if_empty(captures["part"]),
      "title"       => captures["title"],
      "vol"         => nil_if_empty(captures["vol"])
    }
  end

  @spec nil_if_empty(String.t) :: non_neg_integer | nil
  defp nil_if_empty(str) do
    case str do
      "" -> nil
      _ -> str |> String.to_integer
    end
  end

  ## Access Callbacks

  def fetch(chapter, key) do
    Map.fetch(chapter, key)
  end

  def get(t, key, _default), do: __MODULE__.fetch(t, key)
  def get_and_update(_t, _key, _fun) do; end
  def pop(_t, _key) do; end
end
