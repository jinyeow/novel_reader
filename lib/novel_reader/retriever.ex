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
  @spec get(ChapterUpdate.t) :: {:ok, Chapter.t} | {:error, reason}
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
    if not valid_url?(url) do
      {:error, "Invalid URL."}
    else
      case retriever(url) do
        {:ok, translator} ->
          chapter = translator.get(url)
          Cache.add(chapter[:title], chapter[:content])
          {:ok, chapter}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  @doc """
  Returns the correct module to use depending on the translator.
  If the translator is unknown, returns an :error tuple.
  """
  @spec retriever(Retriever.translator) :: {:ok, module} | {:error, String.t}
  def retriever(translator) do
    cond do
      translator =~ ~r/a0132/i                      -> {:ok, Retriever.WuxiaWorld}
      translator =~ ~r/Alyschu/i                    -> {:ok, Retriever.WuxiaWorld}
      translator =~ ~r/Aran/i                       -> {:ok, Retriever.AranTranslations}
      translator =~ ~r/ChongMei/i                   -> {:ok, Retriever.ChongMeiTranslations}
      translator =~ ~r/Dreams of Jianghu|wwyxhqc/i  -> {:ok, Retriever.DreamsOfJianghu}
      translator =~ ~r/faktranslations/i            -> {:ok, Retriever.FakTranslations}
      translator =~ ~r/Gravity Tales|gravitytales/i -> {:ok, Retriever.GravityTales}
      translator =~ ~r/Lastvoice/i                  -> {:ok, Retriever.LastvoiceTranslator}
      translator =~ ~r/Lesyt/i                      -> {:ok, Retriever.Lesyt}
      translator =~ ~r/KobatoChanDaiSuki/i          -> {:ok, Retriever.KobatoChanDaiSuki}
      translator =~ ~r/Myoniyoni/i                  -> {:ok, Retriever.MyoniyoniTranslations}
      translator =~ ~r/novelsreborn/i               -> {:ok, Retriever.NovelsReborn}
      translator =~ ~r/Novel\s*Saga/i               -> {:ok, Retriever.NovelSaga}
      translator =~ ~r/otterspace(translation)*/i   -> {:ok, Retriever.OtterspaceTranslation}
      translator =~ ~r/PiggyBottle/i                -> {:ok, Retriever.PiggyBottleTranslations}
      translator =~ ~r/puttty(translations)*/i      -> {:ok, Retriever.PutttyTranslations}
      translator =~ ~r/Radiant/i                    -> {:ok, Retriever.RadiantTranslations}
      translator =~ ~r/subudai11/i                  -> {:ok, Retriever.Subudai11}
      translator =~ ~r/Shiroyukineko/i              -> {:ok, Retriever.ShiroyukinekoTranslations}
      translator =~ ~r/Thyaeria/i                   -> {:ok, Retriever.WuxiaWorld}
      translator =~ ~r/Thyaeria's Translation/i     -> {:ok, Retriever.WuxiaWorld}
      translator =~ ~r/Translation\s*Nations/i      -> {:ok, Retriever.TranslationNations}
      translator =~ ~r/volaretranslations/i         -> {:ok, Retriever.VolareTranslations}
      translator =~ ~r/weleltranslations/i          -> {:ok, Retriever.WeleTranslations}
      translator =~ ~r/Wuxiaworld/i                 -> {:ok, Retriever.WuxiaWorld}
      translator =~ ~r/XianXiaWorld/i               -> {:ok, Retriever.XianXiaWorld}
      translator =~ ~r/Yoraikun/i                   -> {:ok, Retriever.YoraikunTranslation}
      true                                          -> {:error, "Translator unknown."}
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
      {:error, _} ->
        case retriever(chapter[:translator]) do
          {:ok, translator} -> translator.get(chapter[:chapter_url])
          error -> error
        end
    end
  end
end
