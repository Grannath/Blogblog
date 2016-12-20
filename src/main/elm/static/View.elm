module View exposing (Msg(..), view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Model exposing (..)
import String exposing (join, padLeft)
import Time.Date exposing (Weekday(..))
import Time.DateTime as Time exposing (DateTime, day, month, year, hour, minute)
import Material
import Material.Layout as Layout


type Msg
    = LoadNext
    | LoadPrevious
    | NextLoaded (Result Http.Error (List Post))
    | PreviousLoaded (Result Http.Error (List Post))
    | LoadPost Post
    | PostLoaded (Result Http.Error Post)
    | Mdl (Material.Msg Msg)


view : Model -> Html Msg
view model =
    Layout.render Mdl
        model.mdl
        []
        { header = [ pageTitle model ]
        , drawer = []
        , tabs = ( [], [] )
        , main = [ mainContent model ]
        }


mainContent : Model -> Html Msg
mainContent model =
    case model.page of
        Loading ->
            loadPlaceholder

        Overview list ->
            postPage list

        Detailed post ->
            text "foo"

        LoadError error ->
            text <| errorText error


loadPlaceholder : Html Msg
loadPlaceholder =
    article
        [ class "pageplaceholder" ]
        [ text "Lädt..." ]


postPage : List Post -> Html Msg
postPage posts =
    article
        [ class "postlist" ]
        (List.map postTeaser posts)


postTeaser : Post -> Html Msg
postTeaser post =
    section
        [ class "postlist__teaser" ]
        [ h2
            [ class "postlist__headline"
            ]
            [ a
                [ onClick (LoadPost post) ]
                [ text post.title ]
            ]
        , div
            [ class "postlist__author" ]
            [ text ("von " ++ post.author) ]
        , div
            [ class "postlist__date" ]
            [ text (dateString post.created) ]
        , div
            [ class "postlist__content" ]
            [ p
                []
                [ text post.content ]
            ]
        ]


pageTitle : Model -> Html Msg
pageTitle model =
    div
        [ class "pagetitle" ]
        [ h1
            [ class "pagetitle__headline" ]
            [ text "Blogblog" ]
        ]


errorText : Http.Error -> String
errorText error =
    case error of
        Http.BadUrl url ->
            "Bad URL: " ++ url

        Http.Timeout ->
            "Timeout!"

        Http.NetworkError ->
            "Network error!"

        Http.BadStatus rsp ->
            "Bad status!"

        Http.BadPayload msg rsp ->
            "Bad payload: " ++ msg


dateString : DateTime -> String
dateString date =
    weekday date
        ++ ", the "
        ++ (join "."
                [ paddedDateComp day date
                , paddedDateComp month date
                , toString (year date)
                ]
           )
        ++ ", "
        ++ (join ":"
                [ paddedDateComp hour date
                , paddedDateComp minute date
                ]
           )


paddedDateComp : (DateTime -> Int) -> DateTime -> String
paddedDateComp comp date =
    comp date |> toString |> padLeft 2 '0'


weekday : DateTime -> String
weekday date =
    case Time.weekday date of
        Mon ->
            "Monday"

        Tue ->
            "Tuesday"

        Wed ->
            "Wednesday"

        Thu ->
            "Thursday"

        Fri ->
            "Friday"

        Sat ->
            "Saturday"

        Sun ->
            "Sunday"
