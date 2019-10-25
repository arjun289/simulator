defmodule DroneSimulator.ControlSupervisor do
  @moduledoc """
  Supervises the controlling mechanism for the simulation.

  The simulator mechanism has a timer, dispatcher and multiple
  drone processes which process the incoming events. The ControlSupervisor
  monitors all these processes and takes necessary action to provide
  fault tolerance.
  """

  use Supervisor
  alias DroneSimulator.Control.ConsumerDrone

  def start_link(_) do
    IO.ANSI.color(53)
    <> "Initializing Control Supervisor... "
    <> IO.ANSI.reset()
    |> IO.puts()

    drone_ids = Application.get_env(:drone_simulator, :drone_ids)
    Supervisor.start_link(__MODULE__, drone_ids, name: __MODULE__)
  end

  def init(drone_ids) do
    drone_processes = Enum.map(drone_ids, fn drone_id ->
      drone_name = String.to_atom("drone_process" <> to_string(drone_id))
      Supervisor.child_spec({ConsumerDrone, drone_id}, id: drone_name)
    end)

    children = [
      DroneSimulator.Control.Timer |
      [
        {DroneSimulator.Control.Dispatcher, drone_ids} |
        drone_processes
      ]
    ]

    options = [strategy: :rest_for_one]
    Supervisor.init(children, options)
  end
end
