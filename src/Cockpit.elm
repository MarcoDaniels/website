module Cockpit exposing (Cockpit(..), fetchData)

import DataSource exposing (DataSource)
import DataSource.Http
import OptimizedDecoder exposing (Decoder)
import Pages.Secrets as Secrets


type Cockpit
    = Collection String
    | Singleton String


fetchData : Cockpit -> Decoder a -> DataSource a
fetchData dataType =
    let
        endpoint =
            case dataType of
                Collection collection ->
                    "/collections/entries/" ++ collection ++ "?populate=1"

                Singleton singleton ->
                    "/singletons/get/" ++ singleton
    in
    DataSource.Http.request
        (Secrets.succeed
            (\url token ->
                { url = url ++ endpoint
                , method = "GET"
                , headers = [ ( "Cockpit-Token", token ) ]
                , body = DataSource.Http.emptyBody
                }
            )
            |> Secrets.with "COCKPIT_API_URL"
            |> Secrets.with "COCKPIT_API_TOKEN"
        )
