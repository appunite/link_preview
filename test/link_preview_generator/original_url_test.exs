defmodule LinkPreviewGenerator.OriginalUrlTest do
  alias LinkPreviewGenerator.OriginalUrl
  use ExUnit.Case

  @examples ["example.com", "example.com/", "//example.com", "//example.com/", "http://example.com", "http://example.com/"]
  @worst_case "/example.com"
  @normalized "http://example.com/"

  describe "#normalize_if_allowed when normalize_urls set to true" do
    setup do
      Application.put_env(:link_preview_generator, :normalize_urls, true)
    end

    @examples
    |> Enum.with_index
    |> Enum.each(
      fn({example, index}) ->
        test "returns success tuple with normalized example #{index}" do
          assert OriginalUrl.normalize_if_allowed(unquote(example)) == {:ok, @normalized}
        end
      end
    )

    test "returns error tuple if unable to normalize example" do
      assert OriginalUrl.normalize_if_allowed(@worst_case) == {:error, :normalization_failed}
    end
  end

  describe "#normalize_if_allowed when normalize_urls set to false" do
    setup do
      Application.put_env(:link_preview_generator, :normalize_urls, false)
    end

    @examples
    |> List.insert_at(-1, @worst_case)
    |> Enum.with_index
    |> Enum.each(
      fn({example, index}) ->
        test "returns success tuple with unchanged example #{index}" do
          assert OriginalUrl.normalize_if_allowed(unquote(example)) == {:ok, unquote(example)}
        end
      end
    )
  end

end
