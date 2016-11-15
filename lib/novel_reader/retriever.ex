defmodule NovelReader.Retriever do

  alias NovelReader.Retriever

  @moduledoc """
  This handles getting actual chapter content/text from the respective
  translation websites (e.g. WuxiaWorld, XianXiaWorld, Gravity Tales) known as
  retrievers.

  ## Example
      iex> NovelReader.Retriever.retriever("WuxiaWorld")
      {:ok, Retriever.WuxiaWorld}
      iex> NovelReader.Retriever.retriever("a0132")
      {:ok, Retriever.WuxiaWorld}
      iex> NovelReader.Retriever.retriever("Gravity Tales")
      {:ok, Retriever.GravityTales}
      iex> NovelReader.Retriever.retriever("Some Fake Translations")
      {:error, :translator_unknown}

  """

  # TODO consider setting this up as a GenServer to 'cache' chapters
  #      or else setup a separate GenServer to do that - a ChapterCache ??
  #      And on startup, pre-load with cached chapters
  # TODO use a TaskSupervisor ??
  # TODO implement a cache
  # TODO check if chapter has already been retrieved and is in the "cache"
  #      if it is already in the "cache" then return that; else retrieve.
  # TODO have the retriever.get(url) return a Map or ChapterContent struct that
  #      contains:
  #       - title
  #       - next chapter url
  #       - prev chapter url
  #       - chapter text
  # TODO update the typespecs as interfaces/functions change
  # TODO implement a get/1 that fetches the chapter given a direct URL


  @type url :: String.t
  @type translator :: String.t

  @callback get(url) :: String.t

  @doc """
  Pass in a %ChapterUpdate struct.
  From the %ChapterUpdate[:translator] determine the site to use.

  Use the corresponding modules callback NovelReader.Retriever.[site].get(url)

  Returns the chapter text.
  """
  @spec get(NovelReader.NovelUpdates.ChapterUpdate.t) :: {:ok, String.t} | {:error, any}
  def get(chapter) do
    with url <- chapter[:chapter_url],
         {:ok, retriever} <- chapter[:translator] |> retriever do
      case retriever.get(url) do
        {:error, reason} -> {:error, reason}
        content -> {:ok, content}
      end
    end
  end

  # NOTE: should I implement a "default" retriever? or return :error ?
  @doc """
  Returns the correct module to use depending on the translator.
  """
  @spec retriever(Retriever.translator) :: {:ok, module} | {:error, :translator_unknown}
  def retriever(translator) do
    case translator do
      "a0132"                    -> {:ok, Retriever.WuxiaWorld}
      "Alyschu"                  -> {:ok, Retriever.WuxiaWorld}
      "Aran Translations"        -> {:ok, Retriever.AranTranslations}
      "ChongMeiTranslations"     -> {:ok, Retriever.ChongMeiTranslations}
      "Dreams of Jianghu"        -> {:ok, Retriever.DreamsOfJianghu}
      "faktranslations"          -> {:ok, Retriever.FakTranslations}
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
