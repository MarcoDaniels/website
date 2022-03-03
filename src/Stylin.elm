module Stylin exposing (..)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Html


type Color
    = PrimaryColor
    | SecondaryColor


type Size
    = SmallSize
    | MediumSize
    | LargeSize


type alias Stylin =
    { color : Color, size : Size }


recipe : { base : Css.Style, default : a, variants : a -> List Css.Style } -> (a -> a) -> Html.Attribute msg
recipe { base, default, variants } styleFn =
    (default |> styleFn) |> (variants >> List.append [ base ]) |> Html.css


stylin : (Stylin -> Stylin) -> Html.Attribute msg
stylin =
    recipe
        { base = Css.batch [ Css.padding <| Css.px 20 ]
        , default = { color = PrimaryColor, size = SmallSize }
        , variants =
            \{ color, size } ->
                [ case color of
                    PrimaryColor ->
                        Css.batch
                            [ Css.color <| Css.hex "fff"
                            , Css.backgroundColor <| Css.hex "000"
                            ]

                    SecondaryColor ->
                        Css.batch
                            [ Css.color <| Css.hex "000"
                            , Css.backgroundColor <| Css.hex "fff"
                            ]
                , case size of
                    MediumSize ->
                        Css.batch
                            [ Css.width <| Css.px 100
                            , Css.maxWidth <| Css.pct 100
                            , Css.padding <| Css.px 40
                            ]

                    _ ->
                        Css.batch []
                ]
        }
