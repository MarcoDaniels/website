module Page.SPLAT__ exposing (Data, Model, Msg, page)

import Asset exposing (Asset, assetDecoder)
import Cockpit exposing (Cockpit(..), fetchData)
import Content exposing (Content, ContentData(..), contentDecoder, contentView)
import DataSource exposing (DataSource)
import Head.Seo as Seo
import Html.Styled as Html
import OptimizedDecoder as Decoder
import OptimizedDecoder.Pipeline as Decoder
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import Utilities exposing (toImageAPI, toURL)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { splat : List String }


type alias Data =
    { url : List String
    , title : String
    , description : String
    , image : Maybe Asset
    , content : Maybe (List Content)
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
                                        ++ toImageAPI image.path 300
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
                |> DataSource.map (List.map (\item -> { splat = item.url }))
        , data =
            \route ->
                pageData
                    |> DataSource.map
                        (List.foldr
                            (\item next ->
                                if item.url == route.splat then
                                    item

                                else
                                    next
                            )
                            { url = [], title = "", description = "", image = Nothing, content = Nothing }
                        )
        }
        |> Page.buildNoState { view = view }


pageData : DataSource (List Data)
pageData =
    fetchData (Collection "marcoDanielsPage")
        (Decoder.map identity <|
            Decoder.field "entries" <|
                Decoder.list
                    (Decoder.succeed Data
                        |> Decoder.required "url" (Decoder.string |> Decoder.map toURL)
                        |> Decoder.required "title" Decoder.string
                        |> Decoder.required "description" Decoder.string
                        |> Decoder.required "image" (Decoder.maybe assetDecoder)
                        |> Decoder.required "content" (Decoder.list contentDecoder |> Decoder.maybe)
                    )
        )


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = static.data.title
    , body =
        [ Html.div []
            (case static.data.content of
                Just content ->
                    contentView content

                Nothing ->
                    []
            )
        ]
    }
