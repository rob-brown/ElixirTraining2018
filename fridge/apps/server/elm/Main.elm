module Main exposing (..)

import Html exposing (..)
import Fridge exposing (Flags, Model, Msg, init, view, update, subscriptions)

-- MAIN

main : Program Flags Model Msg
main =
  programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

