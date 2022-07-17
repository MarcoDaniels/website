port module Preview exposing (main)

import Browser
import Content exposing (Content, contentDecoder, contentView)
import Html.Styled as Html
import OptimizedDecoder as Decoder
import Shared exposing (withStyled)


port updatePayload : (String -> msg) -> Sub msg


type Msg
    = PreviewOp String


type alias PreviewModel =
    { content : List Content }


main : Program () PreviewModel Msg
main =
    Browser.element
        { init = \_ -> ( { content = [] }, Cmd.none )
        , view =
            \{ content } ->
                (case content of
                    [] ->
                        [ Html.div [] [ Html.h1 [] [ Html.text "Ooops!" ] ] ]

                    data ->
                        contentView data
                )
                    |> withStyled
        , update =
            \msg _ ->
                case msg of
                    PreviewOp payload ->
                        ( case Decoder.decodeString (Decoder.list contentDecoder) payload of
                            Ok decodedContent ->
                                { content = decodedContent }

                            Err _ ->
                                { content = [] }
                        , Cmd.none
                        )
        , subscriptions = \_ -> updatePayload PreviewOp
        }
