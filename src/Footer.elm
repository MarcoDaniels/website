module Footer exposing (Footer, footer)

import Html.Styled as Html
import Html.Styled.Attributes as Html
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
        , Html.div [] (social |> List.map (\media -> Html.a [] [ Html.text media.media ]))
        ]
