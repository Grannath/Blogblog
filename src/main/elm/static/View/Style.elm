module View.Style exposing (class, classes, styleTag, Overview(..), Header(..))

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace
import Html exposing (Attribute)
import Html.Attributes exposing (scoped)
import Html.CssHelpers
import Html.Attributes


cssHelpers =
    Html.CssHelpers.withNamespace ""


class : cl -> Attribute msg
class c =
    cssHelpers.class [ c ]


classes : List cl -> Attribute msg
classes li =
    cssHelpers.class li


type Overview
    = PostList
    | PostListNavigation
    | PostListTeaser
    | TeaserHeadline
    | TeaserDetails
    | TeaserAuthor
    | TeaserCreated
    | TeaserContent


type Header
    = HeaderArea
    | HeaderHeadline


darkPrimaryColor =
    hex "#455A64"


defaultPrimaryColor =
    hex "#607D8B"


lightPrimaryColor =
    hex "#CFD8DC"


textPrimaryColor =
    hex "#FFFFFF"


accentColor =
    hex "#536DFE"


primaryTextColor =
    hex "#212121"


secondaryTextColor =
    hex "#757575"


dividerColor =
    hex "#BDBDBD"


css =
    stylesheet
        [ (.) PostList
            [ displayFlex
            , flexDirection column
            ]
        , (.) PostListNavigation
            [ margin auto ]
        , (.) PostListTeaser
            [ margin auto
            , width <| px 700
            , paddingLeft <| px 50
            , paddingRight <| px 50
            , borderImageWidth2 (px 5) (px 0)
            , borderStyle solid
            , borderColor transparent
            , nthChild
                "odd"
                [ property
                    "background-image"
                    "linear-gradient(to right, transparent 0%, #E1E7EA 10%, #E1E7EA 90%, transparent 100%)"
                ]
            , hover
                [ property
                    "border-image"
                    "linear-gradient(to right, transparent 0%, #455A64 10%, #455A64 90%, transparent 100%) 1"
                , cursor pointer
                ]
            ]
        , (.) TeaserCreated
            [ textAlign right
            ]
        , (.) HeaderHeadline
            [ paddingLeft <| px 30 ]
        ]


styleTag =
    Html.node
        "style"
        [ scoped True ]
        [ Html.text <| .css <| compile [ css ] ]
