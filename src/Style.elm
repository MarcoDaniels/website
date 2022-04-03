module Style exposing (align, color, container, content, font, gap, screen, space, wide)

import Css
import Css.Media


type alias Category =
    { primary : Css.Style }


type alias Position =
    { center : Css.Style, left : Css.Style }


type alias Size =
    { none : Css.Style, small : Css.Style, medium : Css.Style, large : Css.Style }


type alias SizeAxis size =
    { size | smallX : Css.Style, smallY : Css.Style, mediumX : Css.Style, mediumY : Css.Style }


type alias Font size =
    { size | mono : Css.Style, upperCase : Css.Style }


type alias Content position =
    { position | spaceBetween : Css.Style }


type alias Screen =
    { small : List Css.Style -> Css.Style, large : List Css.Style -> Css.Style }


screen : Screen
screen =
    { small = Css.Media.withMedia [ Css.Media.only Css.Media.screen [ Css.Media.maxWidth <| Css.px 550 ] ]
    , large = Css.Media.withMedia [ Css.Media.only Css.Media.screen [ Css.Media.maxWidth <| Css.px 1200 ] ]
    }


empty : Css.Style
empty =
    Css.batch
        []


color : Category
color =
    { primary =
        Css.batch
            [ Css.backgroundColor <| Css.hex "FEFEFA"
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
            , Css.maxWidth <| Css.px 750
            ]
    }


space : Size
space =
    { none = Css.padding <| Css.px 0
    , small = Css.padding <| Css.px 10
    , medium = Css.padding <| Css.px 40
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
    { left =
        Css.batch
            [ Css.displayFlex
            , Css.justifyContent Css.start
            , Css.alignItems Css.center
            ]
    , center =
        Css.batch
            [ Css.displayFlex
            , Css.justifyContent Css.center
            , Css.alignItems Css.center
            ]
    , spaceBetween =
        Css.justifyContent Css.spaceBetween
    }


align : Position
align =
    { left = empty
    , center = Css.batch [ Css.margin2 (Css.px 0) Css.auto ]
    }


container : { fit : Css.Style, wrapper : Css.Style }
container =
    { fit = Css.boxSizing Css.borderBox
    , wrapper =
        Css.batch
            [ Css.borderWidth <| Css.px 0.1
            , Css.borderStyle Css.solid
            , Css.borderImageWidth <| Css.px 20
            , Css.property "border-image-slice" "50%"
            , Css.property "border-image-source" "url(\"data:image/svg+xml;charset=utf8,%3Csvg xmlns=%22http:%2F%2Fwww.w3.org%2F2000%2Fsvg%22 viewBox=%220 0 40 40%22%3E%3Crect x=%220.5%22 y=%220.5%22 width=%2239%22 height=%2239%22 fill=%22transparent%22 stroke=%22%23000%22 stroke-width=%221%22 %2F%3E%3C%2Fsvg%3E\")"
            ]
    }


font : Font Size
font =
    { none = empty
    , small = Css.fontSize <| Css.px 14
    , medium = Css.fontSize <| Css.px 17
    , large = Css.fontSize <| Css.px 21
    , mono = Css.fontFamilies [ "monospace" ]
    , upperCase = Css.textTransform Css.uppercase
    }
