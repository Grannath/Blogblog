module AppUpdate exposing (update, init, subscriptions, route)

import AppModel exposing (..)
import AppRouting exposing (Location)
import Api exposing (..)
import List exposing (append, head, reverse, take)
import Maybe exposing (withDefault)
import Http
import Navigation exposing (newUrl)
import Time.ZonedDateTime exposing (ZonedDateTime)


route : Location a -> Msg
route =
    AppRouting.match >> GoTo >> Routing


init : Location a -> MCM
init loc =
    let
        initSet =
            (Settings 10)

        initModel =
            Model initSet (Unknown "") Loading
    in
        update (route loc) initModel


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
        postPage =
            case model.page of
                Overview pp ->
                    Maybe.Just pp

                _ ->
                    Maybe.Nothing

        post =
            case model.page of
                Detailed p ->
                    Maybe.Just p

                _ ->
                    Maybe.Nothing
    in
        case nav of
            NextPage ->
                goToNextPage model postPage
                    |> withLoadingPage

            PrevPage ->
                goToPrevPage model postPage
                    |> withLoadingPage

            NextPost ->
                goToNextPost model post
                    |> withLoadingPage

            PrevPost ->
                goToPrevPost model post
                    |> withLoadingPage

            ShowPost p ->
                goToPost model (Maybe.Just p)
                 |> withLoadingPage


apiResponse : ApiResponse -> Model -> MCM
apiResponse api model =
    case api of
        PostPageLoaded (Ok pp) ->
            ( { model | page = Overview pp }
            , Cmd.none
            )

        PostLoaded (Ok p) ->
            ( { model | page = Detailed p }
            , Cmd.none
            )

        PostPageLoaded (Err err) ->
            ( { model | page = ErrorPage (LoadError err) }
            , Cmd.none
            )

        PostLoaded (Err err) ->
            ( { model | page = ErrorPage (LoadError err) }
            , Cmd.none
            )


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
                    ( { model
                        | page = ErrorPage (UnknownPage uri)
                        , location = loc
                      }
                    , Cmd.none
                    )

                Home ->
                    ( model, Cmd.none )

                PostSearch query ->
                    ( model, Cmd.none )

                SinglePost id ->
                    ( model, Cmd.none )


withLoadingPage : MCM -> MCM
withLoadingPage ( model, cmd ) =
    ( { model | page = Loading }
    , cmd
    )
