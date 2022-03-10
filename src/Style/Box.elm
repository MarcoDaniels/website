module Style.Box exposing (Box, Font(..), Category(..), IO(..), Position(..), Size(..), box)

import Css
import Style.Recipe exposing (recipe)


type Category
    = NoCategory
    | Primary
    | Secondary


type Position
    = NoPosition
    | Center
    | Left
    | Right


type Size
    = NoSize
    | None
    | Small
    | Medium
    | Large


type Font
    = NoFont
    | Mono


type IO
    = On
    | Off


type alias Box =
    { color : Category
    , wide : Size
    , content : Position
    , align : Position
    , space : Size
    , gap : Size
    , wrapper : IO
    , font : Font
    }


noProperty : Css.Style
noProperty =
    Css.batch []


box : (Box -> Box) -> List Css.Style
box =
    recipe
        { base = Css.batch []
        , default =
            { color = NoCategory
            , wide = NoSize
            , content = NoPosition
            , align = NoPosition
            , space = NoSize
            , gap = NoSize
            , wrapper = Off
            , font = NoFont
            }
        , variants =
            \{ color, wide, content, align, space, gap, wrapper, font } ->
                [ case color of
                    Primary ->
                        Css.batch
                            [ Css.backgroundColor <| Css.hex "e7e7e7"
                            , Css.color <| Css.hex "000000"
                            ]

                    _ ->
                        noProperty
                , case wide of
                    Large ->
                        Css.batch
                            [ Css.width <| Css.pct 100
                            , Css.maxWidth <| Css.px 750
                            ]

                    _ ->
                        noProperty
                , case content of
                    Center ->
                        Css.batch
                            [ Css.displayFlex
                            , Css.justifyContent Css.center
                            , Css.alignItems Css.center
                            ]

                    _ ->
                        noProperty
                , case align of
                    Center ->
                        Css.batch [ Css.margin2 (Css.px 0) Css.auto ]

                    _ ->
                        noProperty
                , case space of
                    None ->
                        Css.padding <| Css.px 0

                    Small ->
                        Css.padding <| Css.px 10

                    Medium ->
                        Css.padding <| Css.px 40

                    _ ->
                        noProperty
                , case gap of
                    None ->
                        Css.margin <| Css.px 0

                    Small ->
                        Css.batch
                            [ Css.marginTop <| Css.px 10
                            , Css.marginBottom <| Css.px 10
                            ]

                    _ ->
                        noProperty
                , case wrapper of
                    On ->
                        Css.batch
                            [ Css.borderWidth <| Css.px 0.1
                            , Css.borderStyle Css.solid
                            , Css.borderImageWidth <| Css.px 20
                            , Css.property "border-image-slice" "50%"
                            , Css.property "border-image-source" "url(\"data:image/svg+xml;charset=utf8,%3Csvg xmlns=%22http:%2F%2Fwww.w3.org%2F2000%2Fsvg%22 viewBox=%220 0 40 40%22%3E%3Crect x=%220.5%22 y=%220.5%22 width=%2239%22 height=%2239%22 fill=%22transparent%22 stroke=%22%23000%22 stroke-width=%221%22 %2F%3E%3C%2Fsvg%3E\")"
                            ]

                    Off ->
                        noProperty
                , case font of
                    Mono ->
                        Css.fontFamilies [ "monospace" ]

                    NoFont ->
                        noProperty
                ]
        }
