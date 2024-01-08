module AssetRequest exposing (main)

import BaseLambda exposing (ports)
import CloudFront exposing (cloudFront)
import CloudFront.Lambda exposing (originRequest, toRequest)


type alias Config =
    { token : String, domain : String }


main : Program Config (CloudFront.Model Config) CloudFront.Msg
main =
    ports
        |> (originRequest
                (\{ request } { token, domain } ->
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
                )
                |> cloudFront
           )
