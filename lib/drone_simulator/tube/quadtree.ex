defmodule DroneSimulator.Tube.Quadtree do
  @moduledoc """
  The module defines a quad tree structure to specify all the co-ordinates
  for tube stations and allows performing search for nearest neighbor of
  any given co-oridnate.

  ### Note!
  For simplicity and domain handling only one point per node is allowed at present.
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
  point: holds the {lat, lng} for the point in this node.
  data: keeps additional metadata about the point.
  minLng: holds the left corner longitude, which is minLng for the
    bounding box.
  minLat: holds the left corner latitude, which is minLat for the
    bounding box.
  maxLng: holds the right corner longitude, which is maxLng for the
    bounding box.
  maxLat: holds the right corner latitiude, which is maxLat for the
    bounding box.
  """

  @type t :: %__MODULE__{}

  # bounding co-ordinates for london tube stations quad tree
  @root_coordinates %{minLng: -0.94, minLat: 51.341012, maxLng: 0.381789, maxLat: 51.846062}

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

  @spec insert(__MODULE__.t(), map) :: __MODULE__.t()
  def insert(quadtree, point) do
    insert_node(
      bounding_box_contains_cooridnate?(
        {quadtree.minLng, quadtree.minLat, quadtree.maxLng, quadtree.maxLat},
        {point.lat, point.lng}
      ),
      point,
      quadtree
    )
  end

  defp insert_node(false, _point, quadtree), do: quadtree
  defp insert_node(true, point, quadtree) do
    insert_with_subdivide(
      if_needs_subdivide?(quadtree.point),
      quadtree,
      point
    )
  end

  defp if_needs_subdivide?(nil), do: false
  defp if_needs_subdivide?(_), do: true

  defp insert_with_subdivide(false, quadtree, point) do
    data = Map.put(quadtree.data, :name, point.name)
    struct!(quadtree, point: {point.lat, point.lng}, data: data)
  end

  defp insert_with_subdivide(true, quadtree, point) do
    quadtree = subdivide_tree(quadtree)
    require IEx
    IEx.pry
  end

  def bounding_box_contains_cooridnate?(bounding_box, _coordinates = {lat, lng}) do
    {minLng, minLat, maxLng, maxLat} = bounding_box

    condition_1 = lng >= minLng and lng <= maxLng
    condition_2 = lat >= minLat and lat <= maxLat

    condition_1 and condition_2
  end

  def subdivide_tree(quad_tree) do
    latMid = (quad_tree.minLat + quad_tree.maxLat) / 2
    lngMid = (quad_tree.minLng + quad_tree.maxLng) / 2

    struct!(
      quad_tree,
      ne: new({lngMid, latMid, quad_tree.maxLng, quad_tree.maxLat}),
      nw: new({quad_tree.minLng, latMid, lngMid, quad_tree.maxLat}),
      se: new({lngMid, quad_tree.minLat, quad_tree.maxLng, latMid}),
      sw: new({quad_tree.minLng, quad_tree.minLat, latMid, lngMid})
    )
  end

end
