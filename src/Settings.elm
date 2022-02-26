module Settings exposing (Settings, settingsData)

import Cockpit exposing (Cockpit(..), fetchData)
import DataSource
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder


type alias SiteSettings =
    { title : String, description : String, baseURL : String }


type alias NavigationItem =
    { title : String, url : String }


type alias Settings =
    { site : SiteSettings, navigation : List NavigationItem }


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
        |> Decoder.required "navigation"
            (Decoder.list
                (Decoder.succeed NavigationItem
                    |> Decoder.requiredAt [ "value", "title" ] Decoder.string
                    |> Decoder.requiredAt [ "value", "url" ] Decoder.string
                )
            )
