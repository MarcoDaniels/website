module Footer exposing (Footer, footer)

import Content exposing (link, markdownToHTML)
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
            [ Style.space.mediumY, Style.gap.smallY, Style.content.navigation ]
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
