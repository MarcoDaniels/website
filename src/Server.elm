port module Server exposing (main)

import Dict
import Json.Decode as Decode exposing (Decoder, Error)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode exposing (Value)
import Url
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
    , secure : Bool
    }


type Output
    = ResponseOutput ResponseIncoming
    | RequestOutput RequestOutgoing


type Msg
    = ResponseInput (Result Error ResponseIncoming)
    | RequestInput (Result Error RequestIncoming)


type alias Env =
    { baseUrl : String, token : String }


main : Program Env Env Msg
main =
    Platform.worker
        { init = \flags -> ( flags, Cmd.none )
        , subscriptions =
            \_ ->
                Sub.batch
                    [ Decode.decodeValue decodeResponseIncoming >> ResponseInput |> responseInput
                    , Decode.decodeValue decodeRequestIncoming >> RequestInput |> serverInput
                    ]
        , update =
            \msg model ->
                case msg of
                    ResponseInput responseResult ->
                        case responseResult of
                            Ok response ->
                                ( model, responseBuilder response |> ResponseOutput |> encodeModel |> responseOutput )

                            Err _ ->
                                ( model, Cmd.none )

                    RequestInput requestResult ->
                        case requestResult of
                            Ok request ->
                                ( model, requestBuilder model request |> RequestOutput |> encodeModel |> serverOutput )

                            Err _ ->
                                ( model, Cmd.none )
        }


requestBuilder : Env -> RequestIncoming -> RequestOutgoing
requestBuilder env request =
    let
        url : { host : String, path : String, query : Maybe String }
        url =
            [ "http://"
            , Dict.get "host" request.headers |> Maybe.withDefault ""
            , request.url
            ]
                |> String.concat
                |> Url.fromString
                |> Maybe.map (\{ host, path, query } -> { host = host, path = path, query = query })
                |> Maybe.withDefault { host = "", path = "", query = Nothing }
    in
    if String.startsWith "/image/api/" request.url then
        let
            host : String
            host =
                String.replace "https://" "" env.baseUrl

            path : String
            path =
                [ "/api/cockpit/image?token="
                , env.token
                , "&src="
                , env.baseUrl
                , "/storage/uploads"
                , String.replace "/image/api" "" url.path
                , "&"
                , url.query |> Maybe.withDefault ""
                ]
                    |> String.concat
        in
        { headers = Dict.union (Dict.insert "host" host Dict.empty) request.headers
        , port_ = Nothing
        , method = request.method
        , secure = True
        , host = host
        , path = path
        }

    else
        { headers = request.headers
        , port_ = Just 1234
        , method = request.method
        , secure = False
        , host = url.host
        , path = url.path
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

        RequestOutput request ->
            Encode.object
                [ ( "headers", request.headers |> Encode.dict identity Encode.string )
                , ( "host", Encode.string request.host )
                , ( "port", request.port_ |> Maybe.map Encode.int |> Maybe.withDefault Encode.null )
                , ( "path", Encode.string request.path )
                , ( "method", Encode.string request.method )
                , ( "secure", Encode.bool request.secure )
                ]
