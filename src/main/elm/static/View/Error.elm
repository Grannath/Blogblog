module View.Error exposing (loadError)

import AppModel exposing (Model, Msg, Error(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Http


loadError : Error -> Html Msg
loadError error =
    text <| errorText error


errorText : Error -> String
errorText err =
    case err of
        UnknownPage txt ->
            "The page " ++ txt ++ " is unknown."

        LoadError httpErr ->
            httpErrorText httpErr


httpErrorText : Http.Error -> String
httpErrorText error =
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
