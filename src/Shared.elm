module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Css.Global
import Element exposing (Element, ElmElement)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Navigation exposing (Navigation, navigation)
import Path exposing (Path)
import Route exposing (Route)
import Settings exposing (Settings, settingsData)
import SharedTemplate exposing (SharedTemplate)
import Style
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
    -> { title : String, body : ElmElement msg }
view sharedData _ model toMsg pageView =
    { title = sharedData.site.title ++ " - " ++ pageView.title
    , body =
        Html.div [ Html.css [ Style.container.fit, Style.wide.large, Style.align.center, Style.screen.small [ Style.space.small ] ] ]
            [ Css.Global.global
                [ Css.Global.body [ Style.space.none, Style.gap.none, Style.font.mono, Style.color.primary ] ]
            , navigation sharedData.navigation
            , Html.article
                [ Html.css [ Style.space.medium, Style.gap.mediumY, Style.container.wrapper ] ]
                pageView.body
            ]
            |> Html.toUnstyled
    }


template : SharedTemplate Msg Model Data msg
template =
    { init = \_ _ _ -> ( (), Cmd.none )
    , update = \msg model -> ( model, Cmd.none )
    , subscriptions = \_ _ -> Sub.none
    , view = view
    , data = settingsData
    , onPageChange = Nothing
    }
