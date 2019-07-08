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
            String.fromFloat ((euro actionType actions) / 100)

        euro : Action.ActionType -> List Action.Action -> Float
        euro vactionType vactions = 
            map (\i ->
                if i.actionType == vactionType then (i.amount * 100) + i.amountCent
                    else 0
                    ) vactions
            |> foldl (+) 0
            |> toFloat

        cents : Action.ActionType -> List Action.Action -> Int
        cents vactionType vactions = 
            map (\i ->
                if i.actionType == vactionType then i.amountCent
                    else 0
                    ) vactions
            |> foldl (+) 0

        inOutFloat : Action.ActionType -> List Action.Action -> String
        inOutFloat actionType actions =
            String.fromFloat ((euro actionType actions) / 10)

        sum : List Action.Action -> String
        sum actions =
            String.fromFloat <| ((euro Action.In actions) - (euro Action.Out actions)) / 100
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
               --, div [] [ div [ class "button" ] [ i [ class "fas fa-chart-bar" ] [] ] ]
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
            , div [ id "smiley" ] (getSmiley (Maybe.withDefault 0.0 (String.toFloat (sum model.actions))))
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
        
        ]
    }

getSmiley : Float -> List (Html Msg)
getSmiley sum =
    if sum >= 0.0 then 
        [ Svg.svg [ SvgA.viewBox "0 0 200 200", SvgA.width "100%", SvgA.height "100%" ]
                        [ Svg.circle [ SvgA.cx "100", SvgA.cy "100", SvgA.r "100", SvgA.fill "green" ] []
                        , Svg.circle [ SvgA.cx "65", SvgA.cy "65", SvgA.r "10", SvgA.fill "white" ] []
                        , Svg.circle [ SvgA.cx "135", SvgA.cy "65", SvgA.r "10", SvgA.fill "white" ] []
                        , Svg.rect [ SvgA.x "95", SvgA.y "100", SvgA.width "10", SvgA.height "25", SvgA.fill "white" ] []
                        , Svg.rect [ SvgA.x "50", SvgA.y "150", SvgA.width "100", SvgA.height "10", SvgA.fill "white" ] []
                        , Svg.rect [ SvgA.x "50", SvgA.y "130", SvgA.width "10", SvgA.height "25", SvgA.fill "white" ] []
                        , Svg.rect [ SvgA.x "140", SvgA.y "130", SvgA.width "10", SvgA.height "25", SvgA.fill "white" ] []
                        ]
                ]
    else
        [ Svg.svg [ SvgA.viewBox "0 0 200 200", SvgA.width "100%", SvgA.height "100%" ]
                        [ Svg.circle [ SvgA.cx "100", SvgA.cy "100", SvgA.r "100", SvgA.fill "red" ] []
                        , Svg.circle [ SvgA.cx "65", SvgA.cy "65", SvgA.r "10", SvgA.fill "white" ] []
                        , Svg.circle [ SvgA.cx "135", SvgA.cy "65", SvgA.r "10", SvgA.fill "white" ] []
                        , Svg.rect [ SvgA.x "95", SvgA.y "100", SvgA.width "10", SvgA.height "25", SvgA.fill "white" ] []
                        , Svg.rect [ SvgA.x "50", SvgA.y "150", SvgA.width "100", SvgA.height "10", SvgA.fill "white" ] []
                        , Svg.rect [ SvgA.x "50", SvgA.y "150", SvgA.width "10", SvgA.height "25", SvgA.fill "white" ] []
                        , Svg.rect [ SvgA.x "140", SvgA.y "150", SvgA.width "10", SvgA.height "25", SvgA.fill "white" ] []
                        ]
                ]

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

        getCents : Int -> String
        getCents cents =
            if cents == 0 then "00"
                else String.fromInt cents
    in
    map
        (\i ->
            div [ class deleteClass, onClick <| ActionClick i.id i.date.day i.date.month i.date.year ]
                [ div [] [ text i.category ]
                , div [] [ text i.description ]
                , div [ class "amount", class <| amountColor i.actionType ] [ text <| "€ " ++ String.fromInt i.amount ++ "," ++ getCents i.amountCent ]
                ]
        )
        actions
