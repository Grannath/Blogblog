module View.Error exposing (loadError)

import AppModel exposing (Model, Msg)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http


loadError : Http.Error -> Html Msg
loadError error =
    text <| errorText error


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
            "Bad status: " ++ (toString rsp)

        Http.BadPayload msg rsp ->
            "Bad payload: " ++ msg ++ ", " ++ (toString rsp)