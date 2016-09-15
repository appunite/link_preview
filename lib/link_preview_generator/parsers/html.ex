defmodule LinkPreviewGenerator.Parsers.Html do
  @moduledoc """
    Parser implementation based on html tags.
  """
  use LinkPreviewGenerator.Parsers.Basic

  @doc """
    Get page title based on first encountered title tag.

    Config options:
    * :friendly_strings - remove leading and trailing whitespaces, change
      rest of newline characters to space and replace all multiple spaces
      by single space;
      default: true
  """
  def title(page, body) do
    title =
      body
      |> Floki.find("title")
      |> List.first
      |> get_text

    page |> update_title(title)
  end

  @doc """
    Get page description based on first encountered h1..h6 tag.

    Preference: h1> h2 > h3 > h4 > h5 > h6

    Config options:
    * :friendly_strings - remove leading and trailing whitespaces, change
      rest of newline characters to space and replace all multiple spaces
      by single space;
      default: true
  """
  def description(page, body) do
    description = search_h(body, 1)

    page |> update_description(description)
  end

  @doc """
    Get images based on img tags.

    Config options:
    * :force_images_absolute_url - try to add website url from `LinkPreviewGenerator.Page`
      struct to all relative urls, then remove remaining relative urls from list;
      default: false
  """
  def images(page, body) do
    images = if Application.get_env(:link_preview_generator, :force_images_absolute_url, false) do
      map_image_urls(body, page.website_url)
    else
      map_image_urls(body)
    end

    page |> update_images(images)
  end

  defp map_image_urls(body) do
    body
    |> Floki.attribute("img", "src")
    |> Enum.map(&(%{url: &1}))
  end

  defp map_image_urls(body, website_url) do
    body
    |> Floki.attribute("img", "src")
    |> Enum.map(&force_absolute_url(&1, website_url))
    |> Enum.reject(&Kernel.is_nil(&1))
    |> Enum.map(&(%{url: &1}))
  end

  defp force_absolute_url(url, website_url) do
    #TODO better implementation
  end

  defp search_h(_body, 7), do: nil
  defp search_h(body, level) do
    description =
      body
      |> Floki.find("h#{level}")
      |> List.first
      |> get_text

    description || search_h(body, level + 1)
  end

  defp get_text(nil), do: nil
  defp get_text(choosen) do
    if Application.get_env(:link_preview_generator, :friendly_strings, true) do
      choosen |> Floki.text |> String.trim |> String.replace(~r/\n|\r|\r\n/, " ") |> String.replace(~r/\ +/, " ")
    else
      choosen |> Floki.text
    end
  end
end
