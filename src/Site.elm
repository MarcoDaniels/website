module Site exposing (config)

import DataSource
import Pages.Manifest as Manifest
import Route
import SiteConfig exposing (SiteConfig)


type alias Data =
    ()


config : SiteConfig Data
config =
    { data = DataSource.succeed ()
    , canonicalUrl = "https://marcodaniels.com"
    , manifest =
        \_ ->
            Manifest.init
                { name = "MarcoDaniels"
                , description = "MarcoDaniels"
                , startUrl = Route.Index |> Route.toPath
                , icons = []
                }
    , head = \_ -> []
    }
