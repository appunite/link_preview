defmodule LinkPreview.Parsers.UtilTest do
  use LinkPreview.Case
  alias LinkPreview.Parsers.Util

  defp reset_defaults(opts) do
    on_exit fn ->
      Application.put_env(:link_preview, :friendly_strings, true)
      Application.put_env(:link_preview, :force_images_absolute_url, false)
      Application.put_env(:link_preview, :force_images_url_schema, false)
      Application.put_env(:link_preview, :filter_small_images, false)

      Application.put_env(:link_preview, :code_module, Code)
    end

    {:ok, opts}
  end

  setup [:reset_defaults]

  describe "maybe_friendly_string" do
    test "trims" do
      example = "  text  "
      assert Util.maybe_friendly_string(example) == "text"
    end

    test "replaces multi-spaces with single space" do
      example = "text    text"
      assert Util.maybe_friendly_string(example) == "text text"
    end

    test "replaces new lines with space" do
      example = "text\ntext"
      assert Util.maybe_friendly_string(example) == "text text"
    end

    test "decodes html entities" do
      example = "&quot;text&quot;"
      assert Util.maybe_friendly_string(example) == ~s("text")
    end

    test "doesn't decode html entities when HtmlEntities not loaded" do
      Application.put_env(:link_preview, :code_module, HtmlEntitiesNotLoaded)

      example = "&quot;text&quot;"
      assert Util.maybe_friendly_string(example) == example
    end

    test "ignores nils" do
      assert is_nil(Util.maybe_friendly_string(nil))
    end

    test "returns unchanged text when friedly strings are turned off" do
      Application.put_env(:link_preview, :friendly_strings, false)

      example = " \n&quot;terrible  mistage&quot;\n\n  "
      assert Util.maybe_friendly_string(example) == example
    end
  end

  describe "maybe_force_absolute_url" do
    setup opts do
      page = %LinkPreview.Page{website_url: "example.com"}
      result = Map.merge(opts, %{page: page})

      Application.put_env(:link_preview, :force_images_absolute_url, true)

      {:ok, result}
    end

    test "absolute url with http schema", %{page: page} do
      assert Util.maybe_force_absolute_url(["http://example.com/img"], page) == ["http://example.com/img"]
    end

    test "absolute url with https schema", %{page: page} do
      assert Util.maybe_force_absolute_url(["https://example.com/img"], page) == ["https://example.com/img"]
    end

    test "absolute url without schema", %{page: page} do
      assert Util.maybe_force_absolute_url(["example.com/img"], page) == ["example.com/img"]
    end

    test "weird shit", %{page: page} do
      assert Util.maybe_force_absolute_url(["//example.com/img"], page) == ["//example.com/img"]
    end

    test "relative url", %{page: page} do
      assert Util.maybe_force_absolute_url(["/img"], page) == ["example.com/img"]
    end
  end

  describe "maybe_force_url_schema" do
    setup opts do
      Application.put_env(:link_preview, :force_images_url_schema, true)

      {:ok, opts}
    end

    test "absolute url with http schema" do
      assert Util.maybe_force_url_schema(["http://example.com/img"]) == ["http://example.com/img"]
    end

    test "absolute url with https schema" do
      assert Util.maybe_force_url_schema(["https://example.com/img"]) == ["https://example.com/img"]
    end

    test "absolute url without schema" do
      assert Util.maybe_force_url_schema(["example.com/img"]) == ["http://example.com/img"]
    end

    test "weird shit" do
      assert Util.maybe_force_url_schema(["//example.com/img"]) == ["http://example.com/img"]
    end

    test "relative url" do
      assert Util.maybe_force_url_schema(["/img"]) == ["http:///img"]
    end
  end

  describe "maybe_validate" do
    test "when all image related settings are disabled" do
      urls = [@httparrot <> "/get", @httparrot <> "/image"]
      assert Util.maybe_validate(urls) == urls
    end

    test "when :force_images_absolute_url is enabled" do
      Application.put_env(:link_preview, :force_images_absolute_url, true)

      urls = [@httparrot <> "/get", @httparrot <> "/image"]
      assert Util.maybe_validate(urls) == [@httparrot <> "/image"]
    end

    test "when :force_images_url_schema is enabled" do
      Application.put_env(:link_preview, :force_images_url_schema, true)

      urls = [@httparrot <> "/get", @httparrot <> "/image"]
      assert Util.maybe_validate(urls) == [@httparrot <> "/image"]
    end

    test "when :filter_small_images is enabled" do
      Application.put_env(:link_preview, :filter_small_images, true)

      urls = [@httparrot <> "/get", @httparrot <> "/image"]
      assert Util.maybe_validate(urls) == [@httparrot <> "/image"]
    end
  end
end
