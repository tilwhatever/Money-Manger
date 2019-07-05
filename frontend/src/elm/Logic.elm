module Logic exposing (Model, Msg(..))

import Browser
import Browser.Navigation as Nav
import Route exposing (Route)
import Url exposing (Url)
import HttpMod
import Http
import Types
import Action
import Input
import Radiobutton

type alias Model =
    { url : Url
    , key : Nav.Key
    , route : Route
    -- functions
    , currentMonth : Int
    , currentYear : Int
    , actionDelete : Bool
    -- http requests
    , actions : List Action.Action
    , inputs : Input.Inputs
    , radiobuttons : Radiobutton.Radiobuttons
    , categories : List Types.Category
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    -- Clicks
    | ActionClick Int Int Int Int
    | DeleteAction
    | ChangeRoute Route
    | HistoryBack Int
    | HistoryForward Int
    -- Collection
    | ChangeInput Input.Input String
    | ChangeInputInt Input.Input (Maybe Int)
    | ChangeInputString Input.Input (Maybe String)
    | FocusUpdated Bool
    | ChangeRadiobutton Radiobutton.RadiobuttonGroup
    -- HTTP Requests
    | HttpRequest HttpMod.HttpRequest (List String)
    | HttpRequestGetActionsInMonth (Result Http.Error Types.ActionsAndDate)
    | HttpRequestRemoveAction (Result Http.Error Types.ResultAndError)
    | HttpRequestAddAction (Result Http.Error Types.ResultAndError)
    | HttpRequestGetCategories (Result Http.Error Types.Categories)
    | HttpRequestAddCategory (Result Http.Error Types.ResultAndError)
    | HttpRequestRemoveCategory (Result Http.Error Types.ResultAndError)
    | HttpRequestGetAction (Result Http.Error Action.Action)
    | HttpRequestEditAction (Result Http.Error Types.ResultAndError)