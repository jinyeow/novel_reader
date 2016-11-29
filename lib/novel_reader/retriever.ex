defmodule NovelReader.Retriever do
  @moduledoc """
  Handles getting actual chapter content/text from the respective
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

  alias NovelReader.Retriever
  alias NovelReader.Model.ChapterUpdate
  alias NovelReader.Model.Chapter
  alias NovelReader.Cache

  @type url :: String.t
  @type translator :: String.t
  @type reason :: atom

  @callback get(any) :: String.t
  # TODO do we need another callback for get_from_url/2 ??

  # TODO implement get_from_url/2
  # @spec get_from_url(url, list) :: {:ok, String.t} | {:error, reason}
  # def get_from_url(url, opts \\ [force: false]) do
    # if opts[:force] is true then directly retrieve from web using URL
    # else:
    #   check cache
    #   check files
    #   then pull from web using URL if :not_in_cache_or_file
  # end

  @doc """
  Pass in a %ChapterUpdate{} struct.
  From the %ChapterUpdate[:translator] determine the site to use.

  Use the corresponding modules callback NovelReader.Retriever.[site].get(url)

  Saves newly downloaded chapters to the Cache

  Returns the chapter text.
  """
  @spec get_from_update(ChapterUpdate.t) :: {:ok, String.t} | {:error, any}
  def get_from_update(chapter) do
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
  @spec get_from_url(url) :: {:ok, [%Chapter{}]} |
                             {:ok, %Chapter{}} |
                             {:error, :invalid_url}
  def get_from_url(url) do
    if not valid_url?(url) do {:error, :invalid_url} end
    # TODO finish this.
  end

  defp valid_url?(url) do
    uri = URI.parse(url)
    uri.scheme != nil && uri.host =~ "."
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

  defp retrieve(chapter) do
    title = chapter[:title]
    chap  = chapter[:chapters] |> hd
    url   = chapter[:chapter_url]

    # Check the cache first (let the CacheServer check if the chapter is on file)
    case Cache.get(title, chap) do
      {:ok, content} -> content
      {:error, :not_cached_or_saved} ->
        {:ok, retriever} = chapter[:translator] |> retriever
        retriever.get(url)
    end
  end

end
