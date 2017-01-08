module AppModel exposing (..)

import Time.ZonedDateTime exposing (ZonedDateTime)
import Http


type alias Model =
    { settings : Settings
    , location : SiteMap
    , page : Page
    }



-- Content Records


type alias Post =
    { id : Int
    , title : String
    , content : String
    , author : String
    , created : ZonedDateTime
    }


type alias Settings =
    { pageSize : Int }



-- Site Routing


type SiteMap
    = Home
    | PostSearch PostQuery
    | SinglePost Int
    | Unknown String


type alias PostQuery =
    { pageSize : Maybe Int
    , from : Maybe PostOffset
    }


type PostOffset
    = NewerThan ZonedDateTime
    | OlderThan ZonedDateTime



-- Site Pages


type Page
    = Overview (List Post)
    | Detailed Post
    | Loading (Maybe Page)
    | ErrorPage Error


type Error
    = UnknownPage String
    | LoadError Http.Error



-- Messages


type Msg
    = Routing RouteChanges
    | User UserNavigation
    | Api ApiResponse



-- User navigation messages


type UserNavigation
    = LoadOlder
    | LoadNewer
    | LoadPost Post



-- API response messages


type ApiResponse
    = OlderLoaded (Result Http.Error (List Post))
    | NewerLoaded (Result Http.Error (List Post))
    | PostLoaded (Result Http.Error Post)



-- Routing messages


type RouteChanges
    = GoTo SiteMap
