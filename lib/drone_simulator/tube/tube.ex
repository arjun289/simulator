defmodule DroneSimulator.Tube do
  @moduledoc """
  Exposes helper function to deal with queries related
  to tube stations.
  """

  alias DroneSimulator.Tube.DataAgent

  @doc """
  Checks if a tube station is present in the given range.

  The function queries the tube data agent to check if a station
  is present for the speicified {lat, lon} in the given range.
  See `DroneSimulator.Tube.DataAgent`
  """
  @spec nearest_tube(float, float, non_neg_integer) ::
    {:ok, map} | {:error, String.t()}
  def nearest_tube(lat, lng, range) do
    result = DataAgent.get_nearest_neighbor(%{lat: lat, lng: lng})
    tube_in_range(result.best_distance < range, result)
  end

  defp tube_in_range(false, _result) do
    {:error, "No tube within range"}
  end

  defp tube_in_range(true, result) do
    {:ok, result}
  end

end
