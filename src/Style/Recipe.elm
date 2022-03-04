module Style.Recipe exposing (Recipe, recipe)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Html


type alias Recipe variants msg =
    { base : Css.Style
    , default : variants
    , variants : variants -> List Css.Style
    }
    -> (variants -> variants)
    -> Html.Attribute msg


recipe : Recipe variants msg
recipe { base, default, variants } styleFn =
    (default |> styleFn)
        |> (variants >> List.append [ base ])
        |> Html.css
