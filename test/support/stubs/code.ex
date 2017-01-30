defmodule HtmlEntitiesNotLoaded do
  def ensure_loaded?(HtmlEntities), do: false
  def ensure_loaded?(_), do: true
end

defmodule MogrifyNotLoaded do
  def ensure_loaded?(Mogrify), do: false
  def ensure_loaded?(_), do: true
end

defmodule TempfileNotLoaded do
  def ensure_loaded?(Tempfile), do: false
  def ensure_loaded?(_), do: true
end
