defmodule NovelReader.Retriever do

  alias NovelReader.Retriever
  alias NovelReader.CacheServer

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

  # TODO use a TaskSupervisor ??
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
    case cache_or_retrieve(chapter) do
      {:error, reason} -> {:error, reason}
      content ->
        CacheServer.add(chapter[:title], content)
        {:ok, content}
    end
  end

  @doc """
  Returns the correct module to use depending on the translator.
  If the translator is unknown, returns an :error.
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
      "Novel Saga"               -> {:ok, Retriever.NovelSaga}
      "otterspacetranslation"    -> {:ok, Retriever.OtterspaceTranslation}
      "PiggyBottle Translations" -> {:ok, Retriever.PiggyBottleTranslations}
      "putttytranslations"       -> {:ok, Retriever.PutttyTranslations}
      "Radiant Translations"     -> {:ok, Retriever.RadiantTranslations}
      "subudai11"                -> {:ok, Retriever.Subudai11}
      "Thyaeria"                 -> {:ok, Retriever.WuxiaWorld}
      "Thyaeria's Translation"   -> {:ok, Retriever.WuxiaWorld}
      "Translation Nations"      -> {:ok, Retriever.TranslationNations}
      "volaretranslations"       -> {:ok, Retriever.VolareTranslations}
      "wleltranslations"         -> {:ok, Retriever.WeleTranslations}
      "Wuxiaworld"               -> {:ok, Retriever.WuxiaWorld}
      "XianXiaWorld"             -> {:ok, Retriever.XianXiaWorld}
      "Yoraikun Translation"     -> {:ok, Retriever.YoraikunTranslation}
      _                          -> {:error, :translator_unknown}
    end
  end

  # NOTE: Currently 'id' is the chapter title - will change in the future
  defp cache_or_retrieve(chapter) do
    id = chapter[:title]
    url = chapter[:chapter_url]

    # Check the cache first
    case CacheServer.get(id) do
      {:ok, content} -> content
      {:error, :not_in_cache} ->
        {:ok, retriever} = chapter[:translator] |> retriever
        retriever.get(url)
    end
  end

end
