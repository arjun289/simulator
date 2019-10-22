defmodule DroneSimulator.Tube.DataAgent do
  @moduledoc """
  Runs an agent and holds state for a list of tube stations in london.
  """

  use Agent
  alias DroneSimulator.Tube.Quadtree

  NimbleCSV.define(TubeDataParser, separator: ",")

  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_) do
    Agent.start_link(&load_tube_data/0, name: __MODULE__)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get_bounding_block(point) do
    Agent.get(__MODULE__, fn quadtree ->
      Quadtree.get_bounding_block(quadtree, point)
    end, :infinity)
  end

  ##################### private functions #############

  defp load_tube_data() do
    path = "data/tube.csv"
    quadtree = Quadtree.new()

    :drone_simulator
    |> :code.priv_dir()
    |> Path.join(path)
    |> File.stream!()
    |> TubeDataParser.parse_stream()
    |> Enum.map(&process_row_entry/1)
    |> Enum.reduce(quadtree, fn [name, lat, lon], acc ->
      Quadtree.insert(acc, {lat, lon}, [name: name])
    end)
  end

  defp process_row_entry([name, lat, lon]) do
    lat = String.to_float(lat)
    lon = String.to_float(lon)

    [name, lat, lon]
  end
end
