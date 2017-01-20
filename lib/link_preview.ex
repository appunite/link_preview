defmodule LinkPreview do
  @moduledoc """
    Simple package for link previews.
  """

  @type success :: LinkPreview.Page.t
  @type failure :: LinkPreview.Error.t

  defdelegate parse(url), to: LinkPreview.Processor, as: :call
end
