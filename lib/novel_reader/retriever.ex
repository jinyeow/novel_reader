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
  # TODO implement a cache
  # TODO check if chapter has already been retrieved and is in the "cache"
  #      if it is already in the "cache" then return that; else retrieve.
  def get(chapter) do
    with url <- chapter[:chapter_url],
         {:ok, retriever} <- chapter[:translator] |> retriever do
      case retriever.get(url) do
        {:error, reason} -> {:error, reason}
        content -> {:ok, content}
      end
    end
  end

  # TODO implement a "default" retriever?
  defp retriever(translator) do
    case translator do
      "Alyschu"                  -> {:ok, Retriever.WuxiaWorld}
      "Dreams of Jianghu"        -> {:ok, Retriever.DreamsOfJianghu}
      "Gravity Tales"            -> {:ok, Retriever.GravityTales}
      "KobatoChanDaiSuki"        -> {:ok, Retriever.KobatoChanDaiSuki}
      "Myoniyoni Translations"   -> {:ok, Retriever.MyoniyoniTranslations}
      "otterspacetranslation"    -> {:ok, Retriever.OtterspaceTranslation}
      "PiggyBottle Translations" -> {:ok, Retriever.PiggyBottleTranslations}
      "putttytranslations"       -> {:ok, Retriever.PutttyTranslations}
      "Radiant Translations"     -> {:ok, Retriever.RadiantTranslations}
      "subudai11"                -> {:ok, Retriever.Subudai11}
      "Thyaeria"                 -> {:ok, Retriever.WuxiaWorld}
      "Translation Nations"      -> {:ok, Retriever.TranslationNations}
      "volaretranslations"       -> {:ok, Retriever.VolareTranslations}
      "Wuxiaworld"               -> {:ok, Retriever.WuxiaWorld}
      "XianXiaWorld"             -> {:ok, Retriever.XianXiaWorld}
      "Yoraikun Translation"     -> {:ok, Retriever.YoraikunTranslation}
      _                          -> {:error, :translator_unknown}
    end
  end
end
