module AppUpdate exposing (update, init, subscriptions, goTo)

import AppModel exposing (..)
import AppRouting exposing (Location)
import Api exposing (..)
import List exposing (append, head, reverse, take)
import Maybe exposing (withDefault)
import Http
import Navigation exposing (newUrl)
import Time.ZonedDateTime exposing (ZonedDateTime)


goTo : Location a -> Msg
goTo =
    AppRouting.match >> GoTo >> Routing


init : Location a -> MCM
init loc =
    let
        initSet =
            (Settings 10)

        initModel =
            Model initSet (Unknown "") (Loading Nothing)
    in
        update (goTo loc) initModel


subscriptions : { md | app : Model } -> Sub Msg
subscriptions { app } =
    Sub.none


type alias MCM =
    ( Model, Cmd Msg )


update : Msg -> Model -> MCM
update msg model =
    case msg of
        User nav ->
            userNavigation nav model

        Api api ->
            apiResponse api model

        Routing rt ->
            routeChange rt model


userNavigation : UserNavigation -> Model -> MCM
userNavigation nav model =
    let
        goToLocation loc =
            newUrl (AppRouting.toUri loc)

        updateLocation loc ( mdl, cmd ) =
            if mdl.location == loc then
                ( mdl, cmd )
            else
                ( { mdl | location = loc }
                , Cmd.batch [ cmd, goToLocation loc ]
                )

        oldest =
            getPostList model
                |> reverse
                |> head
                |> Maybe.map .created

        newest =
            getPostList model
                |> head
                |> Maybe.map .created

        olderQuery =
            PostQuery
                (Just model.settings.pageSize)
                (oldest
                    |> Maybe.map OlderThan
                )

        newerQuery =
            PostQuery
                (Just model.settings.pageSize)
                (newest
                    |> Maybe.map NewerThan
                )
    in
        case nav of
            LoadOlder ->
                updateLocation
                    (PostSearch olderQuery)
                    (oldest
                        |> Maybe.map (loadOlder model)
                        |> Maybe.withDefault (loadPosts model)
                    )

            LoadNewer ->
                updateLocation
                    (PostSearch newerQuery)
                    (newest
                        |> Maybe.map (loadNewer model)
                        |> Maybe.withDefault (loadPosts model)
                    )

            LoadPost post ->
                updateLocation
                    (SinglePost post.id)
                    (loadSinglePost model post.id)


apiResponse : ApiResponse -> Model -> MCM
apiResponse api model =
    case api of
        OlderLoaded (Ok list) ->
            olderLoaded model list

        NewerLoaded (Ok list) ->
            newerLoaded model list

        PostLoaded (Ok post) ->
            postLoaded model post

        OlderLoaded (Err err) ->
            loadError model err

        NewerLoaded (Err err) ->
            loadError model err

        PostLoaded (Err err) ->
            loadError model err


routeChange : RouteChanges -> Model -> MCM
routeChange rt model =
    let
        unknown uri =
            { model | page = ErrorPage (UnknownPage uri) }

        loc =
            case rt of
                GoTo lc ->
                    lc
    in
        if model.location == loc then
            ( model, Cmd.none )
        else
            case loc of
                Unknown uri ->
                    ( unknown uri, Cmd.none )

                Home ->
                    loadPosts model

                SinglePost id ->
                    loadSinglePost model id

                PostSearch pq ->
                    searchForPosts model pq


loadPosts : Model -> MCM
loadPosts model =
    ( { model | page = Loading (Just model.page) }
    , getPosts model.settings
    )


loadSinglePost : Model -> Int -> MCM
loadSinglePost model id =
    ( { model | page = Loading (Just model.page) }
    , getSinglePost id
    )


loadOlder : Model -> ZonedDateTime -> MCM
loadOlder model zdt =
    ( { model | page = Loading (Just model.page) }
    , getOlderPosts model.settings zdt
    )


loadNewer : Model -> ZonedDateTime -> MCM
loadNewer model zdt =
    ( { model | page = Loading (Just model.page) }
    , getNewerPosts model.settings zdt
    )


searchForPosts : Model -> PostQuery -> MCM
searchForPosts model query =
    let
        updateSettings sett =
            { sett | pageSize = query.pageSize |> Maybe.withDefault sett.pageSize }

        updatedModel =
            { model
                | page = Loading (Just model.page)
                , settings = updateSettings model.settings
            }

        loadResults mdl =
            case query.from of
                Nothing ->
                    loadPosts mdl

                Just (NewerThan zdt) ->
                    loadNewer mdl zdt

                Just (OlderThan zdt) ->
                    loadOlder mdl zdt
    in
        loadResults updatedModel


getPostList : Model -> List Post
getPostList model =
    case model.page of
        Overview list ->
            list

        Loading (Just (Overview list)) ->
            list

        _ ->
            []


newerLoaded : Model -> List Post -> MCM
newerLoaded model list =
    ( list
        ++ (getPostList model)
        |> takeFirst model.settings.pageSize
        |> setPostList model
    , Cmd.none
    )


olderLoaded : Model -> List Post -> MCM
olderLoaded model list =
    ( (getPostList model)
        ++ list
        |> takeLast model.settings.pageSize
        |> setPostList model
    , Cmd.none
    )


postLoaded : Model -> Post -> MCM
postLoaded model post =
    ( { model | page = Detailed post }
    , Cmd.none
    )


loadError : Model -> Http.Error -> MCM
loadError model err =
    ( { model | page = ErrorPage (LoadError err) }
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
