module Content exposing (Asset, Content, ContentData(..), assetDecoder, contentDecoder, contentView)

import Html.Styled as Html
import Html.Styled.Attributes as Html
import Markdown.Block as Block
import Markdown.Html
import Markdown.Parser as Parser
import Markdown.Renderer as Render
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


markdownToHTML : String -> List (Html.Html msg)
markdownToHTML raw =
    raw
        |> Parser.parse
        |> Result.withDefault []
        |> Render.render
            { heading =
                \{ level, children } ->
                    case level of
                        Block.H1 ->
                            Html.h1 [] children

                        Block.H2 ->
                            Html.h2 [] children

                        Block.H3 ->
                            Html.h3 [] children

                        Block.H4 ->
                            Html.h4 [] children

                        Block.H5 ->
                            Html.h5 [] children

                        Block.H6 ->
                            Html.h6 [] children
            , link =
                \link content ->
                    case link.title of
                        Just title ->
                            Html.a [ Html.href link.destination, Html.title title ] content

                        Nothing ->
                            Html.a [ Html.href link.destination ] content
            , paragraph = Html.p []
            , hardLineBreak = Html.br [] []
            , blockQuote = Html.blockquote []
            , strong = \children -> Html.strong [] children
            , emphasis = \children -> Html.em [] children
            , strikethrough = \children -> Html.del [] children
            , codeSpan = \content -> Html.code [] [ Html.text content ]
            , image = \_ -> Html.div [] []
            , text = Html.text
            , orderedList = \_ _ -> Html.div [] []
            , unorderedList = \_ -> Html.div [] []
            , html = Markdown.Html.oneOf []
            , codeBlock = \_ -> Html.div [] []
            , thematicBreak = Html.hr [] []
            , table = Html.table []
            , tableHeader = Html.thead []
            , tableBody = Html.tbody []
            , tableRow = Html.tr []
            , tableHeaderCell = \_ _ -> Html.div [] []
            , tableCell = \_ _ -> Html.div [] []
            }
        |> Result.withDefault []


contentView : List Content -> List (Html.Html msg)
contentView =
    List.map
        (\contentData ->
            case contentData.value of
                ContentMarkdown markdown ->
                    Html.div [ Html.css [ Style.gap.medium ] ] (markdownToHTML markdown)

                ContentAsset asset ->
                    Html.img [ Html.alt asset.title, Html.width 200, Html.src (toImageAPI asset.path 300) ] []

                _ ->
                    Html.text ""
        )
