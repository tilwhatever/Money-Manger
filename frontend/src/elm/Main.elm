module Main exposing (init, initializeCommands, initializeModel, main, subscriptions, update, view)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, div, text)
import HttpMod
import HttpRequest
import Input
import Logic exposing (Model, Msg(..))
import PageAdd
import PageCategories
import PageEdit
import PageOverview
import Radiobutton
import Route exposing (Route, getRoute)
import Url exposing (Url)



-------- PROGRAM ------


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-------- INITIALIZATION --------


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initializeModel url key
    , initializeCommands url
    )


initializeModel : Url -> Nav.Key -> Model
initializeModel url key =
    { url = url
    , key = key
    , route = Route.getRoute url
    , currentMonth = 0
    , currentYear = 0
    , actionDelete = False
    , actions = []
    , radiobuttons = Radiobutton.initializeModel
    , inputs = Input.initializeModel
    , categories = []
    }



-- wandle URL in Route um und führe benötigte HTTP Anfrage
-- als Initialisierung aus


initializeCommands : Url -> Cmd Msg
initializeCommands url =
    case Route.getRoute url of
        Route.Home ->
            HttpRequest.execute_ Route.Home [ "0", "0", "init" ]

        Route.Overview year month ->
            Cmd.batch
                [ HttpRequest.execute_ (Route.Overview year month) [ String.fromInt year, String.fromInt month ]
                ]

        Route.Add ->
            HttpRequest.execute HttpMod.GetCategories []

        Route.Edit id ->
            Cmd.batch
                [ HttpRequest.execute HttpMod.GetAction [ String.fromInt (Maybe.withDefault -1 id) ]
                , HttpRequest.execute HttpMod.GetCategories []
                ]

        Route.Categories ->
            HttpRequest.execute HttpMod.GetCategories []

        Route.NotFound ->
            Cmd.none



-------- SUBSCRIPTIONS --------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-------- VIEW --------


view : Model -> Document Msg
view model =
    case model.route of
        Route.Home ->
            PageOverview.view model

        Route.Overview year month ->
            PageOverview.view model

        Route.Add ->
            PageAdd.view model

        Route.Categories ->
            PageCategories.view model

        Route.Edit id ->
            PageEdit.view model

        _ ->
            { title = "Not Found"
            , body = [ text "Page not found" ]
            }



-------- UPDATE --------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( model, Cmd.none )

        ----- CLICKS -----
        ActionClick id d m y ->
            let
                chooseRequest : Cmd Msg
                chooseRequest =
                    if model.actionDelete then
                        HttpRequest.execute HttpMod.RemoveAction [ String.fromInt id ]

                    else
                        Nav.load ("/edit?n=" ++ String.fromInt id)
            in
            ( model, chooseRequest )

        DeleteAction ->
            ( { model | actionDelete = not model.actionDelete }, Cmd.none )

        ChangeRoute route ->
            let
                routeOverview : String -> String -> Cmd Msg
                routeOverview year month =
                    Cmd.batch
                        [ HttpRequest.execute HttpMod.GetActionsInMonth [ year, month, "" ]
                        , Nav.pushUrl model.key <| "/overview/" ++ year ++ "/" ++ month
                        ]

                --Nav.load <| "/overview/" ++ (String.fromInt year) ++ "/" ++ (String.fromInt month)
            in
            case route of
                Route.Add ->
                    ( model, Nav.load <| "/add" )

                Route.Overview year month ->
                    ( model, routeOverview (String.fromInt year) (String.fromInt month) )

                Route.Categories ->
                    ( model, Nav.load "/categories" )

                _ ->
                    ( model, Cmd.none )

        HistoryBack number ->
            ( model, Nav.back model.key number )

        HistoryForward number ->
            ( model, Nav.forward model.key number )

        ----- COLLECTION -----
        ChangeInput input text ->
            ( { model | inputs = Input.changeInput model.inputs input text }, Cmd.none )

        ChangeInputInt input text ->
            ( { model | inputs = Input.changeInput model.inputs input (String.fromInt (Maybe.withDefault 0 text)) }, Cmd.none )

        ChangeInputString input text ->
            ( { model | inputs = Input.changeInput model.inputs input (Maybe.withDefault "Keine" text) }, Cmd.none )

        FocusUpdated bool ->
            ( model, Cmd.none )

        ChangeRadiobutton radio ->
            ( { model | radiobuttons = Radiobutton.changeState model.radiobuttons radio }, Cmd.none )

        ----- HTTP REQUESTS -----
        HttpRequest request args ->
            ( model, HttpRequest.execute request args )

        HttpRequestGetActionsInMonth result ->
            case result of
                Ok data ->
                    HttpRequest.getActionsInMonthRes data model

                Err error ->
                    HttpRequest.httpError model error

        HttpRequestRemoveAction result ->
            case result of
                Ok data ->
                    HttpRequest.removeActionRes data model

                Err error ->
                    HttpRequest.httpError model error

        HttpRequestAddAction result ->
            case result of
                Ok data ->
                    HttpRequest.addActionRes data model

                Err error ->
                    HttpRequest.httpError model error

        HttpRequestGetCategories result ->
            case result of
                Ok data ->
                    HttpRequest.getCategoriesRes data model

                Err error ->
                    HttpRequest.httpError model error

        HttpRequestAddCategory result ->
            case result of
                Ok data ->
                    HttpRequest.addCategoryRes data model

                Err error ->
                    HttpRequest.httpError model error

        HttpRequestRemoveCategory result ->
            case result of
                Ok data ->
                    HttpRequest.removeCategoryRes data model

                Err error ->
                    HttpRequest.httpError model error

        HttpRequestGetAction result ->
            case result of
                Ok data ->
                    HttpRequest.getActionRes data model

                Err error ->
                    HttpRequest.httpError model error

        HttpRequestEditAction result ->
            case result of
                Ok data ->
                    HttpRequest.editActionRes data model

                Err error ->
                    HttpRequest.httpError model error
