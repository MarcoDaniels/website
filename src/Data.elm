module Data exposing (Content, Entries, Entry, contentDecoder, contentView, entryData, link, markdownToHTML)

import Asset exposing (Asset, assetDecoder, assetView)
import Cockpit exposing (Cockpit(..), fetchData)
import Comic
import Css
import DataSource exposing (DataSource)
import Html.Styled as Html exposing (fromUnstyled)
import Html.Styled.Attributes as Html
import Markdown.Block as Block
import Markdown.Html
import Markdown.Parser as Parser
import Markdown.Renderer as Render
import OptimizedDecoder as Decoder exposing (Decoder)
import OptimizedDecoder.Pipeline as Decoder
import Render
import SPLAT exposing (fromURL, toURL)
import SyntaxHighlight
import Time exposing (Posix)


type alias Entries =
    { entries : List Entry }


type alias Entry =
    { url : List String
    , title : String
    , description : String
    , image : Maybe Asset
    , date : Maybe String
    , content : List Content
    }


type alias Reference =
    { url : List String
    , title : String
    , description : String
    , image : Maybe Asset
    }


entryData : DataSource Entries
entryData =
    fetchData (Collection "marcoDaniels")
        (Decoder.succeed Entries |> Decoder.required "entries" (Decoder.list (entryDecoder Render.Pages)))


type alias Content =
    { value : ContentValue }


type alias Field =
    { fieldType : String, label : String }


type ContentValue
    = ContentMarkdown String
    | ContentAsset Asset
    | ContentGrid (List Grid)
    | ContentReference (List Reference)
    | ContentUnknown


type alias Grid =
    { value : GridValue }


type GridValue
    = GridMarkdown String
    | GridAsset Asset
    | GridUnknown


formatDate : ( Time.Month, Int ) -> String
formatDate =
    \( month, year ) ->
        [ case month of
            Time.Jan ->
                "01"

            Time.Feb ->
                "02"

            Time.Mar ->
                "03"

            Time.Apr ->
                "04"

            Time.May ->
                "05"

            Time.Jun ->
                "06"

            Time.Jul ->
                "07"

            Time.Aug ->
                "08"

            Time.Sep ->
                "09"

            Time.Oct ->
                "10"

            Time.Nov ->
                "11"

            Time.Dec ->
                "12"
        , "/"
        , String.fromInt year
        ]
            |> String.concat


entryDecoder : Render.Mode -> Decoder Entry
entryDecoder renderMode =
    Decoder.succeed Entry
        |> Decoder.required "url" (Decoder.string |> Decoder.map fromURL)
        |> Decoder.required "title" Decoder.string
        |> Decoder.required "description" Decoder.string
        |> Decoder.required "image" (Decoder.maybe (assetDecoder renderMode))
        |> Decoder.required "_modified"
            (Decoder.maybe
                (Decoder.int
                    |> Decoder.andThen
                        (\ms ->
                            Time.millisToPosix (ms * 1000)
                                |> (\posix -> ( Time.toMonth Time.utc posix, Time.toYear Time.utc posix ))
                                |> formatDate
                                |> Decoder.succeed
                        )
                )
            )
        |> Decoder.required "content" (Decoder.list (contentDecoder renderMode))


referenceDecoder : Render.Mode -> Decoder Reference
referenceDecoder renderMode =
    case renderMode of
        Render.Preview ->
            Decoder.succeed Reference
                |> Decoder.required "link" (Decoder.string |> Decoder.map fromURL)
                |> Decoder.required "display" Decoder.string
                |> Decoder.required "display" Decoder.string
                |> Decoder.required "link" (Decoder.maybe (assetDecoder renderMode))

        Render.Pages ->
            Decoder.succeed Reference
                |> Decoder.required "url" (Decoder.string |> Decoder.map fromURL)
                |> Decoder.required "title" Decoder.string
                |> Decoder.required "description" Decoder.string
                |> Decoder.required "image" (Decoder.maybe (assetDecoder renderMode))


fieldDecoder : Decoder Field
fieldDecoder =
    Decoder.succeed Field
        |> Decoder.required "type" Decoder.string
        |> Decoder.required "label" Decoder.string


fieldGridDecoder : Render.Mode -> Field -> Decoder GridValue
fieldGridDecoder renderMode field =
    case ( field.fieldType, field.label ) of
        ( "markdown", _ ) ->
            Decoder.succeed GridMarkdown
                |> Decoder.required "value" Decoder.string

        ( "asset", _ ) ->
            Decoder.succeed GridAsset
                |> Decoder.required "value" (assetDecoder renderMode)

        _ ->
            Decoder.succeed GridUnknown


fieldMap : (Field -> Decoder b) -> Decoder (b -> a) -> Decoder a
fieldMap fieldToDecoder =
    Decoder.andMap
        (Decoder.field "field" fieldDecoder |> Decoder.andThen fieldToDecoder)


nullableContent : (a -> ContentValue) -> Decoder a -> Decoder ContentValue
nullableContent decodeTo decodeWith =
    let
        toDecoder value =
            case value of
                Just _ ->
                    Decoder.succeed decodeTo
                        |> Decoder.required "value" decodeWith

                Nothing ->
                    Decoder.succeed ContentUnknown
    in
    Decoder.succeed toDecoder
        |> Decoder.required "value" (Decoder.nullable decodeWith)
        |> Decoder.resolve


