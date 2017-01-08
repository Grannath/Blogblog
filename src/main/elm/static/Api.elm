module Api exposing (getPosts, getNewerPosts, getOlderPosts, getSinglePost)

import AppModel exposing (Settings, Post, Msg(Api), ApiResponse(..))
import Http exposing (..)
import Json.Decode as Json exposing (field, int, string, list)
import Time.ZonedDateTime exposing (ZonedDateTime)
import TimeExtra exposing (fromExtendedIso, toExtendedIso)


postsApiUrl =
    "http://localhost:8080/public/posts"


getPosts : Settings -> Cmd Msg
getPosts set =
    Http.send (Api << OlderLoaded) (Http.get postsApiUrl parsePostList)


getOlderPosts : Settings -> ZonedDateTime -> Cmd Msg
getOlderPosts set from =
    let
        uri =
            postsApiUrl
                ++ "/next?from="
                ++ (Http.encodeUri <| toExtendedIso from)
                ++ "&pageSize="
                ++ (toString set.pageSize)
    in
        Http.send (Api << OlderLoaded) (Http.get uri parsePostList)


getNewerPosts : Settings -> ZonedDateTime -> Cmd Msg
getNewerPosts set from =
    let
        uri =
            postsApiUrl
                ++ "/previous?from="
                ++ (Http.encodeUri <| toExtendedIso from)
                ++ "&pageSize="
                ++ (toString set.pageSize)
    in
        Http.send (Api << NewerLoaded) (Http.get uri parsePostList)


getSinglePost : Int -> Cmd Msg
getSinglePost id =
    let
        url =
            postsApiUrl ++ "/" ++ (toString id)
    in
        Http.send (Api << PostLoaded) (Http.get url parsePost)



-- JSON


parsePostList : Json.Decoder (List Post)
parsePostList =
    Json.list parsePost


parsePost : Json.Decoder Post
parsePost =
    Json.map5 Post
        (field "id" int)
        (field "title" string)
        (field "content" string)
        (field "author" string)
        (field "created" date)


date : Json.Decoder ZonedDateTime
date =
    string
        |> Json.andThen
            (\val ->
                case fromExtendedIso val of
                    Ok date ->
                        Json.succeed date

                    Err msg ->
                        Json.fail msg
            )
