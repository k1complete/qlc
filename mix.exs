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
        links: %{
          "Docs" => @url_docs,
          "GitHub" => @url_github
        }
      },
      version: "0.0.1",
      elixir: "~> 1.1",
      deps: deps,
      docs: [
        extras: [ "README.md" ],
        source_ref: "master",
        source_url: @url_github
      ]
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
      { :earmark, "~> 0.2.1",  optional: true, only: :dev },
      { :ex_doc,  "~> 0.11.3", optional: true, only: :dev }
    ]
  end
end
