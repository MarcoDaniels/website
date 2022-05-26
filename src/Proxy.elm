port module Proxy exposing (main)

import Dict
import Json.Decode as Decode exposing (Decoder, Error)
import Json.Decode.Pipeline as Decode
import Json.Encode as Encode exposing (Value)


port readInput : (Decode.Value -> msg) -> Sub msg


port writeOutput : Encode.Value -> Cmd msg


type alias Header =
    Dict.Dict String String


type alias Model =
    { headers : Header }


type Msg
    = Input (Result Error Model)


main : Program () Model Msg
main =
    Platform.worker
        { init = \_ -> ( { headers = Dict.empty }, Cmd.none )
        , subscriptions =
            \_ ->
                Decode.decodeValue decodeModel
                    >> Input
                    |> readInput
        , update =
            \msg model ->
                case msg of
                    Input result ->
                        case result of
                            Ok input ->
                                ( model, input |> encodeModel |> writeOutput )

                            Err _ ->
                                ( model, Cmd.none )
        }


decodeModel : Decoder Model
decodeModel =
    Decode.succeed Model
        |> Decode.required "headers" (Decode.dict Decode.string)


encodeModel : Model -> Encode.Value
encodeModel { headers } =
    Encode.object
        [ ( "headers", headers |> Encode.dict identity Encode.string ) ]
