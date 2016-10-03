defmodule LinkPreviewGenerator.Requests do
  @moduledoc """
    Module providing functions to handle needed requests.
  """

  use Tesla
  plug Tesla.Middleware.BaseUrl, "http://"

  @type t :: {:ok, String.t} | {:error, atom}

  def sget(url) do
    response = get(url)

    {:ok, response}
  catch
    _, _ -> {:error, :http}
  end

  def shead(url) do
    response = head(url)

    {:ok, response}
  catch
    _, _ -> {:error, :http}
  end

  @doc """
    Check if given url leads to image
  """
  @spec valid_image?(String.t) :: t
  def valid_image?(url) do
    with {:ok, %Tesla.Env{status: 200, headers: headers}} <- shead(url),
                                                     true <- String.match?(headers["content-type"], ~r/\Aimage\//)
    do
      {:ok, url}
    else
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
