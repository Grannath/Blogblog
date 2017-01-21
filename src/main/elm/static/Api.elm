module Api exposing (getFirstPosts, getNextPost, getPrevPost, getPost, getNextPage, getPrevPage)

import AppModel exposing (ApiResponse(..), Model, Msg(Api), Page(Detailed, Overview), Post, PostPage, Settings)
import Http exposing (..)
import Hal exposing (Resource)
import Json.Decode as Json exposing (field, int, string, list)
import Time.ZonedDateTime exposing (ZonedDateTime)
import TimeExtra exposing (fromExtendedIso, toExtendedIso)


postsApiUrl =
    "http://localhost:8080/public/posts"


getFirstPosts : Model -> Cmd Msg
getFirstPosts mod =
    let
        uri =
            postsApiUrl
                ++ "&pageSize="
                ++ (toString mod.settings.pageSize)
    in
        Http.send (Api << PostPageLoaded) (Http.get uri decodePostPage)


getPrevPost : Post -> Cmd Msg
getPrevPost model =
    navigatePost "prev" model
        |> orElse
            (\() ->
                navigatePost "previous" model
            )
        |> Maybe.withDefault Cmd.none


getNextPost : Post -> Cmd Msg
getNextPost =
    navigatePost "next"
        >> Maybe.withDefault Cmd.none


getPrevPage : PostPage -> Cmd Msg
getPrevPage model =
    navigatePage "prev" model
        |> orElse
            (\() ->
                navigatePage "previous" model
            )
        |> Maybe.withDefault Cmd.none


getNextPage : PostPage -> Cmd Msg
getNextPage =
    navigatePage "next"
        >> Maybe.withDefault Cmd.none


getPost : Post -> Cmd Msg
getPost =
    navigatePost "self"
        >> Maybe.withDefault Cmd.none


type alias ResultMapper a =
    Result Error (Resource a) -> Msg


navigatePost rel =
    navigate rel (Api << PostLoaded) decodePost


navigatePage rel =
    navigate rel (Api << PostPageLoaded) decodePostPage


navigate :
    String
    -> ResultMapper a
    -> Json.Decoder (Resource a)
    -> Resource a
    -> Maybe (Cmd Msg)
navigate rel msg dec rs =
    Hal.link rel rs
        |> Maybe.map
            (\lnk ->
                Http.send msg (Http.get lnk.href dec)
            )


orElse : (() -> Maybe a) -> Maybe a -> Maybe a
orElse alt mb =
    case mb of
        Maybe.Just _ ->
            mb

        Maybe.Nothing ->
            alt ()



-- JSON


decodePostPage : Json.Decoder PostPage
decodePostPage =
    Hal.resource <|
        Json.map PostPage
            (field
                "_embedded"
                (field
                    "posts"
                    (Json.list decodePost)
                )
            )


decodePost : Json.Decoder Post
decodePost =
    Hal.resource <|
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
