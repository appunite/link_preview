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
    Initializes Page struct based on original url provided by user
  """
  @spec new(String.t) :: t | {:error, atom}
  def new(original_url) do
    case LinkPreviewGenerator.Requests.final_location(original_url) do
      {:ok, location} ->
        page = %__MODULE__{
          original_url: original_url,
          website_url: website_url(location)
        }

        {:ok, page}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp website_url(url) do
    path = cond do
      String.match?(url, ~r/\Ahttp(s)?:\/\/([^\/]+\.)+[^\/]+/) ->
        String.replace(url, ~r/\Ahttp(s)?:\/\/([^\/]+\.)+[^\/]+/, "")
      String.match?(url, ~r/\A([^\/]+\.)+[^\/]+/) ->
        String.replace(url, ~r/\A([^\/]+\.)+[^\/]+/, "")
    end

    url |> String.replace_suffix(path, "")
  end
end
