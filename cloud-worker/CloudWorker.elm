port module CloudWorker exposing (..)

import AWS exposing (CloudFront(..), Headers, InputEvent, Origin(..), OriginRequest, OriginResponse, OutputEvent(..), Request, Response, decodeInputEvent, defaultOriginRequest, encodeOutputEvent)
import Dict
import Json.Decode as Decode exposing (Error)
import Json.Encode as Encode


port inputEvent : (Decode.Value -> msg) -> Sub msg


port outputEvent : Encode.Value -> Cmd msg


type alias Model a =
    { event : Maybe InputEvent, init : a }


type Msg
    = Input (Result Error InputEvent)


originRequest : { origin : OriginRequest -> init -> OutputEvent } -> init -> Maybe CloudFront -> OutputEvent
originRequest { origin } init maybeCloudFront =
    case maybeCloudFront of
        Just cloudFront ->
            case cloudFront of
                InputRequest originReq ->
                    origin originReq init

                _ ->
                    origin defaultOriginRequest init

        _ ->
            origin defaultOriginRequest init


toRequest : Request -> OutputEvent
toRequest request =
    OutputRequest request


toResponse : Response -> OutputEvent
toResponse response =
    OutputResponse response


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
