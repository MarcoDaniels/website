module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template, wrapper)

import Comic
import Css.Global
import Footer exposing (footer)
import Html as ElmHtml
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Navigation exposing (Navigation, navigation)
import Path exposing (Path)
import Route exposing (Route)
import Settings exposing (Settings, settingsData)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)


type Msg
    = SharedMsg SharedMsg


type alias Data =
    Settings


type SharedMsg
    = NoOp


type alias Model =
    ()


view :
    Data
    -> { path : Path, route : Maybe Route }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { title : String, body : ElmHtml.Html msg }
view sharedData _ model toMsg pageView =
    { title = pageView.title
    , body =
        [ navigation sharedData.navigation
        , Html.article [] pageView.body
        , footer { line = sharedData.footer, social = sharedData.social }
        ]
            |> wrapper
    }



-- TODO: rename


wrapper : List (Html.Html msg) -> ElmHtml.Html msg
wrapper children =
    Html.div [ Html.css [ Comic.page ] ]
        ([ Css.Global.global
            [ Css.Global.html [ Comic.shelf ], Css.Global.body [ Comic.book ] ]
            |> List.singleton
         , children
         ]
            |> List.concat
        )
        |> Html.toUnstyled


template : SharedTemplate Msg Model Data msg
template =
    { init = \_ _ _ -> ( (), Cmd.none )
    , update = \msg model -> ( model, Cmd.none )
    , subscriptions = \_ _ -> Sub.none
    , view = view
    , data = settingsData
    , onPageChange = Nothing
    }
