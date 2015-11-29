module Main where

import Effects exposing (Never)
import StartApp
import Swap
import Task
import Time

app = StartApp.start
      { init = (Swap.initialModel, Effects.none)
      , update = Swap.update
      , view = Swap.view
      , inputs = [timedGetGroups]
      }

main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks

timedGetGroups = Time.every (5 * Time.second) |> Signal.map (always Swap.RequestGroups)
