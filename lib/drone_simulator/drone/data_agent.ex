defmodule DroneSimulator.Drone.DataAgent do
  @moduledoc """
  Agents to hold all the data for a drone.

  Each agent holds data for a single drone.
  """

  use Agent
  NimbleCSV.define(DroneDataParser, separator: ",")

  @doc """
  Starts an Agent to hold data for the supplied id.

  The agent name is derived from the supplied `drone_id`.
  """
  @spec start_link(non_neg_integer) :: {:error, any} | {:ok, pid}
  def start_link(drone_id) do
    drone_name = String.to_atom("drone_agent_" <> to_string(drone_id))

    Agent.start_link(
      fn ->
        load_drone_data(drone_id)
      end,
      name: drone_name
    )
  end

  @doc """
  Removes and returns entries from the agent where datetime is lesser
  than the supplied time.

  Takes as input the `name` of the `agent` and `time` for which entries
  need to be popped.
  """
  @spec pop_events(atom, NaiveDateTime.t()) :: list
  def pop_events(agent, time) do
    Agent.get_and_update(agent, fn state ->
      get_and_update_events(state, time)
    end,
    5000)
  end

  ##################### private functions ###################

  defp load_drone_data(drone_id) do
    path = "data/drone/#{drone_id}.csv"

    :drone_simulator
    |> :code.priv_dir()
    |> Path.join(path)
    |> File.stream!()
    |> DroneDataParser.parse_stream()
    |> Enum.map(&process_row_entry/1)
  end

  defp process_row_entry([id, lat, lon, time]) do
    id = String.to_integer(id)
    lat = String.to_float(lat)
    lon = String.to_float(lon)
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
