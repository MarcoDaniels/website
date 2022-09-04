module Page.SPLAT__ exposing (Data, Model, Msg, page)

import Asset exposing (Asset, assetAPI)
import Comic
import Css
import Css.Global
import Data exposing (Entry, contentView, entryData)
import DataSource exposing (DataSource)
import Head.Seo as Seo
import Html.Styled as Html
import Html.Styled.Attributes as Html
import Page exposing (Page, StaticPayload)
import Pages.Url
import Render


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
                                        ++ assetAPI { src = image.path, width = 800, render = Render.Pages }
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
                    , title = static.sharedData.site.title ++ " " ++ static.data.title
                    , locale = Nothing
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
                                    { url = [], title = "", description = "", image = Nothing, date = Nothing, content = [] }
                        )
        }
        |> Page.buildNoState
            { view =
                \maybeUrl sharedModel static ->
                    { title = static.data.title
                    , body =
                        [ [ Css.Global.global [ Css.Global.body [ static.data.content |> List.length |> Comic.book ] ] ]
                        , case ( List.head static.data.url, static.data.date ) of
                            ( Just "note", Just date ) ->
                                [ Html.div [ Html.css [ Comic.font.extraSmall, Css.textAlign Css.right ] ]
                                    [ Html.em [] [ Html.text date ] ]
                                ]

                            _ ->
                                []
                        , contentView static.data.content
                        ]
                            |> List.concat
                    }
            }
