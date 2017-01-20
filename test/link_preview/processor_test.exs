defmodule LinkPreview.ProcessorTest do
  use ExUnit.Case
  alias LinkPreview.Parsers.{Opengraph, Html}

  import Mock

  @http "http://localhost:#{Application.get_env(:httparrot, :http_port)}/"
  @opengraph File.read!("test/fixtures/opengraph_example.html")

  describe "call when url leads to html" do
    setup [:reset_defaults]

    test "ignores missing parsers and returns Page" do
      with_mock LinkPreview.Requests, [:passthrough], [
        get:  fn(_)-> %Tesla.Env{status: 200, body: @opengraph} end,
        head: fn(_)-> %Tesla.Env{status: 200, headers: %{"content-type" => "text/html"}} end
      ] do
        Application.put_env(:link_preview, :parsers, [Opengraph, Html, MissingOne])

        assert %LinkPreview.Page{} = LinkPreview.Processor.call(@http <> "image")
      end
    end
  end

  describe "call when url leads to image" do
    test "returns Page" do
      assert %LinkPreview.Page{} = LinkPreview.Processor.call(@http <> "image")
    end
  end

  describe "call when url leads to unsupported format" do
    test "returns Error" do
      assert %LinkPreview.Error{} = LinkPreview.Processor.call(@http <> "robots.txt")
    end
  end

  defp reset_defaults(opts) do
    on_exit fn ->
      Application.put_env(:link_preview, :parsers, nil)
    end

    {:ok, opts}
  end
end
