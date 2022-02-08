module Style.Theme exposing (useTheme)

import Css
import Css.Global
import Element exposing (Element, ElmElement)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Style.Center exposing (centerStyle)

globalStyle : List (Element msg)
globalStyle =
    [ Css.Global.global
        [ Css.Global.body
            [ Css.margin <| Css.px 0
            , Css.padding <| Css.px 0
            , Css.fontFamilies [ "monospace" ]
            , Css.backgroundColor <| Css.hex "e7e7e7"
            ]
        ]
    ]



useTheme : List (Element msg) -> ElmElement msg
useTheme content =
    Html.div
        [ Html.css [ Css.height <| Css.vh 100, centerStyle.column ] ]
        ([ globalStyle, content ] |> List.concat)
        |> Html.toUnstyled
