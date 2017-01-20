defmodule LinkPreview.Parsers.ImageTest do
  use ExUnit.Case
  alias LinkPreview.Parsers.Image
  alias LinkPreview.Page

  @original_url "http://example.com/image.jpg"
  @page %Page{original_url: @original_url}

  describe "images" do
    test "sets original_url as image url" do
      assert %Page{images: [%{url: @original_url}]} = Image.images(@page, nil)
    end
  end
end
