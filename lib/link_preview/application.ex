defmodule LinkPreview.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: LinkPreview.Finch, pools: %{default: [protocol: :http1]}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: LinkPreview.Supervisor)
  end
end
