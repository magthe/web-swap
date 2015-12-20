module Swap where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Json.Encode as JE
import Task
import Debug
import Signal
import Either exposing (..)

-- Model
type alias UserPwd = {user : String, pwd : String}
type alias UserPwdToken = {user : String, pwd : String, token : String}
type alias Model = (List String, List String, List String, Either UserPwd UserPwdToken)

initialModel : Model
initialModel = (["foo", "bar", "baz"], ["toto", "titi", "tata"], ["wibble", "wobble", "wubble"], Left {user = "", pwd = ""})

-- Update
type Action = NoAction
            | UpdateUsername String
            | UpdatePassword String
            | Authenticate
            | RequestGroups
            | NewGroup (List String) (List String) (List String)
            | NewToken String

update : Action -> Model -> (Model, Effects Action)
update action m =
  let (l, r, s, upt) = m
  in
    case action of
      NoAction -> Debug.log "NoAction" (m, Effects.none)
      UpdateUsername user -> elim (\ v -> ((l, r, s, Left {v | user = user}), Effects.none))
                             (\ _ -> (m, Effects.none))
                             upt
      UpdatePassword pwd -> elim (\ v -> ((l, r, s, Left {v | pwd = pwd}), Effects.none))
                            (\ _ -> (m, Effects.none))
                            upt
      Authenticate -> elim (\ v -> (m, postAuth v.user v.pwd))
                      (\ _ -> (m, Effects.none))
                      upt
      RequestGroups -> (m, getGroups)
      NewGroup l' r' s' -> ((l', r', s', upt), Effects.none)
      NewToken t -> elim (\ {user, pwd} -> ((l, r, s, Right {user = user, pwd = pwd, token = t}), Effects.none))
                    (\ v -> ((l, r, s, Right {v | token = t}), Effects.none))
                    upt

-- View
view : Signal.Address Action -> Model -> Html
view address (left, right, swappers, upt) =
  div [] [ h1 [] [text "Lefters"]
         , makeList left
         , h1 [] [text "Righters"]
         , makeList right
         , h1 [] [text "Swappers"]
         , makeList swappers
         , case upt of
             Left unpwd -> makeLoginView address unpwd
             Right token -> makeSwapView address token
         ]

makeLoginView : Signal.Address Action -> UserPwd -> Html
makeLoginView address {user, pwd} =
  div [] [ input [ placeholder "User name"
                 , value user
                 , on "input" targetValue (\ s -> Signal.message address (UpdateUsername s))
                 ] []
         , input [ placeholder "Password"
                 , value pwd
                 , on "input" targetValue (\ s -> Signal.message address (UpdatePassword s))
                 ] []
         , button [onClick address Authenticate] [text "Log in"]
         ]

makeSwapView : Signal.Address Action -> UserPwdToken -> Html
makeSwapView address token = text "TBD: makeSwapView"

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
