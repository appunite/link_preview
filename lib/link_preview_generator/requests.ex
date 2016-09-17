defmodule LinkPreviewGenerator.Requests do
  @moduledoc """
    Module providing functions to handle needed requests.
  """
  alias LinkPreviewGenerator.Page

  @type t :: {:ok, HTTPoison.Response.t, LinkPreviewGenerator.t}

  @doc """
    After all redirects returns response and newly generated
    `LinkPreviewGenerator.Page` struct.
  """
  @spec handle_redirects(String.t | LinkPreviewGenerator.failure, String.t) :: t | LinkPreviewGenerator.failure
  def handle_redirects(url, original_url \\ nil)
  def handle_redirects({:error, reason}, _original_url), do: {:error, reason}
  def handle_redirects(url, original_url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 301} = response} ->
        location = response |> Map.get(:headers) |> get_location

        handle_redirects(location, original_url || url)
      {:ok, %HTTPoison.Response{status_code: 302} = response} ->
        location = response |> Map.get(:headers) |> get_location

        handle_redirects(location, original_url || url)
      {:ok, %HTTPoison.Response{status_code: 200} = response} ->
        {:ok, response, Page.new(url, original_url)}
      _ ->
        {:error, :unprocessable_response}
    end
  end

  @doc """
    Check if given url leads somewhere
  """
  @spec valid?(String.t) :: {:ok, String.t} | {:error, atom}
  def valid?(url) do
    case HTTPoison.head(url, [], follow_redirect: true, timeout: 200) do
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok, url}
      _ ->
        {:error, :invalid_url}
    end
  end

  @doc """
    Check if given url leads to image
  """
  @spec valid_image?(String.t) :: {:ok, String.t} | {:error, atom}
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

  defp get_location(headers) do
    cond do
      List.keymember?(headers, "Location", 0) ->
        headers |> List.keyfind("Location", 0) |> elem(1)
      List.keymember?(headers, "location", 0) ->
        headers |> List.keyfind("location", 0) |> elem(1)
      true ->
        {:error, :unknown_location}
    end
  end
end
