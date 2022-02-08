module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Css
import DataSource
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Path exposing (Path)
import Settings exposing (Settings, settingsData)
import SharedTemplate exposing (SharedTemplate)
import Style.Center exposing (centerStyle)
import Style.Theme exposing (useTheme)


type Msg
    = OnPageChange
        { path : Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | SharedMsg SharedMsg


type alias Data =
    Settings


type SharedMsg
    = NoOp


type alias Model =
    { menuExpand : Bool }


template : SharedTemplate Msg Model Data msg
template =
    { init =
        \_ _ _ ->
            ( { menuExpand = False }, Cmd.none )
    , update =
        \msg model ->
            case msg of
                OnPageChange _ ->
                    ( { model | menuExpand = False }, Cmd.none )

                SharedMsg _ ->
                    ( model, Cmd.none )
    , subscriptions = \_ _ -> Sub.none
    , view =
        \sharedData _ model toMsg pageView ->
            { title = sharedData.site.title ++ " - " ++ pageView.title
            , body =
                useTheme
                    [ Html.article
                        [ Html.css
                            [ Css.height <| Css.vh 100
                            , centerStyle.column
                            ]
                        ]
                        pageView.body
                    ]
            }
    , data = settingsData
    , onPageChange = Just OnPageChange
    }
