module AWS exposing
    ( CloudFront(..)
    , Headers
    , InputEvent
    , Origin(..)
    , OriginRequest
    , OriginResponse
    , OutputEvent(..)
    , Request
    , Response
    , decodeInputEvent
    , defaultOriginRequest
    , defaultOriginResponse
    , encodeOutputEvent
    )

{-| Types based on:
<https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html#request-event-fields>
-}

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, Error)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode



{---- Types ----}


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


type alias CustomOriginData =
    { customHeaders : Headers
    , domainName : String
    , keepaliveTimeout : Int
    , path : String
    , port_ : Int
    , protocol : String
    , readTimeout : Int
    , sslProtocols : List String
    }


type alias CustomOrigin =
    { custom : CustomOriginData }


type alias S3OriginData =
    { authMethod : String
    , customHeaders : Headers
    , domainName : String
    , path : String
    , region : String
    }


type alias S3Origin =
    { s3 : S3OriginData }


type Origin
    = OriginS3 S3Origin
    | OriginCustom CustomOrigin
    | OriginUnknown


type alias Request =
    { clientIp : String
    , headers : Headers
    , method : String
    , origin : Origin
    , querystring : Maybe String
    , uri : String
    }


type alias Response =
    { status : String
    , statusDescription : String
    , headers : Headers
    }


type alias OriginRequest =
    { config : Config, request : Request }


type alias OriginResponse =
    { config : Config, request : Request, response : Response }


type CloudFront
    = InputResponse OriginResponse
    | InputRequest OriginRequest


type alias Record =
    { cf : CloudFront }


type alias InputEvent =
    { records : List Record }


type OutputEvent
    = OutputResponse Response
    | OutputRequest Request



{---- Defaults ----}


defaultConfig : Config
defaultConfig =
    { distributionDomainName = ""
    , distributionId = ""
    , eventType = ""
    , requestId = ""
    }


defaultRequest : Request
defaultRequest =
    { clientIp = ""
    , headers = Dict.empty
    , method = ""
    , origin = OriginUnknown
    , querystring = Nothing
    , uri = ""
    }


defaultOriginRequest : OriginRequest
defaultOriginRequest =
    { request = defaultRequest, config = defaultConfig }


defaultResponse : Response
defaultResponse =
    { status = ""
    , statusDescription = ""
    , headers = Dict.empty
    }


defaultOriginResponse : OriginResponse
defaultOriginResponse =
    { request = defaultRequest, response = defaultResponse, config = defaultConfig }



{---- Decoders ----}


decodeHeader : Decoder Header
decodeHeader =
    Decode.succeed Header
        |> Decode.required "key" Decode.string
        |> Decode.required "value" Decode.string


decodeCustomOriginData : Decoder CustomOriginData
decodeCustomOriginData =
    Decode.succeed CustomOriginData
        |> Decode.required "customHeaders" (Decode.dict (Decode.list decodeHeader))
        |> Decode.required "domainName" Decode.string
        |> Decode.required "keepaliveTimeout" Decode.int
        |> Decode.required "path" Decode.string
        |> Decode.required "port" Decode.int
        |> Decode.required "protocol" Decode.string
        |> Decode.required "readTimeout" Decode.int
        |> Decode.required "sslProtocols" (Decode.list Decode.string)


decodeS3OriginData : Decoder S3OriginData
decodeS3OriginData =
    Decode.succeed S3OriginData
        |> Decode.required "authMethod" Decode.string
        |> Decode.required "customHeaders" (Decode.dict (Decode.list decodeHeader))
        |> Decode.required "domainName" Decode.string
        |> Decode.required "path" Decode.string
        |> Decode.required "region" Decode.string


decodeOrigin : Decoder Origin
decodeOrigin =
    Decode.oneOf
        [ Decode.succeed S3Origin
            |> Decode.required "s3" decodeS3OriginData
            |> Decode.map OriginS3
        , Decode.succeed CustomOrigin
            |> Decode.required "custom" decodeCustomOriginData
            |> Decode.map OriginCustom
        , Decode.succeed OriginUnknown
        ]


