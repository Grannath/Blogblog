module Model exposing (..)

import Time.DateTime exposing (DateTime)
import Http exposing (Error)
import Material


type alias Post =
    { id : Int
    , title : String
    , content : String
    , author : String
    , created : DateTime
    }


type alias Settings =
    { pageSize : Int }


type Page
    = Overview (List Post)
    | Detailed Post
    | Loading
    | LoadError Error


type alias Model =
    { settings : Settings
    , page : Page
    , mdl : Material.Model
    }
