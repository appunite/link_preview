defmodule LinkPreviewGenerator do
  @moduledoc """
    Simple package for link previews.
  """

  @type success :: {:ok, LinkPreviewGenerator.Page.t}
  @type failure :: {:error, atom}

  defdelegate parse(url), to: LinkPreviewGenerator.Processor, as: :call
end
