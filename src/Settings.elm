module Settings exposing (Settings, Social, settingsData)

import Cockpit exposing (Cockpit(..), fetchData)
import DataSource
import Icon
import Navigation exposing (Navigation, navigationDecoder)
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder


type alias SiteSettings =
    { title : String, description : String, baseURL : String }


type alias Social =
    { title : String, url : String, icon : Icon.Icons }


type alias Settings =
    { site : SiteSettings, navigation : Navigation, footer : String, social : List Social }


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
        |> Decoder.required "footer" Decoder.string
        |> Decoder.requiredAt [ "social", "links" ]
            (Decoder.list
                (Decoder.succeed Social
                    |> Decoder.requiredAt [ "value", "title" ] Decoder.string
                    |> Decoder.requiredAt [ "value", "url" ] Decoder.string
                    |> Decoder.requiredAt [ "value", "social" ]
                        (Decoder.string
                            |> Decoder.map
                                (\media ->
                                    case media of
                                        "github" ->
                                            Icon.GitHub

                                        "linkedin" ->
                                            Icon.LinkedIn

                                        "instagram" ->
                                            Icon.Instagram

                                        _ ->
                                            Icon.StackOverflow
                                )
                        )
                )
            )
