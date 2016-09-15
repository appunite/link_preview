defmodule LinkPreviewGenerator.Page do
  @moduledoc """
    Provides struct to store results of data processing and helper function
    to initialize it.
  """

  defstruct [
    original_url: nil,
    website_url: nil,
    title: nil,
    description: nil,
    images: []
  ]

  @type t :: %__MODULE__{
    original_url: String.t | nil,
    website_url: String.t | nil,
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
  @spec new(String.t, String.t | nil) :: t
  def new(current_url, original_url \\ nil) do
    %__MODULE__{
      original_url: original_url || current_url,
      website_url: website_url(current_url)
    }
  end

  def website_url(url) do
    path = cond do
      String.match?(url, ~r/\Ahttp(s)?:\/\/([^\/]+\.)+[^\/]+/) ->
        String.replace(url, ~r/\Ahttp(s)?:\/\/([^\/]+\.)+[^\/]+/, "")
      String.match?(url, ~r/\A([^\/]+\.)+[^\/]+/) ->
        String.replace(url, ~r/\A([^\/]+\.)+[^\/]+/, "")
    end

    url |> String.replace_suffix(path, "")
  end
end
