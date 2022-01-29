module OriginRequest exposing (main)

import CloudWorker exposing (originRequest, toCloudWorker, toRequest, toResponse)


main : Program () CloudWorker.Model CloudWorker.Msg
main =
    originRequest
        (\req ->
            case req.uri of
                "/" ->
                    toRequest
                        { req | clientIp = "hey" }

                _ ->
                    toResponse
                        { status = ""
                        , statusDescription = ""
                        , headers = req.headers
                        , body = ""
                        }
        )
        |> toCloudWorker
