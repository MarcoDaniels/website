module Api exposing (routes)

import ApiRoute
import DataSource exposing (DataSource)
import Html as ElmHtml
import Route exposing (Route)


routes :
    DataSource (List Route)
    -> (ElmHtml.Html Never -> String)
    -> List (ApiRoute.ApiRoute ApiRoute.Response)
routes getStaticRoutes htmlToString =
    []
