module HttpRequest exposing (addAction, addActionRes, addCategory, editAction, editActionRes, addCategoryRes, apiPath, execute, execute_, getAction, getActionRes, getActionsInMonth, getActionsInMonthRes, getArg, getCategories, getCategoriesRes, httpEncoder, httpError, removeAction, removeActionRes, removeCategory, removeCategoryRes)

import Action
import Browser.Navigation as Nav
import Date
import Helpers
import Http
import HttpMod
import Json.Decode as Decoder exposing (bool, field, int, list, string)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encoder
import Logic exposing (Model, Msg(..))
import Route
import Types
import Radiobutton


apiPath : String
apiPath =
    "/backend/api.php"



-- führe bestimmte Anfrage aus


execute : HttpMod.HttpRequest -> List String -> Cmd Msg
execute request args =
    case request of
        HttpMod.GetActionsInMonth ->
            getActionsInMonth args

        HttpMod.RemoveAction ->
            removeAction args

        HttpMod.AddAction ->
            addAction args

        HttpMod.GetCategories ->
            getCategories args

        HttpMod.AddCategory ->
            addCategory args

        HttpMod.RemoveCategory ->
            removeCategory args

        HttpMod.GetAction ->
            getAction args

        HttpMod.EditAction ->
            editAction args


-- führe je nach Route eine bestimmte HTTP Anfrage aus


execute_ : Route.Route -> List String -> Cmd Msg
execute_ route args =
    case route of
        Route.Home ->
            getActionsInMonth args

        Route.Overview year month ->
            getActionsInMonth args

        _ ->
            Cmd.none



-- show error in console


httpError : Model -> Http.Error -> ( Model, Cmd Msg )
httpError model error =
    let
        return : Model -> ( Model, Cmd Msg )
        return function =
            ( function, Cmd.none )

        log : String -> Model -> Model
        log string vmodel =
            vmodel
            --Debug.log string vmodel
    in
    case error of
        Http.BadUrl string ->
            return <| log string model

        Http.Timeout ->
            return <| log "Timeout" model

        Http.NetworkError ->
            return <| log "Network Error" model

        Http.BadStatus int ->
            return <| log (String.fromInt int) model

        Http.BadBody string ->
            return <| log string model



-- template für encoder


httpEncoder : String -> Encoder.Value -> Encoder.Value
httpEncoder query data =
    Encoder.object
        [ ( "request"
          , Encoder.object
                [ ( "query", Encoder.string query )
                , ( "data", data )
                ]
          )
        ]



-- Argumente aus Liste auslesen


getArg : List String -> Int -> String
getArg list n =
    case Helpers.getListItemAtIndex list n of
        Just a ->
            a

        Nothing ->
            "err"



---------------------------------------------------------
-- bekomme alle Actions die in einem bestimmten Monat getätigt wurde
-- [ year, month, "init" ]
-- init, falls php aktuellen Monat/Jahr berechnen muss


getActionsInMonth : List String -> Cmd Msg
getActionsInMonth args =
    let
        encoder : Encoder.Value
        encoder =
            Encoder.object
                [ ( "year", Encoder.string <| getArg args 0 )
                , ( "month", Encoder.string <| getArg args 1 )
                , ( "init", Encoder.string <| getArg args 2 )
                ]
                |> httpEncoder "getActionsInMonth"

        decodeActionType : Decoder.Decoder Action.ActionType
        decodeActionType =
            int
                |> Decoder.andThen
                    (\str ->
                        case str of
                            0 ->
                                Decoder.succeed Action.Out

                            1 ->
                                Decoder.succeed Action.In

                            _ ->
                                Decoder.fail "Parsing actionType failed"
                    )

        decodeDate : Decoder.Decoder Date.Date
        decodeDate =
            Decoder.succeed Date.Date
                |> required "day" int
                |> required "month" int
                |> required "year" int
                |> Decoder.andThen
                    (\date ->
                        Decoder.succeed <| Date.Date date.day date.month date.year
                    )

        decodeActions : Decoder.Decoder (List Action.Action)
        decodeActions =
            Decoder.succeed Action.Action
                |> required "id" int
                |> required "description" string
                |> required "amount" int
                |> required "amountCent" int
                |> required "category" string
                |> required "actionType" decodeActionType
                |> required "date" decodeDate
                |> list

        decoder : Decoder.Decoder Types.ActionsAndDate
        decoder =
            Decoder.succeed Types.ActionsAndDate
                |> required "actions" decodeActions
                |> required "currentDate" decodeDate
                |> field "data"
    in
    Http.post
        { url = apiPath
        , body = Http.jsonBody encoder
        , expect = Http.expectJson HttpRequestGetActionsInMonth decoder
        }


