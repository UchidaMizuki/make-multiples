module Utils exposing (..)

import Dict
import Model


addHand : Int -> Model.Hand -> Model.Hand
addHand rank hand =
    Dict.update rank
        (\maybeNumber ->
            case maybeNumber of
                Just number ->
                    Just <| number + 1

                Nothing ->
                    Just 1
        )
        hand


takeHand : Int -> Model.Hand -> Model.Hand
takeHand rank hand =
    Dict.update rank
        (\maybeNumber ->
            case maybeNumber of
                Just number ->
                    Just <| number - 1

                Nothing ->
                    Just 0
        )
        hand


clearHand : Model.Hand -> Model.Hand
clearHand hand =
    hand
        |> Dict.filter
            (\_ number -> number > 0)


maybeIntToInt : Maybe Int -> Int
maybeIntToInt maybeInt =
    case maybeInt of
        Just int ->
            int

        Nothing ->
            0