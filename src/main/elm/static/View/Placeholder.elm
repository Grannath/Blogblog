module View.Placeholder exposing (loading)

import Html exposing (..)
import Html.Attributes exposing (..)


loading : Html a
loading =
    article
        [ class "pageplaceholder" ]
        [ text "Lädt..." ]
