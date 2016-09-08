defmodule LinkPreviewGenerator.PageTest do
  alias LinkPreviewGenerator.Page
  use ExUnit.Case

  @valid_uri "http://example.com/current"
  @uri_host "example.com"

  @invalid_uri "example.com"

  describe "#new" do
    test "with valid_uri" do
      assert Page.new(@valid_uri, @valid_uri) == %Page{
        original_url: @valid_uri,
        host_url: @uri_host,
        images: []
      }
    end

    test "with invalid_uri" do
      assert Page.new(@invalid_uri, @invalid_uri) == %Page{
        original_url: @invalid_uri,
        host_url: nil,
        images: []
      }
    end
  end

end
