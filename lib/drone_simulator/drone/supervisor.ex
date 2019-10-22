defmodule DroneSimulator.DroneDataSupervisor do
  @moduledoc """
  Starts and supervises individual drone data agents.

  Every drone has an agent to hold it's operational meta data,
  the supervisor starts agents for each of the drones and supervises them.
  """

  use Supervisor
  alias DroneSimulator.Drone.DataAgent

  def start_link(_) do
    drone_id_list = Application.get_env(:drone_simulator, :drone_ids)
    Supervisor.start_link(__MODULE__, drone_id_list, name: __MODULE__)
  end

  def init(drone_id_list) do
    children = Enum.map(drone_id_list, fn drone_id ->
      Supervisor.child_spec({DataAgent, drone_id}, id: drone_id)
    end)

    options = [strategy: :one_for_one]
    Supervisor.init(children, options)
  end

end
