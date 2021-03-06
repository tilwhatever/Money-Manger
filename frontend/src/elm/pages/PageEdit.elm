module PageEdit exposing (view)

import Browser exposing (Document)
import Html exposing (Html, button, div, i, input, nav, text, fieldset)
import Html.Attributes exposing (class, id, min, max, value, type_, checked, maxlength)
import Html.Events exposing (onClick, onInput)
import HttpMod
import Input
import Logic exposing (Model, Msg(..))
import Input.Number
import Dropdown
import Helpers
import Types
import List exposing (map)
import Route
import Radiobutton

view : Model -> Document Msg
view model =
    let 
        checkMax : String -> Int
        checkMax month =
            if month == "2" || month == "4" || month == "6" || month == "9" || month == "11" then 30 else 31

        getDropdownItems : List Types.Category -> List Dropdown.Item
        getDropdownItems categories =
            map (\i -> { value = i.category, text = i.category, enabled = True }) categories

        getIdFromUrl : Model -> String
        getIdFromUrl vmodel =
            case vmodel.route of
                Route.Edit id ->
                    String.fromInt (Maybe.withDefault 0 id)
                
                _ ->
                    ""

    in
    { title = "Eintrag bearbeiten"
    , body =
        [ nav []
            [ div [ id "nav-left" ]
                [ div []
                    [ div [] []
                    , div [ id "back", onClick <| HistoryBack 1 ] [ i [ class "fas fa-arrow-left" ] [] ]
                    ]
                ]
            ]
        , div [ id "add" ]
            [ div [] [ text "Tag" ]
            , div [] 
                [ Input.Number.input 
                    { maxLength = Nothing
                    , maxValue = Just <| checkMax model.inputs.addActionMonth
                    , minValue = Just 1
                    , onInput = ChangeInputInt Input.AddActionDay
                    , hasFocus = Just FocusUpdated
                    }
                    []
                    (String.toInt model.inputs.addActionDay)
                ]
            , div [] [ text "Monat" ]
            , div [] 
                [ Input.Number.input 
                    { maxLength = Nothing
                    , maxValue = Just 12
                    , minValue = Just 1
                    , onInput = ChangeInputInt Input.AddActionMonth
                    , hasFocus = Just FocusUpdated
                    }
                    []
                    (String.toInt model.inputs.addActionMonth)
                ]
            , div [] [ text "Jahr" ]
            , div [] 
                [ Input.Number.input 
                    { maxLength = Nothing
                    , maxValue = Just 2050
                    , minValue = Just 2019
                    , onInput = ChangeInputInt Input.AddActionYear
                    , hasFocus = Just FocusUpdated
                    }
                    []
                    (String.toInt model.inputs.addActionYear)
                ]
            , div [] [ text "Betrag" ]
            , div []
                [ input [ onInput <| ChangeInput Input.AddActionAmount, value model.inputs.addActionAmount, id "amount", maxlength 7 ] [] 
                , text " ,  "
                , input [ onInput <| ChangeInput Input.AddActionAmountCent, value model.inputs.addActionAmountCent, id "amountCent", maxlength 2 ] []
                , text "€"
                ]
            , div [] [ text "Beschreibung" ]
            , div [] [ input [ onInput <| ChangeInput Input.AddActionDescription, value model.inputs.addActionDescription ] [] ]
            , div [] [ text "Kategorie" ]
            , div []
                [ Dropdown.dropdown 
                    { items = getDropdownItems model.categories
                    , emptyItem = Nothing
                    , onChange = (ChangeInputString Input.AddActionCategory)
                    }
                    []
                    (Just model.inputs.addActionCategory)
                ]
            , div []
                [ fieldset [ id "actionField" ]
                    [ input 
                        [ type_ "radio"
                        , checked model.radiobuttons.pageAddIncome
                        , onClick <| ChangeRadiobutton Radiobutton.PageAddAction ] []
                    , text "Einnahmen"
                    , input 
                        [ type_ "radio" 
                        , checked model.radiobuttons.pageAddOutgoing
                        , onClick <| ChangeRadiobutton Radiobutton.PageAddAction ] []
                    , text "Ausgaben"
                    ]
                ]
            , div [] []
            , div []
                [ button
                    [ onClick
                        (HttpRequest HttpMod.EditAction
                            [ getIdFromUrl model
                            , model.inputs.addActionDescription
                            , model.inputs.addActionAmount
                            , getCents model.inputs.addActionAmountCent
                            , model.inputs.addActionDay
                            , model.inputs.addActionMonth
                            , model.inputs.addActionYear
                            , chooseAction model
                            , model.inputs.addActionCategory
                            ]
                        )
                    ] [ text "Save" ]
                ] 
            ]
        ]
    }

getCents : String -> String
getCents cents =
    if (Maybe.withDefault 0 <| String.toInt cents) < 10 then cents ++ "0"
        else cents

chooseAction : Model -> String
chooseAction model =
    case Radiobutton.getSelectedButton model.radiobuttons Radiobutton.PageAddAction of 
        Radiobutton.PageAddIncome ->
            "1"

        _ ->
            "0"