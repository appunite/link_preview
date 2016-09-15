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

  @doc """
    Get page images based on og:image property.
  """
  def images(page, body) do
    images =
      body
      |> Floki.find("[property=og:image]")
      |> Floki.attribute("content")
      |> Enum.map(&(%{url: &1}))

    page |> update_images(images)
  end
end
