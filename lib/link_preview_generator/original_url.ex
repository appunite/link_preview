defmodule LinkPreviewGenerator.OriginalUrl do
  @moduledoc """
    TODO
  """

  @type t :: {:ok, String.t}

  @doc """
    TODO
  """
  @spec normalize_if_allowed(String.t) :: t | LinkPreviewGenerator.failure
  def normalize_if_allowed(url) do
    if Application.get_env(:link_preview_generator, :normalize_urls, false) do
      normalize(url)
    else
      {:ok, url}
    end
  end

  defp normalize(url) do
    case URI.parse(url) do
      %URI{scheme: nil, host: host, path: nil}  ->
        normalize("http://" <> host)
      %URI{scheme: nil, host: nil, path: path} ->
        normalize("http://" <> path)
      %URI{scheme: nil, host: host, path: path} ->
        normalize("http://" <> host <> path)
      %URI{path: nil} ->
        normalize(url <> "/")
      %URI{host: nil} ->
        {:error, :normalization_failed}
      _ ->
        {:ok, url}
    end
  end
end