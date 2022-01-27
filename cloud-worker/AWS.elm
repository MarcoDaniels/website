module AWS exposing (Event, EventResult(..), Request, Response, decodeEvent, encodeEventResult, Headers, Header)

{-| Types based on:
<https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html#request-event-fields>
-}

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, Error)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode


type alias Config =
    { distributionDomainName : String
    , distributionId : String
    , eventType : String
    , requestId : String
    }


type alias Header =
    { key : String, value : String }


type alias Headers =
    Dict.Dict String (List Header)


type alias Request =
    { clientIp : String
    , headers : Headers
    , method : String

    -- TODO: origin : Dict {customHeaders ...}
    , querystring : Maybe String
    , uri : String
    }


type alias Response =
    { status : String
    , statusDescription : String
    , headers : Headers
    , body : String
    }



-- TODO: depending on event type (Origin Response), can have response (to add headers)


type alias CloudFront =
    { config : Config
    , request : Request
    }


type alias Record =
    { cf : CloudFront }


type alias Event =
    { records : List Record }


decodeHeader : Decoder Header
decodeHeader =
    Decode.succeed Header
        |> Decode.required "key" Decode.string
        |> Decode.required "value" Decode.string


decodeRequest : Decoder Request
decodeRequest =
    Decode.succeed Request
        |> Decode.required "clientIp" Decode.string
        |> Decode.required "headers" (Decode.dict (Decode.list decodeHeader))
        |> Decode.required "method" Decode.string
        |> Decode.required "querystring" (Decode.maybe Decode.string)
        |> Decode.required "uri" Decode.string


decodeConfig : Decoder Config
decodeConfig =
    Decode.succeed Config
        |> Decode.required "distributionDomainName" Decode.string
        |> Decode.required "distributionId" Decode.string
        |> Decode.required "eventType" Decode.string
        |> Decode.required "requestId" Decode.string


decodeCloudFront : Decoder Record
decodeCloudFront =
    Decode.succeed Record
        |> Decode.required "cf"
            (Decode.succeed CloudFront
                |> Decode.required "config" decodeConfig
                |> Decode.required "request" decodeRequest
            )


decodeEvent : Decoder Event
decodeEvent =
    Decode.succeed Event
        |> Decode.required "Records"
            (Decode.list decodeCloudFront)


type EventResult
    = ResultResponse Response
    | ResultRequest Request


encodeHeaders : Headers -> Encode.Value
encodeHeaders headers =
    headers
        |> Encode.dict identity
            (Encode.list
                (\header ->
                    Encode.object
                        [ ( "key", Encode.string header.key )
                        , ( "value", Encode.string header.value )
                        ]
                )
            )


encodeQuerystring : Maybe String -> Encode.Value
encodeQuerystring maybeQuerystring =
    maybeQuerystring
        |> Maybe.map Encode.string
        |> Maybe.withDefault Encode.null


encodeEventResult : EventResult -> Encode.Value
encodeEventResult result =
    case result of
        ResultResponse response ->
            Encode.object
                [ ( "status", Encode.string response.status )
                , ( "statusDescription", Encode.string response.statusDescription )
                , ( "headers", response.headers |> encodeHeaders )
                , ( "body", Encode.string response.body )
                ]

        ResultRequest request ->
            Encode.object
                [ ( "clientIp", Encode.string request.clientIp )
                , ( "headers", request.headers |> encodeHeaders )
                , ( "method", Encode.string request.method )
                , ( "querystring", request.querystring |> encodeQuerystring )
                , ( "uri", Encode.string request.uri )
                ]