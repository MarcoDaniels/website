port module CloudWorker exposing (..)

-- TODO: expose only necessary

import AWS exposing (CloudFront(..), Header, Headers, InputEvent, Origin(..), OriginRequest, OriginResponse, OutputEvent(..), Request, Response, decodeInputEvent, defaultOriginRequest, defaultOriginResponse, encodeOutputEvent)
import Dict
import Json.Decode as Decode exposing (Error)
import Json.Encode as Encode


port inputEvent : (Decode.Value -> msg) -> Sub msg


port outputEvent : Encode.Value -> Cmd msg


type alias Model a =
    { event : Maybe InputEvent, init : a }


type Msg
    = Input (Result Error InputEvent)


originRequest :
    { origin : OriginRequest -> init -> OutputEvent }
    -> init
    -> Maybe CloudFront
    -> OutputEvent
originRequest { origin } init maybeCloudFront =
    case maybeCloudFront of
        Just cloudFront ->
            case cloudFront of
                InputRequest inputRequest ->
                    origin inputRequest init

                _ ->
                    origin defaultOriginRequest init

        _ ->
            origin defaultOriginRequest init


originResponse :
    { origin : OriginResponse -> init -> OutputEvent }
    -> init
    -> Maybe CloudFront
    -> OutputEvent
originResponse { origin } init maybeCloudFront =
    case maybeCloudFront of
        Just cloudFront ->
            case cloudFront of
                InputResponse inputResponse ->
                    origin inputResponse init

                _ ->
                    origin defaultOriginResponse init

        _ ->
            origin defaultOriginResponse init


toRequest : Request -> OutputEvent
toRequest request =
    OutputRequest request


toResponse : Response -> OutputEvent
toResponse response =
    OutputResponse response


caseSensitiveHeader : String -> String
caseSensitiveHeader key =
    String.split "-" key
        |> List.map
            (\word ->
                String.uncons word
                    |> Maybe.map (\( first, rest ) -> String.cons (Char.toUpper first) rest)
                    |> Maybe.withDefault ""
            )
        |> String.join "-"


withHeader : Header -> { event | headers : Headers } -> { event | headers : Headers }
withHeader header event =
    { event
        | headers =
            Dict.union
                (Dict.insert header.key
                    [ { key = caseSensitiveHeader header.key, value = header.value } ]
                    Dict.empty
                )
                event.headers
    }


withHeaders : List Header -> { event | headers : Headers } -> { event | headers : Headers }
withHeaders headers event =
    { event
        | headers =
            Dict.union
                (headers
                    |> List.foldr
                        (\header ->
                            Dict.insert header.key
                                [ { key = caseSensitiveHeader header.key, value = header.value } ]
                        )
                        Dict.empty
                )
                event.headers
    }


cloudWorker : (init -> Maybe CloudFront -> OutputEvent) -> Program init (Model init) Msg
cloudWorker worker =
    Platform.worker
        { init = \init -> ( { event = Nothing, init = init }, Cmd.none )
        , subscriptions =
            \_ ->
                Decode.decodeValue decodeInputEvent
                    >> Input
                    |> inputEvent
        , update =
            \msg model ->
                case msg of
                    Input result ->
                        case result of
                            Ok event ->
                                ( { event = Just event, init = model.init }
                                , worker model.init (event.records |> List.head |> Maybe.map (\{ cf } -> cf))
                                    |> encodeOutputEvent
                                    |> outputEvent
                                )

                            Err _ ->
                                ( model, Cmd.none )
        }
