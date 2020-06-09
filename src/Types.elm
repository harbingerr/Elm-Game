module Types exposing (..)


type alias User =
    { username : String
    , level : Int
    }


type alias Direction =
    ( Int, Int )


type alias Directions =
    { right : Direction
    , left : Direction
    , up : Direction
    , down : Direction
    }


directions : Directions
directions =
    { right = ( 0, 1 )
    , left = ( 0, -1 )
    , up = ( -1, 0 )
    , down = ( 1, 0 )
    }


type alias Grid =
    { xy : ( Int, Int )
    , status : Status
    , item : Item
    , dir : Maybe (List ItemDirection)
    }


type Status
    = NonSelected
    | Current
    | CurrentPlusSelected


type Item
    = Wall
    | Bomb
    | Stick
    | Duplicator
    | Swap
    | Win
    | Field
    | SuperWall


type ItemDirection
    = Right
    | Left
    | Down
    | Up
