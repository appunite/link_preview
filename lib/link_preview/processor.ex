defmodule LinkPreview.Processor do
  @moduledoc """
    Combines the logic of other modules with user input.
  """
  alias LinkPreview.{Page, Requests}
  alias LinkPreview.Parsers.{Basic, Opengraph, Html, Image}

  @doc """
    Takes url and returns result of processing.
  """
  @spec call(String.t) :: LinkPreview.success | LinkPreview.failure
  def call(url) do
    case Requests.head(url) do
      %Tesla.Env{headers: %{"content-type" => "text/html" <> _}} ->
        parsers = Application.get_env(:link_preview, :parsers, [Opengraph, Html])

        do_call(url, parsers)
      %Tesla.Env{headers: %{"content-type" => "image/" <> _}} ->
        do_image_call(url, [Image])
      _ ->
        {:error, %LinkPreview.Error{}}
    end
    |> to_tuple()
  catch
    _, _ -> {:error, %LinkPreview.Error{}}
  end

  defp to_tuple(result) do
    case result do
      %Page{}              -> {:ok, result}
      %LinkPreview.Error{} -> {:error, result}
    end
  end

  defp do_image_call(url, parsers) do
    url
    |> Page.new()
    |> collect_data(parsers, nil)
  end

  defp do_call(url, parsers) do
    with %Tesla.Env{status: 200, body: body} <- Requests.get(url) do
      url
      |> Page.new()
      |> collect_data(parsers, body)
    else
      _  -> %LinkPreview.Error{}
    end
  end

  defp collect_data(page, parsers, body) do
    Enum.reduce(parsers, page, &apply_each_function(&1, &2, body))
  end

  defp apply_each_function(parser, page, body) do
    if Code.ensure_loaded?(parser) do
      Enum.reduce_while(Basic.parsable(), page, &apply_or_halt(parser, &1, &2, body))
    else
      page
    end
  end

  defp apply_or_halt(parser, :images, page, body) do
    current_value = Map.get(page, :images)

    if current_value == [] do
      {:cont, apply(parser, :images, [page, body])}
    else
      {:halt, page}
    end
  end

  defp apply_or_halt(parser, function, page, body) do
    current_value = Map.get(page, function)

    if is_nil(current_value) do
      {:cont, apply(parser, function, [page, body])}
    else
      {:halt, page}
    end
  end

end
