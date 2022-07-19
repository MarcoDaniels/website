module WebsiteResponse exposing (main, websiteResponseHeaders)

import AWS exposing (Header)
import CloudWorker exposing (cloudWorker, originResponse, toResponse, withHeader, withHeaders)


main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originResponse
        { origin =
            \{ response, request } _ ->
                (case ( response.status, request.uri ) of
                    ( "403", _ ) ->
                        { response | status = "302", statusDescription = "Found" }
                            |> withHeader { key = "location", value = "/418" }

                    ( _, uri ) ->
                        if String.endsWith "418/index.html" uri then
                            { response | status = "404" }

                        else
                            response
                )
                    |> withHeaders websiteResponseHeaders
                    |> toResponse
        }
        |> cloudWorker


websiteResponseHeaders : List Header
websiteResponseHeaders =
    [ { key = "x-frame-options", value = "DENY" }
    , { key = "x-content-type-options", value = "nosniff" }
    , { key = "x-xss-protection", value = "1; mode=block" }
    , { key = "referrer-policy", value = "same-origin" }
    , { key = "permissions-policy", value = "fullscreen=(self), autoplay=(self)" }
    , { key = "strict-transport-security", value = "max-age=31536000; includeSubDomains" }
    , { key = "content-security-policy"
      , value =
            [ "style-src 'self' 'unsafe-inline';"
            , "script-src 'self' 'unsafe-inline';"
            , "img-src 'self' data:;"
            , "default-src 'self';"
            ]
                |> String.concat
      }
    ]
