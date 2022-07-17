module Style exposing (align, color, comic, content, font, gap, screen, space, wide)

import Css
import Css.Animations
import Css.Media


type alias Category =
    { primary : Css.Style, secondary : Css.Style }


type alias Position =
    { center : Css.Style }


type alias Size =
    { none : Css.Style, small : Css.Style, medium : Css.Style, large : Css.Style }


type alias SizeAxis size =
    { size
        | smallX : Css.Style
        , smallY : Css.Style
        , smallR : Css.Style
        , smallL : Css.Style
        , mediumX : Css.Style
        , mediumY : Css.Style
    }


type alias Font size =
    { size | mono : Css.Style, upperCase : Css.Style, title : Css.Style }


type alias Content position =
    { position | navigation : Css.Style, grid : Css.Style, gridItem : Css.Style, gridItemText : Css.Style }


type alias Screen =
    { small : List Css.Style -> Css.Style, large : List Css.Style -> Css.Style }


-- TODO: figure out screen
screen : Screen
screen =
    { small = Css.Media.withMedia [ Css.Media.only Css.Media.screen [ Css.Media.maxWidth <| Css.px 700 ] ]
    , large = Css.Media.withMedia [ Css.Media.only Css.Media.screen [ Css.Media.minWidth <| Css.px 700 ] ]
    }


empty : Css.Style
empty =
    Css.batch []


color : Category
color =
    { primary =
        Css.batch
            [ Css.backgroundColor <| Css.hex "FFF"
            , Css.color <| Css.hex "1F1926"
            ]
    , secondary =
        Css.batch
            [ Css.backgroundColor <| Css.hex "F2EFEA"
            , Css.color <| Css.hex "000000"
            ]
    }


wide : Size
wide =
    { none = empty
    , small = empty
    , medium = empty
    , large =
        Css.batch
            [ Css.width <| Css.pct 100
            ]
    }


space : SizeAxis Size
space =
    { none = Css.padding <| Css.px 0
    , small = Css.padding <| Css.px 10
    , smallX =
        Css.batch
            [ Css.paddingLeft <| Css.px 10, Css.paddingRight <| Css.px 10 ]
    , smallY =
        Css.batch
            [ Css.paddingTop <| Css.px 10, Css.paddingBottom <| Css.px 10 ]
    , smallL = Css.paddingLeft <| Css.px 20
    , smallR = Css.paddingRight <| Css.px 20
    , medium = Css.padding <| Css.px 40
    , mediumX = empty
    , mediumY =
        Css.batch
            [ Css.paddingTop <| Css.px 40, Css.paddingBottom <| Css.px 40 ]
    , large = empty
    }


gap : SizeAxis Size
gap =
    { none = Css.margin <| Css.px 0
    , small = Css.margin <| Css.px 10
    , smallX =
        Css.batch
            [ Css.marginLeft <| Css.px 10
            , Css.marginRight <| Css.px 10
            ]
    , smallY =
        Css.batch
            [ Css.marginTop <| Css.px 10
            , Css.marginBottom <| Css.px 10
            ]
    , smallL = empty
    , smallR = empty
    , medium = Css.margin <| Css.px 40
    , mediumX =
        Css.batch
            [ Css.marginLeft <| Css.px 40
            , Css.marginRight <| Css.px 40
            ]
    , mediumY =
        Css.batch
            [ Css.marginTop <| Css.px 40
            , Css.marginBottom <| Css.px 40
            ]
    , large = empty
    }


