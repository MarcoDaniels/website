module Page.SPLAT__ exposing (Data, Model, Msg, page)

import Asset exposing (Asset, assetAPI)
import Data exposing (Entry, entryData, contentView)
import DataSource exposing (DataSource)
import Head.Seo as Seo
import Page exposing (Page, StaticPayload)
import Pages.Url
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { splat : List String }


type alias Data =
    Entry


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
            entryData
                |> DataSource.map
                    (\{ entries } -> entries |> List.map (\item -> { splat = item.url }))
        , data =
            \route ->
                entryData
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
