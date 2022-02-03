module Utilities exposing (toURL)


toURL : String -> List String
toURL url =
    let
        withSlash =
            if String.startsWith "/" url then
                String.dropLeft 1 url

            else
                url
    in
    case withSlash of
        "" ->
            []

        rest ->
            [ rest ]
