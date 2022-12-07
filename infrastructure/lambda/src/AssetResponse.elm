module AssetResponse exposing (main)

import CloudWorker exposing (cloudWorker, originResponse, toResponse, withHeader)


main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originResponse
        { origin =
            \{ response, request } _ ->
                response
                    |> withHeader { key = "cache-control", value = "public, max-age=31536000" }
                    |> toResponse
        }
        |> cloudWorker