getActionsInMonthRes : Types.ActionsAndDate -> Model -> ( Model, Cmd Msg )
getActionsInMonthRes data model =
    ( { model | actions = data.actions, currentMonth = data.currentDate.month, currentYear = data.currentDate.year }, Cmd.none )


removeAction : List String -> Cmd Msg
removeAction args =
    let
        encoder : Encoder.Value
        encoder =
            Encoder.object
                [ ( "id", Encoder.string <| getArg args 0 )
                ]
                |> httpEncoder "removeAction"

        decoder : Decoder.Decoder Types.ResultAndError
        decoder =
            Decoder.succeed Types.ResultAndError
                |> required "result" bool
                |> required "error" string
                |> field "data"
    in
    Http.post
        { url = apiPath
        , body = Http.jsonBody encoder
        , expect = Http.expectJson HttpRequestRemoveAction decoder
        }


removeActionRes : Types.ResultAndError -> Model -> ( Model, Cmd Msg )
removeActionRes data model =
    ( model, execute HttpMod.GetActionsInMonth [ String.fromInt model.currentYear, String.fromInt model.currentMonth, "" ] )


addAction : List String -> Cmd Msg
addAction args =
    let
        encoder : Encoder.Value
        encoder =
            Encoder.object
                [ ( "description", Encoder.string <| getArg args 0 )
                , ( "amount", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 1 )
                , ( "amountCent", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 2 )
                , ( "day", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 3 )
                , ( "month", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 4 )
                , ( "year", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 5 )
                , ( "action", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 6 )
                , ( "category", Encoder.string <| getArg args 7 )
                ]
                |> httpEncoder "addAction"

        decoder : Decoder.Decoder Types.ResultAndError
        decoder =
            Decoder.succeed Types.ResultAndError
                |> required "result" bool
                |> required "error" string
                |> field "data"
    in
    Http.post
        { url = apiPath
        , body = Http.jsonBody encoder
        , expect = Http.expectJson HttpRequestAddAction decoder
        }


addActionRes : Types.ResultAndError -> Model -> ( Model, Cmd Msg )
addActionRes data model =
    ( model
    , Nav.load <| "/overview/" ++ model.inputs.addActionYear ++ "/" ++ model.inputs.addActionMonth
    )


getCategories : List String -> Cmd Msg
getCategories args =
    let
        encoder : Encoder.Value
        encoder =
            Encoder.object
                [ ( "request"
                  , Encoder.object
                        [ ( "query", Encoder.string "getCategories" ) ]
                  )
                ]

        decodeCategories : Decoder.Decoder (List Types.Category)
        decodeCategories =
            Decoder.succeed Types.Category
                |> required "category" string
                |> list

        decoder : Decoder.Decoder Types.Categories
        decoder =
            Decoder.succeed Types.Categories
                |> required "categories" decodeCategories
                |> field "data"
    in
    Http.post
        { url = apiPath
        , body = Http.jsonBody encoder
        , expect = Http.expectJson HttpRequestGetCategories decoder
        }


getCategoriesRes : Types.Categories -> Model -> ( Model, Cmd Msg )
getCategoriesRes data model =
    ( { model | categories = data.categories }, Cmd.none )


addCategory : List String -> Cmd Msg
addCategory args =
    let
        encoder : Encoder.Value
        encoder =
            Encoder.object
                [ ( "category", Encoder.string <| getArg args 0 )
                ]
                |> httpEncoder "addCategory"

        decoder : Decoder.Decoder Types.ResultAndError
        decoder =
            Decoder.succeed Types.ResultAndError
                |> required "result" bool
                |> required "error" string
                |> field "data"
    in
    Http.post
        { url = apiPath
        , body = Http.jsonBody encoder
        , expect = Http.expectJson HttpRequestAddCategory decoder
        }


addCategoryRes : Types.ResultAndError -> Model -> ( Model, Cmd Msg )
addCategoryRes data model =
    ( model, execute HttpMod.GetCategories [] )


