module Fridge exposing (..)

import State exposing (State)
import Point exposing (Point)
import Magnet exposing (Magnet)
import View
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Dict exposing (Dict)
import Time exposing (Time, millisecond)
import Keyboard exposing (KeyCode)
import Json.Decode as Decode
import Json.Encode as Encode
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Html.Events.Extra exposing (onEnter)

-- MODEL

type alias Flags =
  { url: String
  }

type alias Model =
  { socket: Phoenix.Socket.Socket Msg
  , state: State
  , status: Status
  }

type Status
  = NotConnected String
  | Connecting String
  | Connected String

init : Flags -> (Model, Cmd Msg)
init flags =
  { socket =
    Phoenix.Socket.init flags.url
    |> Phoenix.Socket.withDebug
  , state = State.init
  , status = NotConnected ""
  } ! []

-- UPDATE

type Msg
  = NoOp
  | PressedKey KeyCode
  | PhoenixMsg (Phoenix.Socket.Msg Msg)
  | JoinChannel
  | ChannelTextChanged String
  | ChannelJoined
  | ChannelLeft
  | ReceiveMagnet Encode.Value
  | BlinkCursor Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []
    PressedKey code ->
      let
        newState = State.handleKeyPress code model.state
        newModel = { model | state = newState }
      in
        case (model.status, model.state.mode, newState.mode) of
          (Connected room, State.Insert text, State.Normal) ->
            let
              payload = Magnet.encode model.state.cursor text
              room_id = "fridge:" ++ room
              push = Phoenix.Push.init "add_word" room_id |> Phoenix.Push.withPayload payload
              (socket, cmd) = Phoenix.Socket.push push model.socket
              finalModel = { newModel | socket = socket }
            in
              finalModel ! [Cmd.map PhoenixMsg cmd]
          _ ->
            newModel ! []
    PhoenixMsg msg ->
      let
        ( socket, phxCmd ) = Phoenix.Socket.update msg model.socket
      in
        ( { model | socket = socket }
        , Cmd.map PhoenixMsg phxCmd
        )
    JoinChannel ->
      case model.status of
        NotConnected text ->
          let
            room = "fridge:" ++ text
            socket = model.socket |> Phoenix.Socket.on "add_word" room ReceiveMagnet
            channel =
              Phoenix.Channel.init room
              |> Phoenix.Channel.onJoin (always ChannelJoined)
              |> Phoenix.Channel.onClose (always ChannelLeft)

            (newSocket, phxCmd) = Phoenix.Socket.join channel socket
          in
            ( { model | socket = newSocket }
            , Cmd.map PhoenixMsg phxCmd
            )
        _ ->
          model ! []
    ChannelTextChanged text ->
      case model.status of
        NotConnected _ ->
          { model | status = NotConnected text } ! []
        _ ->
          model ! []
    ChannelJoined ->
      let name = channelName model.status
      in
        { model | status = Connected name } ! []
    ChannelLeft ->
      let name = channelName model.status
      in
        { model | status = NotConnected name } ! []
    ReceiveMagnet value ->
      case Decode.decodeValue Magnet.decode value of
        Ok magnet ->
          let
            state = model.state
            newState = { state | magnets = magnet :: state.magnets }
            newModel = { model | state = newState }
          in
            newModel ! []
        Err error ->
          Debug.log ("Error decoding magnet: " ++ (toString error))
          model ! []
    BlinkCursor _ ->
      let
        state = model.state
        newState = { state | cursorVisible = not state.cursorVisible }
        newModel = { model | state = newState }
      in
        newModel ! []

channelName status =
  case status of
    NotConnected name ->
      name
    Connecting name ->
      name
    Connected name ->
      name

-- VIEW

view model =
  case model.status of
    NotConnected name ->
      div []
        [ input [type_ "text", value name, autofocus True, onEnter JoinChannel, onInput ChannelTextChanged] []
        , button [onClick JoinChannel] [text "Join"]
        ]
    Connecting name ->
      div [] [text ("Connecting to" ++ name)]
    Connected _ ->
      div [] [pre [] [(content model)]]

content : Model -> Html Msg
content model =
  View.render model.state

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.status of
    Connected _ ->
      Sub.batch
        [ Phoenix.Socket.listen model.socket PhoenixMsg
        , Keyboard.presses PressedKey
        , Time.every (500 * millisecond) BlinkCursor
        ]
    _ ->
      Phoenix.Socket.listen model.socket PhoenixMsg
