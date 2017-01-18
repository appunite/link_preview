defmodule LinkPreviewGenerator.ProcessorTest do
  use ExUnit.Case

  @http "http://localhost:#{Application.get_env(:httparrot, :http_port)}"

  describe "call" do
    test "when url leads to image" do
      %LinkPreviewGenerator.Page{
        title: nil,
        description: nil,
        original_url: original_url,
        website_url: website_url,
        images: images
      } = LinkPreviewGenerator.Processor.call(@http <> "/image")

      assert original_url
      assert website_url
      refute Enum.empty?(images)
    end
  end

end
