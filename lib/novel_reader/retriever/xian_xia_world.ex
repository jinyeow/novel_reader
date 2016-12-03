defmodule NovelReader.Retriever.XianXiaWorld do
  @moduledoc false

  @behaviour NovelReader.Retriever

  def get(url) do
    case url |> HTTPoison.get([], [follow_redirect: true]) do
      {:ok, page} -> find_content(page)
      {:error, reason} -> {:error, reason}
    end
  end

  defp find_content(page) do
    %HTTPoison.Response{body: body} = page
    {_tag, _attr, child} = body
                           |> Floki.find("#content")
                           |> hd

    child
    |> Enum.filter(&is_binary/1)
    |> Enum.join("\n")
  end
end
