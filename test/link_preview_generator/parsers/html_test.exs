defmodule LinkPreviewGenerator.Parsers.HtmlTest do
  alias LinkPreviewGenerator.Parsers.Html
  alias LinkPreviewGenerator.Page
  use ExUnit.Case

  @html File.read!("test/fixtures/html_example.html") |> Floki.parse
  @opengraph File.read!("test/fixtures/opengraph_example.html") |> Floki.parse

  @page %Page{original_url: "http://example.com/", website_url: "http://example.com/", images: []}


  setup [:reset_defaults]

  describe "#title" do
    test "optimistic case with :friendly_strings" do
      assert Html.title(@page, @html) == %Page{@page | title: "HTML Test Title"}
    end

    test "optimistic case without :friendly_strings" do
      Application.put_env(:link_preview_generator, :friendly_strings, false)

      assert Html.title(@page, @html) == %Page{@page | title: "\n      HTML Test  Title\n    "}
    end

    test "pessimistic case" do
      assert Html.title(@page, @opengraph) == %Page{@page | title: nil}
    end
  end

  describe "#description" do
    test "optimistic case with :friendly_strings" do
      assert Html.description(@page, @html) == %Page{@page | description: "HTML Test Description"}
    end

    test "optimistic case without :friendly_strings" do
      Application.put_env(:link_preview_generator, :friendly_strings, false)

      assert Html.description(@page, @html) == %Page{@page | description: "\n      HTML Test\n      Description\n    "}
    end

    test "pessimistic case" do
      assert Html.description(@page, @opengraph) == %Page{@page | description: nil}
    end
  end

  describe "#images" do
    test "optimistic case without :force_images_absolute_url" do
      assert Html.images(@page, @html).images == [
        %{url: "http://example.com/images/html1.jpg"},
        %{url: "//example.com/images/html2.jpg"},
        %{url: "example.com/images/html3.jpg"},
        %{url: "/images/html4.jpg"},
        %{url: "images/html5.jpg"}
      ]
    end

    @tag :excluded
    test "optimistic case with :force_images_absolute_url" do
      Application.put_env(:link_preview_generator, :force_images_absolute_url, true)

      assert Html.images(@page, @html).images == [
        #TODO
      ]
    end

    test "pessimistic case" do
      assert Html.images(@page, @opengraph) == %Page{@page | images: []}
    end
  end

  defp reset_defaults(tags) do
    on_exit fn ->
      Application.put_env(:link_preview_generator, :friendly_strings, true)
      Application.put_env(:link_preview_generator, :force_images_absolute_url, false)
    end

    {:ok, tags}
  end
end
