defmodule LinkPreview.Requests do
  @moduledoc """
    Module providing functions to handle needed requests.
  """
  use Tesla, docs: false, only: ~w(get head)a

  @redirect_statuses [301, 302, 307, 308]

  adapter :httpc, [body_format: :binary]
  plug Tesla.Middleware.BaseUrl, "http://"
  plug Tesla.Middleware.DecompressResponse
  plug Tesla.Middleware.FollowRedirects

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
end
