module Main exposing (..)

import Navigation exposing (Location)
import View.View as View exposing (Model, Msg(..), view)
import AppModel
import AppUpdate



main =
    Navigation.program
        (App << AppUpdate.goTo)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Location -> ( Model, Cmd Msg )
init loc =
    AppUpdate.init loc |> View.init



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        App appMsg ->
            AppUpdate.update appMsg model.app |> map model

        View mdlMsg ->
            View.update mdlMsg model


map : Model -> ( AppModel.Model, Cmd AppModel.Msg) -> ( Model, Cmd Msg )
map model ( appModel, appCmd ) =
    ( { model | app = appModel }
    , Cmd.map App appCmd
    )


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AppUpdate.subscriptions model |> Sub.map App
        , View.subscriptions model
        ]
