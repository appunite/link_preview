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

  describe "final_location/1" do
    test "when given url returns status 200" do
      url = @httparrot <> "/status/200"

      assert Requests.final_location(url) == url
    end

    test "when given url redirects to 200" do
      redirect_to = @httparrot <> "/status/200"
      url = @httparrot <> "/redirect-to?url=" <> redirect_to

      assert Requests.final_location(url) == redirect_to
    end

    test "when given url returns status 4xx" do
      url = @httparrot <> "/status/404"

      refute Requests.final_location(url)
    end

    test "when given url redirects to status 4xx" do
      redirect_to = @httparrot <> "/status/403"
      url = @httparrot <> "/redirect-to?url=" <> redirect_to

      refute Requests.final_location(url)
    end
  end
end
