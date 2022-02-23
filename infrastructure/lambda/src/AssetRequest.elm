module AssetRequest exposing (main)

import CloudWorker exposing (cloudWorker, originRequest, toRequest)


type alias Config =
    { token : String, domain : String }


main : Program Config (CloudWorker.Model Config) CloudWorker.Msg
main =
    originRequest
        { origin =
            \request { token, domain } ->
                let
                    queryString =
                        "token="
                            ++ token
                            ++ "&src=https://"
                            ++ domain
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
