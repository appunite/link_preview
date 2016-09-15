defmodule LinkPreviewGenerator.Parsers.HtmlTest do
  alias LinkPreviewGenerator.Parsers.Html
  alias LinkPreviewGenerator.Page
  use ExUnit.Case

  import Mock

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
      assert Html.title(@page, @opengraph) == @page
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
      assert Html.description(@page, @opengraph) == @page
    end
  end

  describe "#images" do
    test "optimistic case without additional options" do
      assert Html.images(@page, @html).images == [
        %{url: "http://example.com/images/html1.jpg"},
        %{url: "example.com/images/html2.jpg"},
        %{url: "/images/html3.jpg"},
        %{url: "images/html4.jpg"}
      ]
    end

    test "optimistic case with :force_images_absolute_url" do
      with_mock HTTPoison, [head: fn(url, _, _) -> response_helper(url) end] do
        Application.put_env(:link_preview_generator, :force_images_absolute_url, true)

        assert Html.images(@page, @html).images == [
          %{url: "http://example.com/images/html1.jpg"},
          %{url: "example.com/images/html2.jpg"},
          %{url: "http://example.com/images/html3.jpg"},
          %{url: "http://example.com/images/html4.jpg"}
        ]
      end
    end

    test "optimistic case with :force_images_url_schema" do
      with_mock HTTPoison, [head: fn(url, _, _) -> response_helper(url) end] do
        Application.put_env(:link_preview_generator, :force_images_url_schema, true)

        assert Html.images(@page, @html).images == [
          %{url: "http://example.com/images/html1.jpg"},
          %{url: "http://example.com/images/html2.jpg"}
        ]
      end
    end

    test "optimistic case with all additional options" do
      with_mock HTTPoison, [head: fn(url, _, _) -> response_helper(url) end] do
        Application.put_env(:link_preview_generator, :force_images_absolute_url, true)
        Application.put_env(:link_preview_generator, :force_images_url_schema, true)

        assert Html.images(@page, @html).images == [
          %{url: "http://example.com/images/html1.jpg"},
          %{url: "http://example.com/images/html2.jpg"},
          %{url: "http://example.com/images/html3.jpg"},
          %{url: "http://example.com/images/html4.jpg"}
        ]
      end
    end

    test "pessimistic case" do
      assert Html.images(@page, @opengraph) == @page
    end
  end

  defp reset_defaults(tags) do
    on_exit fn ->
      Application.put_env(:link_preview_generator, :friendly_strings, true)
      Application.put_env(:link_preview_generator, :force_images_absolute_url, false)
      Application.put_env(:link_preview_generator, :force_images_url_schema, false)
    end

    {:ok, tags}
  end

  defp response_helper(url) do
    case url do
      "http://example.com" <> _ ->
        {:ok, %HTTPoison.Response{status_code: 200, headers: [{"Content-Type", "image/jpg"}]}}
      "example.com" <> _ ->
        {:ok, %HTTPoison.Response{status_code: 200, headers: [{"Content-Type", "image/jpg"}]}}
      _ ->
        {:error, %HTTPoison.Error{reason: :badarg}}
    end
  end
end
