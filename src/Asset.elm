module Asset exposing (Asset, assetDecoder, assetToHTML)

import Html.Styled as Html
import Html.Styled.Attributes as Html
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder
import Style



-- TODO: cleanup asset


type alias Asset =
    { path : String
    , title : String
    , width : Int
    , height : Int
    , mime : String
    , colors : Maybe (List String)
    }


assetDecoder : Decoder Asset
assetDecoder =
    Decoder.succeed Asset
        |> Decoder.required "path" Decoder.string
        |> Decoder.required "title" Decoder.string
        |> Decoder.required "width" Decoder.int
        |> Decoder.required "height" Decoder.int
        |> Decoder.required "mime" Decoder.string
        |> Decoder.optional "colors" (Decoder.maybe (Decoder.list Decoder.string)) Nothing


assetToHTML : Asset -> Html.Html msg
assetToHTML data =
    Html.img
        [ Html.css
            [ Style.content.center, Style.align.center, Style.wide.large ]
        , Html.alt data.title
        , Html.src (assetAPI data.path 800)
        ]
        []


assetAPI : String -> Int -> String
assetAPI src width =
    "/image/api" ++ src ++ "?w=" ++ String.fromInt width ++ "&o=1&q=60&m=fitToWidth"
