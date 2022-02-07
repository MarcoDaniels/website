module Content exposing (Content, ContentData(..), contentDecoder)

import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder


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
