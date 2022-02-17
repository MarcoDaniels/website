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


originRequest : (Request -> OutputEvent) -> InputEvent -> OutputEvent
originRequest requestToOut inEvent =
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
        |> requestToOut



-- originResponse: {Request, Response} -> Response


toRequest : Request -> OutputEvent
toRequest request =
    OutputRequest request


toResponse : Response -> OutputEvent
toResponse response =
    OutputResponse response



-- TODO: cloudWorker API should be a "regular" worker
-- client should have access to init, update


toCloudWorker : (InputEvent -> OutputEvent) -> Program () Model Msg
toCloudWorker eventResult =
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
                                , eventResult event
                                    |> encodeOutputEvent
                                    |> outputEvent
                                )

                            Err _ ->
                                ( model, Cmd.none )
        }
