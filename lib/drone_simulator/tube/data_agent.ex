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
  Finds the nearest neighbour for the supplied
    point => {lat: lat, lng: lng}.
  """
  @spec get_nearest_neighbor(map) :: map
  def get_nearest_neighbor(point) do
    Agent.get(__MODULE__, fn quadtree ->
      Quadtree.nearest_neighbor(quadtree, point)
    end)
  end

  ##################### private functions #############

  defp load_tube_data() do
    path = "data/tube.csv"
    quadtree = Quadtree.new()

    :drone_simulator
    |> :code.priv_dir()
    |> Path.join(path)
    |> File.stream!()
    |> TubeDataParser.parse_stream(skip_headers: false)
    |> Enum.map(&process_row_entry/1)
    |> Enum.reduce(quadtree, fn point, acc ->
      acc = Quadtree.insert(acc, point)
      acc
    end)
  end

  defp process_row_entry([name, lat, lng]) do
    lat = String.to_float(lat)
    lng = String.to_float(lng)

    %{name: name, lat: lat, lng: lng}
  end
end
