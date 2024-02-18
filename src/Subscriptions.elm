module Subscriptions exposing (..)

import Browser.Events as Events
import Model exposing (Model)
import Msg exposing (Msg)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Events.onResize <| \w h -> Msg.Resize (toFloat w) (toFloat h)
