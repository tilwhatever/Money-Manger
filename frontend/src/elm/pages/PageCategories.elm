module PageCategories exposing (view)

import Browser exposing (Document)
import Html exposing (Html, button, div, i, input, nav, text)
import Html.Attributes exposing (class, id, max, min)
import Html.Events exposing (onClick, onInput)
import HttpMod
import HttpRequest
import Input
import Input.Number
import List exposing (map, indexedMap)
import Logic exposing (Model, Msg(..))
import Tuple


view : Model -> Document Msg
view model =
    { title = "Eintrag hinzufügen"
    , body =
        [ nav []
            [ div [ id "nav-left" ]
                [ div []
                    [ div [] []
                    , div [ id "back", onClick <| HistoryBack 1 ] [ i [ class "fas fa-arrow-left" ] [] ]
                    ]
                ]
            , div [ id "nav-right" ]
                [ div []
                    [ div [ id "categoryInput" ] [ input [ onInput <| ChangeInput Input.AddCategoryName ] [] ]
                    , div [ class "buttonLong", onClick <| HttpRequest HttpMod.AddCategory [ model.inputs.addCategoryName ] ] [ text "Hinzufügen" ]
                    ]
                ]
            ]
        , div [ id "categories" ]
            (getCategories model)
        ]
    }


getCategories : Model -> List (Html Msg)
getCategories model =
    map (\i -> div [ class "category", onClick <| HttpRequest HttpMod.RemoveCategory [ i.category ] ] [ text i.category ]) model.categories
