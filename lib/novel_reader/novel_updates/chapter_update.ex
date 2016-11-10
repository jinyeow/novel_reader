defmodule NovelReader.NovelUpdates.ChapterUpdate do
  @behaviour Access

  defstruct [
    :chapter,
    :chapter_end,
    :chapter_url,
    :part,
    :pubdate,
    :series_url,
    :tags,
    :title,
    :translator,
    :volume
  ]

  # TODO add specs/types for each field
  # TODO see if you can defstruct as: name...

  @doc """
  Updates the ChapterUpdate. Delegates to Map.put/3
  """
  defdelegate update(chapter, key, value), to: Map, as: :put

  # Access Callbacks

  def fetch(chapter, key) do
    Map.fetch(chapter, key)
  end

  def get(t, key, _default), do: __MODULE__.fetch(t, key)
  def get_and_update(_t, _key, _fun) do; end
  def pop(_t, _key) do; end
end
