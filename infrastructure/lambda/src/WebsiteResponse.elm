module WebsiteResponse exposing (main)

import CloudWorker exposing (cloudWorker, originResponse, toResponse, withHeader)


main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originResponse
        { origin =
            \{ response } _ ->
                response
                    |> withHeader { key = "strict-transport-security", value = "max-age=31536000; includeSubDomains" }
                    |> withHeader { key = "x-frame-options", value = "DENY" }
                    |> toResponse
        }
        |> cloudWorker
