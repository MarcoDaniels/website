module Footer exposing (Footer, footer)

import Comic
import Css
import Data exposing (link, markdownToHTML)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Icon exposing (icon)
import Settings exposing (Social)


type alias Footer =
    { line : String, social : List Social }


footer : Footer -> Html.Html msg
footer { line, social } =
    Html.footer
        [ Html.css [ Comic.caption ] ]
        [ Html.div [] (markdownToHTML line)
        , Html.div [ Html.css [ Css.textAlign Css.right ] ]
            (social
                |> List.map
                    (\media ->
                        link
                            { to = media.url
                            , attributes = [ Html.css [ Comic.gutter.x ], Html.title media.title ]
                            , content = [ icon media.icon ]
                            }
                    )
            )
        ]
