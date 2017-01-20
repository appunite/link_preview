defmodule LinkPreview.Mixfile do
  use Mix.Project

  def project do
    [
      app: :link_preview,
      version: "1.0.0",
      elixir: "~> 1.3",
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      docs: [extras: ["README.md", "CHANGELOG.md"]]
    ]
  end

  defp description do
    """
    LinkPreview is a package that tries to receive meta information from given http(s) address.
    Link preview is returned as Page struct that includes website title, description, images and more.
    """
  end

  defp package do
    [
      files: ["lib", "config", "mix.exs", "README.md", "CHANGELOG.md"],
      maintainers: ["Tobiasz Małecki", "Karol Wojtaszek"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/appunite/link_preview"}
   ]
  end

  def application do
    [applications: applications(Mix.env)]
  end

  def applications(:all),  do: [:floki, :logger, :tesla]
  def applications(:test), do: applications(:all) ++ [:httparrot]
  def applications(_),     do: applications(:all)

  defp deps do
    [
      #required
      {:floki, "~> 0.10.0"},
      {:tesla, github: "teamon/tesla", branch: "master"},

      #optional
      {:html_entities, "~> 0.2", optional: true},
      {:mogrify, "~> 0.4.0", optional: true},
      {:tempfile, "~> 0.1.0", optional: true},

      #testing/docs
      {:ex_doc, "~> 0.12", only: :dev},
      {:httparrot, "~> 0.5.0", only: :test},
      {:mock, "~> 0.1", only: :test}
    ]
  end

  defp aliases do
    [
      "test": ["test --exclude excluded"]
    ]
  end
end
