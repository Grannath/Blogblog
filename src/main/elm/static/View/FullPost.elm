module View.FullPost exposing (fullPost)

import AppModel exposing (Msg, Post)
import Html exposing (..)
import Html.Attributes exposing (..)


fullPost : Post -> Html Msg
fullPost model =
    text "foo"