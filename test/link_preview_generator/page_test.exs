defmodule LinkPreviewGenerator.PageTest do
  use ExUnit.Case
  alias LinkPreviewGenerator.Page

  import Mock

  @original_url "http://example.com/current"

  # describe "#new" do
  #   test "returns success tuple when final location is valid" do
  #     with_mock LinkPreviewGenerator.Requests, [final_location: fn(_url) -> {:ok, @original_url} end] do
  #       page = %Page{
  #         original_url: @original_url,
  #         website_url: "http://example.com",
  #       }
  #
  #       assert Page.new(@original_url) == {:ok, page}
  #     end
  #   end
  #
  #   test "returns error tuple when final location is invalid" do
  #     with_mock LinkPreviewGenerator.Requests, [final_location: fn(_url) -> {:error, :reason} end] do
  #       assert Page.new(@original_url) == {:error, :reason}
  #     end
  #   end
  # end

end
