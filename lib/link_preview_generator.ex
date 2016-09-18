defmodule LinkPreviewGenerator do
  use Application
  @moduledoc """
    Simple package for link previews.
  """

  @type success :: {:ok, LinkPreviewGenerator.Page.t}
  @type failure :: {:error, atom}

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Chatbot.Worker, [arg1, arg2, arg3]),
    ]

    opts = [strategy: :one_for_one, name: LinkPreviewGenerator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defdelegate parse(url), to: LinkPreviewGenerator.Processor, as: :call
end
