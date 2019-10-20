defmodule DroneSimulator.Application do
  use Application

  def start(_type, _args)do
    children = [
      DroneSimulator.DroneDataSupervisor
    ]
    opts = [strategy: :one_for_one, name: DroneSimulator.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
