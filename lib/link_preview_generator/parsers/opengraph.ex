defmodule LinkPreviewGenerator.Parsers.Opengraph do
  @moduledoc """
    Parser implementation based on opengraph.
  """
  use LinkPreviewGenerator.Parsers.Basic

  @doc """
    Get page title based on first encountered og:title property.
  """
  def title(page, body) do
    title =
      body
      |> Floki.find("[property=og:title]")
      |> Floki.attribute("content")
      |> List.first

    page |> update_title(title)
  end

  @doc """
    Get page description based on first encountered og:description property.
  """
  def description(page, body) do
    description =
      body
      |> Floki.find("[property=og:description]")
      |> Floki.attribute("content")
      |> List.first

    page |> update_description(description)
  end

  #TODO it shouldn't be restricted to first
  @doc """
    Get page image based on first encountered og:image property.
  """
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
