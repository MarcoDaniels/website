module Page.SPLAT__ exposing (Data, Model, Msg, page)

import Cockpit exposing (Cockpit(..), fetchData)
import Content exposing (Content, ContentData(..), contentDecoder)
import DataSource exposing (DataSource)
import Head.Seo as Seo
import Html.Styled as Html
import Html.Styled.Attributes as Html
import OptimizedDecoder as Decoder
import OptimizedDecoder.Pipeline as Decoder
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import Style.Center exposing (centerStyle)
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
    , content : Maybe (List Content)
    }


page : Page RouteParams Data
page =
    Page.prerender
        { head =
            \_ ->
                Seo.summary
                    { canonicalUrlOverride = Nothing
                    , siteName = "MarcoDaniels"
                    , image =
                        { url = Pages.Url.external "TODO"
                        , alt = "marcodaniels logo"
                        , dimensions = Nothing
                        , mimeType = Nothing
                        }
                    , description = "TODO"
                    , locale = Nothing
                    , title = "Marco Daniels"
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
                            { url = [], title = "", description = "", content = Nothing }
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
                        |> Decoder.required "content" (Decoder.list contentDecoder |> Decoder.maybe)
                    )
        )


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Marco Daniels" ++ " - " ++ static.data.title
    , body =
        [ Html.div [ Html.css [ centerStyle.inline ] ]
            (case static.data.content of
                Just content ->
                    content
                        |> List.map
                            (\contentData ->
                                case contentData.value of
                                    ContentMarkdown string ->
                                        Html.text string

                                    ContentAsset asset ->
                                        Html.img [ Html.src (toImageAPI asset.path 200) ] []

                                    _ ->
                                        Html.text ""
                            )

                Nothing ->
                    []
            )
        ]
    }
