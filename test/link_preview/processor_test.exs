defmodule LinkPreview.ProcessorTest do
  use LinkPreview.Case
  alias LinkPreview.Parsers.{Opengraph, Html}

  import Mock

  describe "call when url leads to html" do
    setup [:reset_defaults]

    test "ignores missing parsers and returns Page" do
      with_mock LinkPreview.Requests, [:passthrough], [
        get:  fn(_)-> %Tesla.Env{status: 200, body: @opengraph} end,
        head: fn(_)-> %Tesla.Env{status: 200, headers: %{"content-type" => "text/html"}} end
      ] do
        Application.put_env(:link_preview, :parsers, [Opengraph, Html, MissingOne])

        assert {:ok, %LinkPreview.Page{}} = LinkPreview.Processor.call(@httparrot <> "/image")
      end
    end
  end

  describe "call when url leads to image" do
    test "returns Page" do
      assert {:ok, %LinkPreview.Page{}} = LinkPreview.Processor.call(@httparrot <> "/image")
    end
  end

  describe "call when url leads to unsupported format" do
    test "returns Error" do
      assert {:error, %LinkPreview.Error{}} = LinkPreview.Processor.call(@httparrot <> "/robots.txt")
    end
  end

  defp reset_defaults(opts) do
    on_exit fn ->
      Application.put_env(:link_preview, :parsers, nil)
    end

    {:ok, opts}
  end
end
