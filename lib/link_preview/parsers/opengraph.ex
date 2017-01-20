defmodule LinkPreview.Parsers.Opengraph do
  @moduledoc """
    Parser implementation based on opengraph.
  """
  alias LinkPreview.Page

  use LinkPreview.Parsers.Basic

  @doc """
    Get page title based on first encountered og:title property.

    Config options:
    * `:friendly_strings`\n
      see `LinkPreview.Parsers.Basic.maybe_friendly_string/1` function\n
      default: true
  """
  def title(page, body) do
    title =
      body
      |> Floki.parse()
      |> Floki.find("meta[property^=\"og:title\"]")
      |> Floki.attribute("content")
      |> List.first()
      |> maybe_friendly_string()

    %Page{page | title: title}
  end

  @doc """
    Get page description based on first encountered og:description property.

    Config options:
    * `:friendly_strings`\n
      see `LinkPreview.Parsers.Basic.maybe_friendly_string/1` function\n
      default: true
  """
  def description(page, body) do
    description =
      body
      |> Floki.parse()
      |> Floki.find("meta[property^=\"og:description\"]")
      |> Floki.attribute("content")
      |> List.first()

    %Page{page | description: description}
  end

  @doc """
    Get page images based on og:image property.
  """
  def images(page, body) do
    images =
      body
      |> Floki.parse()
      |> Floki.find("meta[property^=\"og:image\"]")
      |> Floki.attribute("content")
      |> Enum.map(&String.trim(&1))
      |> Enum.map(&(%{url: &1}))

    %Page{page | images: images}
  end
end
