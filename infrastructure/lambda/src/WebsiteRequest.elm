module WebsiteRequest exposing (main)

import AWS exposing (InputEvent, OutputEvent)
import CloudWorker exposing (cloudWorker, originRequest, toRequest)
import StaticRoute exposing (staticRoute)


main : Program () (CloudWorker.Model ()) CloudWorker.Msg
main =
    originRequest
        { origin =
            \{ request } _ ->
                (case staticRoute request.uri of
                    StaticRoute.HTML uri ->
                        { request | uri = uri }

                    StaticRoute.Other _ ->
                        request
                )
                    |> toRequest
        }
        |> cloudWorker
