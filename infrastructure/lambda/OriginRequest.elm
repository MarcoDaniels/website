module OriginRequest exposing (main)

import AWS exposing (InputEvent, OutputEvent(..))
import CloudWorker exposing (originRequest, toCloudWorker, withHeader)
import Dict


main : Program () CloudWorker.Model CloudWorker.Msg
main =
    originRequest
        { request =
            withHeader
                (Dict.insert "header-name"
                    [ { key = "key-value", value = "value-value" } ]
                    Dict.empty
                )
        }
        |> toCloudWorker
