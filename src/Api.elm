module Api exposing (routes)

import ApiRoute
import DataSource exposing (DataSource)
import Html as ElmHtml
import Route exposing (Route)
import Settings exposing (settingsData)


routes :
    DataSource (List Route)
    -> (ElmHtml.Html Never -> String)
    -> List (ApiRoute.ApiRoute ApiRoute.Response)
routes getStaticRoutes _ =
    [ ApiRoute.succeed
        (settingsData
            |> DataSource.map
                (\settings ->
                    { body =
                        [ "User-agent: *"
                        , "Host:" ++ settings.site.baseURL
                        ]
                            |> String.join "\n"
                    }
                )
        )
        |> ApiRoute.literal "robots.txt"
        |> ApiRoute.single
    ]
