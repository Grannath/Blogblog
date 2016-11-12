import Date exposing (Date)
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Error(BadResponse, NetworkError, Timeout, UnexpectedPayload))
import Json.Decode as Json exposing (string, (:=))
import List exposing (map)
import Task



main =
  App.program
    { init = init "cats"
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Post =
  { title : String
  , content : String
  , author : String
  }

type alias PostList =
  { posts : List Post
  , page : Int
  }

type Model = Multiple PostList | Single Post | LoadError Http.Error

init : String -> (Model, Cmd Msg)
init topic =
  ( Multiple (PostList [] 0)
  , getPostList 0
  )



-- UPDATE


type Msg
  = FetchList PostList
  | FetchPost Post
  | FetchFail Http.Error


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    FetchList list ->
      (Multiple list, Cmd.none)

    FetchPost post ->
      (Single post, Cmd.none)

    FetchFail error ->
      (LoadError error, Cmd.none)



-- VIEW


view : Model -> Html Msg
view model =
  case model of
    Multiple posts ->
      div [] (map showPost posts.posts)
    Single post ->
      showPost post
    LoadError error ->
     div []
         [ h2 [] [text "Error!"]
         , br [] []
         , text (errorText error)
         ]

errorText : Http.Error -> String
errorText error =
  case error of
    Timeout ->
      "Timeout!"
    NetworkError ->
      "Network error!"
    UnexpectedPayload msg ->
      "Unexpected payload: " ++ msg
    BadResponse code msg ->
      "Bad response: " ++ (toString code) ++ " : " ++ msg

showPost : Post -> Html Msg
showPost post =
  div []
    [ h2 [] [text post.title]
    , br [] []
    , text post.content
    , br [] []
    , text post.author
    ]

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- HTTP


getPostList : Int -> Cmd Msg
getPostList page =
  let
    url = Http.url "http://localhost:8080/public/posts/" [("page", (toString page))]
  in
    Task.perform FetchFail FetchList (Http.get (parsePostList page) url)

parsePostList : Int -> Json.Decoder PostList
parsePostList page =
  Json.object2 PostList
    (Json.list parsePost)
    (Json.succeed page)

parsePost : Json.Decoder Post
parsePost =
  Json.object3 Post
    ("title" := string)
    ("content" := string)
    ("author" := string)
