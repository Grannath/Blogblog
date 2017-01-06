module AppUpdate exposing (update, init, subscriptions, goTo)

import Navigation
import AppModel exposing (Model, Msg(..), Page(..), Post, Settings)
import AppRouting
import Api exposing (..)
import List exposing (append, head, reverse, take)
import Maybe exposing (withDefault)
import Http



matchLocation : Navigation.Location -> AppModel.Location
matchLocation {pathname, search} =
    AppRouting.match (pathname ++ search)
        |> Maybe.withDefault AppModel.NotFound


goTo : Navigation.Location -> Msg
goTo = matchLocation >> GoTo


init : Navigation.Location -> ( Model, Cmd Msg )
init loc =
    let
        initSet =
            (Settings 10)


        appLoc =
            matchLocation loc

        initModel =
            Model initSet appLoc (Loading Nothing)
    in
        update (GoTo appLoc) { app = initModel }


subscriptions : { md | app : Model } -> Sub Msg
subscriptions { app } =
    Sub.none


update : Msg -> { md | app : Model } -> ( Model, Cmd Msg )
update msg { app } =
    let
        setPage page =
            { app | page = page }
    in
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
                loadPost app post.id

            PostLoaded (Ok post) ->
                ( setPage (Detailed post), Cmd.none )

            NextLoaded (Err error) ->
                ( setPage (LoadError error), Cmd.none )

            PreviousLoaded (Err error) ->
                ( setPage (LoadError error), Cmd.none )

            PostLoaded (Err error) ->
                ( setPage (LoadError error), Cmd.none )

            GoTo AppModel.Home ->
                loadPosts app

            GoTo (AppModel.SinglePost id) ->
                loadPost app id

            GoTo _ ->
                ( setPage (LoadError (Http.BadUrl "")), Cmd.none )



assertLocation : Model -> AppModel.Location -> (Model, Cmd Msg)
assertLocation model loc =
    if model.location == loc then
        (model, Cmd.none)
    else
        ( { model | location = loc }, Navigation.newUrl (AppRouting.toUri loc) )



loadPosts : Model -> ( Model, Cmd Msg )
loadPosts app =
    let
        (mod, cmd) = assertLocation app AppModel.Home
    in
        ( { mod | page = Loading (Just mod.page) }
        , Cmd.batch
            [ getPosts mod.settings
            , cmd
            ]
        )


loadPost : Model -> Int -> ( Model, Cmd Msg )
loadPost app id =
    let
        (mod, cmd) = assertLocation app (AppModel.SinglePost id)
    in
        ( { mod | page = Loading (Just mod.page) }
        , Cmd.batch
            [ getPost id
            , cmd
            ]
        )


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
