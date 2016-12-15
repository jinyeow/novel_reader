defmodule NovelReader.Retriever.MyoniyoniTranslations do
  @moduledoc false

  @behaviour NovelReader.Retriever

  import NovelReader.Helper

  alias NovelReader.Chapter

  def get(url) do
    case page_type(url) do
      :post ->
        with {:ok, page} <- get_page(url),
             url <- parse_post_page(page),
             {:ok, page} <- get_page(url) do
          parse_chapter_page(page)
        else
          {:error, reason} -> {:error, reason}
        end
      :chapter ->
        with {:ok, page} <- get_page(url) do
          parse_chapter_page(page)
        else
          {:error, reason} -> {:error, reason}
        end
      :novel -> {:error, "To be implemented."}
      {:error, reason} -> {:error, reason}
    end
  end

  def page_type(url) do
    {:ok, head} = HTTPoison.head(url)

    url =
      case head.headers |> Map.new do
        %{"Location" => url} -> url
        _ -> url
      end

    cond do
      url =~ ~r/20[0-9][0-9]\/[0-9]+\/[0-9]+\/.+-chapter-/ -> :post
      url =~ ~r/\w+(-\w+)*\/.+-chapter-/ -> :chapter
      ! (url =~ ~r/-chapter-/) -> :novel
      :else -> {:error, "Unidentified page type."}
    end
  end

  def parse_post_page(page) do
    page.body
    |> Floki.find("div.entry-content a")
    |> Enum.filter(fn elem ->
      case Floki.attribute(elem, "href") do
        [] -> false
        list ->
          list
          |> hd =~ ~r/chapter/i
      end
    end)
    |> hd
    |> Floki.attribute("href")
    |> hd
  end

  def parse_chapter_page(page) do
    body = page.body
    %Chapter{
      content: get_content(body),
      title: get_title(body),
      chapter: get_chapter(body),
      next: get_next(body),
      prev: get_prev(body),
      novel: get_novel(body)
    }
  end

  def get_title(body) do
    body
    |> Floki.find("div.entry-content p")
    |> hd
    |> Floki.text
    |> String.split(~r/[\.:]/)
    |> List.last
    |> String.trim
  end

  def get_chapter(body) do
    "Chapter " <> chapter =
      body
      |> Floki.find("div.entry-content p")
      |> hd
      |> Floki.text
      |> String.split(~r/[\.:]/)
      |> List.first

    chapter
  end

  def get_content(body) do
    {_tag, _attr, content} =
      body
      |> Floki.find("div.entry-content")
      |> hd

    Floki.DeepText.get(content, "\n")
  end

  def get_next(body) do
    case body
    |> Floki.find("div.entry-content p a")
    |> Enum.filter(fn elem -> Floki.text(elem) =~ ~r/Next Chapter/ end) do
      [] -> nil
      list ->
        list
        |> hd
        |> Floki.attribute("href")
        |> hd
    end
  end

  def get_prev(body) do
    case body
    |> Floki.find("div.entry-content p a")
    |> Enum.filter(fn elem -> Floki.text(elem) =~ ~r/Previous Chapter/ end) do
      [] -> nil
      list ->
        list
        |> hd
        |> Floki.attribute("href")
        |> hd
    end
  end

  def get_novel(body) do
    text =
      body
      |> Floki.find("h1.entry-title")
      |> Floki.text

    Regex.named_captures(~r/(?<novel>\w+(\s\w+)*) Chapter [0-9]+/, text)["novel"]
  end
end
