module Action exposing (..)

import Date

type alias Action =
    { id : Int
    , description : String
    , amount : Int
    , category : String
    , actionType : ActionType
    , date : Date.Date
    }

type ActionType
    = In
    | Out