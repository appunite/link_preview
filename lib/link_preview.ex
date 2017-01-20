defmodule LinkPreview do
  @moduledoc """
    Simple package for link previews.
  """

  @type success :: {:ok, LinkPreview.Page.t}
  @type failure :: {:ok, LinkPreview.Error.t}

  defdelegate create(url), to: LinkPreview.Processor, as: :call

  def create!(url) do
    case LinkPreview.Processor.call(url) do
      {:ok, page} ->
        page
      {:error, error} ->
        raise error
    end
  end
end
