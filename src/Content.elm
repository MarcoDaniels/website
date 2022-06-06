module Content exposing (Asset, Content, ContentData(..), assetDecoder, contentDecoder, contentView)

import Html.Styled as Html
import Html.Styled.Attributes as Html
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder
import Style
import Utilities exposing (toImageAPI)


type alias Content =
    { field : Field, value : ContentData }


type alias Field =
    { fieldType : String, label : String }


type ContentData
    = ContentMarkdown String
    | ContentAsset Asset
    | ContentUnknown


type alias Asset =
    { path : String
    , title : String
    , width : Int
    , height : Int
    , mime : String
    , colors : Maybe (List String)
    }


fieldDecoder : Decoder Field
fieldDecoder =
    Decoder.succeed Field
        |> Decoder.required "type" Decoder.string
        |> Decoder.required "label" Decoder.string


assetDecoder : Decoder Asset
assetDecoder =
    Decoder.succeed Asset
        |> Decoder.required "path" Decoder.string
        |> Decoder.required "title" Decoder.string
        |> Decoder.required "width" Decoder.int
        |> Decoder.required "height" Decoder.int
        |> Decoder.required "mime" Decoder.string
        |> Decoder.optional "colors" (Decoder.maybe (Decoder.list Decoder.string)) Nothing


contentDecoder : Decoder Content
contentDecoder =
    Decoder.succeed Content
        |> Decoder.required "field" fieldDecoder
        |> Decoder.custom
            (Decoder.field "field" fieldDecoder
                |> Decoder.andThen
                    (\field ->
                        case ( field.fieldType, field.label ) of
                            ( "markdown", _ ) ->
                                Decoder.succeed ContentMarkdown
                                    |> Decoder.required "value" Decoder.string

                            ( "asset", _ ) ->
                                Decoder.succeed ContentAsset
                                    |> Decoder.required "value" assetDecoder

                            _ ->
                                Decoder.succeed ContentUnknown
                    )
            )


contentView : List Content -> List (Html.Html msg)
contentView =
    List.map
        (\contentData ->
            case contentData.value of
                ContentMarkdown string ->
                    Html.div [ Html.css [ Style.gap.medium ] ] [ Html.text string ]

                ContentAsset asset ->
                    Html.img [ Html.alt asset.title, Html.width 200, Html.src (toImageAPI asset.path 300) ] []

                _ ->
                    Html.text ""
        )
