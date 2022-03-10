module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Css.Global
import Element exposing (Element, ElmElement)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Path exposing (Path)
import Route exposing (Route)
import Settings exposing (Settings, settingsData)
import SharedTemplate exposing (SharedTemplate)
import Style.Box exposing (Category(..), Font(..), IO(..), Position(..), Size(..), box)
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
        Html.div [ Html.css (box (\default -> { default | wide = Large, align = Center })) ]
            [ Css.Global.global
                [ Css.Global.body
                    (box
                        (\default ->
                            { default | space = None, gap = None, font = Mono, color = Primary }
                        )
                    )
                ]
            , Html.nav
                [ Html.css
                    (box
                        (\default ->
                            { default | space = Small, wrapper = On, gap = Small }
                        )
                    )
                ]
                (sharedData.navigation
                    |> List.map
                        (\item ->
                            Html.a
                                [ Html.css
                                    (box
                                        (\default -> { default | color = Primary, space = Small })
                                    )
                                , Html.href item.url
                                ]
                                [ Html.text item.title ]
                        )
                )
            , Html.article
                [ Html.css
                    (box
                        (\default ->
                            { default | space = Medium, wrapper = On, gap = Small }
                        )
                    )
                ]
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