decodeRequest : Decoder Request
decodeRequest =
    Decode.succeed Request
        |> Decode.required "clientIp" Decode.string
        |> Decode.required "headers" (Decode.dict (Decode.list decodeHeader))
        |> Decode.required "method" Decode.string
        |> Decode.required "origin" decodeOrigin
        |> Decode.required "querystring" (Decode.maybe Decode.string)
        |> Decode.required "uri" Decode.string


decodeResponse : Decoder Response
decodeResponse =
    Decode.succeed Response
        |> Decode.required "status" Decode.string
        |> Decode.required "statusDescription" Decode.string
        |> Decode.required "headers" (Decode.dict (Decode.list decodeHeader))


decodeConfig : Decoder Config
decodeConfig =
    Decode.succeed Config
        |> Decode.required "distributionDomainName" Decode.string
        |> Decode.required "distributionId" Decode.string
        |> Decode.required "eventType" Decode.string
        |> Decode.required "requestId" Decode.string


decodeInputEvent : Decoder InputEvent
decodeInputEvent =
    Decode.succeed InputEvent
        |> Decode.required "Records"
            (Decode.list
                (Decode.succeed Record
                    |> Decode.required "cf"
                        (Decode.oneOf
                            [ (Decode.succeed OriginResponse
                                |> Decode.required "config" decodeConfig
                                |> Decode.required "request" decodeRequest
                                |> Decode.required "response" decodeResponse
                              )
                                |> Decode.map InputResponse
                            , (Decode.succeed OriginRequest
                                |> Decode.required "config" decodeConfig
                                |> Decode.required "request" decodeRequest
                              )
                                |> Decode.map InputRequest
                            ]
                        )
                )
            )



{---- Encoders -----}


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


encodeOrigin : Origin -> Encode.Value
encodeOrigin origin =
    case origin of
        OriginS3 { s3 } ->
            Encode.object
                [ ( "s3"
                  , Encode.object
                        [ ( "authMethod", s3.authMethod |> Encode.string )
                        , ( "customHeaders", s3.customHeaders |> encodeHeaders )
                        , ( "domainName", s3.domainName |> Encode.string )
                        , ( "path", s3.path |> Encode.string )
                        , ( "region", s3.region |> Encode.string )
                        ]
                  )
                ]

        OriginCustom { custom } ->
            Encode.object
                [ ( "custom"
                  , Encode.object
                        [ ( "customHeaders", custom.customHeaders |> encodeHeaders )
                        , ( "domainName", custom.domainName |> Encode.string )
                        , ( "keepaliveTimeout", custom.keepaliveTimeout |> Encode.int )
                        , ( "path", custom.path |> Encode.string )
                        , ( "port", custom.port_ |> Encode.int )
                        , ( "protocol", custom.protocol |> Encode.string )
                        , ( "readTimeout", custom.readTimeout |> Encode.int )
                        , ( "sslProtocols", custom.sslProtocols |> Encode.list Encode.string )
                        ]
                  )
                ]

        OriginUnknown ->
            Encode.null


encodeOutputEvent : OutputEvent -> Encode.Value
encodeOutputEvent result =
    case result of
        OutputResponse response ->
            Encode.object
                [ ( "status", response.status |> Encode.string )
                , ( "statusDescription", response.statusDescription |> Encode.string )
                , ( "headers", response.headers |> encodeHeaders )
                ]

        OutputRequest request ->
            Encode.object
                [ ( "clientIp", request.clientIp |> Encode.string )
                , ( "headers", request.headers |> encodeHeaders )
                , ( "method", request.method |> Encode.string )
                , ( "origin", request.origin |> encodeOrigin )
                , ( "querystring"
                  , request.querystring
                        |> Maybe.map Encode.string
                        |> Maybe.withDefault Encode.null
                  )
                , ( "uri", request.uri |> Encode.string )
                ]
