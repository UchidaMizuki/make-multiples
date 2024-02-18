module Msg exposing (..)


type Msg
    = Resize Float Float
    | SetField (List Int)
    | DrawCardsPlayer (List Int)
    | DrawCardsOpponent (List Int)
    | SelectCard Int
    | DeselectCard Int Int
