module Style.Recipe exposing (Recipe, recipe)

import Css


type alias Recipe variants =
    { base : Css.Style
    , default : variants
    , variants : variants -> List Css.Style
    }
    -> (variants -> variants)
    -> List Css.Style


recipe : Recipe variants
recipe { base, default, variants } styleFn =
    (default |> styleFn)
        |> (variants >> List.append [ base ])
