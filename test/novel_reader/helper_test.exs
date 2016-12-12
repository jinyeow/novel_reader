defmodule NovelReader.HelperTest do
  use ExUnit.Case, async: true

  import NovelReader.Helper

  test "valid_url?/1 returns true for a valid url" do
    valid_urls = [
      "http://gravitytales.com",
      "http://www.wuxiaworld.com",
      "https://www.google.com",
      "http://www.xianxiaworld.net/The-Magus-Era/1000098.html"
    ]

    for url <- valid_urls do
      assert valid_url?(url) == true
    end
  end
end
