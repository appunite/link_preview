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
      |> maybe_friendly_string()

    %Page{page | description: description}
  end

  @doc """
    Get page images based on og:image property.

    Config options:
    * `:force_images_absolute_url`\n
      try to add website url from `LinkPreview.Page` struct to all
      relative urls then remove remaining relative urls from list\n
      default: false
    * `:force_images_url_schema`\n
      try to add http:// to urls without schema then remove all invalid urls\n
      default: false
    \n
    WARNING: Using these options may reduce performance. To prevent very long processing time
    images limited to first 50 by design.
  """
  def images(page, body) do
    images =
      body
      |> Floki.parse()
      |> Floki.find("meta[property=\"og:image\"]")
      |> Floki.attribute("content")
      |> Enum.map(&String.trim(&1))
      |> maybe_force_absolute_url(page)
      |> maybe_force_url_schema
      |> maybe_validate
      |> Enum.map(&(%{url: &1}))

    %Page{page | images: images}
  end
end
