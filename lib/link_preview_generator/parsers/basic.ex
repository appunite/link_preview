defmodule LinkPreviewGenerator.Parsers.Basic do
  @moduledoc """
    Basic Parser implementation.

    It provides overridable parsing functions that returns unchanged input
    `LinkPreviewGenerator.Page.t` struct. Main reason behind this is to let
    parsers work without need to implement all possible parsing functions.
    See `__using__/1` macro.

    All parsing functions should take `LinkPreviewGenerator.Page.t` and
    `Floki.html_tree` as params and returns `LinkPreviewGenerator.Page.t`
    as result.

    Parsing function should not override result from previously invoked
    parser unless explicit configuration specifies otherwise.
  """
  alias LinkPreviewGenerator.Page

  @parsing_functions [:title, :description, :images]

  @doc """
    This macro should be invoked in all non-basic parsers.
  """
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: :functions

      @doc """
        For more details see `LinkPreviewGenerator.Parsers.Basic` moduledoc
      """
      @spec title(Page.t, Floki.html_tree) :: Page.t
      def title(%Page{} = page, parsed_body), do: page

      @doc """
        For more details see `LinkPreviewGenerator.Parsers.Basic` moduledoc
      """
      @spec description(Page.t, Floki.html_tree) :: Page.t
      def description(%Page{} = page, parsed_body), do: page

      @doc """
        For more details see `LinkPreviewGenerator.Parsers.Basic` moduledoc
      """
      @spec images(Page.t, Floki.html_tree) :: Page.t
      def images(%Page{} = page, parsed_body), do: page

      defoverridable [title: 2, description: 2, images: 2]
    end
  end

  @doc """
    Returns list of parsing functions.
  """
  @spec parsing_functions :: list
  def parsing_functions, do: @parsing_functions
end
