defmodule LinkPreviewGenerator.Parsers.Opengraph do
  @moduledoc """
    TODO
  """
  use LinkPreviewGenerator.Parsers.Basic

  def title(page, body) do
    title =
      body
      |> Floki.find("[property=og:title]")
      |> Floki.attribute("content")
      |> List.first

    page |> update_title(title)
  end

  def description(page, body) do
    description =
      body
      |> Floki.find("[property=og:description]")
      |> Floki.attribute("content")
      |> List.first

    page |> update_description(description)
  end

  def images(page, body) do
    image_url =
      body
      |> Floki.find("[property=og:image]")
      |> Floki.attribute("content")
      |> List.first

    page |> update_image(image_url)
  end

  defp update_image(page, nil), do: page
  defp update_image(page, url), do: update_images(page, [%{url: url}])
end
