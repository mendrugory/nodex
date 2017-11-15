defmodule Nodex.Mixfile do
  use Mix.Project

  @version "0.1.0"
  def project do
    [
      app: :nodex,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      deps: deps(),
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        extras: ["README.md"],
        source_url: "https://github.com/mendrugory/nodex",
      ],
    ]
  end


  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger], mod: {Nodex.Application, []}]
  end

  defp deps do
    [
      {:earmark, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end


  defp description do
    "Nodex is a OTP Application which will take care of your connected nodes."
  end

  defp package do
    [
      name: :nodex,
      maintainers: ["Gonzalo Jiménez Fuentes"],
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/mendrugory/nodex"},
    ]
  end
end
