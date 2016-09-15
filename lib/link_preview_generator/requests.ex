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
    Check if given url leads to response with non-empty body
  """
  @spec valid?(String.t) :: {:ok, String.t} | {:error, atom}
  def valid?(url) do
    case HTTPoison.get(url, [], follow_redirect: true) do
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      {:ok, %HTTPoison.Response{body: nil}} ->
        {:error, :missing_body}
      {:ok, %HTTPoison.Response{body: ""}} ->
        {:error, :missing_body}
      {:ok, %HTTPoison.Response{}} ->
        {:ok, url}
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
