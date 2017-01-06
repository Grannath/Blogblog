module View.PostOverview exposing (overview)

import List exposing (append)
import View.Style exposing (class, PostListType(..))
import AppModel exposing (Post)
import Html exposing (..)
import Html.Events exposing (..)
import Markdown
import View.Utils exposing (dateString)


overview : List Post -> Html AppModel.Msg
overview posts =
    let
        links =
            postNavigation
    in
        article
            [ class PostListBlock ]
            (append
                (links
                    :: (List.map postTeaser posts)
                )
                [ links ]
            )


postTeaser : Post -> Html AppModel.Msg
postTeaser post =
    section
        [ class PostListTeaser
        , onClick (AppModel.LoadPost post)
        ]
        [ h2
            [ class TeaserHeadline
            ]
            [ text post.title
            ]
        , div
            [ class TeaserDetails ]
            [ span
                [ class TeaserAuthor ]
                [ text ("by " ++ post.author) ]
            , time
                [ class TeaserCreated ]
                [ text (dateString post.created) ]
            ]
        , Markdown.toHtml
            [ class TeaserContent ]
            post.content
        ]


postNavigation : Html AppModel.Msg
postNavigation =
    nav
        [ class PostListNavigation ]
        [ a
            [ onClick AppModel.LoadPrevious
            , class NavigationNewer
            ]
            [ text "< Newer" ]
        , text " | "
        , a
            [ onClick AppModel.LoadNext
            , class NavigationOlder
            ]
            [ text "Older >" ]
        ]
