defmodule LinkPreviewGenerator do
  @moduledoc """
    TODO
  """

  @type success :: {:ok, LinkPreviewGenerator.Page.t}
  @type failure :: {:error, atom}

  @doc """
    TODO
  """
  @spec parse(String.t) :: success | failure
  def parse(url) do
    LinkPreviewGenerator.Processor.call(url)
  end
end
