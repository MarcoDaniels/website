module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Css
import Css.Global
import Element exposing (Element, ElmElement)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Path exposing (Path)
import Route exposing (Route)
import Settings exposing (Settings, settingsData)
import SharedTemplate exposing (SharedTemplate)
import Style.Box exposing (Align(..), Color(..), Content(..), Gap(..), Size(..), Space(..), Wrapper(..), box)
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
        Html.div [ box (\default -> { default | size = LargeSize, align = CenterAlign }) ]
            [ Css.Global.global
                -- TODO: move styles to box
                [ Css.Global.body
                    [ Css.margin <| Css.px 0
                    , Css.padding <| Css.px 0
                    , Css.fontFamilies [ "monospace" ]
                    , Css.backgroundColor <| Css.hex "e7e7e7"
                    ]
                ]
            , Html.nav
                [ box (\default -> { default | space = SmallSpace, wrapper = WithWrapper, gap = SmallGapY }) ]
                (sharedData.navigation
                    |> List.map
                        (\item ->
                            Html.a
                                [ box (\default -> { default | color = PrimaryColor, space = SmallSpace }), Html.href item.url ]
                                [ Html.text item.title ]
                        )
                )
            , Html.article [ box (\default -> { default | space = MediumSpace, wrapper = WithWrapper, gap = SmallGapY }) ] pageView.body
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
