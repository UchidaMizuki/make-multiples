module Update exposing (..)

import List
import Model exposing (Model)
import Msg exposing (Msg(..))
import Tuple exposing (second)
import Utils


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize w h ->
            updateResize model w h

        SetField ranks ->
            updateSetField model ranks

        DrawCardsPlayer ranks ->
            updateDrawCardsPlayer model ranks

        DrawCardsOpponent ranks ->
            updateDrawCardsOpponent model ranks

        SelectCard rank ->
            updateSelectCard model rank

        DeselectCard index rank ->
            updateDeselectCard model index rank


updateResize : Model -> Float -> Float -> ( Model, Cmd Msg )
updateResize model w h =
    let
        view =
            model.view

        boxWidth =
            view.boxWidth

        boxHeight =
            List.sum
                [ view.gameOpponentHandHeight
                , view.gameFieldHeight
                , view.gameInfoHeight
                , view.gameSelectedHandHeight
                , view.gamePlayerHandHeight
                , view.gamePlayerButtonHeight
                , view.boxPadding * 2
                , view.boxSpacing * 5
                ]

        boxZoom =
            if w / h < boxWidth / boxHeight then
                w / boxWidth

            else
                h / boxHeight
    in
    ( { model | view = { view | boxZoom = boxZoom } }, Cmd.none )


updateSetField : Model -> List Int -> ( Model, Cmd Msg )
updateSetField model ranks =
    case List.sort ranks of
        [ first, second, third ] ->
            ( { model | field = { first = first, second = second, third = third } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateDrawCardsPlayer : Model -> List Int -> ( Model, Cmd Msg )
updateDrawCardsPlayer model ranks =
    let
        playerHand =
            ranks
                |> List.foldl Utils.addHand model.playerHand
    in
    ( { model | playerHand = playerHand }, Cmd.none )


updateDrawCardsOpponent : Model -> List Int -> ( Model, Cmd Msg )
updateDrawCardsOpponent model ranks =
    let
        opponentHand =
            ranks
                |> List.foldl Utils.addHand model.opponentHand
    in
    ( { model | opponentHand = opponentHand }, Cmd.none )


updateSelectCard : Model -> Int -> ( Model, Cmd Msg )
updateSelectCard model rank =
    let
        selectedHand =
            model.selectedHand

        first =
            selectedHand.first

        second =
            selectedHand.second

        third =
            selectedHand.third

        playerHand =
            Utils.takeHand rank model.playerHand
    in
    case ( first, second, third ) of
        ( Nothing, _, _ ) ->
            ( { model
                | playerHand = playerHand
                , selectedHand = { selectedHand | first = Just rank }
              }
            , Cmd.none
            )

        ( _, Nothing, _ ) ->
            ( { model
                | playerHand = playerHand
                , selectedHand = { selectedHand | second = Just rank }
              }
            , Cmd.none
            )

        ( _, _, Nothing ) ->
            ( { model
                | playerHand = playerHand
                , selectedHand = { selectedHand | third = Just rank }
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


updateDeselectCard : Model -> Int -> Int -> ( Model, Cmd Msg )
updateDeselectCard model index rank =
    let
        selectedHand =
            model.selectedHand

        first =
            selectedHand.first

        second =
            selectedHand.second

        third =
            selectedHand.third

        playerHand =
            Utils.addHand rank model.playerHand
    in
    case index of
        1 ->
            ( { model
                | playerHand = playerHand
                , selectedHand = { selectedHand | first = Nothing }
              }
            , Cmd.none
            )

        2 ->
            ( { model
                | playerHand = playerHand
                , selectedHand = { selectedHand | second = Nothing }
              }
            , Cmd.none
            )

        3 ->
            ( { model
                | playerHand = playerHand
                , selectedHand = { selectedHand | third = Nothing }
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )
