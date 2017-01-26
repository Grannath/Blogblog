module AppRouting exposing (Location, match, toUrl)

import AppModel exposing (SiteMap(..))
import Route exposing ((</>), (:=), static, int, string)
import QueryString as Query exposing (QueryString)
import TimeExtra exposing (toExtendedIso)


home =
    Home := static ""


post =
    SinglePost := static "posts" </> string


postSearch =
    (PostSearch "") := static "posts"


routes =
    Route.router
        [ home
        , post
        , postSearch
        ]


type alias Location a =
    { a | pathname : String, search : String }


match : Location a -> SiteMap
match { pathname, search } =
    let
        route =
            Route.match routes pathname
                |> Maybe.withDefault (Unknown <| pathname ++ search)
    in
        case route of
            PostSearch _ ->
                PostSearch search

            _ ->
                route


toUrl : SiteMap -> String
toUrl loc =
    case loc of
        Home ->
            Route.reverse home []

        SinglePost title ->
            Route.reverse post [ title ]

        PostSearch query ->
            Route.reverse postSearch []
                ++ query

        Unknown ukn ->
            ukn
