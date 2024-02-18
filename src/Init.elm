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
    { field = { first = 0, second = 0, third = 0 }
    , playerHand = Dict.empty
    , opponentHand = Dict.empty
    , selectedHand = { first = Nothing, second = Nothing, third = Nothing }
    , turn = ()
    , ranks = Nonempty 1 <| List.range 2 9
    , cards = 9
    , view = initModelView
    }



-- https://colorhunt.co/palette/f4f4f2e8e8e8bbbfca495464
-- https://colorate.azurewebsites.net


initModelView : Model.View
initModelView =
    { boxZoom = 1
    , boxWidth = 23
    , boxPadding = 0.5
    , boxSpacing = 0.5
    , boxRounded = 0.5
    , gameFontFamily = Font.external { name = "Poppins", url = "https://fonts.googleapis.com/css?family=Poppins" }
    , gameOpponentHandHeight = 3
    , gameInfoHeight = 1.5
    , gameInfoFontSize = 1
    , gameFieldHeight = 3
    , gameSelectedHandHeight = 3
    , gamePlayerHandHeight = 3
    , gamePlayerButtonWidth = 9.5
    , gamePlayerButtonHeight = 1.5
    , gamePlayerButtonRounded = 0.25
    , gamePlayerButtonFontSize = 0.75
    , gameHandSpacing = 0.5
    , gameCardBorderWidth = 0.05
    , gameCardWidth = 2
    , gameCardHeight = 3
    , gameCardRounded = 0.25
    , gameCardFontSize = 1
    , gameCardNumberFontSize = 0.625
    , color1 = colorWhite
    , color2 = colorGray
    , color3 = colorPaleNavy
    , color4 = colorGrayishBlue
    }


colorWhite : Model.Color
colorWhite =
    { red = 244, green = 244, blue = 242, alpha = 1 }


colorGray : Model.Color
colorGray =
    { red = 232, green = 232, blue = 232, alpha = 1 }


colorPaleNavy : Model.Color
colorPaleNavy =
    { red = 187, green = 191, blue = 202, alpha = 1 }


colorGrayishBlue : Model.Color
colorGrayishBlue =
    { red = 73, green = 84, blue = 100, alpha = 1 }


initSetField : Model -> Cmd Msg
initSetField model =
    Nonempty.sample model.ranks
        |> Random.list 3
        |> Random.generate Msg.SetField


initDrawCardsPlayer : Model -> Cmd Msg
initDrawCardsPlayer model =
    Nonempty.sample model.ranks
        |> Random.list model.cards
        |> Random.generate Msg.DrawCardsPlayer


initDrawCardsOpponent : Model -> Cmd Msg
initDrawCardsOpponent model =
    Nonempty.sample model.ranks
        |> Random.list model.cards
        |> Random.generate Msg.DrawCardsOpponent


initResize : Model -> Cmd Msg
initResize _ =
    Browser.Dom.getViewport
        |> Task.map (\{ viewport } -> ( viewport.width, viewport.height ))
        |> Task.perform (\( w, h ) -> Msg.Resize w h)
