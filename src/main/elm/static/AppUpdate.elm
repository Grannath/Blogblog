module AppUpdate exposing (update, init, subscriptions)

import AppModel exposing (Model, Msg(..), Page(..), Post, Settings)
import Api exposing (..)
import List exposing (append, head, reverse, take)
import Maybe exposing (withDefault)


init : ( Model, Cmd Msg )
init =
    let
        initSet =
            (Settings 10)
    in
        ( Model initSet (Loading Nothing)
        , getPosts initSet
        )


subscriptions : { md | app : Model } -> Sub Msg
subscriptions { app } =
    Sub.none


update : Msg -> { md | app : Model } -> ( Model, Cmd Msg )
update msg { app } =
    case msg of
        LoadNext ->
            loadNext app

        NextLoaded (Ok list) ->
            nextLoaded app list

        LoadPrevious ->
            loadPrevious app

        PreviousLoaded (Ok list) ->
            previousLoaded app list

        LoadPost post ->
            ( { app | page = Loading (Just app.page) }, getPost post )

        PostLoaded (Ok post) ->
            ( { app | page = Detailed post }, Cmd.none )

        NextLoaded (Err error) ->
            ( { app | page = LoadError error }, Cmd.none )

        PreviousLoaded (Err error) ->
            ( { app | page = LoadError error }, Cmd.none )

        PostLoaded (Err error) ->
            ( { app | page = LoadError error }, Cmd.none )


loadNext : Model -> ( Model, Cmd Msg )
loadNext model =
    ( { model | page = Loading (Just model.page) }
    , getPostList model
        |> reverse
        |> head
        |> Maybe.map (getNextPosts model.settings)
        |> withDefault (getPosts model.settings)
    )


loadPrevious : Model -> ( Model, Cmd Msg )
loadPrevious model =
    ( { model | page = Loading (Just model.page) }
    , getPostList model
        |> head
        |> Maybe.map (getPreviousPosts model.settings)
        |> withDefault (getPosts model.settings)
    )


getPostList : Model -> List Post
getPostList model =
    case model.page of
        Overview list ->
            list

        Loading (Just (Overview list)) ->
            list

        _ ->
            []


previousLoaded : Model -> List Post -> ( Model, Cmd Msg )
previousLoaded model list =
    ( list
        ++ (getPostList model)
        |> takeFirst model.settings.pageSize
        |> setPostList model
    , Cmd.none
    )


nextLoaded : Model -> List Post -> ( Model, Cmd Msg )
nextLoaded model list =
    ( (getPostList model)
        ++ list
        |> takeLast model.settings.pageSize
        |> setPostList model
    , Cmd.none
    )


takeFirst : Int -> List a -> List a
takeFirst number list =
    take number list


takeLast : Int -> List a -> List a
takeLast number list =
    reverse list
        |> take number
        |> reverse


setPostList : Model -> List Post -> Model
setPostList model list =
    { model | page = Overview list }
