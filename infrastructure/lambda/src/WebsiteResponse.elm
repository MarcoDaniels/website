module WebsiteResponse exposing (main)

import CloudWorker exposing (cloudWorker, originResponse, toResponse)


main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originResponse
        { origin =
            \{ response } _ ->
                toResponse response
        }
        |> cloudWorker
