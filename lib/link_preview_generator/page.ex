defmodule LinkPreviewGenerator.Page do
  @moduledoc """
    Provides struct to store results of data processing and helper function
    to initialize it.
  """

  defstruct [:original_url, :host_url, :title, :description, :images]

  @type t :: %__MODULE__{
    original_url: String.t | nil,
    host_url: String.t | nil,
    title: String.t | nil,
    description: String.t | nil,
    images: list
  }

  @doc """
    Initializes Page struct based on current and original url.

    Args:
    * `current_url` - final url after redirects and/or normalization
    * `original_url` - original url provided by user
  """
  @spec new(String.t, String.t) :: t
  def new(current_url, original_url) do
    %__MODULE__{
      original_url: original_url,
      host_url: fetch_host(current_url),
      images: []
    }
  end

  defp fetch_host(url) do
    url |> URI.parse |> Map.get(:host)
  end
end
