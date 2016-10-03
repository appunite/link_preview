defmodule LinkPreviewGenerator.Parsers.Html do
  @moduledoc """
    Parser implementation based on html tags.
  """
  alias LinkPreviewGenerator.{Page, ParallelHelper, Requests}

  use LinkPreviewGenerator.Parsers.Basic

  @doc """
    Get page title based on first encountered title tag.

    Config options:
    * `:friendly_strings` - remove leading and trailing whitespaces, change
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

    %Page{page | title: title}
  end

  @doc """
    Get page description based on first encountered h1..h6 tag.

    Preference: h1> h2 > h3 > h4 > h5 > h6

    Config options:
    * `:friendly_strings` - remove leading and trailing whitespaces, change
      rest of newline characters to space and replace all multiple spaces
      by single space;
      default: true
  """
  def description(page, body) do
    description = search_h(body, 1)

    %Page{page | description: description}
  end

  @doc """
    Get images based on img tags.

    Config options:
    * `:force_images_absolute_url` - try to add website url from `LinkPreviewGenerator.Page`
      struct to all relative urls, then remove remaining relative urls from list;
      default: false
    * `:force_images_url_schema` - try to add http:// to urls without schema, then remove
      all invalid urls;
      default: false
    * `:filter_small_images` - if set to true it filters images with at least one dimension
      smaller than 100px;
      if set to integer value it filters images with at least one dimension smaller than that
      integer;
      requires imagemagick to be installed on machine;
      default: false;

    <br>
    WARNING: Using these options may reduce performance. To prevent very long processing time
    images limited to first 50 by design.
  """
  def images(page, body) do
    images =
      body
      |> Floki.attribute("img", "src")
      |> limit_if_needed
      |> check_force_absolute_url(page)
      |> check_force_url_schema
      |> validate_if_needed
      |> check_filter_small_images
      |> Enum.map(&String.trim(&1))
      |> Enum.map(&(%{url: &1}))

    %Page{page | images: images}
  end

  defp get_text(nil), do: nil
  defp get_text(choosen) do
    if Application.get_env(:link_preview_generator, :friendly_strings, true) do
      choosen |> Floki.text |> String.trim |> String.replace(~r/\n|\r|\r\n/, " ") |> String.replace(~r/\ +/, " ")
    else
      choosen |> Floki.text
    end
  end

  defp search_h(_body, 7), do: nil
  defp search_h(body, level) do
    description =
      body
      |> Floki.find("h#{level}")
      |> List.first
      |> get_text

    case description do
      nil -> search_h(body, level + 1)
      "" -> search_h(body, level + 1)
      _ -> description
    end
  end

  defp limit_if_needed(urls) do
    cond do
      Application.get_env(:link_preview_generator, :force_images_absolute_url) ->
        urls |> Enum.take(50)
      Application.get_env(:link_preview_generator, :force_images_url_schema) ->
        urls |> Enum.take(50)
      Application.get_env(:link_preview_generator, :filter_small_images) ->
        urls |> Enum.take(50)
      true ->
        urls
    end
  end

  defp check_force_absolute_url(urls, page) do
    if Application.get_env(:link_preview_generator, :force_images_absolute_url) do
      urls
      |> Enum.map(&force_absolute_url(&1, page.website_url))
    else
      urls
    end
  end

  defp check_force_url_schema(urls) do
    if Application.get_env(:link_preview_generator, :force_images_url_schema) do
      urls
      |> Enum.map(&force_schema(&1))
    else
      urls
    end
  end

  defp validate_if_needed(urls) do
    cond do
      Application.get_env(:link_preview_generator, :force_images_absolute_url) ->
        urls |> validate_images
      Application.get_env(:link_preview_generator, :force_images_url_schema) ->
        urls |> validate_images
      Application.get_env(:link_preview_generator, :filter_small_images) ->
        urls |> validate_images
      true ->
        urls
    end
  end

  defp check_filter_small_images(urls) do
    case Application.get_env(:link_preview_generator, :filter_small_images) do
      nil ->
        urls
      false ->
        urls
      true ->
        urls
        |> ParallelHelper.map(&filter_small_images(&1, 100))
        |> Enum.reject(&Kernel.is_nil(&1))
      value ->
        urls
        |> ParallelHelper.map(&filter_small_images(&1, value))
        |> Enum.reject(&Kernel.is_nil(&1))
    end
  end

  defp force_absolute_url(url, website_url) do
    with           false <- String.match?(url, ~r/\A(http(s)?:\/\/)?([^\/]+\.)+[^\/]+/),
                  prefix <- website_url |> String.replace_suffix("/", ""),
                  suffix <- url |> String.replace_prefix("/", "")
    do
      prefix <> "/" <> suffix
    else
      true -> url
    end
  end

  defp force_schema("http://" <> _ = url), do: url
  defp force_schema("https://" <> _ = url), do: url
  defp force_schema(url), do: "http://" <> url

  defp validate_images(urls) do
    urls
    |> ParallelHelper.map(&validate_image(&1))
    |> Enum.reject(&Kernel.is_nil(&1))
  end

  defp validate_image(url) do
    case Requests.valid_image?(url) do
      {:ok, _} -> url
      {:error, _} -> nil
    end
  end

  defp filter_small_images(url, min_size) do
    with                {:ok, %Tesla.Env{body: body}} <- Requests.sget(url),
                                 {:ok, tempfile_path} <- Tempfile.random("link_preview_generator"),
                                                  :ok <- File.write(tempfile_path, body),
                               %Mogrify.Image{} = raw <- Mogrify.open(tempfile_path),
         %Mogrify.Image{width: width, height: height} <- Mogrify.verbose(raw),
                                    smaller_dimension <- Enum.min([width, height]),
                                                 true <- smaller_dimension > min_size
    do
      url
    else
      _ -> nil
    end
  catch
    #filter url if mogrify cannot collect its size data
    _, _ -> nil
  end
end