content : Content Position
content =
    let
        gridItemBase =
            Css.batch
                [ Css.displayFlex
                , Css.justifyContent Css.center
                , Css.flexDirection Css.column
                , Css.width <| Css.pct 50
                , screen.small
                    [ Css.width <| Css.pct 100 ]
                ]
    in
    { center =
        Css.batch
            [ Css.displayFlex
            , Css.justifyContent Css.center
            , Css.alignItems Css.center
            ]
    , navigation =
        Css.batch
            [ Css.displayFlex
            , Css.justifyContent Css.spaceBetween
            , Css.alignItems Css.center
            ]
    , grid =
        Css.batch
            [ Css.displayFlex
            , Css.justifyContent Css.spaceBetween
            , Css.alignItems Css.center
            , screen.small
                [ Css.flexDirection Css.column, Css.alignItems Css.start ]
            ]
    , gridItem = gridItemBase
    , gridItemText =
        Css.batch
            [ gridItemBase
            , space.smallX
            , Css.firstChild
                [ space.none
                , space.smallR
                , screen.small [ space.none ]
                ]
            , Css.lastChild
                [ space.none
                , space.smallL
                , screen.small [ space.none ]
                ]
            , screen.small [ space.none ]
            ]
    }


align : Position
align =
    { center = Css.batch [ Css.margin2 (Css.px 0) Css.auto ] }


font : Font Size
font =
    { none = empty
    , small = Css.fontSize <| Css.rem 1.05
    , medium = Css.fontSize <| Css.rem 1.25
    , large = Css.fontSize <| Css.rem 2.15
    , mono = Css.batch [ Css.fontFamilies [ "Verdana, sans-serif" ], Css.lineHeight <| Css.rem 1.5 ]
    , upperCase = Css.textTransform Css.uppercase
    , title = Css.fontWeight <| Css.int 100
    }


comic =
    { book =
        Css.batch
            [ space.none
            , gap.none
            , font.mono
            , color.secondary
            , Css.maxWidth <| Css.px 900
            , Css.width <| Css.pct 100
            , Css.margin2 (Css.px 0) Css.auto
            ]
    , pages =
        let
            pageBase =
                Css.batch
                    [ Css.property "content" "''"
                    , Css.height <| Css.pct 98
                    , Css.position Css.absolute
                    , Css.width <| Css.pct 100
                    , Css.zIndex <| Css.int -2
                    ]
        in
        Css.batch
            [ Css.padding <| Css.px 20
            , Css.maxWidth <| Css.px 800
            , Css.width <| Css.pct 100
            , Css.position Css.relative
            , Css.margin3 (Css.px 40) Css.auto (Css.px 0)
            , Css.boxShadow5 (Css.px 0) (Css.px 6) (Css.px 6) (Css.px -6) (Css.hex "000")
            , color.primary
            , screen.large
                [ Css.before
                    [ pageBase
                    , Css.backgroundColor <| Css.hex "fafafa"
                    , Css.boxShadow4 (Css.px 0) (Css.px 0) (Css.px 8) (Css.rgba 0 0 0 0.2)
                    , Css.left <| Css.px -5
                    , Css.top <| Css.px 4
                    , Css.transform <| Css.rotate <| Css.deg -2.5
                    , Css.animationDuration <| Css.sec 2
                    , Css.animationName
                        (Css.Animations.keyframes
                            [ ( 0, [ Css.Animations.property "transform" "rotate(0deg)" ] )
                            , ( 100, [ Css.Animations.property "transform" "rotate(-2.5deg)" ] )
                            ]
                        )
                    ]
                , Css.after
                    [ pageBase
                    , Css.backgroundColor <| Css.hex "f6f6f6"
                    , Css.boxShadow4 (Css.px 0) (Css.px 0) (Css.px 3) (Css.rgba 0 0 0 0.2)
                    , Css.right <| Css.px -3
                    , Css.top <| Css.px 1
                    , Css.transform <| Css.rotate <| Css.deg 1.4
                    , Css.animationDuration <| Css.sec 2
                    , Css.animationIterationCount <| Css.int 1
                    , Css.animationName
                        (Css.Animations.keyframes
                            [ ( 0, [ Css.Animations.property "transform" "rotate(0deg)" ] )
                            , ( 100, [ Css.Animations.property "transform" "rotate(1.4deg)" ] )
                            ]
                        )
                    ]
                ]
            ]
    , canvas = Css.batch []
    , gap = Css.batch [ Css.margin2 (Css.px 15) (Css.px 0) ]
    }
