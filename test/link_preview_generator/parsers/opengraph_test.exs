defmodule LinkPreviewGenerator.Parsers.OpengraphTest do
  alias LinkPreviewGenerator.Parsers.Opengraph
  alias LinkPreviewGenerator.Page
  use ExUnit.Case

  @html File.read!("test/fixtures/html_example.html") |> Floki.parse
  @opengraph File.read!("test/fixtures/opengraph_example.html") |> Floki.parse

  @page %Page{original_url: "http://example.com/", website_url: "http://example.com/", images: []}


  describe "#title" do
    test "optimistic case" do
      assert Opengraph.title(@page, @opengraph) == %Page{@page | title: "Opengraph Test Title"}
    end

    test "pessimistic case" do
      assert Opengraph.title(@page, @html) == @page
    end
  end

  describe "#description" do
    test "optimistic case" do
      assert Opengraph.description(@page, @opengraph) == %Page{@page | description: "Opengraph Test Description"}
    end

    test "pessimistic case" do
      assert Opengraph.description(@page, @html) == @page
    end
  end

  describe "#images" do
    test "optimistic case" do
      assert Opengraph.images(@page, @opengraph).images == [
        %{url: "http://example.com/images/og1.jpg"},
        %{url: "http://example.com/images/og2.jpg"}
      ]
    end

    test "pessimistic case" do
      assert Opengraph.images(@page, @html) == @page
    end
  end
end
