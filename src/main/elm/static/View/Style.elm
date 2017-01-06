module View.Style
    exposing
        ( class
        , classes
        , styleTag
        , PostListType(..)
        , FullPostType(..)
        , HeaderType(..)
        )

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


type PostListType
    = PostListBlock
    | PostListNavigation
    | NavigationNewer
    | NavigationOlder
    | PostListTeaser
    | TeaserHeadline
    | TeaserDetails
    | TeaserAuthor
    | TeaserCreated
    | TeaserContent


type FullPostType
    = FullPostBlock
    | FullPost
    | PostHeadline
    | PostDetails
    | PostAuthor
    | PostCreated
    | PostContent


type HeaderType
    = HeaderBlock
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
    let
        navigationLink =
            mixin
                [ cursor pointer
                , hover
                    [ textDecoration underline ]
                ]

        flexColumn =
            mixin
                [ displayFlex
                , flexDirection column
                ]

        flexRow =
            mixin
                [ displayFlex
                , flexDirection row
                , flexWrap noWrap
                ]

        flexChildCentered =
            margin auto

        headerStyles =
            [ (.) HeaderHeadline
                [ paddingLeft (em 1) ]
            ]

        postListStyles =
            [ (.) PostListBlock
                [ flexColumn ]
            , (.) PostListNavigation
                [ flexChildCentered
                , fontSize xLarge
                , padding2 (em 1) (em 0)
                ]
            , (.) NavigationNewer
                [ navigationLink ]
            , (.) NavigationOlder
                [ navigationLink ]
            , (.) PostListTeaser
                [ flexChildCentered
                , width (em 55)
                , paddingLeft (em 5)
                , paddingRight (em 5)
                , borderImageWidth2 (em 1) (em 1)
                , borderStyle solid
                , borderColor transparent
                , cursor pointer
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
                    ]
                ]
            , (.) TeaserDetails
                [ flexRow
                , paddingBottom (em 1)
                ]
            , (.) TeaserAuthor
                [ marginRight auto
                , marginLeft (em 0)
                ]
            , (.) TeaserCreated
                [ marginLeft auto
                , marginRight (em 0)
                ]
            ]

        fullPostStyles =
            [ (.) FullPostBlock
                [ flexColumn ]
            , (.) FullPost
                [ flexChildCentered
                , width (em 65)
                ]
            , (.) PostDetails
                [ flexRow
                , paddingBottom (em 1.5)
                ]
            , (.) PostAuthor
                [ marginRight auto
                , marginLeft (em 0)
                ]
            , (.) PostCreated
                [ marginLeft auto
                , marginRight (em 0)
                ]
            ]
    in
        (stylesheet << List.concat)
            [ headerStyles
            , postListStyles
            , fullPostStyles
            ]


styleTag =
    Html.node
        "style"
        [ scoped True ]
        [ Html.text <| .css <| compile [ css ] ]
