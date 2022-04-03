module Settings exposing (Settings, settingsData)

import Cockpit exposing (Cockpit(..), fetchData)
import DataSource
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder


type alias SiteSettings =
    { title : String, description : String, baseURL : String }


type alias LinkItem =
    { title : String, url : String }


type alias Navigation =
    { brand : LinkItem, menu : List LinkItem }


type alias Settings =
    { site : SiteSettings, navigation : Navigation }


settingsData : DataSource.DataSource Settings
settingsData =
    fetchData (Singleton "marcoDanielsWebsite") settingsDecoder


linkValueDecoder : Decoder LinkItem
linkValueDecoder =
    Decoder.succeed LinkItem
        |> Decoder.requiredAt [ "value", "title" ] Decoder.string
        |> Decoder.requiredAt [ "value", "url" ] Decoder.string


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
            (Decoder.succeed Navigation
                |> Decoder.required "brand"
                    (Decoder.succeed LinkItem
                        |> Decoder.required "title" Decoder.string
                        |> Decoder.required "url" Decoder.string
                    )
                |> Decoder.required "menu" (Decoder.list linkValueDecoder)
            )
