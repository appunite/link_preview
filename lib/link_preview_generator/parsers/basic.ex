defmodule LinkPreviewGenerator.Parsers.Basic do
  @moduledoc """
    Basic Parser implementation.

    It provides overridable parsing functions that returns unchanged input
    `LinkPreviewGenerator.Page.t` struct. Main reason behind this is to let
    parsers work without need to implement all possible parsing functions.
    See `__using__/1` macro.

    All parsing functions should take `LinkPreviewGenerator.Page.t` and
    String with response body for parsed url as params and returns
    `LinkPreviewGenerator.Page.t` as result.
  """
  alias LinkPreviewGenerator.Page

  @parsable [:title, :description, :images]

  @doc """
    This macro should be invoked in all non-basic parsers.
  """
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [maybe_friendly_string: 1]

      @doc """
        For more details see `LinkPreviewGenerator.Parsers.Basic` moduledoc
      """
      @spec title(Page.t, String.t) :: Page.t
      def title(%Page{} = page, body), do: page

      @doc """
        For more details see `LinkPreviewGenerator.Parsers.Basic` moduledoc
      """
      @spec description(Page.t, String.t) :: Page.t
      def description(%Page{} = page, body), do: page

      @doc """
        For more details see `LinkPreviewGenerator.Parsers.Basic` moduledoc
      """
      @spec images(Page.t, String.t) :: Page.t
      def images(%Page{} = page, body), do: page

      defoverridable [title: 2, description: 2, images: 2]
    end
  end

  @doc """
    Returns list of parsable values.
  """
  @spec parsable :: list
  def parsable, do: @parsable

  @doc """
    Removes leading and trailing whitespaces.\n
    Changes rest of newline characters to space and replace all multiple
    spaces by single space.\n
    If HtmlEntities optional package is loaded then decodes html entities,
    e.g. &quot
  """
  @spec maybe_friendly_string(String.t) :: String.t
  def maybe_friendly_string(text) do
    if Application.get_env(:link_preview_generator, :friendly_strings, true) do
      text
      |> String.trim
      |> String.replace(~r/\n|\r|\r\n/, " ")
      |> String.replace(~r/\ +/, " ")
      |> decode_html()
    else
      text
    end
  end

  defp decode_html(text) do
    if Code.ensure_loaded?(HtmlEntities) do
      text |> HtmlEntities.decode()
    else
      text
    end
  end
end
