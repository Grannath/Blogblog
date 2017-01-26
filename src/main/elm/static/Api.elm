module Api
    exposing
        ( goToFirstPosts
        , goToNextPage
        , goToPrevPage
        , goToNextPost
        , goToPrevPost
        , goToPost
        )

import AppModel exposing (ApiResponse(..), Model, Msg(Api), Post, PostPage, SiteMap(..))
import AppRouting
import Http exposing (..)
import Maybe exposing (Maybe(..), map, withDefault, andThen)
import Navigation exposing (newUrl)
import Hal exposing (Link, Resource)
import Json.Decode as Json exposing (field, int, string, list)
import Time.ZonedDateTime exposing (ZonedDateTime)
import TimeExtra exposing (fromExtendedIso, toExtendedIso)


apiUrl =
    "http://localhost:8080/api"


type alias MCM =
    ( Model, Cmd Msg )



-- Navigation


goToFirstPosts : Model -> MCM
goToFirstPosts model =
    setFirstPostsUrl
        |> map
            (locationAnd (getFirstPosts model) model)
        |> withDefault
            ( model, Cmd.none )


goToPrevPost : Model -> Maybe Post -> MCM
goToPrevPost =
    goTo setPrevPostUrl getPrevPost


goToNextPost : Model -> Maybe Post -> MCM
goToNextPost =
    goTo setNextPostUrl getNextPost


goToPost : Model -> Maybe Post -> MCM
goToPost =
    goTo setPostUrl getPost


goToPrevPage : Model -> Maybe PostPage -> MCM
goToPrevPage =
    goTo setPrevPageUrl getPrevPage


goToNextPage : Model -> Maybe PostPage -> MCM
goToNextPage =
    goTo setNextPageUrl getNextPage


goTo :
    (r -> Maybe ( SiteMap, Cmd Msg ))
    -> (r -> Cmd Msg)
    -> Model
    -> Maybe r
    -> MCM
goTo pageMap loadMap mdl res =
    let
        empty = ( mdl, Cmd.none )
    in
        case res of
            Just re ->
                pageMap re
                    |> map
                        (locationAnd (loadMap re) mdl)
                    |> withDefault
                        empty

            _ ->
                empty


locationAnd : Cmd Msg -> Model -> ( SiteMap, Cmd Msg ) -> MCM
locationAnd loadCmd model ( sm, setCmd ) =
    ( { model | location = sm }
    , Cmd.batch [ setCmd, loadCmd ]
    )



-- Loading


getFirstPosts : Model -> Cmd Msg
getFirstPosts mod =
    let
        uri =
            apiUrl
                ++ "/posts"
                ++ "&pageSize="
                ++ (toString mod.settings.pageSize)
    in
        Http.send (Api << PostPageLoaded) (Http.get uri decodePostPage)


getPrevPost : Post -> Cmd Msg
getPrevPost post =
    loadPostLink "prev" post
        |> orElse
            (\() ->
                loadPostLink "previous" post
            )
        |> withDefault Cmd.none


getNextPost : Post -> Cmd Msg
getNextPost =
    loadPostLink "next"
        >> withDefault Cmd.none


getPrevPage : PostPage -> Cmd Msg
getPrevPage model =
    loadPageLink "prev" model
        |> orElse
            (\() ->
                loadPageLink "previous" model
            )
        |> withDefault Cmd.none


getNextPage : PostPage -> Cmd Msg
getNextPage =
    loadPageLink "next"
        >> withDefault Cmd.none


getPost : Post -> Cmd Msg
getPost =
    loadPostLink "self"
        >> withDefault Cmd.none


type alias ResultMapper a =
    Result Error (Resource a) -> Msg


loadPostLink rel =
    load rel (Api << PostLoaded) decodePost


loadPageLink rel =
    load rel (Api << PostPageLoaded) decodePostPage


load :
    String
    -> ResultMapper a
    -> Json.Decoder (Resource a)
    -> Resource a
    -> Maybe (Cmd Msg)
load rel msg dec rs =
    Hal.link rel rs
        |> map
            (\lnk ->
                Http.send msg (Http.get lnk.href dec)
            )



-- URL handling


setFirstPostsUrl : Maybe ( SiteMap, Cmd Msg )
setFirstPostsUrl =
    Just ( Home, newUrl (AppRouting.toUrl Home) )


setNextPostUrl : Post -> Maybe ( SiteMap, Cmd Msg )
setNextPostUrl =
    navigatePost "next"


setPrevPostUrl : Post -> Maybe ( SiteMap, Cmd Msg )
setPrevPostUrl post =
    navigatePost "prev" post
        |> orElse
            (\() ->
                navigatePost "previous" post
            )


setPostUrl : Post -> Maybe ( SiteMap, Cmd Msg )
setPostUrl =
    navigatePost "self"


setNextPageUrl : PostPage -> Maybe ( SiteMap, Cmd Msg )
setNextPageUrl =
    navigatePage "next"


setPrevPageUrl : PostPage -> Maybe ( SiteMap, Cmd Msg )
setPrevPageUrl page =
    navigatePage "prev" page
        |> orElse
            (\() ->
                navigatePage "previous" page
            )


navigatePage rel =
    navigate rel pageLocation


pageLocation lnk =
    let
        api =
            apiUrl ++ "/posts"

        offset =
            String.length api

        query =
            String.dropLeft offset lnk.href
    in
        if String.startsWith api lnk.href then
            Just (PostSearch query)
        else
            Nothing


navigatePost rel =
    navigate rel postLocation


postLocation lnk =
    let
        api =
            apiUrl ++ "/posts/"

        offset =
            String.length api

        title =
            String.dropLeft offset lnk.href
    in
        if String.startsWith api lnk.href then
            Just (SinglePost title)
        else
            Nothing


navigate :
    String
    -> (Link -> Maybe SiteMap)
    -> Resource a
    -> Maybe ( SiteMap, Cmd Msg )
navigate rel mapper rs =
    Hal.link rel rs
        |> andThen
            mapper
        |> map
            (\sm ->
                ( sm, newUrl (AppRouting.toUrl sm) )
            )



-- Utils


orElse : (() -> Maybe a) -> Maybe a -> Maybe a
orElse alt mb =
    case mb of
        Just _ ->
            mb

        Nothing ->
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
