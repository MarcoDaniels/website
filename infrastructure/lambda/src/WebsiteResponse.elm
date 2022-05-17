module WebsiteResponse exposing (main)

import CloudWorker exposing (cloudWorker, originResponse, toResponse, withHeaders)


main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originResponse
        { origin =
            \{ response } _ ->
                response
                    |> withHeaders
                        [ { key = "x-frame-options", value = "DENY" }
                        , { key = "x-content-type-options", value = "nosniff" }
                        , { key = "x-xss-protection", value = "1; mode=block" }
                        , { key = "referrer-policy", value = "same-origin" }
                        , { key = "permissions-policy", value = "fullscreen=(self), autoplay=(self)" }
                        , { key = "strict-transport-security", value = "max-age=31536000; includeSubDomains" }
                        , { key = "content-security-policy"
                          , value =
                                [ "script-src 'self' 'unsafe-inline'; "
                                , "style-src 'self' 'unsafe-inline'; "
                                , "object-src 'none'"
                                ]
                                    |> String.concat
                          }
                        ]
                    |> toResponse
        }
        |> cloudWorker
