defmodule LinkPreview.PageTest do
  use LinkPreview.Case
  alias LinkPreview.{Page, Requests}

  import Mock

  @valid_urls [
    "http://www.example.com/path",
    "http://example.com/path",
    "http://www.example.com/",
    "http://example.com/",
    "http://www.example.com",
    "http://example.com",
    "https://www.example.com/path",
    "https://example.com/path",
    "https://www.example.com/",
    "https://example.com/",
    "https://www.example.com",
    "https://example.com",
    "www.example.com/path",
    "example.com/path",
    "www.example.com/",
    "example.com/",
    "www.example.com",
    "example.com"
  ]

  describe "new" do
    for url <- @valid_urls do
      test "returned page has proper website_url for valid url: #{url}" do
        with_mock Requests, [final_location: fn(url) -> url end] do
          assert %{
            original_url: unquote(url),
            website_url: "example.com"
          } = Page.new(unquote(url))
        end
      end
    end
  end
end
