module Point exposing (..)

type alias Point = { x: Int, y: Int }

init : Int -> Int -> Point
init x y =
  { x = x, y = y}

translate : Int -> Int -> Point -> Point
translate dx dy { x, y } =
  { x = x + dx, y = y + dy }

string : Point -> String
string {x, y} =
  (toString x) ++ ":" ++ (toString y)