removeCategory : List String -> Cmd Msg
removeCategory args =
    let
        encoder : Encoder.Value
        encoder =
            Encoder.object
                [ ( "category", Encoder.string <| getArg args 0 )
                ]
                |> httpEncoder "removeCategory"

        decoder : Decoder.Decoder Types.ResultAndError
        decoder =
            Decoder.succeed Types.ResultAndError
                |> required "result" bool
                |> required "error" string
                |> field "data"
    in
    Http.post
        { url = apiPath
        , body = Http.jsonBody encoder
        , expect = Http.expectJson HttpRequestRemoveCategory decoder
        }


removeCategoryRes : Types.ResultAndError -> Model -> ( Model, Cmd Msg )
removeCategoryRes data model =
    ( model, execute HttpMod.GetCategories [] )


getAction : List String -> Cmd Msg
getAction args =
    let
        encoder : Encoder.Value
        encoder =
            Encoder.object
                [ ( "id", Encoder.string <| getArg args 0 )
                ]
                |> httpEncoder "getAction"

        decodeActionType : Decoder.Decoder Action.ActionType
        decodeActionType =
            int
                |> Decoder.andThen
                    (\str ->
                        case str of
                            0 ->
                                Decoder.succeed Action.Out

                            1 ->
                                Decoder.succeed Action.In

                            _ ->
                                Decoder.fail "Parsing actionType failed"
                    )

        decodeDate : Decoder.Decoder Date.Date
        decodeDate =
            Decoder.succeed Date.Date
                |> required "day" int
                |> required "month" int
                |> required "year" int
                |> Decoder.andThen
                    (\date ->
                        Decoder.succeed <| Date.Date date.day date.month date.year
                    )

        decodeAction : Decoder.Decoder Action.Action
        decodeAction =
            Decoder.succeed Action.Action
                |> required "id" int
                |> required "description" string
                |> required "amount" int
                |> required "amountCent" int
                |> required "category" string
                |> required "actionType" decodeActionType
                |> required "date" decodeDate
                |> field "data"
    in
    Http.post
        { url = apiPath
        , body = Http.jsonBody encoder
        , expect = Http.expectJson HttpRequestGetAction decodeAction
        }


getActionRes : Action.Action -> Model -> ( Model, Cmd Msg )
getActionRes action model =
    let
        oldInputs =
            model.inputs

        newInputs =
            { oldInputs
                | addActionDescription = action.description
                , addActionAmount = String.fromInt action.amount
                , addActionAmountCent = String.fromInt action.amountCent
                , addActionCategory = action.category
                , addActionDay = String.fromInt action.date.day
                , addActionMonth = String.fromInt action.date.month
                , addActionYear = String.fromInt action.date.year
            }

        actionTypeToBool : Action.ActionType -> Bool
        actionTypeToBool vaction =
            case vaction of
                Action.In ->
                    True

                Action.Out ->
                    False

    in
    ( { model 
        | inputs = newInputs 
        , radiobuttons = Radiobutton.Radiobuttons (actionTypeToBool action.actionType) (not (actionTypeToBool action.actionType))
        }
    , Cmd.none )

editAction : List String -> Cmd Msg 
editAction args =
    let
        encoder : Encoder.Value
        encoder =
            Encoder.object
                [ ( "id", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 0)
                , ( "description", Encoder.string <| getArg args 1 )
                , ( "amount", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 2 )
                , ( "amountCent", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 3 )
                , ( "day", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 4 )
                , ( "month", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 5 )
                , ( "year", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 6 )
                , ( "action", Encoder.int <| Helpers.stringToIntWithDefaultZero <| getArg args 7 )
                , ( "category", Encoder.string <| getArg args 8 )
                ]
                |> httpEncoder "editAction"

        decoder : Decoder.Decoder Types.ResultAndError
        decoder =
            Decoder.succeed Types.ResultAndError
                |> required "result" bool
                |> required "error" string
                |> field "data"
    in
    Http.post 
        { url = apiPath
        , body = Http.jsonBody encoder
        , expect = Http.expectJson HttpRequestEditAction decoder
        }

editActionRes : Types.ResultAndError -> Model -> ( Model, Cmd Msg )
editActionRes data model =
    ( model, Nav.load <| "/overview/" ++ model.inputs.addActionYear ++ "/" ++ model.inputs.addActionMonth )