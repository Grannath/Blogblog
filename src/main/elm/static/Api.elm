module Api exposing (getPosts, getPreviousPosts, getNextPosts, getPost)

import AppModel exposing (Settings, Post, Msg(..))
import Http exposing (..)
import Json.Decode as Json exposing (field, int, string, list)
import List exposing (head)
import Maybe exposing (andThen, map, withDefault)
import Regex exposing (HowMany(AtMost), contains, find, regex, split)
import String exposing (join)
import Time.TimeZone exposing (TimeZone, name)
import Time.TimeZones exposing (fromName)
import Time.ZonedDateTime exposing (ZonedDateTime, fromISO8601, toISO8601, timeZone)


postsApiUrl =
    "http://localhost:8080/public/posts"


getPosts : Settings -> Cmd Msg
getPosts set =
    Http.send NextLoaded (Http.get postsApiUrl parsePostList)


getNextPosts : Settings -> Post -> Cmd Msg
getNextPosts set post =
    let
        uri =
            postsApiUrl
                ++ "/next?from="
                ++ (Http.encodeUri <| toExtendedIso post.created)
                ++ "&pageSize="
                ++ (toString set.pageSize)
    in
        Http.send NextLoaded (Http.get uri parsePostList)


getPreviousPosts : Settings -> Post -> Cmd Msg
getPreviousPosts set post =
    let
        uri =
            postsApiUrl
                ++ "/previous?from="
                ++ (Http.encodeUri <| toExtendedIso post.created)
                ++ "&pageSize="
                ++ (toString set.pageSize)
    in
        Http.send PreviousLoaded (Http.get uri parsePostList)


getPost : Int -> Cmd Msg
getPost id =
    let
        url =
            postsApiUrl ++ "/" ++ (toString id)
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


zoneRegex =
    regex "\\[(.*)\\]"


fromExtendedIso : String -> Result String ZonedDateTime
fromExtendedIso iso =
    let
        zone =
            getZone iso

        timestamp =
            getTimestamp iso
    in
        case zone of
            Ok z ->
                case timestamp of
                    Ok ts ->
                        fromISO8601 z ts

                    Err msg ->
                        Err msg

            Err msg ->
                Err msg


getZone : String -> Result String TimeZone
getZone iso =
    let
        match =
            head <| find (AtMost 1) zoneRegex iso
    in
        case match of
            Just m ->
                head m.submatches
                    |> withDefault Nothing
                    |> andThen fromName
                    |> map Ok
                    |> withDefault (Err ("Did not recognize time zone found in string " ++ iso ++ "."))

            Nothing ->
                Err ("No time zone information in " ++ iso ++ ".")


getTimestamp : String -> Result String String
getTimestamp iso =
    let
        match =
            head <| split (AtMost 1) zoneRegex iso
    in
        case match of
            Just m ->
                Ok m

            Nothing ->
                Err ("No date-time information found in " ++ iso ++ ".")


toExtendedIso : ZonedDateTime -> String
toExtendedIso dateTime =
    toISO8601 dateTime
        ++ "["
        ++ (name <| timeZone dateTime)
        ++ "]"
