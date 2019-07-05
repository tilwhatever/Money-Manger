module Helpers exposing (changeListItemAtIndex, elmMonthToFullString, elmMonthToInt, getListItemAtIndex, getYearAndMonth, posixToDate, stringToIntWithDefaultZero)

import Date
import Time exposing (Month(..), Posix, toDay, toMonth, toYear, utc)


getListItemAtIndex : List a -> Int -> Maybe a
getListItemAtIndex list n =
    case list of
        x :: xs ->
            if n == 0 then
                Just x

            else
                getListItemAtIndex xs (n - 1)

        [] ->
            Nothing


changeListItemAtIndex : List a -> List a -> Int -> a -> Maybe (List a)
changeListItemAtIndex begin end n value =
    let
        removeFrontItemFromHead : List a -> List a
        removeFrontItemFromHead list =
            case list of
                x :: xs ->
                    xs

                [] ->
                    []
    in
    case begin of
        x :: xs ->
            if n == 0 then
                Just (begin ++ [ value ] ++ removeFrontItemFromHead end)

            else
                changeListItemAtIndex (begin ++ [ x ]) xs (n - 1) value

        [] ->
            Nothing


stringToIntWithDefaultZero : String -> Int
stringToIntWithDefaultZero string =
    case String.toInt string of
        Just a ->
            a

        Nothing ->
            0


elmMonthToInt : Month -> Int
elmMonthToInt month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


elmMonthToFullString : Month -> String
elmMonthToFullString month =
    case month of
        Jan ->
            "Januar"

        Feb ->
            "Februar"

        Mar ->
            "März"

        Apr ->
            "April"

        May ->
            "Mai"

        Jun ->
            "Juni"

        Jul ->
            "Juli"

        Aug ->
            "August"

        Sep ->
            "September"

        Oct ->
            "Oktober"

        Nov ->
            "November"

        Dec ->
            "Dezember"


posixToDate : Posix -> Date.Date
posixToDate time =
    Date.Date (toDay utc time) (elmMonthToInt (toMonth utc time)) (toYear utc time)


getYearAndMonth : Int -> Int -> String
getYearAndMonth year month =
    Date.getMonthString (Date.Date 0 month 0) ++ " " ++ String.fromInt year
