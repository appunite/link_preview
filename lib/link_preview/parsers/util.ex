defmodule LinkPreview.Parsers.Util do
  @moduledoc """
    Utility functions shared across 2 or more parsers.
  """

  alias LinkPreview.{ParallelHelper, Requests}

  @doc """
    When `:friendly_string` is set to true, given url will be converted to
    more human friedly format

    * Removes leading and trailing whitespaces.
    * Changes rest of newline characters to space and replace all multiple
      spaces by single space.
    * If HtmlEntities optional package is loaded then decodes html entities,
      e.g. &quot
  """
  @spec maybe_friendly_string(String.t | nil) :: String.t | nil
  def maybe_friendly_string(nil), do: nil
  def maybe_friendly_string(text) do
    if Application.get_env(:link_preview, :friendly_strings, true) do
      text
      |> String.trim
      |> String.replace(~r/\n|\r|\r\n/, " ")
      |> String.replace(~r/\ +/, " ")
      |> decode_html()
    else
      text
    end
  end

  @doc """
    When `:force_images_absolute_url` is set to true, website_url from page struct will
    be prepend to all relative urls. Absolute urls remain unchanged.

    Example:
      iex> page = %Page{website_url: "example.com"}

      iex> maybe_force_absolute_url(["another_page/image.jpg", "/assets/image.jpg"], page)
      ["another_page/image.jpg", "/assets/image.jpg"]

      iex> Application.put_env(:link_preview, :force_images_absolute_url, true)

      iex> maybe_force_absolute_url(["another_page/image.jpg", "/assets/image.jpg"], page)
      ["another_page/image.jpg", "example.com/assets/image.jpg"]
  """
  def maybe_force_absolute_url(urls, page) do
    if Application.get_env(:link_preview, :force_images_absolute_url) do
      urls
      |> Enum.map(&force_absolute_url(&1, page.website_url))
    else
      urls
    end
  end

  @doc """
    When `:force_images_url_schema` is set to true, `http://` will
    be prepend to all urls without schema.

    Example:
      iex> maybe_force_url_schema(["page1/image.jpg", "https:://page2/image.jpg"])
      ["page1/image.jpg", "https:://page2/image.jpg"]

      iex> Application.put_env(:link_preview, :force_images_url_schema, true)

      iex> maybe_force_url_schema(["page1/image.jpg", "https:://page2/image.jpg"])
      ["http://page1/image.jpg", "https:://page2/image.jpg"]
  """
  def maybe_force_url_schema(urls) do
    if Application.get_env(:link_preview, :force_images_url_schema) do
      urls
      |> Enum.map(&force_schema(&1))
    else
      urls
    end
  end

  @doc """
    Check if given urls leads to images when some url-changing options are
    enabled.
  """
  def maybe_validate(urls) do
    cond do
      Application.get_env(:link_preview, :force_images_absolute_url) ->
        urls |> validate_images
      Application.get_env(:link_preview, :force_images_url_schema) ->
        urls |> validate_images
      Application.get_env(:link_preview, :filter_small_images) ->
        urls |> validate_images
      true ->
        urls
    end
  end

  defp decode_html(text) do
    code = Application.get_env(:link_preview, :code_module, Code)

    if code.ensure_loaded?(HtmlEntities) do
      text |> HtmlEntities.decode()
    else
      text
    end
  end

  defp force_absolute_url(url, website_url) do
    with           false <- String.match?(url, ~r/\A((http(s)?:)?\/\/)?([^\/]+\.)+[^\/]+/),
                  prefix <- website_url |> String.replace_suffix("/", ""),
                  suffix <- url |> String.replace_prefix("/", "")
    do
      prefix <> "/" <> suffix
    else
      true -> url
    end
  end

  defp force_schema("http://" <> _ = url),  do: url
  defp force_schema("https://" <> _ = url), do: url
  defp force_schema("//" <> _ = url),       do: "http:" <> url
  defp force_schema(url),                   do: "http://" <> url

  defp validate_images(urls) do
    urls
    |> ParallelHelper.map(&validate_image(&1))
    |> Enum.reject(&is_nil(&1))
  end

  defp validate_image(url) do
    if Requests.image?(url), do: url
  end
end
