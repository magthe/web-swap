module Swap where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Task
import Debug

-- Model
type alias Model = (List String, List String, List String)

initialModel = (["foo", "bar", "baz"], ["toto", "titi", "tata"], ["wibble", "wobble", "wubble"])

-- Update
type Action = NoAction
            | RequestGroups
            | NewGroup (List String) (List String) (List String)

update : Action -> Model -> (Model, Effects Action)
update action m =
  case action of
    NoAction -> Debug.log "NoAction" (m, Effects.none)
    RequestGroups -> (m, getGroups)
    NewGroup l r s -> ((l, r, s), Effects.none)

-- View
view : Signal.Address Action -> Model -> Html
view address (left, right, swappers) =
  div [] [ h1 [] [text "Lefters"]
         , makeList left
         , h1 [] [text "Righters"]
         , makeList right
         , h1 [] [text "Swappers"]
         , makeList swappers
         , button [onClick address RequestGroups] [text "get groups"]
         ]

makeList : List String -> Html
makeList xs = ol [] (List.map (\ i -> li [] [text i]) xs)

-- Effects
getGroups : Effects Action
getGroups = Http.get decodeGroups groupUrl
            |> Task.map (Debug.log "getGroups")
            |> Task.toMaybe
            |> Task.map (Maybe.withDefault NoAction)
            |> Effects.task

groupUrl = Http.url "http://localhost:3000/swap/groups" []

decodeGroups : Json.Decoder Action
decodeGroups =
  let
    e s = Json.at ["groups",s] (Json.list Json.string)
  in Json.object3 NewGroup (e "left") (e "right") (e "swappers")
