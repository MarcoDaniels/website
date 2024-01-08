port module BaseLambda exposing (inputEvent, outputEvent, ports)

import Json.Decode as Decode
import Json.Encode as Encode


port inputEvent : (Decode.Value -> msg) -> Sub msg


port outputEvent : Encode.Value -> Cmd msg


ports : ( (Decode.Value -> msg) -> Sub msg, Encode.Value -> Cmd msg )
ports =
    ( inputEvent, outputEvent )
