module Route exposing (Route(..), fromUrl, getRoute)

import Url.Parser exposing (..)
import Url exposing (Url)
import Url.Parser.Query as Query

type Route
    = Home
    | Overview Int Int
    | Add
    | Edit (Maybe Int)
    | Categories
    | NotFound

parser : Parser (Route -> a) a
parser =
    oneOf 
        [ map Home top
        , map Overview (s "overview" </> int </> int)
        , map Add (s "add")
        , map Edit (s "edit" <?> Query.int "n")
        , map Categories (s "categories")
        ]

fromUrl : Url -> Route
fromUrl url =
    Maybe.withDefault NotFound (parse parser url)

getRoute : Url -> Route
getRoute url =
    fromUrl url