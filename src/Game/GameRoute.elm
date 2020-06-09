module Game.GameRoute exposing (..)

import Browser
import Game.Levels.Level1 as Level1 exposing (..)
import Game.Levels.Level10 as Level10 exposing (..)
import Game.Levels.Level2 as Level2 exposing (..)
import Game.Levels.Level3 as Level3 exposing (..)
import Game.Levels.Level4 as Level4 exposing (..)
import Game.Levels.Level5 as Level5 exposing (..)
import Game.Levels.Level6 as Level6 exposing (..)
import Game.Levels.Level7 as Level7 exposing (..)
import Game.Levels.Level8 as Level8 exposing (..)
import Game.Levels.Level9 as Level9 exposing (..)
import Types exposing (..)


generateLevelGrid : Int -> List Grid
generateLevelGrid level =
    case level of
        1 ->
            Level1.generateGrid

        2 ->
            Level2.generateGrid

        3 ->
            Level3.generateGrid

        4 ->
            Level4.generateGrid

        5 ->
            Level5.generateGrid

        6 ->
            Level6.generateGrid

        7 ->
            Level7.generateGrid

        8 ->
            Level8.generateGrid

        9 ->
            Level9.generateGrid

        _ ->
            Level10.generateGrid


getSelectedGrid : Int -> Grid
getSelectedGrid level =
    case level of
        1 ->
            Level1.selectedGrid

        2 ->
            Level2.selectedGrid

        3 ->
            Level3.selectedGrid

        4 ->
            Level4.selectedGrid

        5 ->
            Level5.selectedGrid

        6 ->
            Level6.selectedGrid

        7 ->
            Level7.selectedGrid

        8 ->
            Level8.selectedGrid

        9 ->
            Level9.selectedGrid

        _ ->
            Level10.selectedGrid


getPlayField : Int -> ( Int, Int )
getPlayField level =
    case level of
        1 ->
            ( Level1.playFieldHeight, Level1.playFieldWidth )

        2 ->
            ( Level2.playFieldHeight, Level2.playFieldWidth )

        3 ->
            ( Level3.playFieldHeight, Level3.playFieldWidth )

        4 ->
            ( Level4.playFieldHeight, Level4.playFieldWidth )

        5 ->
            ( Level5.playFieldHeight, Level5.playFieldWidth )

        6 ->
            ( Level6.playFieldHeight, Level6.playFieldWidth )

        7 ->
            ( Level7.playFieldHeight, Level7.playFieldWidth )

        8 ->
            ( Level8.playFieldHeight, Level8.playFieldWidth )

        9 ->
            ( Level9.playFieldHeight, Level9.playFieldWidth )

        _ ->
            ( Level10.playFieldHeight, Level10.playFieldWidth )
