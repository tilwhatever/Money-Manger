module PageOverview exposing (view)

import Action
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, i, nav, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import List exposing (map, foldl)
import Logic exposing (Model, Msg(..))
import Route
import Helpers
import Types
import Svg
import Svg.Attributes as SvgA

view : Model -> Document Msg
view model =
    let
        deleteButtonClass : String
        deleteButtonClass =
            if model.actionDelete then
                "fas fa-times"

            else
                "fas fa-trash"

        changeMonth : Types.Direction -> Int -> Int -> Msg
        changeMonth direction year month =
            case direction of
                Types.Right ->
                    if month == 12 then ChangeRoute <| Route.Overview (year+1) 1
                        else ChangeRoute <| Route.Overview year (month+1)
                Types.Left ->
                    if month == 1 then ChangeRoute <| Route.Overview (year-1) 12
                        else ChangeRoute <| Route.Overview year (month-1)

        inOut : Action.ActionType -> List Action.Action -> String
        inOut actionType actions =
            map (\i ->
                if i.actionType == actionType then i.amount 
                    else 0
            ) actions
            |> foldl (+) 0
            |> String.fromInt

        sum : List Action.Action -> String
        sum actions =
            String.fromInt <| (Maybe.withDefault 0 (String.toInt (inOut Action.In actions))) - (Maybe.withDefault 0 (String.toInt (inOut Action.Out actions))) 

    in
    { title = "Übersicht"
    , body =
        [ nav []
            [ div [ id "nav-left" ]
                [ div [ id "prev-month", onClick <| changeMonth Types.Left model.currentYear model.currentMonth ] [ i [ class "fas fa-angle-left" ] [] ]
                , div [ id "month" ] [ text <| Helpers.getYearAndMonth model.currentYear model.currentMonth ]
                , div [ id "next-month", onClick <| changeMonth Types.Right model.currentYear model.currentMonth ] [ i [ class "fas fa-angle-right" ] [] ]    
                ]
            , div [ id "nav-right" ]
                [ div [] [ div [ class "buttonLong", onClick <| ChangeRoute Route.Categories ] [ text "Kategorien" ] ]
                , div [] [ div [ class "button", onClick DeleteAction ] [ i [ class deleteButtonClass ] [] ] ]
                , div [] [ div [ class "button" ] [ i [ class "fas fa-chart-bar" ] [] ] ]
                ]
            ]
        , div [ id "summary" ]
            [ div [ id "income" ]
                [ div []
                    [ div [] [ text "Einkommen" ]
                    , div [] [ text <| (inOut Action.In model.actions) ++ " €" ]
                    ]
                ]
            , div [ id "outgoing" ]
                [ div []
                    [ div [] [ text "Ausgaben" ]
                    , div [] [ text <| (inOut Action.Out model.actions) ++ " €" ]
                    ]
                ]
            , div [ id "sum" ]
                [ div []
                    [ div [] [ text "Summe" ]
                    , div [] [ text <| (sum model.actions) ++ " €" ]
                    ]
                ]
            ]
        , div [ id "actions" ]
            ([ div [ id "actions-head" ]
                [ div [] [ text "Kategorie" ]
                , div [] [ text "Beschreibung" ]
                , div [] [ text "Betrag" ]
                ]
             ]
                ++ getActions model.actions model.actionDelete
            )
        , div [ id "addAction", onClick <| ChangeRoute Route.Add ]
            [ div [] [ i [ class "fas fa-plus" ] [] ]
            ]
        {- , Svg.svg [ SvgA.width "400", SvgA.height "400" ] 
            [ Svg.rect 
                [ SvgA.width "200"
                , SvgA.height "200"
                , SvgA.fill "#2A7BB4"
                ] []
            ] -}
        ]
    }


getActions : List Action.Action -> Bool -> List (Html Msg)
getActions actions deleteState =
    let
        deleteClass : String
        deleteClass =
            if deleteState then
                "action action-delete"

            else
                "action"

        amountColor : Action.ActionType -> String
        amountColor actionType =
            if actionType == Action.In then "colGreen" else "colRed"
    in
    map
        (\i ->
            div [ class deleteClass, onClick <| ActionClick i.id i.date.day i.date.month i.date.year ]
                [ div [] [ text i.category ]
                , div [] [ text i.description ]
                , div [ class "amount", class <| amountColor i.actionType ] [ text <| "€ " ++ String.fromInt i.amount ]
                ]
        )
        actions
