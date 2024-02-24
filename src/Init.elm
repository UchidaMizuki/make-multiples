module Init exposing (..)

import Browser.Dom
import Dict
import Element.Font as Font
import List
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Random
import Task


init : () -> ( Model, Cmd Msg )
init _ =
    ( initModel
    , Cmd.batch
        [ initResize initModel
        , initSetField initModel
        , initDrawCardsPlayer initModel
        , initDrawCardsOpponent initModel
        ]
    )


initModel : Model
initModel =
    { field = List.repeat initModelFieldLength Nothing
    , fieldLength = initModelFieldLength
    , fieldIndex = 0
    , playerHand = Dict.empty
    , opponentHand = Dict.empty
    , selectedHand = List.repeat initModelFieldLength Nothing
    , turn = Model.Player
    , turnOpponentSleep = 1000
    , ranks = initModelRanks
    , cardsPlayerInit = 7
    , cardsOpponentInit = 5
    , cardsDraw = 1
    , winner = Nothing
    , view = initModelView
    }


initModelFieldLength : Int
initModelFieldLength =
    3


initModelRanks : Nonempty Int
initModelRanks =
    Nonempty 1 <| List.range 2 initModelRanksMax


initModelRanksMax : Int
initModelRanksMax =
    5



-- https://colorhunt.co/palette/f4f4f2e8e8e8bbbfca495464
-- https://colorhunt.co/palette/d04848f3b95ffde7676895d2


initModelView : Model.View
initModelView =
    let
        lengthInitModelRanks =
            max (initModelFieldLength * 2 - 1) (Nonempty.length initModelRanks)

        boxPadding =
            0.5

        boxSpacing =
            0.5

        boxRounded =
            0.5

        boxWidth =
            toFloat lengthInitModelRanks * 2 + toFloat (lengthInitModelRanks - 1) * boxSpacing + boxPadding * 2
    in
    { boxZoom = 1
    , boxWidth = boxWidth
    , boxPadding = boxPadding
    , boxSpacing = boxSpacing
    , boxRounded = boxRounded
    , gameFontFamily = Font.external { name = "Poppins", url = "https://fonts.googleapis.com/css?family=Poppins" }
    , gameOpponentHandHeight = 3
    , gameInfoHeight = 2
    , gameFieldHeight = 3
    , gameSelectedHandHeight = 3
    , gamePlayerHandHeight = 3
    , gamePlayerButtonWidth = boxWidth / 2 - 1 - boxPadding - boxSpacing
    , gamePlayerButtonHeight = 2
    , gamePlayerButtonRounded = 0.25
    , gamePlayerButtonFontSize = 1
    , gameHandSpacing = 0.5
    , gameCardBorderWidth = 0.1
    , gameCardWidth = 2
    , gameCardHeight = 3
    , gameCardRounded = 0.25
    , gameCardFontSize = 1
    , gameCardNumberFontSize = 0.625
    , color1 = { red = 244, green = 244, blue = 242, alpha = 1 }
    , color2 = { red = 232, green = 232, blue = 232, alpha = 1 }
    , color3 = { red = 187, green = 191, blue = 202, alpha = 1 }
    , color4 = { red = 73, green = 84, blue = 100, alpha = 1 }
    , color5 = { red = 208, green = 72, blue = 72, alpha = 1 } 
    }


initSetField : Model -> Cmd Msg
initSetField model =
    Nonempty.sample model.ranks
        |> Random.list 1
        |> Random.generate Msg.SetField


initDrawCardsPlayer : Model -> Cmd Msg
initDrawCardsPlayer model =
    Nonempty.sample model.ranks
        |> Random.list model.cardsPlayerInit
        |> Random.generate Msg.DrawCardsPlayer


initDrawCardsOpponent : Model -> Cmd Msg
initDrawCardsOpponent model =
    Nonempty.sample model.ranks
        |> Random.list model.cardsOpponentInit
        |> Random.generate Msg.DrawCardsOpponent


initResize : Model -> Cmd Msg
initResize _ =
    Browser.Dom.getViewport
        |> Task.map (\{ viewport } -> ( viewport.width, viewport.height ))
        |> Task.perform (\( w, h ) -> Msg.Resize w h)
