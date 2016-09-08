defmodule LinkPreviewGenerator.Redirects do
  @moduledoc """
    TODO
  """
  alias LinkPreviewGenerator.Page

  @type t :: {:ok, HTTPoison.Response.t, LinkPreviewGenerator.t}

  @doc """
    TODO
  """
  @spec handle(String.t | LinkPreviewGenerator.failure, String.t) :: t | LinkPreviewGenerator.failure
  def handle({:error, reason}, _original_url), do: {:error, reason}
  def handle(url, original_url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 301} = response} ->
        location = response |> Map.get(:headers) |> get_location

        handle(location, original_url || url)
      {:ok, %HTTPoison.Response{status_code: 302} = response} ->
        location = response |> Map.get(:headers) |> get_location

        handle(location, original_url || url)
      {:ok, %HTTPoison.Response{status_code: 200} = response} ->
        {:ok, response, Page.new(url, original_url)}
      _ ->
        {:error, :unprocessable_response}
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
