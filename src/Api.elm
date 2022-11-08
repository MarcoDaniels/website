module Api exposing (routes)

import ApiRoute
import DataSource exposing (DataSource)
import Dict
import Html as ElmHtml
import Route exposing (Route)
import Settings exposing (settingsData)
import Xml exposing (Value)
import Xml.Encode as XML


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
                        , "Host: " ++ settings.site.baseURL
                        , "Sitemap: " ++ settings.site.baseURL ++ "/sitemap.xml"
                        ]
                            |> String.join "\n"
                    }
                )
        )
        |> ApiRoute.literal "robots.txt"
        |> ApiRoute.single
    , ApiRoute.succeed
        (settingsData
            |> DataSource.andThen
                (\settings ->
                    getStaticRoutes
                        |> DataSource.map
                            (\staticRoutes ->
                                { body =
                                    XML.object
                                        [ ( "urlset"
                                          , Dict.singleton "xmlns" (XML.string "http://www.sitemaps.org/schemas/sitemap/0.9")
                                          , staticRoutes
                                                |> List.filterMap (routeToURL settings.site.baseURL)
                                                |> XML.list
                                          )
                                        ]
                                        |> XML.encode 0
                                }
                            )
                )
        )
        |> ApiRoute.literal "sitemap.xml"
        |> ApiRoute.single
    ]


routeToURL : String -> Route -> Maybe Value
routeToURL baseURL route =
    case Route.routeToPath route |> String.join "/" of
        "418" ->
            Nothing

        _ ->
            let
                loc =
                    baseURL :: Route.routeToPath route |> String.join "/"
            in
            Just
                (XML.object
                    [ ( "url", Dict.empty, XML.list [ XML.object [ ( "loc", Dict.empty, XML.string loc ) ] ] ) ]
                )
