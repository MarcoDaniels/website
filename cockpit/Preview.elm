port module Preview exposing (main)

import Browser
import Html


port updatePayload : (String -> msg) -> Sub msg


type Msg
    = PreviewOp String


type alias PreviewModel =
    { content : List String }


main : Program () PreviewModel Msg
main =
    Browser.element
        { init = \_ -> ( { content = [] }, Cmd.none )
        , view =
            \decoded -> Html.div [] [ Html.h1 [] [ Html.text "Ooops!" ] ]
        , update =
            \msg _ ->
                case msg of
                    PreviewOp payload ->
                        ( { content = [] }, Cmd.none )
        , subscriptions = \_ -> updatePayload PreviewOp
        }
