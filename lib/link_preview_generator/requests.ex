defmodule LinkPreviewGenerator.Requests do
  @moduledoc """
    Module providing functions to handle needed requests.
  """

  @type t :: {:ok, String.t} | {:error, atom}

  @doc """
    Follow redirects and returns final location.
  """
  @spec final_location(String.t) :: t
  def final_location(url) do
    case :hackney.request(:get, url, [], [], [follow_redirect: true]) do
      {:ok, _, _, client} ->
        location = :hackney.location(client)

        {:ok, location}
      _ ->
        {:error, :hackney_redirect}
    end
  end

  @doc """
    Check if given url leads to image
  """
  @spec valid_image?(String.t) :: t
  def valid_image?("/" <> _), do: {:error, :relative_url}
  def valid_image?(url) do
    with {:ok, %HTTPoison.Response{status_code: 200, headers: headers}} <- HTTPoison.head(url, [], follow_redirect: true, timeout: 200),
                                                                   true <- List.keymember?(headers, "Content-Type", 0),
                                                           content_type <- headers |> List.keyfind("Content-Type", 0) |> elem(1),
                                                                   true <- String.match?(content_type, ~r/\Aimage\//)
    do
      {:ok, url}
    else
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      _ ->
        {:error, :invalid_image}
    end
  end
end
