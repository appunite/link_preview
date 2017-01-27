defmodule LinkPreview.Requests do
  @moduledoc """
    Module providing functions to handle needed requests.
  """
  use Tesla

  @redirect_statuses [301, 302, 307, 308]

  adapter :httpc, [body_format: :binary]
  plug Tesla.Middleware.BaseUrl, "http://"
  plug Tesla.Middleware.DecompressResponse

  @doc """
    Check if given url leads to image.
  """
  @spec image?(String.t) :: boolean
  def image?(url) do
    %Tesla.Env{status: status, headers: headers} = head(url)

    status == 200 && String.match?(headers["content-type"], ~r/\Aimage\//)
  catch
    _, %Tesla.Error{} -> false
  end

  @doc """
    Follow redirections to check final website adress.
  """
  @spec final_location(String.t) :: String.t | nil
  def final_location(url) do
    case head(url, opts: [autoredirect: false]) do
      %Tesla.Env{status: 200} ->
        url
      %Tesla.Env{status: status, headers: %{"location" => location}} when status in @redirect_statuses ->
        final_location(location)
      _ ->
        nil
    end
  catch
    _, %Tesla.Error{} -> nil
  end
end
