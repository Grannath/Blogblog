module AppRouting exposing (match, toUri)

import AppModel exposing (Location(..))
import Route exposing (..)


home =
    Home := static ""


post =
    SinglePost := static "posts" </> int


notFound =
    NotFound := static "posts" </> static "notfound"


routes =
    Route.router
        [ home
        , post
        , notFound
        ]


match : String -> Maybe Location
match =
    Route.match routes


toUri : Location -> String
toUri loc =
    case loc of
        Home ->
            reverse home []

        SinglePost id ->
            reverse post [ toString id ]

        NotFound ->
            reverse notFound []

        _ ->
            ""
