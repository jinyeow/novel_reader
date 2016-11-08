defmodule NovelReader.NovelUpdates.ChapterUpdate do
  # @behaviour Access

  defstruct [
    :chapter,
    :chapter_url,
    :part,
    :pubdate,
    :series_url,
    :tags,
    :title,
    :translator,
    :volume
  ]

  # TODO implement Access behaviour
  # TODO add functions to get/set struct fields
  # TODO add specs/types for each field
  # TODO see if you can defstruct as: name...
end
