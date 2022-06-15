module View exposing (View, map)

import Html.Styled as Html


type alias View msg =
    { title : String, body : List (Html.Html msg) }


map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title, body = List.map (Html.map fn) doc.body }
