module WebsiteResponse exposing (main)

import CloudWorker exposing (cloudWorker, originResponse, toResponse, withHeader, withHeaders)


main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originResponse
        { origin =
            \{ response } _ ->
                response
                    |> withHeaders
                        [ { key = "strict-transport-security"
                          , value = "max-age=31536000; includeSubDomains"
                          }
                        , { key = "x-frame-options", value = "DENY" }
                        ]
                    |> toResponse
        }
        |> cloudWorker
