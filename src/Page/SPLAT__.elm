module Page.SPLAT__ exposing (Data, Model, Msg, page)

import Cockpit exposing (Cockpit(..), fetchData)
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
                    |> DataSource.map (List.filter (\item -> item.url == route.splat))
                    |> DataSource.map
                        (\maybeItem ->
                            case List.head maybeItem of
                                Just item ->
                                    item

                                Nothing ->
                                    { url = [ "" ], title = "", description = "" }
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
                        |> Decoder.required "url"
                            (Decoder.string
                                |> Decoder.map
                                    (\url ->
                                        if String.startsWith "/" url then
                                            if String.dropLeft 1 url == "" then
                                                []

                                            else
                                                [ String.dropLeft 1 url ]

                                        else
                                            [ url ]
                                    )
                            )
                        |> Decoder.required "title" Decoder.string
                        |> Decoder.required "description" Decoder.string
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
            [ Html.h1 [] [ Html.text "hey there! 👋" ] ]
        ]
    }
