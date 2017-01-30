defmodule LinkPreview.Parsers.Image do
  @moduledoc """
    Parser implementation for situation when url leads to image.
  """
  alias LinkPreview.Page

  use LinkPreview.Parsers.Basic

  @doc """
    Set page original_url as image_url.
  """
  def images(page, _body) do
    %Page{page | images: [%{url: page.original_url}]}
  end
end
