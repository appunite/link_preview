defmodule LinkPreview do
  @moduledoc """
    Simple package for link previews.
  """

  @type success :: LinkPreview.Page.t
  @type failure :: {:error, atom}

  defdelegate parse(url), to: LinkPreview.Processor, as: :call
end
