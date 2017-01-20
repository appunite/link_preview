defmodule LinkPreview.RequestsTest do
  use ExUnit.Case
  alias LinkPreview.Requests

  @http "http://localhost:#{Application.get_env(:httparrot, :http_port)}/"

  describe "image?/1" do
    test "when url leads to image" do
      assert Requests.image?(@http <> "image")
    end

    test "when url doesn't lead to image" do
      refute Requests.image?(@http <> "get")
    end
  end

  describe "final_location/1" do
    test "when given url returns status 200" do
      url = @http <> "status/200"

      assert Requests.final_location(url) == url
    end

    test "when given url redirects to 200" do
      redirect_to = @http <> "status/200"
      url = @http <> "redirect-to?url=" <> redirect_to

      assert Requests.final_location(url) == redirect_to
    end

    test "when given url returns status 4xx" do
      url = @http <> "status/404"

      refute Requests.final_location(url)
    end

    test "when given url redirects to status 4xx" do
      redirect_to = @http <> "status/403"
      url = @http <> "redirect-to?url=" <> redirect_to

      refute Requests.final_location(url)
    end
  end
end
