module Swap where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Json.Encode as JE
import Task
import Debug
import Signal

-- Model
type alias Model = (List String, List String, List String)

initialModel : Model
initialModel = (["foo", "bar", "baz"], ["toto", "titi", "tata"], ["wibble", "wobble", "wubble"])

-- Update
type Action = NoAction
            | Auth
            | RequestGroups
            | NewGroup (List String) (List String) (List String)
            | NewToken String

update : Action -> Model -> (Model, Effects Action)
update action m =
  case action of
    NoAction -> Debug.log "NoAction" (m, Effects.none)
    Auth -> Debug.log "Auth" (m, postAuth "Viveka" "magnus")
    RequestGroups -> (m, getGroups)
    -- RequestGroups -> (m, Effects.none)
    NewGroup l r s -> ((l, r, s), Effects.none)
    NewToken _ -> Debug.log "NewToken" (m, Effects.none)

-- View
view : Signal.Address Action -> Model -> Html
view address (left, right, swappers) =
  div [] [ h1 [] [text "Lefters"]
         , makeList left
         , h1 [] [text "Righters"]
         , makeList right
         , h1 [] [text "Swappers"]
         , makeList swappers
         , button [onClick address Auth] [text "Post"]
         ]

makeList : List String -> Html
makeList xs = ol [] (List.map (\ i -> li [] [text i]) xs)

-- Effects
getGroups : Effects Action
getGroups = jsonGet decodeGroups groupUrl
            -- |> Task.map (Debug.log "getGroups")
            |> Task.toMaybe
            |> Task.map (Maybe.withDefault NoAction)
            |> Effects.task

groupUrl : String
groupUrl = Http.url "http://localhost:3000/swap/groups" []

decodeGroups : Json.Decoder Action
decodeGroups =
  let
    e s = Json.at ["groups",s] (Json.list Json.string)
  in Json.object3 NewGroup (e "left") (e "right") (e "swappers")

postAuth : String -> String -> Effects Action
postAuth name pword = jsonPost decodeToken authUrl (authBody name pword)
                      |> Task.map (Debug.log "postAuth")
                      |> Task.toMaybe
                      |> Task.map (Maybe.withDefault NoAction)
                      |> Effects.task

authUrl : String
authUrl = Http.url "http://localhost:3000/swap/auth" []

authBody : String -> String -> Http.Body
authBody n p =
  let
    o = JE.object [("name", JE.string n), ("pword", JE.string p)]
  in Http.string (JE.encode 0 o)

decodeToken : Json.Decoder Action
decodeToken = Json.object1 NewToken (Json.at ["token"] Json.string)

jsonGet : Json.Decoder value -> String -> Task.Task Http.Error value
jsonGet decoder url =
  let request = { verb = "GET"
                , headers = [("Content-Type", "application/json")]
                , url = url
                , body = Http.empty
                }
  in
    Http.fromJson decoder (Http.send Http.defaultSettings request)

jsonPost : Json.Decoder value -> String -> Http.Body -> Task.Task Http.Error value
jsonPost decoder url body =
  let request = { verb = "POST"
                , headers = [("Content-Type", "application/json")]
                , url = url
                , body = body
                }
  in
    Http.fromJson decoder (Http.send Http.defaultSettings request)
