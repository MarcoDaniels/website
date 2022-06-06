module Settings exposing (Settings, settingsData)

import Cockpit exposing (Cockpit(..), fetchData)
import DataSource
import Navigation exposing (Navigation, navigationDecoder)
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder


type alias SiteSettings =
    { title : String, description : String, baseURL : String }


type alias Settings =
    { site : SiteSettings, navigation : Navigation }


settingsData : DataSource.DataSource Settings
settingsData =
    fetchData (Singleton "marcoDanielsWebsite") settingsDecoder


settingsDecoder : Decoder Settings
settingsDecoder =
    Decoder.succeed Settings
        |> Decoder.required "site"
            (Decoder.succeed SiteSettings
                |> Decoder.required "title" Decoder.string
                |> Decoder.required "description" Decoder.string
                |> Decoder.required "baseURL" Decoder.string
            )
        |> Decoder.required "navigation" navigationDecoder
