defmodule LinkPreviewGenerator.Parsers.Html do
  @moduledoc """
    TODO
  """
  use LinkPreviewGenerator.Parsers.Basic

  def title(page, body) do
    title =
      body
      |> Floki.find("title")
      |> List.first
      |> get_text

    page |> update_title(title)
  end

  def description(page, body) do
    description = search_h(body, 1)

    page |> update_description(description)
  end

  def images(page, body) do
    images = map_image_urls(body, page.host_url)

    page |> update_images(images)
  end

  defp map_image_urls(body, host_url) do
    body
    |> Floki.attribute("img", "src")
    |> Enum.map(&force_absolute_url(&1, host_url))
    |> Enum.map(&(%{url: &1}))
  end

  defp force_absolute_url(url, host_url) do
    case Regex.match?(~r/.+\..+\/.+/, url) do
      true -> url
      false -> host_url <> url
    end
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
  defp get_text(choosen), do: choosen |> Floki.text
end
