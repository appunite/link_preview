defmodule LinkPreviewGenerator.Processor do
  @moduledoc """
    Combines the logic of other modules with user input.
  """
  alias LinkPreviewGenerator.Requests
  alias LinkPreviewGenerator.Parsers.{Basic, Opengraph, Html}

  @doc """
    Takes url and returns result of processing.
  """
  @spec call(String.t) :: LinkPreviewGenerator.success | LinkPreviewGenerator.failure
  def call(url) do
    with  {:ok, response, page}  <- Requests.handle_redirects(url),
          {:ok, parsed_body}     <- parse_body(response.body)
    do
      parsers = Application.get_env(:link_preview_generator, :parsers, [Opengraph, Html])
      page = page |> collect_data(parsers, parsed_body)

      {:ok, page}
    else
      {:error, reason} ->
        {:error, reason}
      _  ->
        {:error, :unknown}
    end
  end

  defp parse_body(body) do
    {:ok, Floki.parse(body)}
  catch
    _, _ -> {:error, :floki_raised}
  end

  defp collect_data(page, parsers, parsed_body) do
    Enum.reduce(parsers, page, &apply_each_function(&1, &2, parsed_body))
  end

  defp apply_each_function(parser, page, parsed_body) do
    Enum.reduce_while(Basic.parsing_functions, page, &apply_or_halt(parser, &1, &2, parsed_body))
  end

  defp apply_or_halt(parser, :images, page, parsed_body) do
    current_value = Map.get(page, :images)

    if current_value == [] do
      {:cont, Kernel.apply(parser, :images, [page, parsed_body])}
    else
      {:halt, page}
    end
  end

  defp apply_or_halt(parser, function, page, parsed_body) do
    current_value = Map.get(page, function)

    if is_nil(current_value) do
      {:cont, Kernel.apply(parser, function, [page, parsed_body])}
    else
      {:halt, page}
    end
  end

end
