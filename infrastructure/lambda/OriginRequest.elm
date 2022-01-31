module OriginRequest exposing (main)

import AWS exposing (InputEvent, OutputEvent)
import CloudWorker exposing (originRequest, toCloudWorker, toRequest)


main : Program () CloudWorker.Model CloudWorker.Msg
main =
    originRequest
        (\request ->
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
        )
        |> toCloudWorker
