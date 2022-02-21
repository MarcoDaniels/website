port module CloudWorker exposing (..)

import AWS exposing (Headers, InputEvent, Origin(..), OutputEvent(..), Request, Response, decodeInputEvent, encodeOutputEvent)
import Dict
import Json.Decode as Decode exposing (Error)
import Json.Encode as Encode


port inputEvent : (Decode.Value -> msg) -> Sub msg


port outputEvent : Encode.Value -> Cmd msg


type alias Model a =
    { event : Maybe InputEvent, init : a }


type Msg
    = Input (Result Error InputEvent)


originRequest : { origin : Request -> init -> OutputEvent } -> init -> InputEvent -> OutputEvent
originRequest { origin } init inEvent =
    origin
        (inEvent.records
            |> List.foldr
                (\{ cf } _ -> cf.request)
                { clientIp = ""
                , headers = Dict.empty
                , method = ""
                , origin = OriginUnknown
                , querystring = Nothing
                , uri = ""
                }
        )
        init



-- originResponse: {Request, Response} -> Response


toRequest : Request -> OutputEvent
toRequest request =
    OutputRequest request


toResponse : Response -> OutputEvent
toResponse response =
    OutputResponse response


cloudWorker : (init -> InputEvent -> OutputEvent) -> Program init (Model init) Msg
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
                                , worker model.init event
                                    |> encodeOutputEvent
                                    |> outputEvent
                                )

                            Err _ ->
                                ( model, Cmd.none )
        }
