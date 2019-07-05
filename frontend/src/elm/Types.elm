module Types exposing (..)

-- alle Types, die einzeln gebraucht werden, zum Beispiel
-- in HTTP Anfragen

import Action
import Date
import Http

type alias ActionsAndDate =
    { actions : List Action.Action
    , currentDate : Date.Date
    }

type alias ResultAndError =
    { result : Bool
    , error : String
    }

type Direction
    = Left
    | Right

type alias Categories =
    { categories : List Category
    }

type alias Category =
    { category : String
    }