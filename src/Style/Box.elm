module Style.Box exposing (Align(..), Box, Color(..), Content(..), Size(..), Space(..), Wrapper(..), box)

import Css
import Html.Styled as Html
import Style.Recipe exposing (recipe)


type Color
    = DefaultColor
    | PrimaryColor
    | SecondaryColor


type Size
    = DefaultSize
    | SmallSize
    | MediumSize
    | LargeSize


type Content
    = DefaultContent
    | CenterContent
    | LeftContent
    | RightContent


type Align
    = DefaultAlign
    | CenterAlign


type Space
    = DefaultSpace
    | SmallSpace
    | MediumSpace


type Wrapper
    = WithWrapper
    | WithoutWrapper


type alias Box =
    { color : Color
    , size : Size
    , content : Content
    , align : Align
    , space : Space
    , wrapper : Wrapper
    }


noProperty : Css.Style
noProperty =
    Css.batch []


box : (Box -> Box) -> Html.Attribute msg
box =
    recipe
        { base = Css.batch []
        , default =
            { color = DefaultColor
            , size = DefaultSize
            , content = DefaultContent
            , align = DefaultAlign
            , space = DefaultSpace
            , wrapper = WithoutWrapper
            }
        , variants =
            \{ color, size, content, align, space, wrapper } ->
                [ case color of
                    PrimaryColor ->
                        Css.batch
                            [ Css.backgroundColor <| Css.hex "e7e7e7"
                            , Css.color <| Css.hex "000000"
                            ]

                    SecondaryColor ->
                        noProperty

                    DefaultColor ->
                        noProperty
                , case size of
                    _ ->
                        noProperty
                , case content of
                    CenterContent ->
                        Css.batch
                            [ Css.displayFlex
                            , Css.justifyContent Css.center
                            , Css.alignItems Css.center
                            ]

                    _ ->
                        noProperty
                , case align of
                    _ ->
                        noProperty
                , case space of
                    SmallSpace ->
                        Css.padding <| Css.px 10

                    MediumSpace ->
                        Css.padding <| Css.px 40

                    DefaultSpace ->
                        noProperty
                , case wrapper of
                    WithWrapper ->
                        Css.batch
                            [ Css.borderWidth <| Css.px 0.1
                            , Css.borderStyle Css.solid
                            , Css.borderImageWidth <| Css.px 20
                            , Css.property "border-image-slice" "50%"
                            , Css.property "border-image-source" "url(\"data:image/svg+xml;charset=utf8,%3Csvg xmlns=%22http:%2F%2Fwww.w3.org%2F2000%2Fsvg%22 viewBox=%220 0 40 40%22%3E%3Crect x=%220.5%22 y=%220.5%22 width=%2239%22 height=%2239%22 fill=%22transparent%22 stroke=%22%23000%22 stroke-width=%221%22 %2F%3E%3C%2Fsvg%3E\")"
                            ]

                    WithoutWrapper ->
                        noProperty
                ]
        }
