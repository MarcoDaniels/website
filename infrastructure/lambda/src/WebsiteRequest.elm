module WebsiteRequest exposing (main)

import AWS exposing (InputEvent, OutputEvent)
import CloudWorker exposing (cloudWorker, originRequest, toRequest)


main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originRequest
        { origin =
            \{ request } _ ->
                toRequest
                    (if String.contains "." request.uri then
                        request

                     else if String.endsWith "/" request.uri then
                        { request | uri = request.uri ++ "index.html" }

                     else
                        { request | uri = request.uri ++ "/index.html" }
                    )
        }
        |> cloudWorker
