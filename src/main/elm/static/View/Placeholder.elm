module View.Placeholder exposing (loading)

import Html exposing (..)
import Material.Spinner exposing (..)
import View.Style exposing (..)


loading : Html a
loading =
    article
        [ class PlaceholderBlock ]
        [ div
            [ class PlaceholderSpinner ]
            [ spinner
                [ active True ]
            ]
        ]
