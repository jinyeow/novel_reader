defmodule NovelReader.Retriever do
  @moduledoc """
  This handles getting actual chapter content/text from the respective
  translation websites (e.g. WuxiaWorld, XianXiaWorld, Gravity Tales).

  It should store the chapter in [memory|text|ets] ?

               |--TaskSupervisor := async tasks ?
               |--NovelUpdates := communicate with NU and get chapter updates
  NovelReader--|--GUI := display information using Electron
               |--Retriever := pull chapter text

  Retrievers: [WuxiaWorld, XianXiaWorld, Gravity Tales, etc.]
  """

  # TODO: define callbacks for that each retriever needs to implement.

  @type url :: String.t

  # @callback get(url) :: {:ok, %HTTPoison.Response{}}

  # @spec get(url) :: {:ok, %HTTPoison.Response{}} | {:error, reason}
  # Pass in a ChapterUpdate ?
  # Determine from translator or title?
  # Use the corresponding site NovelReader.Retriever.[site].get(url)
  # Should return a Map? Struct? in the general form:
  #     %{content: content} ?? What other keys are needed?
end
