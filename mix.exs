defmodule Qlc.Mixfile do
  use Mix.Project

  @url_docs "http://hexdocs.pm/qlc"
  @url_github "https://github.com/k1complete/qlc"

  def project do
    [
      app: :qlc,
      name: "qlc",
      description: "QLC interface for Elixir",
      package: %{
        files: [
          "lib",
          "mix.exs",
          "README.md"
        ],
        maintainers: ["ODA Terutaka"],
        licenses: ["MIT"],
        links: %{
          "Docs" => @url_docs,
          "GitHub" => @url_github
        }
      },
      version: "1.0.5",
      elixir: "~> 1.7",
      deps: deps(),
      docs: [
        extras: [ "README.md" ],
        source_ref: "master",
        source_url: @url_github
      ],
      dialyzer: [plt_add_apps: [:mnesia], 
                flags: ["-Wunmatched_returns", 
                        "-Werror_handling", 
                        "-Wrace_conditions", 
                        "-Wunderspecs"
                ]]
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      { :earmark, "~> 1.3",  optional: true, only: :dev },
      { :ex_doc,  "~> 0.19", optional: true, only: :dev },
      {:dialyxir, "~> 0.5", only: [:dev]}
    ]
  end
end
