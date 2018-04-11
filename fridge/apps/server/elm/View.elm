module View exposing (..)

import State exposing (State)
import Grid exposing (Grid)
import Point exposing (Point)
import Magnet exposing (Magnet)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Char

type alias FrameBuffer = Grid String

render : State -> Html a
render state =
  let
    maxX = state.dimensions.width
    maxY = state.dimensions.height
  in
    Grid.empty
    |> addMagnets state.magnets
    |> addFrame maxX maxY
    |> addCursor state.cursor state.cursorVisible state.mode
    |> bufferToLines

cursorString : String
cursorString =
  9612 |> Char.fromCode |> String.fromChar

addFrame : Int -> Int -> FrameBuffer -> FrameBuffer
addFrame width height buffer =
  let
    buf1 = List.range 0 (width + 1) |> List.foldr (\x b -> Grid.put (Point.init x 0) "-" b) buffer
    buf2 = List.range 0 (width + 1) |> List.foldr (\x b -> Grid.put (Point.init x (height + 1)) "-" b) buf1
    buf3 = List.range 0 (height + 1) |> List.foldr (\y b -> Grid.put (Point.init 0 y) "|" b) buf2
    buf4 = List.range 0 (height + 1) |> List.foldr (\y b -> Grid.put (Point.init (width + 1) y) "|" b) buf3
  in
    buf4
    |> Grid.put (Point.init 0 0) "+"
    |> Grid.put (Point.init 0 (height + 1)) "+"
    |> Grid.put (Point.init (width + 1) 0) "+"
    |> Grid.put (Point.init (width + 1) (height + 1)) "+"

addMagnets : List Magnet -> FrameBuffer -> FrameBuffer
addMagnets magnets buffer =
  magnets
  |> List.foldr (\{ text, location } buf ->
      text
      |> String.toList
      |> List.indexedMap (,)
      |> List.foldl (\(n, c) b ->
        Grid.put (Point.translate (n + 1) 1 location) (String.fromChar c) b) buf
    ) buffer

addCursor : Point -> Bool -> State.Mode -> FrameBuffer -> FrameBuffer
addCursor { x, y } visible mode buffer =
  case (mode, visible) of
    (State.Normal, True) ->
      let point = Point.init (x + 1) (y + 1)
      in
        Grid.put point cursorString buffer

    (State.Insert text, visible) ->
      let
        character = if visible then cursorString else " "
        fullText = text ++ character
      in
        fullText
        |> String.toList
        |> List.indexedMap (,)
        |> List.foldl (\(n, c) b ->
          Grid.put (Point.init (x + n + 1) (y + 1)) (String.fromChar c) b) buffer

    _ ->
      buffer

-- TODO: Blink the cursor

bufferToLines : FrameBuffer -> Html a
bufferToLines buffer =
  let
    maxX = buffer.maxX
    maxY = buffer.maxY
    lines =
      List.range 0 maxY
      |> List.map (\y ->
        List.range 0 maxX
        |> List.map (\x -> buffer |> Grid.get (Point.init x y) |> Maybe.withDefault " ")
        |> String.join ""
        |> text)
      |> List.intersperse (br [] [])
  in
    div [style [("font-family", "monospace")]] lines
