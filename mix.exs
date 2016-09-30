defmodule LinkPreviewGenerator.Mixfile do
  use Mix.Project

  def project do
    [
      app: :link_preview_generator,
      version: "0.0.3",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description,
      package: package,
      deps: deps,
      aliases: aliases
    ]
  end

  defp description do
    """
    LinkPreviewGenerator is a package that tries to receive meta information from given http(s) address
    """
  end

  defp package do
    [
      files: ["lib", "config", "mix.exs", "README.md"],
      maintainers: ["Tobiasz Małecki", "Karol Wojtaszek"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/appunite/link_preview_generator",
            "Docs" => "http://hexdocs.pm/link_preview_generator/"}
   ]
  end

  def application do
    [
      applications: [:floki, :httpoison, :logger, :mogrify, :tempfile]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.12", only: :dev},
      {:floki, "~> 0.10.0"},
      {:httpoison, "~>0.9"},
      {:mock, "~>0.1", only: :test},
      {:mogrify, "~> 0.4.0"},
      {:tempfile, "~> 0.1.0"}
    ]
  end

  defp aliases do
    [
      "test": ["test --exclude excluded"]
    ]
  end
end
