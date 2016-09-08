defmodule LinkPreviewGenerator.ProcessorTest do
  alias LinkPreviewGenerator.Processor
  use ExUnit.Case
  import Mock

  @tag :excluded
  describe "#call" do
    test "when Floki raises error" do
      with_mock Floki, [parse: fn(_) -> :meck.exception() end] do
        assert (Processor.call("example.com") == {:error, :floki_raised})
      end
    end
  end

end
