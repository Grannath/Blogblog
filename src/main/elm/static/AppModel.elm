module AppModel exposing (..)

import Time.ZonedDateTime exposing (ZonedDateTime)
import Http exposing (Error)


type alias Post =
    { id : Int
    , title : String
    , content : String
    , author : String
    , created : ZonedDateTime
    }


type alias Settings =
    { pageSize : Int }


type Page
    = Overview (List Post)
    | Detailed Post
    | Loading (Maybe Page)
    | LoadError Error


type alias Model =
    { settings : Settings
    , page : Page
    }


type Msg
    = LoadNext
    | LoadPrevious
    | NextLoaded (Result Http.Error (List Post))
    | PreviousLoaded (Result Http.Error (List Post))
    | LoadPost Post
    | PostLoaded (Result Http.Error Post)
