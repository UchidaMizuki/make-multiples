module MakeMultiples exposing (..)

import Browser
import Model exposing (Model)
import Msg exposing (Msg)
import Init exposing (init)
import View exposing (view)
import Update exposing (update)
import Subscriptions exposing (subscriptions)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
