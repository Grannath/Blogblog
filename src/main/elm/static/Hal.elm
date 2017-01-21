module Hal exposing (Link, link, Resource, resource)

import Json.Decode as Json exposing (Decoder)


type alias Link =
    { rel : String
    , href : String
    }


type alias Resource a =
    { a | links : List Link }


decodeLinks : Decoder (List Link)
decodeLinks =
    Json.keyValuePairs (Json.map (Link "") Json.string)
        |> Json.map (List.map (\( r, l ) -> { l | rel = r }))


resource : Decoder (List Link -> Resource a) -> Decoder (Resource a)
resource =
    Json.andThen
        (\f ->
            Json.map
                f
                (Json.field "_links" decodeLinks)
        )


link : String -> Resource a -> Maybe Link
link rel res =
    let
        hasRel r l =
            l.rel == r
    in
        List.filter (hasRel rel) res.links
            |> List.head
