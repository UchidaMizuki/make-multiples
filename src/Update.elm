module Update exposing (..)

import Dict
import List
import List.Extra
import List.Nonempty as Nonempty exposing (Nonempty(..))
import Maybe.Extra
import Model exposing (Model)
import Msg exposing (Msg(..))
import Process
import Random
import Task
import Utils


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Resize w h ->
            updateResize model w h

        SetField cards ->
            updateSetField model cards

        DrawCardsPlayer cards ->
            updateDrawCardsPlayer model cards

        DrawCardsOpponent cards ->
            updateDrawCardsOpponent model cards

        SelectCard rank ->
            updateSelectCard model rank

        DeselectCard index rank ->
            updateDeselectCard model index rank

        PressPass ->
            updatePressPass model

        PressPlay ->
            updatePressPlay model

        TurnOpponent ->
            updateTurnOpponent model

        PlayCardsOpponent maybeCards ->
            updatePlayCardsOpponent model maybeCards


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
updateSetField model cards =
    let
        lengthCards =
            List.length cards

        field =
            List.map Just (List.sort cards)
                ++ List.repeat (model.fieldLength - lengthCards) Nothing
    in
    ( { model
        | field = field
        , fieldIndex = fieldIndex cards
      }
    , Cmd.none
    )


updateDrawCardsPlayer : Model -> List Int -> ( Model, Cmd Msg )
updateDrawCardsPlayer model cards =
    let
        playerHand =
            cards
                |> List.foldl Utils.addHand model.playerHand
    in
    ( { model | playerHand = playerHand }, Cmd.none )


updateDrawCardsOpponent : Model -> List Int -> ( Model, Cmd Msg )
updateDrawCardsOpponent model cards =
    let
        opponentHand =
            cards
                |> List.foldl Utils.addHand model.opponentHand
    in
    ( { model | opponentHand = opponentHand }, Cmd.none )


updateSelectCard : Model -> Int -> ( Model, Cmd Msg )
updateSelectCard model rank =
    let
        playerHand =
            Utils.takeHand rank model.playerHand

        selectedHand =
            case List.Extra.findIndex Maybe.Extra.isNothing model.selectedHand of
                Just index ->
                    List.Extra.setAt index (Just rank) model.selectedHand

                Nothing ->
                    model.selectedHand
    in
    ( { model
        | playerHand = playerHand
        , selectedHand = selectedHand
      }
    , Cmd.none
    )


updateDeselectCard : Model -> Int -> Int -> ( Model, Cmd Msg )
updateDeselectCard model index rank =
    let
        playerHand =
            Utils.addHand rank model.playerHand

        selectedHand =
            List.Extra.setAt index Nothing model.selectedHand
    in
    ( { model
        | playerHand = playerHand
        , selectedHand = selectedHand
      }
    , Cmd.none
    )


updatePressPass : Model -> ( Model, Cmd Msg )
updatePressPass model =
    let
        playerHand =
            model.selectedHand
                |> List.filterMap identity
                |> List.foldl Utils.addHand model.playerHand

        selectedHand =
            List.repeat (List.length model.selectedHand) Nothing

        turn =
            Model.Opponent
    in
    ( { model
        | playerHand = playerHand
        , selectedHand = selectedHand
        , turn = turn
      }
    , Cmd.batch
        [ Nonempty.sample model.ranks
            |> Random.list model.cardsDraw
            |> Random.generate Msg.DrawCardsPlayer
        , turnOpponent model
        ]
    )


