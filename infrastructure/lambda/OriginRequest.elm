module OriginRequest exposing (main)

import AWS exposing (InputEvent, OutputEvent)
import CloudWorker exposing (originRequest, toCloudWorker, toRequest)


main : Program () CloudWorker.Model CloudWorker.Msg
main =
    originRequest
        (\req ->
            case req.uri of
                "/" ->
                    toRequest
                        { req | uri = "index.html" }

                _ ->
                    toRequest req
        )
        |> toCloudWorker
