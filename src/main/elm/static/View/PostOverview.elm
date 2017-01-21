module View.PostOverview exposing (overview)

import List exposing (append)
import View.Style exposing (class, PostListType(..))
import AppModel exposing (Post, PostPage, UserNavigation(..))
import Html exposing (..)
import Html.Events exposing (..)
import Markdown
import View.Utils exposing (dateString)


overview : PostPage -> Html AppModel.Msg
overview page =
    let
        links =
            postNavigation
    in
        article
            [ class PostListBlock ]
            (append
                (links
                    :: (List.map postTeaser page.posts)
                )
                [ links ]
            )


postTeaser : Post -> Html AppModel.Msg
postTeaser post =
    section
        [ class PostListTeaser
        , onClick (AppModel.User (ShowPost post))
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
            [ onClick (AppModel.User PrevPage)
            , class NavigationNewer
            ]
            [ text "< Newer" ]
        , text " | "
        , a
            [ onClick (AppModel.User NextPage)
            , class NavigationOlder
            ]
            [ text "Older >" ]
        ]
