module Navigation exposing (Navigation, navigation, navigationDecoder)

import Comic
import Data exposing (link)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder


type alias LinkItem =
    { title : String, url : String }


type alias Navigation =
    { brand : LinkItem, menu : List LinkItem }


linkValueDecoder : Decoder LinkItem
linkValueDecoder =
    Decoder.succeed LinkItem
        |> Decoder.requiredAt [ "value", "title" ] Decoder.string
        |> Decoder.requiredAt [ "value", "url" ] Decoder.string


navigationDecoder : Decoder Navigation
navigationDecoder =
    Decoder.succeed Navigation
        |> Decoder.required "brand"
            (Decoder.succeed LinkItem
                |> Decoder.required "title" Decoder.string
                |> Decoder.required "url" Decoder.string
            )
        |> Decoder.required "menu" (Decoder.list linkValueDecoder)


navigation : Navigation -> Html.Html msg
navigation { brand, menu } =
    Html.nav
        [ Html.css [ Comic.caption ] ]
        [ link
            { to = brand.url, content = [ Html.text brand.title ], attributes = [] }
        , Html.div
            []
            (menu
                |> List.map
                    (\{ url, title } ->
                        link
                            { to = url
                            , content = [ Html.text title ]
                            , attributes = [ Html.css [ Comic.font.upperCase, Comic.gutter.x ] ]
                            }
                    )
            )
        ]
