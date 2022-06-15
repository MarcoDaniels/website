module StaticRoute exposing (StaticRoute(..), staticRoute)


type StaticRoute
    = HTML String
    | Other String


staticRoute : String -> StaticRoute
staticRoute url =
    case
        [ ".js", ".css", ".json", ".ico" ]
            |> List.filter (\ext -> String.endsWith ext url)
    of
        [] ->
            if String.endsWith "/" url then
                HTML <| url ++ "index.html"

            else
                HTML <| url ++ "/index.html"

        _ ->
            Other url
