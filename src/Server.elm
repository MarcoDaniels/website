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
                    ResponseInput responseResult ->
                        case responseResult of
                            Ok response ->
                                ( model, responseBuilder response |> ResponseOutput |> encodeModel |> responseOutput )

                            Err _ ->
                                ( model, Cmd.none )

                    RequestInput requestResult ->
                        case requestResult of
                            Ok request ->
                                ( model, requestBuilder request |> RequestOutput |> encodeModel |> serverOutput )

                            Err _ ->
                                ( model, Cmd.none )
        }


requestBuilder : RequestIncoming -> RequestOutgoing
requestBuilder request =
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
                -- TODO: COCKPIT_BASE_URL env flag
                String.replace "https://" "" ""

            path : String
            path =
                [ "/api/cockpit/image?token="

                -- TODO: COCKPIT_API_TOKEN env flag
                , ""
                , "&src="

                -- TODO: COCKPIT_BASE_URL env flag
                , ""
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
