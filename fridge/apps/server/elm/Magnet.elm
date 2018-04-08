module Magnet exposing (..)

import Point exposing (Point)
import Json.Encode as Encode
import Json.Decode as Decode

type alias Magnet =
  { id: String
  , text: String
  , location: Point
  }

encode : Point -> String -> Encode.Value
encode { x, y } word =
  Encode.object
    [ ("x", Encode.int x)
    , ("y", Encode.int y)
    , ("word", Encode.string word)
    ]

decode : Decode.Decoder Magnet
decode =
  Decode.map3 Magnet
    (Decode.field "id" Decode.string)
    (Decode.field "text" Decode.string)
    (Decode.map2 Point
      (Decode.field "x" Decode.int)
      (Decode.field "y" Decode.int))
