defmodule DroneSimulator.Tube do
  @moduledoc """
  Exposes helper function to deal with queries related
  to tube stations.
  """

  @doc """
  Checks if a tube station is present in the given range.

  The function queries the tube data agent to check if a station
  is present for the speicified {lat, lon} in the given range.
  See `DroneSimulator.Tube.DataAgent`
  """
  @spec tube_present?(String.t(), String.t(), non_neg_integer) :: boolean
  def tube_present?(lat, lon, range) do

  end

end
