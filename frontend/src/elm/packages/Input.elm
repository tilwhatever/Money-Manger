module Input exposing (Input(..), Inputs, changeInput, initializeModel)

import Helpers


type alias Inputs =
    { addActionDescription : String
    , addActionAmount : String
    , addActionAmountCent : String
    , addActionDay : String
    , addActionMonth : String
    , addActionYear : String
    , addActionCategory : String
    , addCategoryName : String
    }


type Input
    = AddActionDescription
    | AddActionAmount
    | AddActionAmountCent
    | AddActionDay
    | AddActionMonth
    | AddActionYear
    | AddActionCategory
    | AddCategoryName


initializeModel : Inputs
initializeModel =
    Inputs "" "" "" "1" "1" "2019" "Keine" ""


changeInput : Inputs -> Input -> String -> Inputs
changeInput inputs input text =
    case input of
        AddActionDescription ->
            { inputs | addActionDescription = text }

        AddActionAmount ->
            { inputs | addActionAmount = text }

        AddActionAmountCent ->
            { inputs | addActionAmountCent = text }

        AddActionDay ->
            { inputs | addActionDay = text }

        AddActionMonth ->
            { inputs | addActionMonth = text }

        AddActionYear ->
            { inputs | addActionYear = text }

        AddActionCategory ->
            { inputs | addActionCategory = text }

        AddCategoryName ->
            { inputs | addCategoryName = text }