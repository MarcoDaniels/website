module Utilities exposing (toImageAPI, toURL)


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



-- TODO: delete


toImageAPI : String -> Int -> String
toImageAPI src width =
    "/image/api" ++ src ++ "?w=" ++ String.fromInt width ++ "&o=1&q=60&m=fitToWidth"
