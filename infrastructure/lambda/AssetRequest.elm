module AssetRequest exposing (main)

import CloudWorker exposing (cloudWorker, originRequest, toRequest)


type alias Config =
    { token : String, assetURL : String }


main : Program Config (CloudWorker.Model Config) CloudWorker.Msg
main =
    originRequest
        { origin =
            \request { token, assetURL } ->
                let
                    queryString =
                        "token="
                            ++ token
                            ++ "&src="
                            ++ assetURL
                            ++ String.replace "image/api" "storage/uploads" request.uri
                            ++ "&"
                            ++ Maybe.withDefault "" request.querystring
                in
                { request
                    | uri = "/api/cockpit/image"
                    , querystring = Just queryString
                }
                    |> toRequest
        }
        |> cloudWorker
