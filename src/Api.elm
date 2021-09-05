module Api exposing (routes)

import ApiRoute
import DataSource exposing (DataSource)
import Element exposing (ElmElement)
import Route exposing (Route)


routes :
    DataSource (List Route)
    -> (ElmElement Never -> String)
    -> List (ApiRoute.ApiRoute ApiRoute.Response)
routes getStaticRoutes htmlToString =
    []
