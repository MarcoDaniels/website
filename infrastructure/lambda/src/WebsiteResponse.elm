module WebsiteResponse exposing (main, websiteResponseHeaders)

import BaseLambda exposing (ports)
import CloudFront exposing (cloudFront)
import CloudFront.Header exposing (Header, withHeader, withHeaders)
import CloudFront.Lambda exposing (originResponse, toResponse)


main : Program () (CloudFront.Model ()) CloudFront.Msg
main =
    ports
        |> (originResponse
                (\{ response, request } _ ->
                    (case ( response.status, request.uri ) of
                        ( "403", _ ) ->
                            { response | status = "302", statusDescription = "Found" }
                                |> withHeader { key = "location", value = "/418" }

                        ( _, uri ) ->
                            if String.endsWith "418/index.html" uri then
                                { response | status = "404" }

                            else if
                                [ ".js", ".css", ".json", ".ico", ".xml", ".txt" ]
                                    |> List.filter (\ext -> String.endsWith ext uri)
                                    |> List.isEmpty
                                    |> not
                            then
                                response
                                    |> withHeader { key = "cache-control", value = "public, max-age=864000" }

                            else
                                response
                    )
                        |> withHeaders websiteResponseHeaders
                        |> toResponse
                )
                |> cloudFront
           )


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
