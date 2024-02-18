module View exposing (..)

import Dict
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)
import Utils


view : Model -> Html Msg
view model =
    Element.layout
        [ Background.color <| Element.fromRgb255 model.view.color4 ]
    <|
        Element.column
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
        List.map (\( rank, cards ) -> viewGameCard model CardOpponentHand rank cards) <|
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
        [ viewGameCard model CardField model.field.first 1
        , viewGameCardText model "≤"
        , viewGameCard model CardField model.field.second 1
        , viewGameCardText model "≤"
        , viewGameCard model CardField model.field.third 1
        ]


viewGameInfo : Model -> Element Msg
viewGameInfo model =
    Element.el
        [ Element.width Element.fill
        , Element.height <| Element.px <| boxZoom model model.view.gameInfoHeight
        , Element.centerX
        , Font.color <| Element.fromRgb255 model.view.color4
        , Font.size <| boxZoom model model.view.gameInfoFontSize
        ]
    <|
        Element.el
            [ Element.centerX
            , Element.centerY
            ]
        <|
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
        [ viewGameCard model (CardSelectedHand 1) (Utils.maybeIntToInt model.selectedHand.first) 1
        , viewGameCardText model "+"
        , viewGameCard model (CardSelectedHand 2) (Utils.maybeIntToInt model.selectedHand.second) 1
        , viewGameCardText model "+"
        , viewGameCard model (CardSelectedHand 3) (Utils.maybeIntToInt model.selectedHand.third) 1
        ]


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
        List.map (\( rank, cards ) -> viewGameCard model CardPlayerHand rank cards) <|
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
        [ Element.el
            [ Element.width <| Element.px <| boxZoom model model.view.gamePlayerButtonWidth
            , Element.height Element.fill
            , Element.alignLeft
            , Border.rounded <| boxZoom model model.view.gamePlayerButtonRounded
            , Background.color <| Element.fromRgb255 model.view.color4
            ]
          <|
            Element.el
                [ Element.centerX
                , Element.centerY
                ]
            <|
                Element.text "Draw"
        , Element.el
            [ Element.width <| Element.px <| boxZoom model model.view.gamePlayerButtonWidth
            , Element.height Element.fill
            , Element.alignRight
            , Border.rounded <| boxZoom model model.view.gamePlayerButtonRounded
            , Background.color <| Element.fromRgb255 model.view.color4
            ]
          <|
            Element.el
                [ Element.centerX
                , Element.centerY
                ]
            <|
                Element.text "Play"
        ]


viewGameCard : Model -> Card -> Int -> Int -> Element Msg
viewGameCard model card rank cards =
    let
        labelRank =
            if rank <= 0 || cards == 0 then
                ""

            else
                String.fromInt rank

        labelNumber =
            if rank <= 0 || cards <= 1 then
                ""

            else
                "× " ++ String.fromInt cards

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

        backgroundColor =
            if rank <= 0 || cards == 0 then
                model.view.color3

            else
                model.view.color1

        fontColor =
            if rank <= 0 || cards == 0 then
                model.view.color1

            else
                model.view.color4

        attributes =
            [ Background.color <| Element.fromRgb255 backgroundColor
            , Element.width <| Element.px <| boxZoom model model.view.gameCardWidth
            , Element.height <| Element.px <| boxZoom model model.view.gameCardHeight
            , Border.width <| boxZoom model model.view.gameCardBorderWidth
            , Border.color <| Element.fromRgb255 model.view.color3
            , Border.rounded <| boxZoom model model.view.gameCardRounded
            , Element.centerX
            , Element.centerY
            , Font.color <| Element.fromRgb255 fontColor
            ]
    in
    case card of
        CardPlayerHand ->
            Input.button attributes
                { onPress =
                    if cards <= 0 then
                        Nothing

                    else
                        Just (Msg.SelectCard rank)
                , label = label
                }

        CardSelectedHand index ->
            Input.button attributes
                { onPress =
                    if rank <= 0 then
                        Nothing

                    else
                        Just (Msg.DeselectCard index rank)
                , label = label
                }

        _ ->
            Element.el attributes label


type Card
    = CardField
    | CardPlayerHand
    | CardOpponentHand
    | CardSelectedHand Int


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
