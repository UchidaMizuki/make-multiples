module Model exposing (..)

import Dict exposing (Dict)
import Element.Font as Font
import List.Nonempty exposing (Nonempty)


type alias Model =
    { field : Field
    , fieldLength : Int
    , fieldIndex : Int
    , playerHand : Hand
    , opponentHand : Hand
    , selectedHand : Field
    , turn : Turn
    , turnOpponentSleep : Float
    , ranks : Nonempty Int
    , cardsPlayerInit : Int
    , cardsOpponentInit : Int
    , cardsDraw : Int
    , winner : Maybe Turn
    , view : View
    }


type alias Field =
    List (Maybe Int)


type alias Hand =
    Dict Int Int


type Turn
    = Player
    | Opponent


type alias View =
    { boxZoom : Float
    , boxWidth : Float
    , boxPadding : Float
    , boxSpacing : Float
    , boxRounded : Float
    , gameFontFamily : Font.Font
    , gameOpponentHandHeight : Float
    , gameInfoHeight : Float
    , gameFieldHeight : Float
    , gameSelectedHandHeight : Float
    , gamePlayerHandHeight : Float
    , gamePlayerButtonWidth : Float
    , gamePlayerButtonHeight : Float
    , gamePlayerButtonRounded : Float
    , gamePlayerButtonFontSize : Float
    , gameHandSpacing : Float
    , gameCardBorderWidth : Float
    , gameCardWidth : Float
    , gameCardHeight : Float
    , gameCardRounded : Float
    , gameCardFontSize : Float
    , gameCardNumberFontSize : Float
    , color1 : Color
    , color2 : Color
    , color3 : Color
    , color4 : Color
    , color5 : Color
    }


type alias Color =
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }
