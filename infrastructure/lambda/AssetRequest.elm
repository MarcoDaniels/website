module AssetRequest exposing (main)

import CloudWorker exposing (originRequest, toCloudWorker, toRequest)



-- TODO: access -> get it as flags?


access =
    { token = "TODO:TOKEN", assetURL = "TODO:URI" }


main : Program () CloudWorker.Model CloudWorker.Msg
main =
    originRequest
        (\request ->
            let
                queryString =
                    "token="
                        ++ access.token
                        ++ "&src="
                        ++ access.assetURL
                        ++ String.replace "image/api" "storage/uploads" request.uri
                        ++ "&"
                        ++ Maybe.withDefault "" request.querystring
            in
            { request
                | uri = "/api/cockpit/image"
                , querystring = Just queryString
            }
                |> toRequest
        )
        |> toCloudWorker
