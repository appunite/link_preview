defmodule LinkPreview.Parsers.Basic do
  @moduledoc """
    Basic Parser implementation.

    It provides overridable parsing functions that returns unchanged input
    `LinkPreview.Page.t` struct. Main reason behind this is to let
    parsers work without need to implement all possible parsing functions.
    See `__using__/1` macro.

    All parsing functions should take `LinkPreview.Page.t` and
    String with response body for parsed url as params and returns
    `LinkPreview.Page.t` as result.
  """
  alias LinkPreview.Page

  @parsable [:title, :description, :images]

  @doc """
    This macro should be invoked in all non-basic parsers.
  """
  defmacro __using__(_opts) do
    quote do
      import LinkPreview.Parsers.Util

      @doc """
        For more details see `LinkPreview.Parsers.Basic` moduledoc
      """
      @spec title(Page.t, String.t) :: Page.t
      def title(%Page{} = page, body), do: page

      @doc """
        For more details see `LinkPreview.Parsers.Basic` moduledoc
      """
      @spec description(Page.t, String.t) :: Page.t
      def description(%Page{} = page, body), do: page

      @doc """
        For more details see `LinkPreview.Parsers.Basic` moduledoc
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
end
