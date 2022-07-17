module Footer exposing (Footer, footer)

import Content exposing (link, markdownToHTML)
import Css
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Icon exposing (icon)
import Settings exposing (Social)
import Style


type alias Footer =
    { line : String, social : List Social }


footer : Footer -> Html.Html msg
footer { line, social } =
    Html.footer
        [ Html.css
            [ Css.margin2 (Css.px 15) (Css.px 0) ]
        ]
        [ Html.div
            [ Html.css
                [ Css.width <| Css.pct 50
                , Style.color.primary
                , Css.position Css.absolute
                , Css.height <| Css.px 58
                , Css.left <| Css.px 0
                ]
            ]
            []
        , Html.div
            [ Html.css
                [ Style.color.primary
                , Style.content.navigation
                , Css.position Css.relative
                , Css.maxWidth <| Css.px 800
                , Css.margin2 (Css.px 0) Css.auto
                , Css.padding2 (Css.px 0) (Css.px 10)
                ]
            ]
            [ Html.div [] (markdownToHTML line)
            , Html.div []
                (social
                    |> List.map
                        (\media ->
                            link
                                { to = media.url
                                , attributes =
                                    [ Html.css [ Style.gap.smallX ], Html.title media.title ]
                                , content =
                                    [ icon media.icon ]
                                }
                        )
                )
            ]
        ]
