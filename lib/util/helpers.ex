defmodule NovelReader.Util.Helpers do
  @moduledoc """
  Helper functions used by any module.
  """

  def valid_url?(url) do
    uri = URI.parse(url)
    uri.scheme != nil && uri.host =~ "."
  end

  def status_code_error(code) do
    case code do
      404 -> {:error, "File Not Found"}
      503 -> {:error, "Service Unavailable"}
      _ -> {:error, code}
    end
  end
end
