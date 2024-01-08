module WebsiteRequest exposing (main)

import BaseLambda exposing (ports)
import CloudFront exposing (cloudFront)
import CloudFront.Lambda exposing (originRequest, toRequest)


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


main : Program () (CloudFront.Model ()) CloudFront.Msg
main =
    ports
        |> (originRequest
                (\{ request } _ ->
                    (case staticRoute request.uri of
                        HTML uri ->
                            { request | uri = uri }

                        Other _ ->
                            request
                    )
                        |> toRequest
                )
                |> cloudFront
           )
