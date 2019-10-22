defmodule DroneSimulator.Drone.TrafficReport do
  defstruct [
    :drone_id,
    :time,
    :speed,
    :traffic_condition
  ]

  alias DroneSimulator.Tube

  @typedoc """
  - `drone_id`: id of the drone reporting the traffic,
  - `time`: time at which reporting was done,
  - `speed`: speed of the drone
  - `traffic_condition`: traffic condition at the tube station.
  - `station_name`: name of the tube station.
  """
  @type t :: %__MODULE__{}


  @doc """
  Analyses the event recieved and generates reports.

  The function checks if a tube station is present within the given
  range, if found, generates a reports and prints it to the console.
  """
  def analyse_event(id, lat, lon, time, range \\ 350) do
    if Tube.tube_present?(lat, lon, range) do
      generate_report(id, time)
    end
  end

  defp generate_report(id, time) do
    data = struct!(%__MODULE__{}, id: id, time: time, speed: "80mph")
    IO.inspect(data)
  end

end
