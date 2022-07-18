module SPLAT exposing (fromURL, toURL)


fromURL : String -> List String
fromURL url =
    let
        trimSlash =
            \slash ->
                if String.startsWith "/" slash then
                    String.dropLeft 1 slash

                else
                    slash
    in
    case trimSlash url of
        "" ->
            []

        rest ->
            String.split "/" rest


toURL : List String -> String
toURL splat =
    String.join "/" splat |> String.append "/"
