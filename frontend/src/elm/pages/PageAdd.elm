module PageAdd exposing (view)

import Browser exposing (Document)
import Html exposing (Html, button, div, i, input, nav, text, fieldset)
import Html.Attributes exposing (class, id, min, max, value, checked, type_)
import Html.Events exposing (onClick, onInput, onClick)
import HttpMod
import Input
import Logic exposing (Model, Msg(..))
import Input.Number
import Dropdown
import Helpers
import Types
import List exposing (map)
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
    in
    { title = "Eintrag hinzufügen"
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
            , div [] [ input [ onInput <| ChangeInput Input.AddActionAmount, value model.inputs.addActionAmount ] [] ]
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
                        (HttpRequest HttpMod.AddAction
                            [ model.inputs.addActionDescription
                            , model.inputs.addActionAmount
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

chooseAction : Model -> String
chooseAction model =
    case Radiobutton.getSelectedButton model.radiobuttons Radiobutton.PageAddAction of 
        Radiobutton.PageAddIncome ->
            "1"

        _ ->
            "0"