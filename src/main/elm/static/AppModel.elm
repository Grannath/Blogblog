module AppModel exposing (..)

import Hal exposing (Link, Resource)
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
    , links : List Link
    }


type alias PostPage =
    { posts : List Post
    , links : List Link
    }


type alias Settings =
    { pageSize : Int }



-- Site Routing


type SiteMap
    = Home
    | PostSearch String
    | SinglePost String
    | Unknown String



-- Site Pages


type Page
    = Overview PostPage
    | Detailed Post
    | Loading
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
    = NextPage
    | PrevPage
    | NextPost
    | PrevPost
    | ShowPost Post



-- API response messages


type ApiResponse
    = PostPageLoaded (Result Http.Error PostPage)
    | PostLoaded (Result Http.Error Post)



-- Routing messages


type RouteChanges
    = GoTo SiteMap
