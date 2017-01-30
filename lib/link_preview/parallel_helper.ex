defmodule LinkPreview.ParallelHelper do
  @moduledoc false

  def map(collection, fun) do
    collection
    |> Enum.map(&Task.async(fn -> fun.(&1) end))
    |> Enum.map(&Task.await(&1))
  end
end
