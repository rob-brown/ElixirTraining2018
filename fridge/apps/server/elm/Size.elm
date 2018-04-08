module Size exposing (..)

type alias Size = { width: Int, height: Int }

init : Int -> Int -> Size
init width height =
  { width = width, height = height }
