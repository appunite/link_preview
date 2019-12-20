defmodule LinkPreview.Parsers.HtmlTest do
  use LinkPreview.Case
  alias LinkPreview.Parsers.Html
  alias LinkPreview.Page

  @page %Page{original_url: "http://example.com/", website_url: "example.com"}

  setup [:reset_defaults]

  describe "title" do
    test "optimistic case" do
      assert Html.title(@page, @html) == %Page{@page | title: "HTML Test Title"}
    end

    test "pessimistic case" do
      assert Html.title(@page, @opengraph) == @page
    end
  end

  describe "description" do
    test "optimistic case" do
      assert Html.description(@page, @html) == %Page{@page | description: "HTML Test Description"}
    end

    test "pessimistic case" do
      assert Html.description(@page, @opengraph) == @page
    end
  end

  describe "images" do
    test "optimistic case without additional options" do
      assert Html.images(@page, @html).images == [
               %{url: "http://example.com/images/html1.jpg"},
               %{url: "example.com/images/html2.jpg"},
               %{url: "/images/html3.jpg"},
               %{url: "images/html4.jpg"},
               %{url: "https://example.com/images/html5.jpg"}
             ]
    end

    test "doesn't limit images" do
      images = Html.images(@page, @image_spam).images
      assert Enum.count(images) == 73
    end

    test "limits images with :force_images_absolute_url" do
      Application.put_env(:link_preview, :force_images_absolute_url, true)

      images = Html.images(@page, @image_spam).images
      assert Enum.count(images) == 50
    end

    test "limits images with :force_images_url_schema" do
      Application.put_env(:link_preview, :force_images_url_schema, true)

      images = Html.images(@page, @image_spam).images
      assert Enum.count(images) == 50
    end

    @tag :excluded
    test "limits images with :filter_small_images" do
      Application.put_env(:link_preview, :filter_small_images, 1)

      images = Html.images(@page, @image_spam).images
      assert Enum.count(images) == 50
    end

    test "pessimistic case" do
      assert Html.images(@page, @opengraph) == @page
    end
  end

  defp reset_defaults(opts) do
    on_exit(fn ->
      Application.put_env(:link_preview, :friendly_strings, true)
      Application.put_env(:link_preview, :force_images_absolute_url, false)
      Application.put_env(:link_preview, :force_images_url_schema, false)
      Application.put_env(:link_preview, :filter_small_images, false)
    end)

    {:ok, opts}
  end
end
