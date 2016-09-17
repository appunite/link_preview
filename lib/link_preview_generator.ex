defmodule LinkPreviewGenerator do
  use Application
  @moduledoc """
    Simple package for link previews.
  """

  @type success :: {:ok, LinkPreviewGenerator.Page.t}
  @type failure :: {:error, atom}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Chatbot.Worker, [arg1, arg2, arg3]),
    ]

    opts = [strategy: :one_for_one, name: LinkPreviewGenerator.Supervisor]
    Supervisor.start_link(children, opts)
  end


  @doc """
    Returns result of processing.
  """
  @spec parse(String.t) :: success | failure
  def parse(url) do
    LinkPreviewGenerator.Processor.call(url)
  end
end
