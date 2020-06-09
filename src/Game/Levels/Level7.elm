module Game.Levels.Level7 exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Types exposing (..)


playFieldHeight : Int
playFieldHeight =
    5


playFieldWidth : Int
playFieldWidth =
    6


selectedGrid : Grid
selectedGrid =
    { xy = ( -1, -1 ), status = NonSelected, item = Stick, dir = Nothing }


generateGrid : List Grid
generateGrid =
    [ { xy = ( 0, 0 ), status = Current, item = Bomb, dir = Just [ Right ] }
    , { xy = ( 0, 1 ), status = NonSelected, item = Bomb, dir = Just [ Right, Down ] }
    , { xy = ( 0, 2 ), status = NonSelected, item = Bomb, dir = Just [ Right ] }
    , { xy = ( 0, 3 ), status = NonSelected, item = Bomb, dir = Just [ Down ] }
    , { xy = ( 0, 4 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 0, 5 ), status = NonSelected, item = Swap, dir = Just [ Left, Down ] }
    , { xy = ( 1, 0 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 1, 1 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 1, 2 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 1, 3 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 1, 4 ), status = NonSelected, item = Swap, dir = Just [ Up, Down ] }
    , { xy = ( 1, 5 ), status = NonSelected, item = Field, dir = Nothing }
    , { xy = ( 2, 0 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 2, 1 ), status = NonSelected, item = Swap, dir = Just [ Down, Up ] }
    , { xy = ( 2, 2 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 2, 3 ), status = NonSelected, item = Swap, dir = Just [ Left, Up ] }
    , { xy = ( 2, 4 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 2, 5 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 3, 0 ), status = NonSelected, item = Swap, dir = Just [ Right, Down ] }
    , { xy = ( 3, 1 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 3, 2 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 3, 3 ), status = NonSelected, item = Duplicator, dir = Just [ Left ] }
    , { xy = ( 3, 4 ), status = NonSelected, item = SuperWall, dir = Nothing }
    , { xy = ( 3, 5 ), status = NonSelected, item = Bomb, dir = Just [ Down ] }
    , { xy = ( 4, 0 ), status = NonSelected, item = Stick, dir = Nothing }
    , { xy = ( 4, 1 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 4, 2 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 4, 3 ), status = NonSelected, item = Wall, dir = Nothing }
    , { xy = ( 4, 4 ), status = NonSelected, item = Win, dir = Nothing }
    , { xy = ( 4, 5 ), status = NonSelected, item = Wall, dir = Nothing }
    ]
