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


containHand : Model.Hand -> Model.Hand -> Bool
containHand hand1 hand2 =
    Dict.merge
        (\_ _ result -> result && True)
        (\_ a b result -> result && a >= b)
        (\_ _ result -> result && False)
        hand1
        hand2
        True


lengthHand : Model.Hand -> Int
lengthHand hand =
    Dict.values hand
        |> List.sum


sumHand : Model.Hand -> Int
sumHand hand =
    Dict.foldl
        (\rank number sum -> rank * number + sum)
        0
        hand
