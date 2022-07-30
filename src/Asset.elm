module Asset exposing (Asset, AssetSize(..), assetAPI, assetDecoder, assetView)

import Comic
import Html.Styled as Html
import Html.Styled.Attributes as Html
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder
import Render


type alias Asset =
    { path : String
    , title : String
    , width : Int
    , height : Int
    , mime : String
    , render : Render.Mode
    }


assetDecoder : Render.Mode -> Decoder Asset
assetDecoder mode =
    Decoder.succeed Asset
        |> Decoder.required "path" Decoder.string
        |> Decoder.required "title" Decoder.string
        |> Decoder.required "width" Decoder.int
        |> Decoder.required "height" Decoder.int
        |> Decoder.required "mime" Decoder.string
        |> Decoder.hardcoded mode


type AssetSize
    = Regular
    | Grid Int


assetView : Asset -> AssetSize -> Html.Html msg
assetView { title, path, render } assetSize =
    let
        size =
            case assetSize of
                Regular ->
                    800

                -- TODO: use grid length to calculate srcsets
                Grid _ ->
                    500
    in
    Html.img
        [ Html.css [ Comic.illustration ]
        , Html.alt title
        , Html.src (assetAPI { src = path, width = size, render = render })
        ]
        []


assetAPI : { src : String, width : Int, render: Render.Mode } -> String
assetAPI { src, width, render } =
    let
        buildAPI =
            [ "/image/api", src, "?w=", String.fromInt width, "&o=1&q=70&m=fitToWidth" ]
    in
    (case render of
        Render.Preview ->
            "https://marcodaniels.com" :: buildAPI

        Render.Pages ->
            buildAPI
    )
        |> String.concat
