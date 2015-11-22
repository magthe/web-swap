module Swap where

import Effects exposing (Effects)
import Html exposing (..)

-- Model
type Model = Start

-- Update
type Action = Login String String

update : Action -> Model -> (Model, Effects Action)
update a m = (Start, Effects.none)

-- View
view : Signal.Address Action -> Model -> Html
view addr m = text "foo bar baz"
