import Effects exposing (Never)
import StartApp
import Swap
import Task

app = StartApp.start
      { init = (Swap.initialModel, Effects.none)
      , update = Swap.update
      , view = Swap.view
      , inputs = []
      }

main = app.html

port tasks : Signal (Task.Task Never ())
port tasks = app.tasks
