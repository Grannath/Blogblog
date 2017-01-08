module AppRouting exposing (Location, match, toUri)

import AppModel exposing (SiteMap(..), PostQuery, PostOffset(..))
import Route exposing ((</>), (:=), static, int)
import QueryString as Query exposing (QueryString)
import TimeExtra exposing (toExtendedIso)


home =
    Home := static ""


post =
    SinglePost := static "posts" </> int


postSearch =
    PostSearch (PostQuery Nothing Nothing) := static "posts"


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

        query =
            Query.parse search

        pageSize =
            Query.one Query.int "pageSize" query

        newerThan =
            Query.one TimeExtra.zonedDateTime "newerThan" query

        olderThan =
            Query.one TimeExtra.zonedDateTime "olderThan" query

        postOffset =
            case olderThan of
                Just zdt ->
                    Just (OlderThan zdt)

                _ ->
                    Maybe.map NewerThan newerThan
    in
        case route of
            PostSearch _ ->
                PostSearch (PostQuery pageSize postOffset)

            _ ->
                route


toUri : SiteMap -> String
toUri loc =
    let
        addParam : String -> (a -> String) -> Maybe a -> QueryString -> QueryString
        addParam p ts mv =
            case mv of
                Just v ->
                    Query.add p (ts v)

                _ ->
                    identity

        addPageSize pq =
            addParam "pageSize" toString pq.pageSize

        addOffset pq =
            case pq.from of
                Just (NewerThan zdt) ->
                    addParam "newerThan" toExtendedIso (Just zdt)

                Just (OlderThan zdt) ->
                    addParam "olderThan" toExtendedIso (Just zdt)

                _ ->
                    identity
    in
        case loc of
            Home ->
                Route.reverse home []

            SinglePost id ->
                Route.reverse post [ toString id ]

            PostSearch pq ->
                Route.reverse postSearch []
                    ++ Query.render
                        (Query.empty
                            |> addPageSize pq
                            |> addOffset pq
                        )

            Unknown ukn ->
                ukn
