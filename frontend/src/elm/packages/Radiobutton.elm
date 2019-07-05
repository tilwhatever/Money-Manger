module Radiobutton exposing (Radiobutton(..), RadiobuttonGroup(..), Radiobuttons, changeState, initializeModel, getSelectedButton)


type alias Radiobuttons =
    { pageAddIncome : Bool
    , pageAddOutgoing : Bool
    }


type Radiobutton
    = PageAddIncome
    | PageAddOutgoing


type RadiobuttonGroup
    = PageAddAction


initializeModel : Radiobuttons
initializeModel =
    Radiobuttons True False


changeState : Radiobuttons -> RadiobuttonGroup -> Radiobuttons
changeState radios group =
    case group of
        PageAddAction ->
            { radios
                | pageAddIncome = not radios.pageAddIncome
                , pageAddOutgoing = not radios.pageAddOutgoing
            }


getSelectedButton : Radiobuttons -> RadiobuttonGroup -> Radiobutton
getSelectedButton radios group =
    case group of
        PageAddAction ->
            if radios.pageAddIncome then
                PageAddIncome

            else
                PageAddOutgoing
