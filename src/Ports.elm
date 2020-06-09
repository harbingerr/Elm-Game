port module Ports exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Types exposing (..)


port storeUser : Decode.Value -> Cmd msg


port play : Encode.Value -> Cmd msg
