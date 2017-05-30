defmodule LinkPreview.Requests do
  @moduledoc """
    Module providing functions to handle needed requests.
  """
  use Tesla, docs: false, only: ~w(get head)a

  adapter :httpc, [body_format: :binary]
  plug Tesla.Middleware.Tuples
  plug Tesla.Middleware.BaseUrl, "http://"
  plug Tesla.Middleware.DecompressResponse
  plug Tesla.Middleware.FollowRedirects

  @doc """
    Check if given url leads to image.
  """
  @spec image?(String.t) :: boolean
  def image?(url) do
    case head(url) do
      {:ok, %Tesla.Env{status: 200, headers: headers}} ->
        String.match?(headers["content-type"], ~r/\Aimage\//)
      {:ok, %Tesla.Env{}} ->
        false
      {:error, %Tesla.Error{}} ->
        false
    end
  end
end
