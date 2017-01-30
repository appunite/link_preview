defmodule LinkPreview.Page do
  @moduledoc """
    Provides struct to store results of data processing and helper function
    to initialize it.
  """

  defstruct [
    original_url: nil,
    website_url:  nil,
    title:        nil,
    description:  nil,
    images:       []
  ]

  @type image_map  :: %{url: String.t}
  @type image_list :: [image_map | image_list] | []

  @type t :: %__MODULE__{
    original_url: String.t | nil,
    website_url:  String.t | nil,
    title:        String.t | nil,
    description:  String.t | nil,
    images:       image_list
  }

  @doc """
    Initializes Page struct based on original url provided by user
  """
  @spec new(String.t) :: t
  def new(original_url) do
    %__MODULE__{
      original_url: original_url,
      website_url: website_url(original_url)
    }
  end

  defp website_url(original_url) do
    final_location = LinkPreview.Requests.final_location(original_url)

    (final_location || original_url)
    |> remove_suffix
    |> remove_prefix
  end

  defp remove_suffix(url) do
    suffix = cond do
      String.match?(url, ~r/\Ahttp(s)?:\/\/([^\/]+\.)+[^\/]+/) ->
        String.replace(url, ~r/\Ahttp(s)?:\/\/([^\/]+\.)+[^\/]+/, "")
      String.match?(url, ~r/\A(\/)?([^\/]+\.)+[^\/]+/) ->
        String.replace(url, ~r/\A(\/)?([^\/]+\.)+[^\/]+/, "")
      :else ->
        ""
    end

    url |> String.replace_suffix(suffix, "")
  end

  defp remove_prefix(url) do
    String.replace(url, ~r/\A(http(s)?:\/\/)?(www\.)?/, "")
  end
end
