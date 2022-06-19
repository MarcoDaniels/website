module Page.SPLAT__ exposing (Data, Model, Msg, page)

import Asset exposing (Asset, assetAPI, assetDecoder)
import Cockpit exposing (Cockpit(..), fetchData)
import Content exposing (Content, contentDecoder, contentView)
import DataSource exposing (DataSource)
import Head.Seo as Seo
import OptimizedDecoder as Decoder
import OptimizedDecoder.Pipeline as Decoder
import Page exposing (Page, StaticPayload)
import Pages.Url
import Utilities exposing (toURL)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { splat : List String }


type alias Entries =
    { entries : List Data }


type alias Data =
    { url : List String
    , title : String
    , description : String
    , image : Maybe Asset
    , content : List Content
    }


page : Page RouteParams Data
page =
    Page.prerender
        { head =
            \static ->
                Seo.summary
                    { canonicalUrlOverride = Nothing
                    , siteName = static.sharedData.site.title
                    , image =
                        case static.data.image of
                            Just image ->
                                { url =
                                    static.sharedData.site.baseURL
                                        ++ assetAPI image.path 300
                                        |> Pages.Url.external
                                , alt = image.title
                                , dimensions = Just { width = image.width, height = image.height }
                                , mimeType = Just image.mime
                                }

                            Nothing ->
                                { url = Pages.Url.external ""
                                , alt = ""
                                , dimensions = Nothing
                                , mimeType = Nothing
                                }
                    , description = static.data.description
                    , locale = Nothing
                    , title = static.sharedData.site.title
                    }
                    |> Seo.website
        , routes =
            pageData
                |> DataSource.map
                    (\{ entries } -> entries |> List.map (\item -> { splat = item.url }))
        , data =
            \route ->
                pageData
                    |> DataSource.map
                        (\{ entries } ->
                            entries
                                |> List.foldr
                                    (\item next ->
                                        if item.url == route.splat then
                                            item

                                        else
                                            next
                                    )
                                    { url = [], title = "", description = "", image = Nothing, content = [] }
                        )
        }
        |> Page.buildNoState
            { view =
                \maybeUrl sharedModel static ->
                    { title = static.data.title, body = contentView static.data.content }
            }


pageData : DataSource Entries
pageData =
    fetchData (Collection "marcoDanielsPage")
        (Decoder.succeed Entries
            |> Decoder.required "entries"
                (Decoder.list
                    (Decoder.succeed Data
                        |> Decoder.required "url" (Decoder.string |> Decoder.map toURL)
                        |> Decoder.required "title" Decoder.string
                        |> Decoder.required "description" Decoder.string
                        |> Decoder.required "image" (Decoder.maybe assetDecoder)
                        |> Decoder.required "content" (Decoder.list contentDecoder)
                    )
                )
        )