updatePressPlay : Model -> ( Model, Cmd Msg )
updatePressPlay model =
    let
        cards =
            model.selectedHand
                |> List.filterMap identity

        lengthCards =
            List.length cards

        numberCards =
            List.sum cards

        maybeNumberField =
            model.field
                |> List.Extra.getAt model.fieldIndex
                |> Maybe.andThen identity
    in
    case maybeNumberField of
        Just numberField ->
            if lengthCards > 0 && modBy numberField numberCards == 0 then
                let
                    field =
                        List.map Just (List.sort cards)
                            ++ List.repeat (model.fieldLength - lengthCards) Nothing

                    playerHand =
                        Utils.clearHand model.playerHand

                    selectedHand =
                        List.repeat (List.length model.selectedHand) Nothing

                    turn =
                        Model.Opponent
                in
                ( { model
                    | field = field
                    , fieldIndex = fieldIndex cards
                    , playerHand = playerHand
                    , selectedHand = selectedHand
                    , turn = turn
                  }
                , turnOpponent model
                )

            else
                ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateTurnOpponent : Model -> ( Model, Cmd Msg )
updateTurnOpponent model =
    let
        maybeRank =
            List.Extra.getAt model.fieldIndex model.field
                |> Maybe.andThen identity
    in
    case maybeRank of
        Just rank ->
            ( model
            , generatorOpponentCards model rank
                |> Random.generate Msg.PlayCardsOpponent
            )

        _ ->
            ( model, Cmd.none )


updatePlayCardsOpponent : Model -> Maybe (List Int) -> ( Model, Cmd Msg )
updatePlayCardsOpponent model maybeCards =
    case maybeCards of
        Just cards ->
            let
                field =
                    List.map Just (List.sort cards)
                        ++ List.repeat (model.fieldLength - List.length cards) Nothing

                opponentHand =
                    cards
                        |> List.foldl Utils.takeHand model.opponentHand
                        |> Utils.clearHand

                turn =
                    Model.Player
            in
            ( { model
                | field = field
                , opponentHand = opponentHand
                , turn = turn
              }
            , Cmd.none
            )

        Nothing ->
            let
                turn =
                    Model.Player
            in
            ( { model | turn = turn }
            , Nonempty.sample model.ranks
                |> Random.list 1
                |> Random.generate DrawCardsOpponent
            )


fieldIndex : List Int -> Int
fieldIndex _ =
    0


turnOpponent : Model -> Cmd Msg
turnOpponent model =
    Process.sleep model.turnOpponentSleep
        |> Task.perform (\_ -> Msg.TurnOpponent)


generatorOpponentCards : Model -> Int -> Random.Generator (Maybe (List Int))
generatorOpponentCards model rank =
    case listOpponentCards model rank of
        x :: xs ->
            Nonempty x xs
                |> Nonempty.map Just
                |> Nonempty.sample

        _ ->
            Random.constant Nothing


listOpponentCards : Model -> Int -> List (List Int)
listOpponentCards model rank =
    List.range 1 model.fieldLength
        |> List.concatMap
            (\length_ ->
                cartesianListCards model.opponentHand length_
                    |> filterCards model.opponentHand
            )
        |> List.filter
            (\cards ->
                modBy rank (List.sum cards) == 0
            )
        |> List.filter
            (\cards ->
                let
                    maybeRank =
                        List.Extra.getAt (fieldIndex cards) cards
                in
                case maybeRank of
                    Just rank_ ->
                        if Utils.lengthHand model.opponentHand > List.length cards && Utils.lengthHand model.playerHand <= model.fieldLength then
                            modBy rank_ (Utils.sumHand model.playerHand) /= 0

                        else
                            True

                    Nothing ->
                        False
            )


filterCards : Model.Hand -> List (List Int) -> List (List Int)
filterCards hand listCards =
    listCards
        |> List.filter
            (\cards ->
                cards
                    |> List.foldl Utils.addHand Dict.empty
                    |> Utils.containHand hand
            )


cartesianListCards : Model.Hand -> Int -> List (List Int)
cartesianListCards hand length =
    if length == 0 then
        [ [] ]

    else
        Dict.keys hand
            |> List.concatMap
                (\rank ->
                    cartesianListCards hand (length - 1)
                        |> List.map (\listCards -> rank :: listCards)
                )
