module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Css
import Element exposing (Element)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Path exposing (Path)
import Settings exposing (Settings, settingsData)
import SharedTemplate exposing (SharedTemplate)
import Style.Theme exposing (useTheme)
import Stylin exposing (Color(..), Size(..), stylin)


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


wrapper : Element msg -> List (Element msg) -> List (Element msg)
wrapper nav body =
    [ Html.div
        [ Html.css
            [ Css.padding <| Css.px 40
            , Css.borderWidth <| Css.px 0.1
            , Css.borderStyle Css.solid
            , Css.borderImageWidth <| Css.px 20
            , Css.property "border-image-slice" "50%"
            , Css.property "border-image-source" "url(\"data:image/svg+xml;charset=utf8,%3Csvg xmlns=%22http:%2F%2Fwww.w3.org%2F2000%2Fsvg%22 viewBox=%220 0 40 40%22%3E%3Crect x=%220.5%22 y=%220.5%22 width=%2239%22 height=%2239%22 fill=%22transparent%22 stroke=%22%23000%22 stroke-width=%221%22 %2F%3E%3C%2Fsvg%3E\")"
            ]
        ]
        [ nav
        , Html.p [ stylin (\default -> { default | color = SecondaryColor }) ] [ Html.text "some" ]
        , Html.article [] body
        ]
    ]


navigation : Settings -> Element msg
navigation settings =
    Html.nav
        [ Html.css [ Css.displayFlex ] ]
        (settings.navigation
            |> List.map
                (\item ->
                    Html.a
                        [ stylin (\_ -> { color = PrimaryColor, size = MediumSize })
                        , Html.href item.url
                        ]
                        [ Html.text item.title ]
                )
        )


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
            , body = wrapper (navigation sharedData) pageView.body |> useTheme
            }
    , data = settingsData
    , onPageChange = Just OnPageChange
    }
