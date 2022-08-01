module Comic exposing (book, caption, color, font, gutter, illustration, page, panel, shelf, tier)

import Css
import Css.Animations
import Css.Media


onLargeScreen =
    Css.Media.withMedia [ Css.Media.only Css.Media.screen [ Css.Media.minWidth <| Css.px 700 ] ]


color : { book : Css.Color, page : Css.Color, page1 : Css.Color, page2 : Css.Color, ink : Css.Color, shadow : Css.Color }
color =
    { book = Css.hex "F2EFEA"
    , page = Css.hex "FFF"
    , page1 = Css.hex "FAFAFA"
    , page2 = Css.hex "F6F6F6"
    , ink = Css.hex "1F1926"
    , shadow = Css.hex "00000033"
    }


font : { extraSmall : Css.Style, small : Css.Style, medium : Css.Style, large : Css.Style, upperCase : Css.Style, mainTitle : Css.Style }
font =
    { extraSmall = Css.fontSize <| Css.rem 0.97
    , small = Css.fontSize <| Css.rem 1.05
    , medium = Css.fontSize <| Css.rem 1.25
    , large =
        Css.batch
            [ Css.fontSize <| Css.rem 2.15, Css.lineHeight <| Css.rem 2 ]
    , upperCase = Css.textTransform Css.uppercase
    , mainTitle = Css.fontWeight <| Css.int 100
    }


{-| Shelf: the book shelf
-}
shelf : Css.Style
shelf =
    Css.batch
        [ Css.backgroundColor color.book
        , Css.padding <| Css.px 0
        , Css.margin <| Css.px 0
        , Css.fontFamilies [ "Verdana, sans-serif" ]
        , Css.lineHeight <| Css.rem 1.5
        , Css.maxWidth <| Css.pct 100
        , Css.width <| Css.px 900
        , Css.margin2 (Css.px 0) Css.auto
        ]


{-| Book: comic contents
-}
book : Css.Style
book =
    let
        pageBase =
            Css.batch
                [ Css.property "content" "''"
                , Css.height <| Css.pct 98
                , Css.position Css.absolute
                , Css.width <| Css.pct 100
                , Css.zIndex <| Css.int -2
                , Css.animationDuration <| Css.sec 2
                ]
    in
    Css.batch
        [ Css.maxWidth <| Css.pct 100
        , Css.width <| Css.px 800
        , Css.position Css.relative
        , Css.margin3 (Css.px 40) Css.auto (Css.px 0)
        , Css.boxShadow5 (Css.px 0) (Css.px 6) (Css.px 6) (Css.px -6) color.shadow
        , Css.backgroundColor color.page
        , Css.color color.ink
        , Css.overflowX Css.hidden
        , Css.before
            [ pageBase
            , Css.backgroundColor color.page1
            , Css.boxShadow4 (Css.px 0) (Css.px 0) (Css.px 8) color.shadow
            , Css.top <| Css.px -10
            , onLargeScreen
                [ Css.left <| Css.px -5
                , Css.top <| Css.px 4
                , Css.transform <| Css.rotate <| Css.deg -2.5
                , Css.animationName
                    (Css.Animations.keyframes
                        [ ( 0, [ Css.Animations.property "transform" "rotate(0deg)" ] )
                        , ( 100, [ Css.Animations.property "transform" "rotate(-2.5deg)" ] )
                        ]
                    )
                ]
            ]
        , Css.after
            [ pageBase
            , Css.backgroundColor color.page2
            , Css.boxShadow4 (Css.px 0) (Css.px 0) (Css.px 3) color.shadow
            , Css.top <| Css.px -5
            , onLargeScreen
                [ Css.right <| Css.px -3
                , Css.top <| Css.px 1
                , Css.transform <| Css.rotate <| Css.deg 1.4
                , Css.animationName
                    (Css.Animations.keyframes
                        [ ( 0, [ Css.Animations.property "transform" "rotate(0deg)" ] )
                        , ( 100, [ Css.Animations.property "transform" "rotate(1.4deg)" ] )
                        ]
                    )
                ]
            ]
        ]


{-| Page: main page wrapper
-}
page =
    Css.batch [ Css.padding2 (Css.px 5) (Css.px 20) ]


{-| Caption: a box that is separate from the rest of the panel to provide context
-}
caption : Css.Style
caption =
    Css.batch
        [ Css.displayFlex
        , Css.justifyContent Css.spaceBetween
        , Css.alignItems Css.center
        , Css.margin2 (Css.px 20) (Css.px 0)
        , font.medium
        ]


{-| Panel: an illustration on a page usually surrounded by a border
-}
panel : Css.Style
panel =
    Css.batch
        [ Css.border2 (Css.px 2) Css.solid
        , Css.boxShadow5 (Css.px 0) (Css.px 6) (Css.px 6) (Css.px -6) color.ink
        , Css.backgroundColor color.page
        , Css.color color.ink
        , font.small
        , Css.maxWidth <| Css.vw 83
        ]


{-| Gutter: the space between the panels
-}
gutter : { x : Css.Style, y : Css.Style, inner : Css.Style }
gutter =
    { x = Css.batch [ Css.marginLeft <| Css.px 15, Css.marginRight <| Css.px 15 ]
    , y = Css.batch [ Css.marginTop <| Css.px 15, Css.marginBottom <| Css.px 15 ]
    , inner = Css.padding2 (Css.px 10) (Css.px 15)
    }


{-| Tier: a single row of panels
-}
tier : { base : Css.Style, item : Css.Style }
tier =
    { base =
        Css.batch
            [ Css.displayFlex
            , Css.justifyContent Css.spaceBetween
            , Css.flexDirection Css.column
            , Css.alignItems Css.start
            , gutter.y
            , onLargeScreen
                [ Css.alignItems Css.center, Css.flexDirection Css.row ]
            ]
    , item =
        Css.batch
            [ Css.displayFlex
            , Css.justifyContent Css.start
            , Css.flexDirection Css.column
            , gutter.y
            , onLargeScreen
                [ Css.width <| Css.pct 50
                , Css.firstChild [ Css.marginRight <| Css.px 15 ]
                , Css.lastChild [ Css.marginLeft <| Css.px 15 ]
                ]
            ]
    }


{-| Illustration: the image illustrations
-}
illustration : Css.Style
illustration =
    Css.batch
        [ Css.width <| Css.pct 100
        , Css.displayFlex
        , Css.justifyContent Css.center
        , Css.alignItems Css.center
        ]
