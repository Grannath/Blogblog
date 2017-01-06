module View.FullPost exposing (fullPost)

import AppModel exposing (Msg, Post)
import View.Style exposing (class, FullPostType(..))
import Html exposing (..)
import View.Utils exposing (dateString)
import Markdown


fullPost : Post -> Html Msg
fullPost post =
    article
        [ class FullPostBlock ]
        [ showPost post ]


showPost : Post -> Html AppModel.Msg
showPost post =
    div
        [ class FullPost ]
        [ h1
            [ class PostHeadline
            ]
            [ text post.title
            ]
        , div
            [ class PostDetails ]
            [ span
                [ class PostAuthor ]
                [ text ("by " ++ post.author) ]
            , time
                [ class PostCreated ]
                [ text (dateString post.created) ]
            ]
        , Markdown.toHtml
            [ class PostContent ]
            post.content
        ]
