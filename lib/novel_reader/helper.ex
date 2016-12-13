defmodule NovelReader.Helper do
  @moduledoc """
  Helper functions used by any module.
  """

  def valid_url?(url) do
    uri = URI.parse(url)
    uri.scheme != nil && uri.host =~ "."
  end

  def get_page(url) do
    case HTTPoison.get(url, [], [follow_redirect: true]) do
      {:ok, page} ->
        case page.status_code do
          200 -> {:ok, page}
          code -> status_code_error(code)
        end
      {:error, reason} -> {:error, reason}
    end
  end

  def status_code_error(code) do
    case code do
      200 -> {:ok, "OK"}
      404 -> {:error, "File Not Found"}
      503 -> {:error, "Service Unavailable"}
      _ -> {:error, code}
    end
  end
end
