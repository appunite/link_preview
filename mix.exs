defmodule LinkPreview.Mixfile do
  use Mix.Project

  @version "1.0.0"

  def project do
    [
      aliases: aliases(),
      app: :link_preview,
      deps: deps(),
      description: description(),
      docs: [
        extras: ["README.md", "CHANGELOG.md"]
      ],
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      homepage_url: "https://appunite.com",
      name: "Link Preview",
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.travis": :test
      ],
      source_url: "https://github.com/appunite/link_preview",
      test_coverage: [
        tool: ExCoveralls
      ],
      version: @version
    ]
  end

  defp description do
    """
    LinkPreview is a package that tries to receive meta information from given http(s) address.
    Returned Page struct includes website title, description, images and more.
    """
  end

  defp package do
    [
      files: ["lib", "config", "mix.exs", "README.md", "CHANGELOG.md"],
      maintainers: ["Tobiasz Małecki", "Karol Wojtaszek"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/appunite/link_preview",
        "Sponsor" => "https://appunite.com"
      }
   ]
  end

  def application do
    [applications: applications(Mix.env)]
  end

  def applications(:all),  do: [:floki, :logger, :tesla]
  def applications(:test), do: applications(:all) ++ [:httparrot]
  def applications(_),     do: applications(:all)

  defp elixirc_paths(:test), do: ["lib", "test/case.ex"]
  defp elixirc_paths(_),     do: ["lib"]

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
      {:excoveralls, "~> 0.6", only: :test},
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
