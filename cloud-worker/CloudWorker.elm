port module CloudWorker exposing (..)

import AWS exposing (Headers, InputEvent, Origin(..), OutputEvent(..), Request, Response, decodeInputEvent, encodeOutputEvent)
import Dict
import Json.Decode as Decode exposing (Error)
import Json.Encode as Encode


port inputEvent : (Decode.Value -> msg) -> Sub msg


port outputEvent : Encode.Value -> Cmd msg


type alias Model =
    { event : Maybe InputEvent }


type Msg
    = Input (Result Error InputEvent)


originRequest : { origin : Request -> OutputEvent } -> InputEvent -> OutputEvent
originRequest { origin } inEvent =
    inEvent.records
        |> List.foldr
            (\{ cf } _ -> cf.request)
            { clientIp = ""
            , headers = Dict.empty
            , method = ""
            , origin = OriginUnknown
            , querystring = Nothing
            , uri = ""
            }
        |> origin



-- originResponse: {Request, Response} -> Response


toRequest : Request -> OutputEvent
toRequest request =
    OutputRequest request


toResponse : Response -> OutputEvent
toResponse response =
    OutputResponse response


cloudWorker : { init : a, worker : InputEvent -> OutputEvent } -> Program a Model Msg
cloudWorker { init, worker } =
    Platform.worker
        { init = \_ -> ( { event = Nothing }, Cmd.none )
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
                                ( { event = Just event }
                                , worker event
                                    |> encodeOutputEvent
                                    |> outputEvent
                                )

                            Err _ ->
                                ( model, Cmd.none )
        }
