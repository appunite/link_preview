defmodule LinkPreviewGenerator.Requests do
  @moduledoc """
    Module providing functions to handle needed requests.
  """

  @type t :: {:ok, String.t} | {:error, atom}

  @doc """
    Function that invokes HTTPoison.get only if badarg error can not occur.
  """
  @spec get(String.t, list, list) :: {:ok, HTTPoison.Response.t} | {:error, atom}
  def get(url, headers, options) do
    case check_badargs(url) do
      :ok ->
        HTTPoison.get(url, headers, options)
      :badarg ->
        {:error, :badarg}
    end
  end

  @doc """
    Function that invokes HTTPoison.head only if badarg error can not occur.
  """
  @spec head(String.t, list, list) :: {:ok, HTTPoison.Response.t} | {:error, atom}
  def head(url, headers, options) do
    case check_badargs(url) do
      :ok ->
        HTTPoison.head(url, headers, options)
      :badarg ->
        {:error, :badarg}
    end
  end

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
  def valid_image?(url) do
    with {:ok, %HTTPoison.Response{status_code: 200, headers: headers}} <- head(url, [], follow_redirect: true, timeout: 200),
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

  defp check_badargs(url) do
    case url do
      nil ->
        :badarg
      "" ->
        :badarg
      "/" <> _ ->
        :badarg
      _ ->
        :ok
    end
  end
end
