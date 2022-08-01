port module Preview exposing (main)

import Browser
import Data exposing (Content, contentDecoder, contentView)
import Html.Styled as Html
import OptimizedDecoder as Decoder
import Render
import Shared exposing (withStyled)


port updatePayload : (String -> msg) -> Sub msg


type Msg
    = PreviewOp String


type alias PreviewModel =
    { content : List Content, error : Maybe String }


main : Program () PreviewModel Msg
main =
    Browser.element
        { init = \_ -> ( { content = [], error = Nothing }, Cmd.none )
        , view =
            \{ content, error } ->
                (case content of
                    [] ->
                        [ Html.div []
                            [ Html.h1 [] [ Html.text "Ooops!" ]
                            , Html.p [] [ Html.text "The preview needs the CMS context to load..." ]
                            , case error of
                                Just err ->
                                    Html.p [] [ Html.text err ]

                                Nothing ->
                                    Html.text ""
                            ]
                        ]

                    data ->
                        contentView data
                )
                    |> withStyled
        , update =
            \msg model ->
                case msg of
                    PreviewOp payload ->
                        ( case Decoder.decodeString (Decoder.list (contentDecoder Render.Preview)) payload of
                            Ok decodedContent ->
                                { model | content = decodedContent }

                            Err err ->
                                { content = [], error = Decoder.errorToString err |> Just }
                        , Cmd.none
                        )
        , subscriptions = \_ -> updatePayload PreviewOp
        }
