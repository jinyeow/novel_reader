defmodule NovelReader.Retriever.GravityTales do
  @moduledoc false

  @behaviour NovelReader.Retriever

  import NovelReader.Helper

  alias NovelReader.Chapter

  @base_url "http://gravitytales.com/"

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
      url =~ ~r/\/post\// -> :post
      url =~ ~r/\/novel\/.+-chapter-/ -> :chapter
      ! (url =~ ~r/chapter/) -> :novel
      :else -> {:error, "Unidentified page type."}
    end
  end

  def parse_post_page(page) do
    %HTTPoison.Response{body: body} = page

    link =
      body
      |> Floki.find(".entry-content a")
      |> Enum.filter(fn elem ->
        with [href] <- elem
                      |> Floki.attribute("href") do
          href =~ ~r/-chapter-[0-9]+/
        else
          [] -> false
        end
      end)
      |> hd

    link
    |> Floki.attribute("href")
    |> hd
    |> String.replace("../../", @base_url)
  end

  def parse_chapter_page(page) do
    %HTTPoison.Response{body: body} = page
    %Chapter{
      chapter: get_chapter(body),
      content: get_content(body),
      next:    get_next(body),
      novel:   get_novel(body),
      prev:    get_prev(body),
      title:   get_title(body)
    }
  end

  def get_content(body) do
    {_div, _attr, content} =
      body
      |> Floki.find("div.innerContent")
      |> hd

    Floki.DeepText.get(content, "\n")
  end

  def get_novel(body) do
    body
    |> Floki.find("h3")
    |> hd
    |> Floki.text
  end

  def get_title(body) do
    body
    |> Floki.find("div.innerContent p")
    |> hd
    |> Floki.text
    |> String.split(~r/[:\-] /, trim: true)
    |> List.last
  end

  def get_chapter(body) do
    "Chapter " <> num =
      body
      |> Floki.find("div.innerContent p")
      |> hd
      |> Floki.text
      |> String.split(~r/[:\-] /, trim: true)
      |> hd

    String.trim(num)
  end

  def get_next(body) do
    next =
      body
      |> Floki.find("div.chapter-navigation a")
      |> List.last
      |> Floki.attribute("href")
      |> hd
    @base_url <> next
  end

  def get_prev(body) do
    prev =
      body
      |> Floki.find("div.chapter-navigation a")
      |> hd
      |> Floki.attribute("href")
      |> hd
    @base_url <> prev
  end
end
