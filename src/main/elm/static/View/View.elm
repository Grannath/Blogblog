module View.View exposing (Msg(..), Model, view, update, init, subscriptions)

import View.Style as Style
import View.Header as Header
import View.Placeholder as Placeholder
import View.FullPost as FullPost
import View.PostOverview as Overview
import View.Error as ErrorView
import AppModel exposing (Page(..))
import Html exposing (Html)
import Html.Attributes
import Material.Layout as Layout
import Material


type Msg
    = App AppModel.Msg
    | View (Material.Msg Msg)


type alias Model =
    { app : AppModel.Model
    , mdl : Material.Model
    }


init : ( AppModel.Model, Cmd AppModel.Msg ) -> ( Model, Cmd Msg )
init ( model, cmd ) =
    ( Model model Material.model
    , Cmd.batch [ Material.init View, Cmd.map App cmd ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Material.subscriptions View model


update : Material.Msg Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Material.update View msg model


view : Model -> Html Msg
view model =
    Html.div
        []
        [ Style.styleTag
        , Layout.render View
            model.mdl
            []
            { header = Header.header model.app |> toFullMsg
            , drawer = []
            , tabs = ( [], [] )
            , main = mainContent model
            }
        ]


toFullMsg : List (Html AppModel.Msg) -> List (Html Msg)
toFullMsg list =
    List.map (Html.map App) list


mainContent : Model -> List (Html Msg)
mainContent model =
    (case model.app.page of
        Loading ->
            [ Placeholder.loading ]

        Overview list ->
            [ Overview.overview list ]

        Detailed post ->
            [ FullPost.fullPost post ]

        ErrorPage error ->
            [ ErrorView.loadError error ]
    )
        |> toFullMsg
