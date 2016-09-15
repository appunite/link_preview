defmodule LinkPreviewGenerator do
  @moduledoc """
    Simple package for link previews.
  """

  @type success :: {:ok, LinkPreviewGenerator.Page.t}
  @type failure :: {:error, atom}

  @doc """
    Returns result of processing.
  """
  @spec parse(String.t) :: success | failure
  def parse(url) do
    LinkPreviewGenerator.Processor.call(url)
  end
end
