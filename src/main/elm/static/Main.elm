module Main exposing (..)

import Platform.Cmd exposing (batch)
import List exposing (head, reverse, take)
import Maybe exposing (withDefault)
import Html
import Model exposing (..)
import Material
import View exposing (..)
import Api exposing (..)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    let
        initSet =
            (Settings 10)
    in
        ( Model initSet Loading Material.model
        , batch [ getPosts initSet, Material.init Mdl ]
        )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadNext ->
            loadNext model

        NextLoaded (Ok list) ->
            nextLoaded model list

        LoadPrevious ->
            loadPrevious model

        PreviousLoaded (Ok list) ->
            previousLoaded model list

        LoadPost post ->
            ( { model | page = Loading }, getPost post )

        PostLoaded (Ok post) ->
            ( { model | page = Detailed post }, Cmd.none )

        NextLoaded (Err error) ->
            ( { model | page = LoadError error }, Cmd.none )

        PreviousLoaded (Err error) ->
            ( { model | page = LoadError error }, Cmd.none )

        PostLoaded (Err error) ->
            ( { model | page = LoadError error }, Cmd.none )

        Mdl mdlMsg ->
            Material.update mdlMsg model


loadNext : Model -> ( Model, Cmd Msg )
loadNext model =
    ( { model | page = Loading }
    , getPostList model
        |> reverse
        |> head
        |> Maybe.map (getNextPosts model.settings)
        |> withDefault (getPosts model.settings)
    )


loadPrevious : Model -> ( Model, Cmd Msg )
loadPrevious model =
    ( { model | page = Loading }
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

        _ ->
            []


previousLoaded : Model -> List Post -> ( Model, Cmd Msg )
previousLoaded model list =
    ( prependPreviousPosts (getPostList model) model.settings.pageSize list
        |> setPostList model
    , Cmd.none
    )


prependPreviousPosts : List a -> Int -> List a -> List a
prependPreviousPosts listOld pageSize listPrev =
    listPrev ++ listOld |> take pageSize


nextLoaded : Model -> List Post -> ( Model, Cmd Msg )
nextLoaded model list =
    ( appendNextPosts (getPostList model) model.settings.pageSize list
        |> setPostList model
    , Cmd.none
    )


appendNextPosts : List a -> Int -> List a -> List a
appendNextPosts listOld pageSize listNext =
    listOld ++ listNext |> reverse |> take pageSize |> reverse


setPostList : Model -> List Post -> Model
setPostList model list =
    { model | page = Overview list }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Material.subscriptions Mdl model
