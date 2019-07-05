module HttpMod exposing (..)

type HttpRequest   
    = GetActionsInMonth
    | RemoveAction
    | AddAction
    | EditAction
    | GetCategories
    | AddCategory
    | RemoveCategory
    | GetAction