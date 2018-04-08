module Grid exposing (..)

import Point exposing (Point)
import Dict exposing (Dict)

type alias Grid a =
  { dict: Dict String a
  , maxX: Int
  , maxY: Int
  }

empty : Grid a
empty =
  { dict = Dict.empty, maxX = 0, maxY = 0 }

get : Point -> Grid a -> Maybe a
get point { dict, maxX, maxY } =
  Dict.get (key point) dict

put : Point -> a -> Grid a -> Grid a
put point value { dict, maxX , maxY } =
  { dict = Dict.insert (key point) value dict
  , maxX = max point.x maxX
  , maxY = max point.y maxY
  }

key : Point -> String
key point =
  Point.string point
