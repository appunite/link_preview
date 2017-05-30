defmodule LinkPreview.RequestsTest do
  use LinkPreview.Case
  alias LinkPreview.Requests

  describe "image?/1" do
    test "when url leads to image" do
      assert Requests.image?(@httparrot <> "/image")
    end

    test "when url doesn't lead to image" do
      refute Requests.image?(@httparrot <> "/get")
    end
  end
end
