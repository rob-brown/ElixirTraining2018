module State exposing (..)

import Dict exposing (Dict)
import Magnet exposing (Magnet)
import Char
import Keyboard exposing (KeyCode)
import Point exposing (Point)
import Size exposing (Size)

type Mode
  = Normal
  | Insert String

type alias State =
  { dimensions: Size
  , cursor: Point
  , cursorVisible: Bool
  , magnets: List Magnet
  , mode: Mode
  }

init : State
init =
  { dimensions = (Size.init 140 30)
  , cursor = (Point.init 0 0)
  , cursorVisible = True
  , magnets = []
  , mode = Normal
  }

setDimensions : Size -> State -> State
setDimensions dimensions state =
  { state | dimensions = dimensions }

addMagnet : Magnet -> State -> State
addMagnet magnet state =
  let
    newMagnets = magnet :: state.magnets
  in
    { state | magnets = newMagnets }

handleKeyPress : KeyCode -> State -> State
handleKeyPress code state =
  case state.mode of
    Normal ->
      handleNormalKeyPress code state
    Insert text ->
      handleInsertKeyPress code text state

handleNormalKeyPress code state =
  let
    x = state.cursor.x
    y = state.cursor.y
    maxX = state.dimensions.width
    maxY = state.dimensions.height
  in
    case Char.fromCode code of
      'j' ->
        if y < maxY - 1 then
          { state | cursor = (Point.init x (y + 1)) }
        else
          state
      'k' ->
        if y > 0 then
          { state | cursor = (Point.init x (y - 1)) }
        else
          state
      'h' ->
        if x > 0 then
          { state | cursor = (Point.init (x - 1) y) }
        else
          state
      'l' ->
        if x < maxX - 1 then
          { state | cursor = (Point.init (x + 1) y) }
        else
          state
      'i' ->
        { state | mode = Insert "" }
      _ ->
        Debug.log ("Unknown code " ++ (toString code))
        state

handleInsertKeyPress code text state =
  case code of
    27 ->  -- ESC Key
      { state | mode = Normal }
    13 ->  -- Enter Key
      { state | mode = Normal }
    8 ->  -- Backspace key
      { state | mode = Insert <| String.dropRight 1 text }
    _ ->
      let
        char = Char.fromCode code
      in
        -- if Char.isUpper char || Char.isLower char || Char.isDigit char || Char then
          { state | mode = Insert <| text ++ (String.fromChar char) }
        -- else
        --   state
