port module Proxy exposing (main)

import Dict
import Json.Decode as Decode exposing (Decoder, Error)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode exposing (Value)
import WebsiteResponse exposing (websiteResponseHeaders)


port proxyInput : (Decode.Value -> msg) -> Sub msg


port proxyOutput : Encode.Value -> Cmd msg


port serverInput : (Decode.Value -> msg) -> Sub msg


port serverOutput : Encode.Value -> Cmd msg


type alias Header =
    Dict.Dict String String


type alias Proxy =
    { headers : Header }


type alias Server =
    { clientRequest : String }


type DataPayload
    = ProxyPayload Proxy
    | ServerPayload Server


type alias Model =
    Maybe DataPayload


type Msg
    = ProxyInput (Result Error Proxy)
    | ServerInput (Result Error Server)


main : Program () Model Msg
main =
    Platform.worker
        { init = \_ -> ( Nothing, Cmd.none )
        , subscriptions =
            \_ ->
                Sub.batch
                    [ Decode.decodeValue decodeProxy >> ProxyInput |> proxyInput
                    , Decode.decodeValue decodeServer >> ServerInput |> serverInput
                    ]
        , update =
            \msg model ->
                case msg of
                    ProxyInput proxyResult ->
                        case proxyResult of
                            Ok input ->
                                ( model
                                , responseBuilder input
                                    |> ProxyPayload
                                    |> encodeModel
                                    |> proxyOutput
                                )

                            Err _ ->
                                ( model, Cmd.none )

                    ServerInput serverResult ->
                        case serverResult of
                            Ok input ->
                                ( model
                                , input
                                    |> ServerPayload
                                    |> encodeModel
                                    |> serverOutput
                                )

                            Err _ ->
                                ( model, Cmd.none )
        }


responseBuilder : Proxy -> Proxy
responseBuilder { headers } =
    { headers =
        Dict.union
            (websiteResponseHeaders
                |> List.foldr
                    (\{ key, value } -> Dict.insert key value)
                    Dict.empty
            )
            headers
    }


decodeProxy : Decoder Proxy
decodeProxy =
    Decode.succeed Proxy
        |> Decode.required "headers" (Decode.dict Decode.string)


decodeServer : Decoder Server
decodeServer =
    Decode.succeed Server
        |> Decode.required "clientRequest" Decode.string


encodeModel : DataPayload -> Encode.Value
encodeModel data =
    case data of
        ProxyPayload { headers } ->
            Encode.object
                [ ( "headers", headers |> Encode.dict identity Encode.string ) ]

        ServerPayload { clientRequest } ->
            Encode.object [ ( "clientRequest", Encode.string clientRequest ) ]