contentDecoder : Render.Mode -> Decoder Content
contentDecoder renderMode =
    Decoder.succeed Content
        |> fieldMap
            (\field ->
                case ( field.fieldType, field.label ) of
                    ( "markdown", _ ) ->
                        nullableContent ContentMarkdown Decoder.string

                    ( "asset", _ ) ->
                        nullableContent ContentAsset (assetDecoder renderMode)

                    ( "repeater", "Grid" ) ->
                        nullableContent ContentGrid (Decoder.list (Decoder.succeed Grid |> fieldMap (fieldGridDecoder renderMode)))

                    ( "collectionlink", "Reference" ) ->
                        nullableContent ContentReference (Decoder.list (referenceDecoder renderMode))

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
                            Html.h1 [ Html.id textToID, Html.css [ Comic.font.large, Comic.font.mainTitle ] ] children

                        Block.H2 ->
                            Html.h2 [ Html.id textToID, Html.css [ Comic.font.medium ] ] children

                        Block.H3 ->
                            Html.h3 [ Html.id textToID, Html.css [ Comic.font.medium ] ] children

                        Block.H4 ->
                            Html.h4 [ Html.id textToID, Html.css [ Comic.font.medium ] ] children

                        Block.H5 ->
                            Html.h5 [ Html.id textToID, Html.css [ Comic.font.medium ] ] children

                        Block.H6 ->
                            Html.h6 [ Html.id textToID, Html.css [ Comic.font.medium ] ] children
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
            , blockQuote =
                \children ->
                    Html.blockquote
                        [ Html.css [ Comic.font.extraSmall ] ]
                        [ Html.em [] children ]
            , strong = \children -> Html.strong [] children
            , emphasis = \children -> Html.em [] children
            , strikethrough = \children -> Html.del [] children
            , codeSpan =
                \content ->
                    Html.code
                        [ Html.css [ Comic.font.extraSmall ] ]
                        [ Html.text content ]
            , image = \_ -> Html.div [] []
            , text = Html.text
            , orderedList =
                \index items ->
                    Html.ol [ Html.start index, Html.css [ Comic.font.small ] ]
                        (items |> List.map (\li -> Html.li [] li))
            , unorderedList =
                \items ->
                    Html.ul [ Html.css [ Comic.font.small ] ]
                        (items
                            |> List.map
                                (\li ->
                                    case li of
                                        Block.ListItem _ children ->
                                            Html.li [] children
                                )
                        )
            , html = Markdown.Html.oneOf []
            , codeBlock =
                \{ body } ->
                    Html.div [ Html.css [ Comic.font.extraSmall ] ]
                        [ SyntaxHighlight.useTheme SyntaxHighlight.oneDark
                            |> fromUnstyled
                        , SyntaxHighlight.elm body
                            |> Result.map (SyntaxHighlight.toBlockHtml (Just 1))
                            |> Result.map fromUnstyled
                            |> Result.withDefault
                                (Html.pre [] [ Html.code [] [ Html.text body ] ])
                        ]
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
            , [ Html.css [ Css.color Comic.color.ink ]
              , Html.target "_blank"
              , Html.rel "noopener noreferrer"
              , Html.href to
              ]
            ]
                |> List.concat

         else
            [ attributes, [ Html.css [ Css.color Comic.color.ink ], Html.href to ] ] |> List.concat
        )
        content


contentView : List Content -> List (Html.Html msg)
contentView =
    List.map
        (\contentData ->
            case contentData.value of
                ContentMarkdown markdown ->
                    Html.div
                        [ Html.css [ Comic.panel, Comic.gutter.y, Comic.gutter.inner ] ]
                        (markdownToHTML markdown)

                ContentAsset asset ->
                    Html.div
                        [ Html.css [ Comic.panel, Comic.gutter.y ] ]
                        [ assetView asset Asset.Regular ]

                ContentGrid gridContent ->
                    Html.div [ Html.css [ Comic.tier.base ] ]
                        (gridContent
                            |> List.map
                                (\{ value } ->
                                    case value of
                                        GridMarkdown markdown ->
                                            Html.div
                                                [ Html.css [ Comic.panel, Comic.gutter.inner, Comic.tier.item ] ]
                                                (markdownToHTML markdown)

                                        GridAsset asset ->
                                            Html.div
                                                [ Html.css [ Comic.panel, Comic.tier.item ] ]
                                                [ assetView asset (Asset.Grid (gridContent |> List.length)) ]

                                        GridUnknown ->
                                            Html.text ""
                                )
                        )

                ContentReference entries ->
                    Html.div []
                        (entries
                            |> List.map
                                (\{ url, title, description, image } ->
                                    Html.div [ Html.css [ Comic.panel, Comic.gutter.y, Comic.gutter.inner ] ]
                                        [ link
                                            { to = toURL url
                                            , attributes = []
                                            , content =
                                                [ Html.h2 [ Html.css [ Comic.font.mainTitle ] ] [ Html.text title ]
                                                , Html.div [ Html.css [ Comic.tier.base ] ]
                                                    [ Html.p [ Html.css [ Comic.tier.item ] ] [ Html.text description ]
                                                    , case image of
                                                        Just asset ->
                                                            Html.div
                                                                [ Html.css [ Comic.tier.item ] ]
                                                                [ assetView asset Asset.Regular ]

                                                        Nothing ->
                                                            Html.text ""
                                                    ]
                                                ]
                                            }
                                        ]
                                )
                        )

                ContentUnknown ->
                    Html.text ""
        )
