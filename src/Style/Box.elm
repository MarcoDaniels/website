module Style.Box exposing (..)

import Css
import Html.Styled as Html
import Style.Recipe exposing (recipe)


type Color
    = PrimaryColor
    | SecondaryColor
    | DefaultColor


type Size
    = SmallSize
    | MediumSize
    | LargeSize
    | DefaultSize


type Content
    = CenterContent
    | LeftContent
    | RightContent
    | DefaultContent


type Align
    = CenterAlign
    | DefaultAlign


type alias Box =
    { color : Color, size : Size, content : Content, align : Align }


box : (Box -> Box) -> Html.Attribute msg
box =
    recipe
        { base = Css.batch []
        , default =
            { color = DefaultColor
            , size = DefaultSize
            , content = DefaultContent
            , align = DefaultAlign
            }
        , variants =
            \{ color, size, content, align } ->
                [ case color of
                    PrimaryColor ->
                        Css.batch
                            [ Css.backgroundColor <| Css.hex "e7e7e7"
                            , Css.color <| Css.hex "000000"
                            ]

                    SecondaryColor ->
                        Css.batch []

                    DefaultColor ->
                        Css.batch []
                , case size of
                    _ ->
                        Css.batch []
                , case content of
                    CenterContent ->
                        Css.batch
                            [ Css.displayFlex
                            , Css.justifyContent Css.center
                            , Css.alignItems Css.center
                            ]

                    _ ->
                        Css.batch []
                , case align of
                    _ ->
                        Css.batch []
                ]
        }
