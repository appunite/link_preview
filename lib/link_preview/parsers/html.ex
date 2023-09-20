defmodule LinkPreview.Parsers.Html do
  @moduledoc """
    Parser implementation based on html tags.
  """
  alias LinkPreview.{Page, ParallelHelper, Requests}

  use LinkPreview.Parsers.Basic

  @doc """
    Get page title based on first encountered title tag.

    Config options:
    * `:friendly_strings`\n
      see `LinkPreview.Parsers.Basic.maybe_friendly_string/1` function\n
      default: true
  """
  def title(page, body) do
    title =
      body
      |> Floki.parse_document()
      |> Floki.find("title")
      |> List.first()
      |> get_text

    %Page{page | title: title}
  end

  @doc """
    Get page description based on first encountered h1..h6 tag.

    Preference: h1> h2 > h3 > h4 > h5 > h6

    Config options:
    * `:friendly_strings`\n
      see `LinkPreview.Parsers.Basic.maybe_friendly_string/1` function\n
      default: true
  """
  def description(page, body) do
    description = search_h(body, 1)

    %Page{page | description: description}
  end

  @doc """
    Get images based on img tags.

    Config options:
    * `:force_images_absolute_url`\n
      try to add website url from `LinkPreview.Page` struct to all
      relative urls then remove remaining relative urls from list\n
      default: false
    * `:force_images_url_schema`\n
      try to add http:// to urls without schema then remove all invalid urls\n
      default: false
    * `:filter_small_images`\n
      if set to true it filters images with at least one dimension smaller
      than 100px\n
      if set to integer value it filters images with at least one dimension
      smaller than that integer\n
      requires Mogrify and Tempfile optional packages and imagemagick to be installed on machine\n
      default: false
    \n
    WARNING: Using these options may reduce performance. To prevent very long processing time
    images limited to first 50 by design.
  """
  def images(page, body) do
    images =
      body
      |> Floki.parse_document()
      |> Floki.attribute("img", "src")
      |> Enum.map(&String.trim(&1))
      |> maybe_limit
      |> maybe_force_absolute_url(page)
      |> maybe_force_url_schema
      |> maybe_validate
      |> maybe_filter_small_images
      |> Enum.map(&%{url: &1})

    %Page{page | images: images}
  end

  defp get_text(nil), do: nil

  defp get_text(choosen) do
    choosen |> Floki.text() |> maybe_friendly_string()
  end

  defp search_h(_body, 7), do: nil

  defp search_h(body, level) do
    description =
      body
      |> Floki.parse_document()
      |> Floki.find("h#{level}")
      |> List.first()
      |> get_text

    case description do
      nil -> search_h(body, level + 1)
      "" -> search_h(body, level + 1)
      _ -> description
    end
  end

  defp maybe_limit(urls) do
    cond do
      Application.get_env(:link_preview, :force_images_absolute_url) ->
        urls |> Enum.take(50)

      Application.get_env(:link_preview, :force_images_url_schema) ->
        urls |> Enum.take(50)

      Application.get_env(:link_preview, :filter_small_images) ->
        urls |> Enum.take(50)

      true ->
        urls
    end
  end

  defp maybe_filter_small_images(urls) do
    case Application.get_env(:link_preview, :filter_small_images) do
      nil ->
        urls

      false ->
        urls

      true ->
        urls
        |> ParallelHelper.map(&filter_small_image(&1, 100))
        |> Enum.reject(&is_nil(&1))

      value ->
        urls
        |> ParallelHelper.map(&filter_small_image(&1, value))
        |> Enum.reject(&is_nil(&1))
    end
  end

  defp filter_small_image(url, min_size) do
    with true <- Code.ensure_loaded?(Mogrify),
         true <- Code.ensure_loaded?(Tempfile),
         {:ok, %Tesla.Env{body: body}} <- Requests.get(url),
         {:ok, tempfile_path} <- Tempfile.random("link_preview"),
         :ok <- File.write(tempfile_path, body),
         %Mogrify.Image{} = raw <- Mogrify.open(tempfile_path),
         %Mogrify.Image{width: width, height: height} <- Mogrify.verbose(raw),
         smaller_dimension <- Enum.min([width, height]),
         true <- smaller_dimension > min_size do
      url
    else
      _ -> nil
    end
  catch
    # filter url if mogrify cannot collect its size data
    _, _ ->
      nil
  end
end
