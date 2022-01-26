module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head.Seo as Seo
import Html.Styled as Html
import Html.Styled.Attributes as Html
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
    {}


type alias Data =
    ()


page : Page RouteParams Data
page =
    Page.single
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
        , data = DataSource.succeed ()
        }
        |> Page.buildNoState { view = view }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Marco Daniels"
    , body =
        [ Html.div [ Html.css [ centerStyle.inline ] ]
            [ Html.h1 [] [ Html.text "hey there! 👋" ]
            ]
        ]
    }
