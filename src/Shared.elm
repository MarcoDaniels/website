module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Html.Styled as Html
import Html.Styled.Attributes as Html
import Path exposing (Path)
import Settings exposing (Settings, settingsData)
import SharedTemplate exposing (SharedTemplate)
import Style.Box exposing (Color(..), Content(..), Space(..), Wrapper(..), box)
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
                [ Html.div
                    [ box (\default -> { default | space = MediumSpace, wrapper = WithWrapper }) ]
                    [ Html.nav
                        []
                        (sharedData.navigation
                            |> List.map
                                (\item ->
                                    Html.a
                                        [ box (\default -> { default | color = PrimaryColor, space = SmallSpace }), Html.href item.url ]
                                        [ Html.text item.title ]
                                )
                        )
                    , Html.article [] pageView.body
                    ]
                ]
                    |> useTheme
            }
    , data = settingsData
    , onPageChange = Just OnPageChange
    }
