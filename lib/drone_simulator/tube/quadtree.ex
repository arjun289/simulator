defmodule DroneSimulator.Tube.Quadtree do
  @moduledoc """
  The module defines a quad tree data structure to specify all the co-ordinates
  for tube stations and allows performing search for nearest neighbor of
  any given co-oridnate.

  ### Note!
  For simplicity and domain handling, only one point per node is allowed
  at present.
  """

  defstruct(
    point: nil,
    data: %{},
    minLng: nil,
    minLat: nil,
    maxLng: nil,
    maxLat: nil,
    ne: nil,
    nw: nil,
    se: nil,
    sw: nil
  )

  @typedoc """
  point: holds the point in {lat, lng} format for current node.
  data: keeps additional metadata about the point.
  minLng: holds the lower-left corner longitude, which is minLng for the
    bounding box.
  minLat: holds the lower-left corner latitude, which is minLat for the
    bounding box.
  maxLng: holds the top-right corner longitude, which is maxLng for the
    bounding box.
  maxLat: holds the top-right corner latitude, which is maxLat for the
    bounding box.
  ne: contains child node in north-east quadrant.
  nw: contains child in north-west quadrant.
  se: contains child in south-east quadrant.
  sw: contains child in south-west quadrant.
  """

  @type t :: %__MODULE__{}

  # bounding co-ordinates for london tube stations quad tree
  @root_coordinates %{minLng: -1.1072384, minLat: 51.1987282, maxLng: 0.7302249,
    maxLat: 51.9430139}

  def new() do
    new(
      {
        @root_coordinates.minLng,
        @root_coordinates.minLat,
        @root_coordinates.maxLng,
        @root_coordinates.maxLat
      }
    )
  end

  def new(_bounding_coordinates = {minLng, minLat, maxLng, maxLat}) do
    %__MODULE__{
      minLng: minLng,
      minLat: minLat,
      maxLng: maxLng,
      maxLat: maxLat
    }
  end

  @doc """
  Inserts a point in the supplied at the right location in the quadtree and
  returns it.
  """
  @spec insert(__MODULE__.t(), map) :: __MODULE__.t()
  def insert(quadtree, point) do
    insert_node(
      bounding_box_contains_cooridnates?(
        {quadtree.minLng, quadtree.minLat, quadtree.maxLng, quadtree.maxLat},
        {point.lat, point.lng}
      ),
      point,
      quadtree
    )
  end

  @doc """
  Returns the nearest point in `quadtree` to the `point` given in input
  parameters.

  ### Steps to find:
    1.Recurse to the leaf node in which point falls.
    2.Mark the best distance as distance b/w leaf node point and input point.
      Hold this in an acuumulator.
    3.Start recursing outwards and check if the best distance we have is
      lesser than the distance from bounding boxes which are sibling of the
      current node.
    4.If found, check the distance b/w node point and drone point then recurse
      inside the same node and find the leaf node which is nearest to the point
      and the point check if the point in that node
    5.If not found, then return the acc with the point, it's the nearest
      neighbour.
  """
  @spec nearest_neighbor(__MODULE__.t(), tuple) :: map
  def nearest_neighbor(quadtree, point) do
    acc = %{point: nil, data: nil, best_distance: nil}
    find_nearest_neighbour(quadtree, point, acc)
  end

  ######################## private functions #################

  defp find_nearest_neighbour(quadtree, point, acc) do
    acc = recurse_to_leaf(
      is_leaf_node?(quadtree.ne),
      quadtree,
      point,
      acc
    )
  end

  defp recurse_to_leaf(_leaf_node = true, quadtree, point, acc) do
    {lat, lng} = quadtree.point
    dx = point.lng - lng
    dy = point.lat - lat
    distance = :math.sqrt(dx*dx + dy*dy)
    acc
      |> Map.put(:point, {lat, lng})
      |> Map.put(:best_distance, distance)
  end

  defp recurse_to_leaf(_leaf_node = false, quadtree, point, acc) do
    quad = get_bounding_quadrant(quadtree, point)
    tree = quadtree[quad]
    acc = recurse_to_leaf(tree.ne, tree, point, acc)

    check_with_sibling_bounding_box()

  end

  defp check_with_sibling_bounding_box() do

  end

  defp get_bounding_quadrant(quadtree, point) do
    [quad] = Enum.filter([:ne, :nw, :se, :sw], fn quad ->
      bounding_box_contains_cooridnates?(quadtree[quad], point)
    end)
    quad
  end

  defp insert_node(false, _point, quadtree), do: quadtree
  defp insert_node(true, point, quadtree) do
    add_point_if_absent(
      has_point?(quadtree.point),
      quadtree,
      point
    )
  end

  defp has_point?(_quadtree_point = nil), do: false
  defp has_point?(_quadtree_point), do: true

  defp add_point_if_absent(_point_present = false, quadtree, point) do
    data = Map.put(quadtree.data, :name, point.name)
    struct!(quadtree, point: {point.lat, point.lng}, data: data)
  end

  defp add_point_if_absent(_point_present = true, quadtree, point) do
    insert_after_subdivide(
      is_leaf_node?(quadtree.ne),
      quadtree,
      point
    )
  end

  defp is_leaf_node?(_child = nil), do: true
  defp is_leaf_node?(_child), do: false

  defp insert_after_subdivide(_needs_divison = false, quadtree, point) do
    update_tree(quadtree, point)
  end

  defp insert_after_subdivide(_needs_divison = true, quadtree, point) do
    quadtree = subdivide_tree(quadtree)
    update_tree(quadtree, point)
  end

  defp update_tree(quadtree, point) do
    quadtree_ne = insert(quadtree.ne, point)
    quadtree_nw = insert(quadtree.nw, point)
    quadtree_se = insert(quadtree.se, point)
    quadtree_sw = insert(quadtree.sw, point)

    struct!(quadtree,
      ne: quadtree_ne,
      nw: quadtree_nw,
      se: quadtree_se,
      sw: quadtree_sw
    )
  end

  defp bounding_box_contains_cooridnates?(bounding_box,
      _coordinates = {lat, lng}) do
    {minLng, minLat, maxLng, maxLat} = bounding_box

    condition_1 = lng >= minLng and lng <= maxLng
    condition_2 = lat >= minLat and lat <= maxLat

    condition_1 and condition_2
  end

  defp subdivide_tree(quad_tree) do
    latMid = (quad_tree.minLat + quad_tree.maxLat) / 2
    lngMid = (quad_tree.minLng + quad_tree.maxLng) / 2

    struct!(
      quad_tree,
      ne: new({lngMid, latMid, quad_tree.maxLng, quad_tree.maxLat}),
      nw: new({quad_tree.minLng, latMid, lngMid, quad_tree.maxLat}),
      se: new({lngMid, quad_tree.minLat, quad_tree.maxLng, latMid}),
      sw: new({quad_tree.minLng, quad_tree.minLat, lngMid, latMid})
    )
  end

end
