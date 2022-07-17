module Navigation exposing (Navigation, navigation, navigationDecoder)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Html
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder
import Style exposing (comic)


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
navigation nav =
    Html.nav
        [ Html.css [ comic.gap ] ]
        [ Html.div
            [ Html.css
                [ Css.width <| Css.pct 50
                , Style.color.primary
                , Css.right <| Css.px 0
                , Css.position Css.absolute
                , Css.height <| Css.px 46
                ]
            ]
            []
        , Html.div
            [ Html.css
                [ Style.content.navigation
                , Style.color.primary
                , Css.position Css.relative
                , Css.maxWidth <| Css.px 800
                , Css.margin2 (Css.px 0) Css.auto
                ]
            ]
            [ Html.a
                [ Html.css
                    [ Style.color.primary
                    , Style.space.smallY
                    , Style.gap.mediumX
                    , Style.font.medium
                    , Style.screen.small [ Style.gap.smallX ]
                    ]
                , Html.href nav.brand.url
                ]
                [ Html.text nav.brand.title ]
            , Html.div
                [ Html.css [ Style.space.smallY ] ]
                (nav.menu
                    |> List.map
                        (\item ->
                            Html.a
                                [ Html.css
                                    [ Style.color.primary
                                    , Style.gap.mediumX
                                    , Style.font.upperCase
                                    , Style.font.medium
                                    , Style.screen.small [ Style.gap.smallX ]
                                    ]
                                , Html.href item.url
                                ]
                                [ Html.text item.title ]
                        )
                )
            ]
        ]
