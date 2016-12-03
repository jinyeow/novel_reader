defmodule NovelReader.Retriever.GravityTales do
  @moduledoc false

  @behaviour NovelReader.Retriever

  @base_url "https://www.gravitytales.com/"

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
          |> String.replace("../../", @base_url)

    {:ok, page} = HTTPoison.get(url, [], [follow_redirect: true])
    %HTTPoison.Response{body: body} = page

    {_div, _attr, content} = body
                             |> Floki.find("div.innerContent")
                             |> hd

    content
    |> Floki.DeepText.get("\n")
  end
end
