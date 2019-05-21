defmodule LinkPreview do
  @moduledoc """
    Simple package for link previews.
  """

  @type success :: {:ok, LinkPreview.Page.t()}
  @type failure :: {:error, LinkPreview.Error.t()}

  @spec create(String.t()) :: success | failure
  defdelegate create(url), to: LinkPreview.Processor, as: :call

  @doc """
    Similar to `create/1`, but returns struct instead of tuple and raises
    error when it fails.
  """
  @spec create!(String.t()) :: LinkPreview.Page.t() | no_return
  def create!(url) do
    case LinkPreview.Processor.call(url) do
      {:ok, page} ->
        page

      {:error, error} ->
        raise error
    end
  end
end
