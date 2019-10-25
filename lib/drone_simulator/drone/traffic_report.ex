defmodule DroneSimulator.Drone.TrafficReport do
  defstruct [
    :drone_id,
    :time,
    :speed,
    :traffic_condition,
    :station_name
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
  def analyse_event(id, lat, lng, time, range) do
      lat
      |> Tube.nearest_tube(lng, range)
      |> generate_report(id, time)
  end

  defp generate_report({:ok, metadata}, id, time) do
    data = struct!(%__MODULE__{},
      drone_id: id,
      time: time,
      speed: "30mph",
      station_name: metadata.data.name,
      traffic_condition: traffic_condition()
      )
    IO.inspect(data)
  end

  defp generate_report({:error, message}, id, time) do
    IO.puts(message <> " by drone " <> to_string(id) <> " at #{inspect(time)}")
  end

  defp traffic_condition() do
    Enum.random(["HEAVY", "MODERATE", "LIGHT"])
  end

end
