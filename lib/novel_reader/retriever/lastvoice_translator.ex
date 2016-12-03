defmodule NovelReader.Retriever.LastvoiceTranslator do
  @moduledoc false

  @behaviour NovelReader.Retriever

  def get(url) do
    case url |> HTTPoison.get([], [follow_redirect: true]) do
      {:ok, page} -> find_content(page)
      {:error, reason} -> {:error, reason}
    end
  end

  # TODO
  defp find_content(page) do
    %HTTPoison.Response{body: body} = page
  end
end
