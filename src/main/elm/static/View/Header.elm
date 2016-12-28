module View.Header exposing (header)

import AppModel exposing (Model, Msg)
import Html exposing (..)
import View.Style exposing (class, Header(..))


header : Model -> List (Html Msg)
header model =
    [ pageTitle model ]


pageTitle : Model -> Html AppModel.Msg
pageTitle model =
    div
        [ class HeaderArea ]
        [ h1
            [ class HeaderHeadline ]
            [ text "Blogblog" ]
        ]