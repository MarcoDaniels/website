module Asset exposing (Asset, AssetSize(..), assetAPI, assetDecoder, assetToHTML)

import Comic
import Html.Styled as Html
import Html.Styled.Attributes as Html
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder


type alias Asset =
    { path : String
    , title : String
    , width : Int
    , height : Int
    , mime : String
    }


assetDecoder : Decoder Asset
assetDecoder =
    Decoder.succeed Asset
        |> Decoder.required "path" Decoder.string
        |> Decoder.required "title" Decoder.string
        |> Decoder.required "width" Decoder.int
        |> Decoder.required "height" Decoder.int
        |> Decoder.required "mime" Decoder.string


type AssetSize
    = Regular
    | Grid Int


assetToHTML : Asset -> AssetSize -> Html.Html msg
assetToHTML data assetSize =
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
        , Html.alt data.title
        , Html.src (assetAPI data.path size)
        ]
        []


assetAPI : String -> Int -> String
assetAPI src width =
    "/image/api" ++ src ++ "?w=" ++ String.fromInt width ++ "&o=1&q=60&m=fitToWidth"
