module Site exposing (config)

import Pages.Manifest as Manifest
import Path
import Settings exposing (Settings, settingsData)
import SiteConfig exposing (SiteConfig)


type alias Data =
    Settings


config : SiteConfig Data
config =
    { data = settingsData
    , canonicalUrl = "https://marcodaniels.com"
    , manifest =
        \{ site } ->
            Manifest.init
                { name = site.title
                , description = site.description
                , startUrl = site.baseURL |> Path.fromString
                , icons = []
                }
    , head = \_ -> []
    }
