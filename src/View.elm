module View exposing (..)

import Dict
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Maybe.Extra
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
    Element.layout
        [ Background.color <| Element.fromRgb255 model.view.color4 ]
    <|
        Element.column
            [ Element.width <| Element.fill
            , Element.height <| Element.fill
            ]
            [ Element.column
                [ Background.color <| Element.fromRgb255 model.view.color2
                , Element.width <| Element.px <| boxZoom model model.view.boxWidth
                , Element.centerX
                , Element.centerY
                , Element.padding <| boxZoom model model.view.boxPadding
                , Element.spacing <| boxZoom model model.view.boxSpacing
                , Border.rounded <| boxZoom model model.view.boxRounded
                , Font.family [ model.view.gameFontFamily ]
                ]
                [ viewGameOpponentHand model
                , viewGameField model
                , viewGameInfo model
                , viewGameSelectedHand model
                , viewGamePlayerHand model
                , viewGamePlayerButton model
                ]
            , viewFooter model
            ]


viewGameOpponentHand : Model -> Element Msg
viewGameOpponentHand model =
    Element.row
        [ Element.width Element.fill
        , Element.height <| Element.px <| boxZoom model model.view.gameOpponentHandHeight
        , Element.centerX
        , Element.centerY
        , Element.spacing <| boxZoom model model.view.gameHandSpacing
        ]
    <|
        List.map (\( rank, cards ) -> viewGameCard model OpponentHandCard (Just rank) cards) <|
            Dict.toList model.opponentHand


viewGameField : Model -> Element Msg
viewGameField model =
    Element.row
        [ Element.width Element.fill
        , Element.height <| Element.px <| boxZoom model model.view.gameFieldHeight
        , Element.centerX
        , Element.centerY
        , Element.spacing <| boxZoom model model.view.gameHandSpacing
        ]
    <|
        List.intersperse (viewGameCardText model "≤") <|
            List.indexedMap (\index maybeRank -> viewGameCard model (FieldCard index) maybeRank 1) model.field


viewGameInfo : Model -> Element Msg
viewGameInfo model =
    Element.el
        [ Element.width Element.fill
        , Element.height <| Element.px <| boxZoom model model.view.gameInfoHeight
        , Element.centerX
        , Element.centerY
        , Element.spacing <| boxZoom model model.view.gameHandSpacing
        , Font.size <| boxZoom model model.view.gameCardFontSize
        , Font.color <| Element.fromRgb255 model.view.color5
        ]
    <|
        Element.el
            [ Element.centerX
            , Element.centerY
            ]
        <|
            case model.winner of
                Just Model.Player ->
                    Element.text "You win!"

                Just Model.Opponent ->
                    Element.text "You lose!"

                Nothing ->
                    Element.text "× n ="


viewGameSelectedHand : Model -> Element Msg
viewGameSelectedHand model =
    Element.row
        [ Element.width Element.fill
        , Element.height <| Element.px <| boxZoom model model.view.gameSelectedHandHeight
        , Element.centerX
        , Element.centerY
        , Element.spacing <| boxZoom model model.view.gameHandSpacing
        ]
    <|
        List.intersperse (viewGameCardText model "+") <|
            List.indexedMap (\index maybeRank -> viewGameCard model (SelectedHandCard index) maybeRank 1) model.selectedHand


viewGamePlayerHand : Model -> Element Msg
viewGamePlayerHand model =
    Element.row
        [ Element.width Element.fill
        , Element.height <| Element.px <| boxZoom model model.view.gamePlayerHandHeight
        , Element.centerX
        , Element.centerY
        , Element.spacing <| boxZoom model model.view.gameHandSpacing
        ]
    <|
        List.map (\( rank, cards ) -> viewGameCard model PlayerHandCard (Just rank) cards) <|
            Dict.toList model.playerHand


viewGamePlayerButton : Model -> Element Msg
viewGamePlayerButton model =
    Element.row
        [ Element.width Element.fill
        , Element.height <| Element.px <| boxZoom model model.view.gamePlayerButtonHeight
        , Element.centerX
        , Element.centerY
        , Font.size <| boxZoom model model.view.gamePlayerButtonFontSize
        , Font.color <| Element.fromRgb255 model.view.color1
        ]
        [ Input.button
            [ Element.width <| Element.px <| boxZoom model model.view.gamePlayerButtonWidth
            , Element.height Element.fill
            , Element.alignLeft
            , Border.rounded <| boxZoom model model.view.gamePlayerButtonRounded
            , Background.color <| Element.fromRgb255 model.view.color4
            ]
            { onPress =
                if model.turn == Model.Player && Maybe.Extra.isNothing model.winner then
                    Just Msg.PressPass

                else
                    Nothing
            , label =
                Element.el
                    [ Element.centerX
                    , Element.centerY
                    ]
                <|
                    Element.text "Pass"
            }
        , Input.button
            [ Element.width <| Element.px <| boxZoom model model.view.gamePlayerButtonWidth
            , Element.height Element.fill
            , Element.alignRight
            , Border.rounded <| boxZoom model model.view.gamePlayerButtonRounded
            , Background.color <| Element.fromRgb255 model.view.color5
            ]
            { onPress =
                if model.turn == Model.Player && Maybe.Extra.isNothing model.winner then
                    Just Msg.PressPlay

                else
                    Nothing
            , label =
                Element.el
                    [ Element.centerX
                    , Element.centerY
                    ]
                <|
                    Element.text "Play"
            }
        ]


