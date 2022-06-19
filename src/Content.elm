module Content exposing (Content, contentDecoder, contentView)

import Asset exposing (Asset, assetDecoder, assetToHTML)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Markdown.Block as Block
import Markdown.Html
import Markdown.Parser as Parser
import Markdown.Renderer as Render
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder


type alias Content =
    { value : ContentValue }


type alias Field =
    { fieldType : String, label : String }


type ContentValue
    = ContentMarkdown String
    | ContentAsset Asset
    | ContentGrid (List Grid)
    | ContentUnknown


type alias Grid =
    { value : GridValue }


type GridValue
    = GridMarkdown String
    | GridAsset Asset
    | GridColumn (List Grid)
    | GridUnknown


fieldDecoder : Decoder Field
fieldDecoder =
    Decoder.succeed Field
        |> Decoder.required "type" Decoder.string
        |> Decoder.required "label" Decoder.string


fieldGridDecoder : ( String, String ) -> Decoder GridValue
fieldGridDecoder ( fieldType, label ) =
    case ( fieldType, label ) of
        ( "markdown", _ ) ->
            Decoder.succeed GridMarkdown
                |> Decoder.required "value" Decoder.string

        ( "asset", _ ) ->
            Decoder.succeed GridAsset
                |> Decoder.required "value" assetDecoder

        _ ->
            Decoder.succeed GridUnknown


fieldCase : (( String, String ) -> Decoder b) -> Decoder (b -> a) -> Decoder a
fieldCase caseFn =
    Decoder.andMap
        (Decoder.field "field" fieldDecoder
            |> Decoder.andThen (\field -> caseFn ( field.fieldType, field.label ))
        )


contentDecoder : Decoder Content
contentDecoder =
    Decoder.succeed Content
        |> fieldCase
            (\( fieldType, label ) ->
                case ( fieldType, label ) of
                    ( "markdown", _ ) ->
                        Decoder.succeed ContentMarkdown
                            |> Decoder.required "value" Decoder.string

                    ( "asset", _ ) ->
                        Decoder.succeed ContentAsset
                            |> Decoder.required "value" assetDecoder

                    ( "repeater", "Grid" ) ->
                        Decoder.succeed ContentGrid
                            |> Decoder.required "value"
                                (Decoder.list (Decoder.succeed Grid |> fieldCase fieldGridDecoder))

                    _ ->
                        Decoder.succeed ContentUnknown
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
            , orderedList =
                \index items ->
                    Html.ol [ Html.start index ]
                        (items |> List.map (\li -> Html.li [] li))
            , unorderedList =
                \items ->
                    Html.ul []
                        (items
                            |> List.map
                                (\li ->
                                    case li of
                                        Block.ListItem _ children ->
                                            Html.li [] children
                                )
                        )
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
                    Html.div [] (markdownToHTML markdown)

                ContentAsset asset ->
                    assetToHTML asset Asset.Large

                ContentGrid gridContent ->
                    Html.div []
                        (gridContent
                            |> List.map
                                (\{ value } ->
                                    case value of
                                        GridMarkdown markdown ->
                                            Html.div [] (markdownToHTML markdown)

                                        GridAsset asset ->
                                            assetToHTML asset Asset.Large

                                        _ ->
                                            Html.div [] [ Html.text "unknown content grid" ]
                                )
                        )

                ContentUnknown ->
                    Html.text ""
        )
