defmodule DroneSimulator.DroneDataAgent do
  @moduledoc """
  Agents to hold all the data for a drone.

  Each agent holds data for a single drone.
  """

  use Agent

  def start_link(drone_id) do
    drone_name = String.to_atom("drone_agent_" <> to_string(drone_id))

    Agent.start_link(
      fn ->
        load_drone_data(drone_id)
      end,
      name: drone_name
    )
  end

  def pop_events(agent, time) do
    Agent.get_and_update(agent, fn state ->
      get_and_update_events(state, time)
    end,
    5000)
  end

  ##################### private function ###################

  defp load_drone_data(drone_id) do
    path = "data/drone/#{drone_id}.csv"

    :drone_simulator
    |> :code.priv_dir()
    |> Path.join(path)
    |> File.read!()
    |> String.trim()
    |> String.split(~r/\n/)
    |> Stream.map(&String.split(&1, ","))
    |> Enum.map(&process_row_entry/1)
  end

  defp process_row_entry([id, lat, lon, time]) do
    id = String.to_integer(id)
    lat = Poison.decode!(lat)
    lon = Poison.decode!(lon)
    time = Poison.decode!(time)
    time = time |> Timex.parse!("%F %T", :strftime)
    [id, lat, lon, time]
  end

  def get_and_update_events(_state = events_list, time) do
    result_list = Enum.take_while(events_list,
      fn [_, _, _, datetime] ->
        Timex.compare(datetime, time) == -1
    end)
    {result_list, events_list -- result_list}
  end

end
