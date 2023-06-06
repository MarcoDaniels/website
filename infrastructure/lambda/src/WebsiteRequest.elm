module WebsiteRequest exposing (main)

import AWS exposing (InputEvent, OutputEvent)
import CloudWorker exposing (cloudWorker, originRequest, toRequest)

type StaticRoute
    = HTML String
    | Other String


staticRoute : String -> StaticRoute
staticRoute url =
    case
        [ ".js", ".css", ".json", ".ico", ".xml", ".txt" ]
            |> List.filter (\ext -> String.endsWith ext url)
    of
        [] ->
            if String.endsWith "/" url then
                HTML <| url ++ "index.html"

            else
                HTML <| url ++ "/index.html"

        _ ->
            Other url

main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originRequest
        { origin =
            \{ request } _ ->
                (case staticRoute request.uri of
                    HTML uri ->
                        { request | uri = uri }

                    Other _ ->
                        request
                )
                    |> toRequest
        }
        |> cloudWorker
