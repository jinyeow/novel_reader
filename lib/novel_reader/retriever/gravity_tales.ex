defmodule NovelReader.Retriever.GravityTales do
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

    link = Floki.find(body, ".entry-content a")
           |> Enum.filter(fn elem ->
             Floki.attribute(elem, "href")
             |> hd =~ ~r/chapter-[0-9]+/
           end)
           |> hd

    url = Floki.attribute(link, "href")
          |> hd
          |> String.replace("../../", @base_url)

    {:ok, page} = HTTPoison.get(url, [], [follow_redirect: true])
    %HTTPoison.Response{body: body} = page

    {_div, _attr, content} = Floki.find(body, "div.innerContent") |> hd

    content
    |> Floki.DeepText.get("\n")
    # |> Enum.map(fn elem -> Floki.text(elem) <> "\n" end)
    # |> Enum.join
  end
end
