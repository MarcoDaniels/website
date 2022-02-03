module Site exposing (config)

import DataSource
import Pages.Manifest as Manifest
import Path
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
                , startUrl = "" |> Path.fromString
                , icons = []
                }
    , head = \_ -> []
    }
