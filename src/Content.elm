module Content exposing (Content, contentDecoder, contentView, link, markdownToHTML)

import Asset exposing (Asset, assetDecoder, assetToHTML)
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Markdown.Block as Block
import Markdown.Html
import Markdown.Parser as Parser
import Markdown.Renderer as Render
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder
import Style


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
    | GridUnknown


fieldDecoder : Decoder Field
fieldDecoder =
    Decoder.succeed Field
        |> Decoder.required "type" Decoder.string
        |> Decoder.required "label" Decoder.string


fieldGridDecoder : Field -> Decoder GridValue
fieldGridDecoder field =
    case ( field.fieldType, field.label ) of
        ( "markdown", _ ) ->
            Decoder.succeed GridMarkdown
                |> Decoder.required "value" Decoder.string

        ( "asset", _ ) ->
            Decoder.succeed GridAsset
                |> Decoder.required "value" assetDecoder

        _ ->
            Decoder.succeed GridUnknown


fieldMap : (Field -> Decoder b) -> Decoder (b -> a) -> Decoder a
fieldMap fieldToDecoder =
    Decoder.andMap
        (Decoder.field "field" fieldDecoder |> Decoder.andThen fieldToDecoder)


contentDecoder : Decoder Content
contentDecoder =
    Decoder.succeed Content
        |> fieldMap
            (\field ->
                case ( field.fieldType, field.label ) of
                    ( "markdown", _ ) ->
                        Decoder.succeed ContentMarkdown
                            |> Decoder.required "value" Decoder.string

                    ( "asset", _ ) ->
                        Decoder.succeed ContentAsset
                            |> Decoder.required "value" assetDecoder

                    ( "repeater", "Grid" ) ->
                        Decoder.succeed ContentGrid
                            |> Decoder.required "value"
                                (Decoder.list (Decoder.succeed Grid |> fieldMap fieldGridDecoder))

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
                \{ level, rawText, children } ->
                    let
                        textToID =
                            String.words rawText |> String.join "-" |> String.toLower
                    in
                    case level of
                        Block.H1 ->
                            Html.h1 [ Html.id textToID ] children

                        Block.H2 ->
                            Html.h2 [ Html.id textToID ] children

                        Block.H3 ->
                            Html.h3 [ Html.id textToID ] children

                        Block.H4 ->
                            Html.h4 [ Html.id textToID ] children

                        Block.H5 ->
                            Html.h5 [ Html.id textToID ] children

                        Block.H6 ->
                            Html.h6 [ Html.id textToID ] children
            , link =
                \{ title, destination } content ->
                    case title of
                        Just linkTitle ->
                            link
                                { to = destination
                                , attributes = [ Html.href destination, Html.title linkTitle ]
                                , content = content
                                }

                        Nothing ->
                            link
                                { to = destination
                                , attributes = [ Html.href destination ]
                                , content = content
                                }
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


type alias Link msg =
    { to : String
    , attributes : List (Html.Attribute msg)
    , content : List (Html.Html msg)
    }


link : Link msg -> Html.Html msg
link { to, attributes, content } =
    Html.a
        (if String.startsWith "https://" to || String.startsWith "http://" to then
            [ attributes
            , [ Html.css [ Style.color.primary ]
              , Html.target "_blank"
              , Html.rel "noopener noreferrer"
              , Html.href to
              ]
            ]
                |> List.concat

         else
            [ attributes, [ Html.css [ Style.color.primary ], Html.href to ] ] |> List.concat
        )
        content


contentView : List Content -> List (Html.Html msg)
contentView =
    List.map
        (\contentData ->
            case contentData.value of
                ContentMarkdown markdown ->
                    Html.div [] (markdownToHTML markdown)

                ContentAsset asset ->
                    assetToHTML asset Asset.Regular

                ContentGrid gridContent ->
                    Html.div [ Html.css [ Style.content.grid ] ]
                        (gridContent
                            |> List.map
                                (\{ value } ->
                                    case value of
                                        GridMarkdown markdown ->
                                            Html.div
                                                [ Html.css
                                                    [ Style.content.gridItem
                                                    , Style.content.gridItemText
                                                    ]
                                                ]
                                                (markdownToHTML markdown)

                                        GridAsset asset ->
                                            Html.div [ Html.css [ Style.content.gridItem ] ] [ assetToHTML asset (Asset.Grid (gridContent |> List.length)) ]

                                        GridUnknown ->
                                            Html.text ""
                                )
                        )

                ContentUnknown ->
                    Html.text ""
        )
