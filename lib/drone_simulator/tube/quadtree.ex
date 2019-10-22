defmodule DroneSimulator.Tube.Quadtree do

  alias __MODULE__, as: Quadtree

  defstruct(
    point: nil,
    data: [],
    nw: nil,
    ne: nil,
    sw: nil,
    se: nil
  )

  @type t :: %__MODULE__{}


  @doc """
  Returns an empty `Qudadtree` struct.
  """
  def new() do
    %Quadtree{}
  end

  @doc """
  Inserts the co-ordintaes {lat. lng} in the supplied `quadtree` struct.
  """
  @spec insert(__MODULE__.t(), tuple, list) :: __MODULE__.t()
  def insert(quadtree, {_lat,_lng} = child, data) do
    if quadtree.point == nil do
      %Quadtree{
        point: child,
        data: data
      }
    else
      point = quadtree.point
      quadrant = get_quadrant(point, child)
      if Map.get(quadtree, quadrant) == nil do
        Map.put(quadtree, quadrant, %Quadtree{point: child, data: data})
      else
        Map.put(quadtree, quadrant, insert(Map.get(quadtree, quadrant),
          child, data))
      end
    end
  end

  @doc """
  Returns the bounding block for the given {lat, lng} point.
  """
  def get_bounding_block(quadtree, {_lat, _lng} = point) do
    acc = []
    find_bounding_points(quadtree, point, acc)
  end

  ################# private functions ##########################

  defp find_bounding_points(quadtree, point, acc) do
    cond do
      quadtree.ne != nil and check_if_contains?(quadtree, quadtree.ne, point) ->
        acc = [quadtree.point, quadtree.ne.point]
        find_bounding_points(quadtree.ne, point, acc)

      quadtree.nw != nil and check_if_contains?(quadtree, quadtree.nw, point) ->
        acc = [quadtree.point, quadtree.nw.point]
        find_bounding_points(quadtree.nw, point, acc)

      quadtree.sw != nil and check_if_contains?(quadtree, quadtree.sw, point) ->
        acc = [quadtree.point, quadtree.sw.point]
        find_bounding_points(quadtree.sw, point, acc)

      quadtree.se != nil and check_if_contains?(quadtree, quadtree.se, point) ->
        acc = [quadtree.point, quadtree.se.point]
        find_bounding_points(quadtree.se, point, acc)

      true ->
        acc
    end
  end

  defp check_if_contains?(_quadtree, nil, _point), do: false

  defp check_if_contains?(quadtree, child, {point_lat, point_lng}) do
    {parent_lat, parent_lng} = quadtree.point
    {child_lat, child_lng } = Map.get(child, :point)

    case1 = point_lat >= min(parent_lat, child_lat) and
      point_lat <= max(parent_lat, child_lat)
    case2 = point_lng >= min(parent_lng, child_lng)
      and point_lng <= max(parent_lng, child_lng)

    case1 and case2
  end

  def get_quadrant({parent_lat, parent_lng}, {child_lat, child_lng}) do
    cond do
      child_lat >= parent_lat and child_lng > parent_lng ->
        :ne
      child_lat > parent_lat and child_lng <= parent_lng ->
        :nw
      child_lat <= parent_lat and child_lng < parent_lng ->
        :sw
      child_lat < parent_lat and child_lng >= parent_lng ->
        :se
    end
  end
end
