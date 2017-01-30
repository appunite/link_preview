defmodule LinkPreview.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      @httparrot "http://localhost:#{Application.get_env(:httparrot, :http_port)}"

      @opengraph File.read!("test/fixtures/opengraph_example.html")
      @html File.read!("test/fixtures/html_example.html")
      @image_spam File.read!("test/fixtures/html_image_spam_example.html")

    end
  end
end
