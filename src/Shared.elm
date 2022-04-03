module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Css.Global
import Element exposing (Element, ElmElement)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Path exposing (Path)
import Route exposing (Route)
import Settings exposing (Settings, settingsData)
import SharedTemplate exposing (SharedTemplate)
import Style
import View exposing (View)


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
            , Html.nav
                [ Html.css
                    [ Style.space.small, Style.gap.smallY, Style.content.left ]
                ]
                ([ List.singleton
                    (Html.a
                        [ Html.css
                            [ Style.color.primary
                            , Style.gap.mediumX
                            , Style.font.medium
                            , Style.screen.small [ Style.gap.smallX ]
                            ]
                        , Html.href sharedData.navigation.brand.url
                        ]
                        [ Html.text sharedData.navigation.brand.title ]
                    )
                 , sharedData.navigation.menu
                    |> List.map
                        (\item ->
                            Html.a
                                [ Html.css
                                    [ Style.color.primary
                                    , Style.gap.mediumX
                                    , Style.font.upperCase
                                    , Style.font.medium
                                    , Style.screen.small [ Style.gap.smallX ]
                                    ]
                                , Html.href item.url
                                ]
                                [ Html.text item.title ]
                        )
                 ]
                    |> List.concat
                )
            , Html.article
                [ Html.css [ Style.space.medium, Style.gap.mediumY, Style.container.wrapper ] ]
                pageView.body
            ]
            |> Html.toUnstyled
    }


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
    , view = view
    , data = settingsData
    , onPageChange = Just OnPageChange
    }
