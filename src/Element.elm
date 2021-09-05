module Element exposing (ElmElement, Element)

import Html as ElmHtml
import Html.Styled as Html


type alias ElmElement msg =
    ElmHtml.Html msg


type alias Element msg =
    Html.Html msg