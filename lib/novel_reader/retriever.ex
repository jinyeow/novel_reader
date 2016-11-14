defmodule NovelReader.Retriever do

  alias NovelReader.Retriever

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

  @type url :: String.t

  @callback get(url) :: {:ok, %HTTPoison.Response{}}

  # @spec get(url) :: {:ok, %HTTPoison.Response{}} | {:error, reason}
  # Pass in a ChapterUpdate ?
  # Determine from translator or title?
  # Use the corresponding site NovelReader.Retriever.[site].get(url)
  # Should return a Map? Struct? in the general form:
  #     %{content: content} ?? What other keys are needed?

  # TODO consider setting this up as a GenServer to 'cache' chapters
  # or else setup a separate GenServer to do that - a ChapterCache ??
  # TODO use a TaskSupervisor ??
  def get(chapter) do
    with url <- chapter[:chapter_url],
         {:ok, retriever} <- chapter[:translator] |> retriever do
      case retriever.get(url) do
        {:ok, content} -> {:ok, content}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  defp retriever(translator) do
    case translator do
      "Wuxiaworld" -> {:ok, Retriever.WuxiaWorld}
      "Alyschu" -> {:ok, Retriever.WuxiaWorld}
      "Thyaeria" -> {:ok, Retriever.WuxiaWorld}
      "XianXiaWorld" -> {:ok, Retriever.XianXiaWorld}
      "Gravity Tales" -> {:ok, Retriever.GravityTales}
      _ -> {:error, :translator_unknown}
    end
  end
end
