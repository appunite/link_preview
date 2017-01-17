defmodule LinkPreviewGenerator.RequestsTest do
  use ExUnit.Case
  alias LinkPreviewGenerator.{Page, Requests}

  import Mock

  @url "http://example.com/"

  # @ok %HTTPoison.Response{status_code: 200}

  # describe "#get" do
  #   test "returns success tuple when url is valid" do
  #     with_mock HTTPoison, [get: fn(_url, _h, _opts) -> {:ok, @ok} end] do
  #       assert Requests.get(@url, [], []) == {:ok, @ok}
  #     end
  #   end
  #
  #   test "returns error tuple when url can cause badarg error" do
  #     assert Requests.get("/invalid", [], []) == {:error, :badarg}
  #   end
  # end
  #
  # describe "#head" do
  #   test "returns success tuple when url is valid" do
  #     with_mock HTTPoison, [head: fn(_url, _h, _opts) -> {:ok, @ok} end] do
  #       assert Requests.head(@url, [], []) == {:ok, @ok}
  #     end
  #   end
  #
  #   test "returns error tuple when url can cause badarg error" do
  #     assert Requests.head("", [], []) == {:error, :badarg}
  #   end
  # end
end
