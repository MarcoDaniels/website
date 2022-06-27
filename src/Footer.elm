module Footer exposing (Footer, footer)

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
        [ Html.div [] [ Html.text line ]

        -- TODO: new window
        , Html.div []
            (social
                |> List.map
                    (\media ->
                        Html.a
                            [ Html.css [ Style.gap.smallX ]
                            , Html.href media.url
                            , Html.title media.title
                            , Html.target "_blank"
                            , Html.rel "noopener noreferrer"
                            ]
                            [ icon media.icon ]
                    )
            )
        ]
