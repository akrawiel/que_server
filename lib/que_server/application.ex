defmodule QueServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      QueServerWeb.Telemetry,
      # Start the Ecto repository
      QueServer.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: QueServer.PubSub},
      # Start Finch
      {Finch, name: QueServer.Finch},
      # Start the Endpoint (http/https)
      QueServerWeb.Endpoint,
      QueServerWeb.Presence
      # Start a worker by calling: QueServer.Worker.start_link(arg)
      # {QueServer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QueServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QueServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
