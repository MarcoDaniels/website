module Asset exposing (Asset, AssetSize(..), assetAPI, assetDecoder, assetToHTML)

import Html.Styled as Html
import Html.Styled.Attributes as Html
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder
import Style


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
    = Small
    | Large


assetToHTML : Asset -> AssetSize -> Html.Html msg
assetToHTML data assetSize =
    let
        size =
            case assetSize of
                Small ->
                    300

                Large ->
                    800
    in
    Html.img
        [ Html.css
            [ Style.content.center, Style.align.center, Style.wide.large ]
        , Html.alt data.title
        , Html.src (assetAPI data.path size)
        ]
        []


assetAPI : String -> Int -> String
assetAPI src width =
    "/image/api" ++ src ++ "?w=" ++ String.fromInt width ++ "&o=1&q=60&m=fitToWidth"
