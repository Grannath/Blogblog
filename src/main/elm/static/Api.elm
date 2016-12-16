module Api exposing (getPosts, getPreviousPosts, getNextPosts, getPost)

import Model exposing (Settings, Post)
import View exposing (Msg(..))
import Http exposing (..)
import Json.Decode as Json exposing (field, int, string, list)
import Time.DateTime exposing (DateTime, fromISO8601)


postsApiUrl =
    "http://localhost:8080/public/posts"


getPosts : Settings -> Cmd Msg
getPosts set =
    Http.send NextLoaded (Http.get postsApiUrl parsePostList)


getNextPosts : Settings -> Post -> Cmd Msg
getNextPosts set post =
    let
        url =
            postsApiUrl ++ "/next?from=" ++ (toString post.created) ++ "&pageSize=" ++ (toString set.pageSize)
    in
        Http.send NextLoaded (Http.get url parsePostList)


getPreviousPosts : Settings -> Post -> Cmd Msg
getPreviousPosts set post =
    let
        url =
            postsApiUrl ++ "/previous?from=" ++ (toString post.created) ++ "&pageSize=" ++ (toString set.pageSize)
    in
        Http.send PreviousLoaded (Http.get url parsePostList)


getPost : Post -> Cmd Msg
getPost post =
    let
        url =
            postsApiUrl ++ "/" ++ (toString post.id)
    in
        Http.send PostLoaded (Http.get url parsePost)



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


date : Json.Decoder DateTime
date =
    string
        |> Json.andThen
            (\val ->
                case fromISO8601 val of
                    Ok date ->
                        Json.succeed date

                    Err msg ->
                        Json.fail msg
            )
