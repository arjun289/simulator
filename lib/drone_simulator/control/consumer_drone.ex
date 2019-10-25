defmodule DroneSimulator.Control.ConsumerDrone do
  @moduledoc """
  Drone process module to handle traffic reporting.

  The module is responsible for receiving events from the
  dispatcher, check for traffic at co-ordinates recieved and
  report it. The process here is a consumer process which has
  a memory limit implemented using `back_pressure` mechaism in
  `GenStage`.
  See `GenStage`.
  """

  use GenStage
  alias DroneSimulator.Control.Dispatcher
  alias DroneSimulator.Drone.TrafficReport

  @range 350

  @doc "Starts the consumer."
  def start_link(drone_id) do
    drone_name = String.to_atom("drone_process_" <> to_string(drone_id))
    GenStage.start_link(__MODULE__, drone_id, name: drone_name)
  end

  def init(drone_process_id) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer,
      :ok,
      subscribe_to: [
        {
          Dispatcher,
          selector: fn [id, _, _, _] ->
            id == drone_process_id
          end,
          max_demand: 10,
          min_demand: 5
        }
      ]
    }
  end

  def handle_events(events, _from, state) do
    for event <- events do
      [id, lat, lon, time] = event
      IO.inspect("Analyse event #{inspect(event)}" )
      TrafficReport.analyse_event(id, lat, lon, time,  @range)
    end
    {:noreply, [], state}
  end
end
