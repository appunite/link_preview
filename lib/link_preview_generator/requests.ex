defmodule LinkPreviewGenerator.Requests do
  @moduledoc """
    Module providing functions to handle needed requests.
  """
  use Tesla

  adapter :httpc, [body_format: :binary]
  plug Tesla.Middleware.BaseUrl, "http://"

  @doc """
    Check if given url leads to image.
  """
  @spec image?(String.t) :: boolean
  def image?(url) do
    %Tesla.Env{status: status, headers: headers} = head(url)

    status == 200 && String.match?(headers["content-type"], ~r/\Aimage\//)
  end

  @doc """
    Follow redirections to check final website adress.
  """
  @spec final_location(String.t) :: String.t | nil
  def final_location(url) do
    case head(url, opts: [autoredirect: false]) do
      %Tesla.Error{} ->
        nil
      %Tesla.Env{status: 200} ->
        url
      %Tesla.Env{headers: %{"location" => location}} ->
        final_location(location)
      _ ->
        nil
    end
  end
end
