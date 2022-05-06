module WebsiteRequest exposing (main)

import AWS exposing (InputEvent, OutputEvent)
import CloudWorker exposing (cloudWorker, originRequest, toRequest)


main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originRequest
        { origin =
            \{ request } _ ->
                case request.uri of
                    "" ->
                        toRequest
                            { request | uri = "/index.html" }

                    uri ->
                        toRequest
                            (if String.endsWith "/" uri then
                                { request | uri = uri ++ "index.html" }

                             else
                                request
                            )
        }
        |> cloudWorker