viewFooter : Model -> Element Msg
viewFooter model =
    Element.el
        [ Element.width Element.fill
        , Element.height <| Element.px <| boxZoom model model.view.footerHeight
        , Element.centerX
        , Element.centerY
        , Font.size <| boxZoom model model.view.footerFontSize
        , Font.color <| Element.fromRgb255 model.view.color3
        ]
    <|
        Element.newTabLink
            [ Element.centerX
            , Element.centerY
            ]
            { url = "https://github.com/UchidaMizuki/make-multiples"
            , label = Element.text "https://github.com/UchidaMizuki/make-multiples"
            }

viewGameCard : Model -> GameCard -> Maybe Int -> Int -> Element Msg
viewGameCard model gameCard maybeRank cards =
    let
        labelRank =
            case maybeRank of
                Just rank ->
                    if cards <= 0 then
                        ""

                    else
                        String.fromInt rank

                Nothing ->
                    ""

        labelNumber =
            if Maybe.Extra.isNothing maybeRank || cards <= 1 then
                ""

            else
                "× " ++ String.fromInt cards

        backgroundColor =
            if Maybe.Extra.isNothing maybeRank || cards == 0 then
                model.view.color3

            else
                case gameCard of
                    FieldCard index ->
                        if index == model.fieldIndex then
                            model.view.color1

                        else
                            model.view.color3

                    PlayerHandCard ->
                        if model.turn == Model.Player then
                            model.view.color1

                        else
                            model.view.color3

                    OpponentHandCard ->
                        if model.turn == Model.Opponent then
                            model.view.color1

                        else
                            model.view.color3

                    _ ->
                        model.view.color1

        borderColor =
            case gameCard of
                FieldCard index ->
                    if index == model.fieldIndex then
                        model.view.color5

                    else
                        model.view.color3

                SelectedHandCard _ ->
                    model.view.color5

                _ ->
                    model.view.color3

        fontColor =
            model.view.color4

        attributes =
            [ Background.color <| Element.fromRgb255 backgroundColor
            , Element.width <| Element.px <| boxZoom model model.view.gameCardWidth
            , Element.height <| Element.px <| boxZoom model model.view.gameCardHeight
            , Border.width <| boxZoom model model.view.gameCardBorderWidth
            , Border.color <| Element.fromRgb255 borderColor
            , Border.rounded <| boxZoom model model.view.gameCardRounded
            , Element.centerX
            , Element.centerY
            , Font.color <| Element.fromRgb255 fontColor
            ]

        label =
            Element.column
                [ Element.width <| Element.fill
                , Element.height <| Element.fill
                ]
                [ Element.el
                    [ Element.height <| Element.fillPortion 5 ]
                  <|
                    Element.none
                , Element.el
                    [ Element.height <| Element.fillPortion 8
                    , Element.centerX
                    , Font.size <| boxZoom model model.view.gameCardFontSize
                    ]
                  <|
                    Element.el [ Element.centerY ] <|
                        Element.text labelRank
                , Element.el
                    [ Element.height <| Element.fillPortion 5
                    , Element.centerX
                    , Element.centerY
                    , Font.size <| boxZoom model <| model.view.gameCardNumberFontSize
                    ]
                  <|
                    Element.el [ Element.centerY ] <|
                        Element.text labelNumber
                ]
    in
    case gameCard of
        PlayerHandCard ->
            Input.button attributes
                { onPress =
                    if model.turn == Model.Player && cards > 0 && List.any Maybe.Extra.isNothing model.selectedHand && Maybe.Extra.isNothing model.winner then
                        Maybe.map Msg.SelectCard maybeRank

                    else
                        Nothing
                , label = label
                }

        SelectedHandCard index ->
            Input.button attributes
                { onPress =
                    if model.turn == Model.Player && Maybe.Extra.isNothing model.winner then
                        Maybe.map (Msg.DeselectCard index) maybeRank

                    else
                        Nothing
                , label = label
                }

        _ ->
            Element.el attributes label


type GameCard
    = FieldCard Int
    | PlayerHandCard
    | OpponentHandCard
    | SelectedHandCard Int


viewGameCardText : Model -> String -> Element Msg
viewGameCardText model text =
    Element.el
        [ Element.width <| Element.px <| boxZoom model model.view.gameCardWidth
        , Element.height <| Element.px <| boxZoom model model.view.gameCardHeight
        , Element.centerX
        , Element.centerY
        , Font.color <| Element.fromRgb255 model.view.color4
        , Font.size <| boxZoom model model.view.gameCardFontSize
        ]
    <|
        Element.el
            [ Element.centerX
            , Element.centerY
            ]
        <|
            Element.text text


boxZoom : Model -> Float -> Int
boxZoom model size =
    floor (model.view.boxZoom * size)
