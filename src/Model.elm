module Model exposing (..)

import Dict exposing (Dict)
import Element.Font as Font
import List.Nonempty exposing (Nonempty)


type alias Model =
    { field : Field
    , playerHand : Hand
    , opponentHand : Hand
    , selectedHand : SelectedHand
    , turn : Turn
    , ranks : Nonempty Int
    , cards : Int
    , view : View
    }


type alias Field =
    { first : Int
    , second : Int
    , third : Int
    }


type alias Hand =
    Dict Int Int


type alias SelectedHand =
    { first : Maybe Int
    , second : Maybe Int
    , third : Maybe Int
    }


type alias Turn =
    ()


type alias View =
    { boxZoom : Float
    , boxWidth : Float
    , boxPadding : Float
    , boxSpacing : Float
    , boxRounded : Float
    , gameFontFamily : Font.Font
    , gameOpponentHandHeight : Float
    , gameInfoHeight : Float
    , gameInfoFontSize : Float
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
    }


type alias Color =
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }
