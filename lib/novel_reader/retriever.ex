defmodule NovelReader.Retriever do
  @moduledoc """
  Handles getting actual chapter content/text from the respective
  translation websites (e.g. WuxiaWorld, XianXiaWorld, Gravity Tales) known as
  retrievers.

  ## Example
      iex> NovelReader.Retriever.retriever("Wuxiaworld")
      {:ok, NovelReader.Retriever.WuxiaWorld}
      iex> NovelReader.Retriever.retriever("a0132")
      {:ok, NovelReader.Retriever.WuxiaWorld}
      iex> NovelReader.Retriever.retriever("Gravity Tales")
      {:ok, NovelReader.Retriever.GravityTales}
      iex> NovelReader.Retriever.retriever("Some Fake Translations")
      {:error, "Translator unknown."}

  """

  import NovelReader.Helper

  alias NovelReader.Retriever
  alias NovelReader.ChapterUpdate
  alias NovelReader.Chapter
  alias NovelReader.Cache

  @type url :: String.t
  @type translator :: String.t
  @type reason :: String.t

  @callback get(any) :: String.t

  @doc """
  Pass in a %ChapterUpdate{} struct.
  From the %ChapterUpdate[:translator] determine the site to use.

  Use the corresponding modules callback NovelReader.Retriever.[site].get(url)

  Saves newly downloaded chapters to the Cache

  Returns the chapter text.
  """
  @spec get(ChapterUpdate.t) :: {:ok, String.t} | {:error, reason}
  def get(%ChapterUpdate{} = chapter) do
    case retrieve(chapter) do
      {:error, reason} -> {:error, reason}
      content ->
        Cache.add(chapter[:title], content)
        {:ok, content}
    end
  end

  @doc """
  Retrieves chapter(s) given a URL.

  If URL points to the novel index, return a List of %Chapter{}.
  If URL points to one chapter return a %Chapter{}.
  """
  @spec get(String.t) :: {:ok, [%Chapter{}]} | {:ok, %Chapter{}} | {:error, reason}
  def get(url) when is_binary(url) do
    if not valid_url?(url) do {:error, "Invalid URL."} end
    # TODO finish this.
  end

  @doc """
  Returns the correct module to use depending on the translator.
  If the translator is unknown, returns an :error tuple.
  """
  @spec retriever(Retriever.translator) :: {:ok, module} | {:error, String.t}
  def retriever(translator) do
    case translator do
      "a0132"                      -> {:ok, Retriever.WuxiaWorld}
      "Alyschu"                    -> {:ok, Retriever.WuxiaWorld}
      "Aran Translations"          -> {:ok, Retriever.AranTranslations}
      "ChongMeiTranslations"       -> {:ok, Retriever.ChongMeiTranslations}
      "Dreams of Jianghu"          -> {:ok, Retriever.DreamsOfJianghu}
      "faktranslations"            -> {:ok, Retriever.FakTranslations}
      "Gravity Tales"              -> {:ok, Retriever.GravityTales}
      "Lastvoice Translations"     -> {:ok, Retriever.LastvoiceTranslator}
      "Lesyt"                      -> {:ok, Retriever.Lesyt}
      "KobatoChanDaiSuki"          -> {:ok, Retriever.KobatoChanDaiSuki}
      "Myoniyoni Translations"     -> {:ok, Retriever.MyoniyoniTranslations}
      "novelsreborn"               -> {:ok, Retriever.NovelsReborn}
      "Novel Saga"                 -> {:ok, Retriever.NovelSaga}
      "otterspacetranslation"      -> {:ok, Retriever.OtterspaceTranslation}
      "PiggyBottle Translations"   -> {:ok, Retriever.PiggyBottleTranslations}
      "putttytranslations"         -> {:ok, Retriever.PutttyTranslations}
      "Radiant Translations"       -> {:ok, Retriever.RadiantTranslations}
      "subudai11"                  -> {:ok, Retriever.Subudai11}
      "Shiroyukineko Translations" -> {:ok, Retriever.ShiroyukinekoTranslations}
      "Thyaeria"                   -> {:ok, Retriever.WuxiaWorld}
      "Thyaeria's Translation"     -> {:ok, Retriever.WuxiaWorld}
      "Translation Nations"        -> {:ok, Retriever.TranslationNations}
      "volaretranslations"         -> {:ok, Retriever.VolareTranslations}
      "weleltranslations"          -> {:ok, Retriever.WeleTranslations}
      "Wuxiaworld"                 -> {:ok, Retriever.WuxiaWorld}
      "XianXiaWorld"               -> {:ok, Retriever.XianXiaWorld}
      "Yoraikun Translation"       -> {:ok, Retriever.YoraikunTranslation}
      _                            -> {:error, "Translator unknown."}
    end
  end

  defp retrieve(chapter) do
    chap  =
      chapter[:chapters]
      |> hd
    title = chapter[:title]

    # Check the cache first (let the CacheServer check if the chapter is on file)
    # If not in cache retrieve from web
    case Cache.get(title, chap) do
      {:ok, content} -> content
      {:error, cache_error} ->
        case retriever(chapter[:translator]) do
          {:ok, retriever} -> retriever.get(chapter[:chapter_url])
          error -> error
        end
    end
  end
end
