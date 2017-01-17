defmodule LinkPreviewGenerator.ProcessorTest do
  use ExUnit.Case
  alias LinkPreviewGenerator.Processor

  import Mock

  @tag :excluded
  # describe "#call" do
  #   test "when Floki raises error" do
  #     with_mock Floki, [parse: fn(_) -> "raise error here" end] do
  #       assert (Processor.call("example.com") == {:error, :floki_raised})
  #     end
  #   end
  # end

end
