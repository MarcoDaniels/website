module AssetRequest exposing (main)

import CloudWorker exposing (originRequest, toCloudWorker, toRequest)



-- TODO: implement


main : Program () CloudWorker.Model CloudWorker.Msg
main =
    originRequest
        (\request -> request |> toRequest)
        |> toCloudWorker
