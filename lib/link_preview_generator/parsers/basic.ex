defmodule LinkPreviewGenerator.Parsers.Basic do
  @moduledoc """
    TODO
  """
  alias LinkPreviewGenerator.Page

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

  #TODO replace functions below by something more clever
  @doc false
  def update_title(%Page{title: title} = page, _new) when not is_nil(title), do: page
  def update_title(page, new),do: %Page{page | title: new}

  @doc false
  def update_description(%Page{description: description} = page, _new) when not is_nil(description), do: page
  def update_description(page, new), do: %Page{page | description: new}

  @doc false
  def update_images(%Page{images: images} = page, _new) when images != [], do: page
  def update_images(page, new), do: %Page{page | images: new}
end
