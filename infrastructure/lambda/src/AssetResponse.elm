module AssetResponse exposing (main)

import BaseLambda exposing (ports)
import CloudFront exposing (cloudFront)
import CloudFront.Header exposing (withHeader)
import CloudFront.Lambda exposing (originResponse, toResponse)


main : Program () (CloudFront.Model ()) CloudFront.Msg
main =
    ports
        |> (originResponse
                (\{ response, request } _ ->
                    response
                        |> withHeader { key = "cache-control", value = "public, max-age=31536000" }
                        |> toResponse
                )
                |> cloudFront
           )
