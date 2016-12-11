defmodule NovelReader.Retriever.WuxiaWorld do
  @moduledoc false

  @behaviour NovelReader.Retriever

  import NovelReader.Helper

  @base_url "https://www.wuxiaworld.com"

  # TODO Update this module similarly to GravityTales
  def get(url) do
    case url |> HTTPoison.get([], [follow_redirect: true]) do
      {:ok, page} -> find_content(page)
      {:error, reason} -> {:error, reason}
    end
  end

  defp find_content(page) do
    %HTTPoison.Response{body: body} = page

    link = body
           |> Floki.find(".entry-content a")
           |> Enum.filter(fn elem ->
             elem
             |> Floki.attribute("href")
             |> hd =~ ~r/-chapter-[0-9]+/
           end)
           |> hd

    url = link
          |> Floki.attribute("href")
          |> hd

    {:ok, page} = HTTPoison.get(url, [], [follow_redirect: true])
    %HTTPoison.Response{body: body} = page

    {_tag, _attr, content} = body
                             |> Floki.find("div[itemprop='articleBody']")
                             |> hd

    content |> Floki.DeepText.get("\n")
  end
end
