port module CloudWorker exposing (..)

import AWS exposing (Event, EventResult(..), Headers, Request, decodeEvent, encodeEventResult)
import Dict
import Json.Decode as Decode exposing (Error)
import Json.Encode as Encode


port incomingEvent : (Decode.Value -> msg) -> Sub msg


port outgoingResult : Encode.Value -> Cmd msg


type alias Model =
    { event : Maybe Event }


type Msg
    = Incoming (Result Error Event)


toCloudWorker : (Event -> EventResult) -> Program () Model Msg
toCloudWorker eventResult =
    Platform.worker
        { init = \_ -> ( { event = Nothing }, Cmd.none )
        , subscriptions =
            \_ ->
                Decode.decodeValue decodeEvent
                    >> Incoming
                    |> incomingEvent
        , update =
            \msg model ->
                case msg of
                    Incoming result ->
                        case result of
                            Ok event ->
                                ( { event = Just event }
                                , eventResult event
                                    |> encodeEventResult
                                    |> outgoingResult
                                )

                            Err _ ->
                                ( model, Cmd.none )
        }



-- originResponse: {Request, Response} -> Response
-- originRequest: Request -> Request | Response


originRequest : { request : Request -> Request } -> Event -> EventResult
originRequest { request } event =
    ResultRequest
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
