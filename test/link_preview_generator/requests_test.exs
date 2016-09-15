defmodule LinkPreviewGenerator.RequestsTest do
  alias LinkPreviewGenerator.{Page, Requests}
  alias HTTPoison.Response

  use ExUnit.Case

  import Mock

  @url "http://example.com/"
  @location "http://example2.com/"

  @ok %Response{status_code: 200}
  @bad_request %Response{status_code: 400}
  @moved_permamently %Response{status_code: 301, headers: [{"Location", @location}]}
  @found %Response{status_code: 302, headers: [{"location", @location}]}

  @redirect_without_location %Response{status_code: 301}

  describe "#handle_redirects" do
    test "returns success tuple if response status is 200" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @ok} end] do
        assert Requests.handle_redirects(@url, @url) == {:ok, @ok, Page.new(@url, @url)}
      end
    end

    test "returns error tuple if Requests module doesn't support given status code" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @bad_request} end] do
        assert Requests.handle_redirects(@url, @url) == {:error, :unprocessable_response}
      end
    end

    test "returns success tuple after successful 301 redirect" do
      with_mock HTTPoison, [get: fn(url) -> moved_permamently_helper(url) end] do
        assert Requests.handle_redirects(@url, @url) == {:ok, @ok, Page.new(@location, @url)}
      end
    end

    test "returns success tuple after successful 302 redirect" do
      with_mock HTTPoison, [get: fn(url) -> found_helper(url) end] do
        assert Requests.handle_redirects(@url, @url) == {:ok, @ok, Page.new(@location, @url)}
      end
    end

    test "returns error tuple if redirect is missing location header" do
      with_mock HTTPoison, [get: fn(_url) -> {:ok, @redirect_without_location} end] do
        assert Requests.handle_redirects(@url, @url) == {:error, :unknown_location}
      end
    end
  end

  defp moved_permamently_helper(url) do
    case url do
      @url -> {:ok, @moved_permamently}
      @location -> {:ok, @ok}
    end
  end

  defp found_helper(url) do
    case url do
      @url -> {:ok, @found}
      @location -> {:ok, @ok}
    end
  end

end
