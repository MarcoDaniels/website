port module CloudWorker exposing (..)

import AWS exposing (Headers, InputEvent, OutputEvent(..), Request, Response, decodeInputEvent, encodeOutputEvent)
import Dict
import Json.Decode as Decode exposing (Error)
import Json.Encode as Encode


port inputEvent : (Decode.Value -> msg) -> Sub msg


port outputEvent : Encode.Value -> Cmd msg


type alias Model =
    { event : Maybe InputEvent }


type Msg
    = Input (Result Error InputEvent)


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



-- originResponse: {Request, Response} -> Response
-- originRequest: Request -> Request | Response


originRequest : { request : Request -> Request } -> InputEvent -> OutputEvent
originRequest { request } event =
    OutputRequest
        (event.records
            |> List.foldr
                (\{ cf } _ -> cf.request)
                { clientIp = ""
                , headers = Dict.empty
                , method = ""
                , querystring = Nothing
                , uri = ""
                }
            |> request
        )


withHeader : Headers -> Request -> Request
withHeader headers request =
    { request | headers = Dict.union headers request.headers }
