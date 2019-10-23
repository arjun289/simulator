defmodule DroneSimulator.Tube.QuadtreeTest do
  @moduledoc """
  ###Note!

  The module uses bounding box for london tubes for creating
  the quadtree.
  root_coordinates %{minLng: -0.94, minLat: 51.341012,
    maxLng: 0.381789, maxLat: 51.846062}
  """

  use ExUnit.Case, async: true

  alias DroneSimulator.Tube.Quadtree

  describe "new_tree/0" do
    test "returns a new tree" do
      tree = Quadtree.new()
      assert tree == %DroneSimulator.Tube.Quadtree{
            data: %{},
            maxLat: 51.846062,
            maxLng: 0.381789,
            minLat: 51.341012,
            minLng: -0.94,
            ne: nil,
            nw: nil,
            point: nil,
            se: nil,
            sw: nil
          }
    end
  end

  describe "insert/2" do
    test "inserts co-ordinates at root if tree empty" do
      tree = Quadtree.new()
      point = %{lat: 51.503071, lng: -0.280303, name: "Acton Town"}
      quadtree = Quadtree.insert(tree, point)
      assert quadtree == %DroneSimulator.Tube.Quadtree{
        data: %{name: "Acton Town"},
        maxLat: 51.846062,
        maxLng: 0.381789,
        minLat: 51.341012,
        minLng: -0.94,
        ne: nil,
        nw: nil,
        point: {51.503071, -0.280303},
        se: nil,
        sw: nil
      }
    end

    test "inserts in child if parent already contains a point" do
      tree = Quadtree.new()
      point = %{lat: 51.503071, lng: -0.280303, name: "Acton Town"}
      quadtree = Quadtree.insert(tree, point)
      next_point = %{lat: 51.514342, lng: -0.075627, name: "Aldgate"}
      quadtree = Quadtree.insert(quadtree, next_point)
      assert quadtree == %DroneSimulator.Tube.Quadtree{
        data: %{name: "Acton Town"},
        maxLat: 51.846062,
        maxLng: 0.381789,
        minLat: 51.341012,
        minLng: -0.94,
        point: {51.503071, -0.280303},
        se: %DroneSimulator.Tube.Quadtree{
          data: %{name: "Aldgate"},
          maxLat: 51.593537,
          maxLng: 0.381789,
          minLat: 51.341012,
          minLng: -0.2791055,
          ne: nil,
          nw: nil,
          point: {51.514342, -0.075627},
          se: nil,
          sw: nil
        }
      }
    end
  end
end
