defmodule LinkPreviewGenerator.PageTest do
  alias LinkPreviewGenerator.Page
  use ExUnit.Case

  @original_url "http://example.com/current"

  describe "#new" do
    test "current url with http schema and path" do
      assert Page.new("http://example.com/path/to/something", @original_url) == %Page{
        original_url: @original_url,
        website_url: "http://example.com",
      }
    end

    test "current url with http schema and without path" do
      assert Page.new("http://example.com", @original_url) == %Page{
        original_url: @original_url,
        website_url: "http://example.com",
      }
    end

    test "current url with https schema and path" do
      assert Page.new("https://example.com/path/to/something", @original_url) == %Page{
        original_url: @original_url,
        website_url: "https://example.com",
      }
    end

    test "current url with https schema and without path" do
      assert Page.new("https://example.com", @original_url) == %Page{
        original_url: @original_url,
        website_url: "https://example.com",
      }
    end

    test "current url without schema but with path" do
      assert Page.new("example.com/path/to/something", @original_url) == %Page{
        original_url: @original_url,
        website_url: "example.com",
      }
    end

    test "current url without schema and path" do
      assert Page.new("example.com", @original_url) == %Page{
        original_url: @original_url,
        website_url: "example.com",
      }
    end
  end

end
