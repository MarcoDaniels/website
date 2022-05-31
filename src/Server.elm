port module Server exposing (main)

import Dict
import Json.Decode as Decode exposing (Decoder, Error)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode exposing (Value)
import WebsiteResponse exposing (websiteResponseHeaders)


port responseInput : (Decode.Value -> msg) -> Sub msg


port responseOutput : Encode.Value -> Cmd msg


port serverInput : (Decode.Value -> msg) -> Sub msg


port serverOutput : Encode.Value -> Cmd msg


type alias Headers =
    Dict.Dict String String


type alias ResponseIncoming =
    { headers : Headers }


type alias ResponseOutgoing =
    { headers : Headers }


type alias RequestIncoming =
    { headers : Headers
    , method : String
    , url : String
    }


type alias RequestOutgoing =
    { headers : Headers
    , host : String
    , port_ : Maybe Int
    , path : String
    , method : String
    }


type Output
    = ResponseOutput ResponseIncoming
    | RequestOutput RequestOutgoing


type alias Model =
    Maybe Output


type Msg
    = ResponseInput (Result Error ResponseIncoming)
    | RequestInput (Result Error RequestIncoming)


main : Program () Model Msg
main =
    Platform.worker
        { init = \_ -> ( Nothing, Cmd.none )
        , subscriptions =
            \_ ->
                Sub.batch
                    [ Decode.decodeValue decodeResponseIncoming >> ResponseInput |> responseInput
                    , Decode.decodeValue decodeRequestIncoming >> RequestInput |> serverInput
                    ]
        , update =
            \msg model ->
                case msg of
                    ResponseInput proxyResult ->
                        case proxyResult of
                            Ok input ->
                                ( model
                                , responseBuilder input
                                    |> ResponseOutput
                                    |> encodeModel
                                    |> responseOutput
                                )

                            Err _ ->
                                ( model, Cmd.none )

                    RequestInput serverResult ->
                        case serverResult of
                            Ok input ->
                                ( model
                                , { headers = input.headers
                                  , host = ""
                                  , port_ = Nothing
                                  , path = input.url
                                  , method = input.method
                                  }
                                    |> RequestOutput
                                    |> encodeModel
                                    |> serverOutput
                                )

                            Err _ ->
                                ( model, Cmd.none )
        }


responseBuilder : ResponseIncoming -> ResponseIncoming
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


decodeResponseIncoming : Decoder ResponseIncoming
decodeResponseIncoming =
    Decode.succeed ResponseIncoming
        |> Decode.required "headers" (Decode.dict Decode.string)


decodeRequestIncoming : Decoder RequestIncoming
decodeRequestIncoming =
    Decode.succeed RequestIncoming
        |> Decode.required "headers" (Decode.dict Decode.string)
        |> Decode.required "method" Decode.string
        |> Decode.required "url" Decode.string


encodeModel : Output -> Encode.Value
encodeModel data =
    case data of
        ResponseOutput { headers } ->
            Encode.object
                [ ( "headers", headers |> Encode.dict identity Encode.string ) ]

        RequestOutput { headers } ->
            Encode.object [ ( "headers", headers |> Encode.dict identity Encode.string ) ]
