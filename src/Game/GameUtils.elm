module Game.GameUtils exposing (..)

import Browser
import Browser.Events
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Json.Decode as Decode
import String exposing (..)
import Types exposing (..)



{- checks current status -}


checkCurrent : Grid -> Bool
checkCurrent grid =
    if grid.status == Current || grid.status == CurrentPlusSelected then
        True

    else
        False



{- check if it is the requested grid possition -}


checkGrid : Grid -> Grid -> Bool
checkGrid gridInList findThis =
    let
        return =
            if gridInList.xy == findThis.xy then
                True

            else
                False
    in
    return


checkBomb : Grid -> Bool
checkBomb gridInList =
    let
        return =
            if gridInList.item == Bomb then
                True

            else
                False
    in
    return



{- returns current grid from grids -}


getCurrentGrid : List Grid -> Grid
getCurrentGrid allGrids =
    let
        startGrid =
            List.filter checkCurrent allGrids

        oneGrid =
            case List.head startGrid of
                Just g ->
                    g

                Nothing ->
                    { xy = ( 0, 0 ), status = Current, item = Field, dir = Nothing }
    in
    oneGrid


getNewGrid : List Grid -> Grid -> Grid -> Grid
getNewGrid allGrids findThisGrid oldGrid =
    let
        thisGrids =
            List.filter (\x -> checkGrid x findThisGrid) allGrids

        oneGrid =
            case List.head thisGrids of
                Just g ->
                    if g.item == Wall then
                        oldGrid

                    else
                        g

                Nothing ->
                    { xy = ( 0, 0 ), status = Current, item = Field, dir = Nothing }
    in
    oneGrid



{- returns requested grid and changed it to Filed -}


getDestroyedGrid : List Grid -> Grid -> Grid
getDestroyedGrid grids gridToFind =
    let
        thisGrids =
            List.filter (\x -> checkGrid x gridToFind) grids

        oneGrid =
            case List.head thisGrids of
                Just g ->
                    { g | item = Field, dir = Nothing }

                Nothing ->
                    gridToFind
    in
    oneGrid


getNormalGrid : List Grid -> Grid -> Grid
getNormalGrid grids gridToFind =
    let
        thisGrids =
            List.filter (\x -> checkGrid x gridToFind) grids

        oneGrid =
            case List.head thisGrids of
                Just g ->
                    g

                Nothing ->
                    gridToFind
    in
    oneGrid



{- case Field je empty no v Selected uz nieco je -}


swapSelectedItemWithField : Grid -> Grid -> Grid
swapSelectedItemWithField gridInList selectedGrid =
    let
        updateGrid =
            if checkCurrent gridInList then
                { xy = gridInList.xy, status = Current, item = selectedGrid.item, dir = selectedGrid.dir }

            else
                gridInList
    in
    updateGrid



{- case Field ma item selected je empty -> zmena statusu -}


swapAndChangeStatus : Grid -> Grid -> Grid
swapAndChangeStatus gridInList selectedGrid =
    let
        updateGrid =
            if checkCurrent gridInList then
                if selectedGrid.item == Field then
                    { xy = gridInList.xy, status = Current, item = selectedGrid.item, dir = selectedGrid.dir }

                else
                    { xy = gridInList.xy, status = CurrentPlusSelected, item = selectedGrid.item, dir = selectedGrid.dir }

            else
                gridInList
    in
    updateGrid


destroyGrid : Grid -> Grid -> Grid
destroyGrid gridToDestory xy =
    let
        destroyed =
            if checkGrid gridToDestory xy then
                { gridToDestory | item = Field, dir = Nothing }

            else
                gridToDestory
    in
    destroyed



{- update old/new current grid -}


updateGrids : Grid -> Grid -> Grid -> Grid -> Grid
updateGrids gridInList newCurrent oldCurr selectedGrid =
    let
        updatedGrid =
            if gridInList.xy == newCurrent.xy then
                if selectedGrid.item == Field then
                    { newCurrent | status = Current }

                else
                    { newCurrent | status = CurrentPlusSelected }

            else if gridInList.xy == oldCurr.xy then
                { oldCurr | status = NonSelected }

            else
                gridInList
    in
    updatedGrid



{- check if the move is out of map -}


checkOOM : Grid -> Direction -> ( Int, Int ) -> Bool
checkOOM currentGrid dir playField =
    let
        isValid =
            if dir == directions.right then
                if Tuple.second currentGrid.xy == (Tuple.second playField - 1) then
                    False

                else
                    True

            else if dir == directions.left then
                if Tuple.second currentGrid.xy == 0 then
                    False

                else
                    True

            else if dir == directions.up then
                if Tuple.first currentGrid.xy == 0 then
                    False

                else
                    True

            else if Tuple.first currentGrid.xy == (Tuple.first playField - 1) then
                False

            else
                True
    in
    isValid



-------------------------VIEW UTILS ------------------------------


directionImage : Grid -> List (Attribute msg)
directionImage grid =
    case grid.dir of
        Just dir ->
            let
                rightAttribute : Attribute msg
                rightAttribute =
                    if List.member Right dir then
                        inFront (Element.image [ scale 0.2, moveRight 30, moveUp 50 ] { src = "/right.png", description = "right" })

                    else
                        onRight (Element.none |> el [])

                leftAttribute : Attribute msg
                leftAttribute =
                    if List.member Left dir then
                        inFront (Element.image [ scale 0.2, moveLeft 50, moveUp 50 ] { src = "/left.png", description = "left" })

                    else
                        onLeft (Element.none |> el [])

                upAttribute : Attribute msg
                upAttribute =
                    if List.member Up dir then
                        inFront (Element.image [ scale 0.2, moveUp 90, moveLeft 10 ] { src = "/up.png", description = "up" })

                    else
                        onLeft (Element.none |> el [])

                downAttribute : Attribute msg
                downAttribute =
                    if List.member Down dir then
                        inFront (Element.image [ scale 0.2, moveUp 10, moveLeft 10 ] { src = "/down.png", description = "down" })

                    else
                        onLeft (Element.none |> el [])
            in
            [ rightAttribute, leftAttribute, upAttribute, downAttribute ]

        Nothing ->
            [ onRight (Element.none |> el []), onLeft (Element.none |> el []) ]


selectedItem : Grid -> List (Attribute msg)
selectedItem grid =
    case grid.status of
        Current ->
            let
                overlay : List (Attribute msg)
                overlay =
                    [ Border.width 3
                    , Border.color (rgb255 32 255 64)
                    ]
            in
            overlay

        CurrentPlusSelected ->
            let
                overlay : List (Attribute msg)
                overlay =
                    [ Border.width 3
                    , Border.color (rgb255 60 180 170)
                    ]
            in
            overlay

        _ ->
            []


generateSrc : Grid -> Element msg
generateSrc grid =
    case grid.item of
        Wall ->
            { src = "/wall.png"
            , description = "nah"
            }
                |> Element.image
                    (selectedItem grid
                        |> List.append (directionImage grid)
                        |> List.append
                            [ width (px 100)
                            , height (px 100)
                            , Background.color (rgb255 255 220 190)
                            ]
                    )

        Bomb ->
            { src = "/bomb.png"
            , description = "nah"
            }
                |> Element.image
                    (selectedItem grid
                        |> List.append (directionImage grid)
                        |> List.append
                            [ width (px 100)
                            , height (px 100)
                            , Border.width 1
                            , Background.color (rgb255 255 220 190)
                            ]
                    )

        Stick ->
            { src = "/stick.png"
            , description = "nah"
            }
                |> Element.image
                    (selectedItem grid
                        |> List.append (directionImage grid)
                        |> List.append
                            [ width (px 100)
                            , height (px 100)
                            , Border.width 1
                            , Background.color (rgb255 255 220 190)
                            ]
                    )

        Duplicator ->
            { src = "/copy.png"
            , description = "nah"
            }
                |> Element.image
                    (selectedItem grid
                        |> List.append (directionImage grid)
                        |> List.append
                            [ width (px 100)
                            , height (px 100)
                            , Border.width 1
                            , Background.color (rgb255 255 220 190)
                            ]
                    )

        Win ->
            { src = "/win.png"
            , description = "nah"
            }
                |> Element.image
                    (selectedItem grid
                        |> List.append (directionImage grid)
                        |> List.append
                            [ width (px 100)
                            , height (px 100)
                            , Border.width 1
                            , Background.color (rgb255 255 220 190)
                            ]
                    )

        Swap ->
            { src = "/swap.png"
            , description = "nah"
            }
                |> Element.image
                    (selectedItem grid
                        |> List.append (directionImage grid)
                        |> List.append
                            [ width (px 100)
                            , height (px 100)
                            , Border.width 1
                            , Background.color (rgb255 255 220 190)
                            ]
                    )

        Field ->
            Element.el
                (selectedItem grid
                    |> List.append (directionImage grid)
                    |> List.append
                        [ width (px 100)
                        , height (px 100)
                        , Border.width 1
                        , Background.color (rgb255 255 220 190)
                        ]
                )
                Element.none

        SuperWall ->
            Element.el
                (selectedItem grid
                    |> List.append
                        [ width (px 100)
                        , height (px 100)
                        , Background.color (rgb255 186 145 73)
                        ]
                )
                Element.none



-----------DESTROYYYY
{- funkcia vracia list vsetkych gridov ktore by mali byt znicene -}


destroyThoseGrids : List Grid -> Grid -> ( Int, Int ) -> List Grid -> List Grid
destroyThoseGrids grids bomb playfield gridsToDestroy =
    if List.member bomb gridsToDestroy then
        gridsToDestroy

    else
        let
            helper =
                case bomb.dir of
                    Just list ->
                        let
                            allgrids =
                                bomb :: gridsToDestroy

                            getRight =
                                if List.member Right list && checkOOM bomb directions.right playfield then
                                    let
                                        newGrid =
                                            getNormalGrid grids { xy = ( Tuple.first bomb.xy, Tuple.second bomb.xy + 1 ), status = bomb.status, item = bomb.item, dir = bomb.dir }

                                        allGrids =
                                            if newGrid.item == Bomb then
                                                List.append (destroyThoseGrids grids newGrid playfield allgrids) allgrids

                                            else
                                                newGrid :: allgrids
                                    in
                                    allGrids

                                else
                                    allgrids

                            getLeft =
                                if List.member Left list && checkOOM bomb directions.left playfield then
                                    let
                                        newGrid =
                                            getNormalGrid grids { xy = ( Tuple.first bomb.xy, Tuple.second bomb.xy - 1 ), status = bomb.status, item = bomb.item, dir = bomb.dir }

                                        allGrids =
                                            if newGrid.item == Bomb then
                                                List.append (destroyThoseGrids grids newGrid playfield allgrids) allgrids

                                            else
                                                newGrid :: getRight
                                    in
                                    allGrids

                                else
                                    getRight

                            getUp =
                                if List.member Up list && checkOOM bomb directions.up playfield then
                                    let
                                        newGrid =
                                            getNormalGrid grids { xy = ( Tuple.first bomb.xy - 1, Tuple.second bomb.xy ), status = bomb.status, item = bomb.item, dir = bomb.dir }

                                        allGrids =
                                            if newGrid.item == Bomb then
                                                List.append (destroyThoseGrids grids newGrid playfield allgrids) allgrids

                                            else
                                                newGrid :: getLeft
                                    in
                                    allGrids

                                else
                                    getLeft

                            getDown =
                                if List.member Down list && checkOOM bomb directions.down playfield then
                                    let
                                        newGrid =
                                            getNormalGrid grids { xy = ( Tuple.first bomb.xy + 1, Tuple.second bomb.xy ), status = bomb.status, item = bomb.item, dir = bomb.dir }

                                        allGrids =
                                            if newGrid.item == Bomb then
                                                List.append (destroyThoseGrids grids newGrid playfield allgrids) allgrids

                                            else
                                                newGrid :: getUp
                                    in
                                    allGrids

                                else
                                    getUp
                        in
                        getDown

                    Nothing ->
                        bomb :: gridsToDestroy
        in
        helper


getDestroyedGrids : List Grid -> Grid -> ( Int, Int ) -> List Grid
getDestroyedGrids grids currentGrid playField =
    let
        {- list vsetkych gridov -}
        getAllGridsToDestroy =
            destroyThoseGrids grids currentGrid playField []

        cleareAll =
            List.map (\x -> destroyAndUpdate getAllGridsToDestroy currentGrid x) grids
    in
    cleareAll


destroyAndUpdate : List Grid -> Grid -> Grid -> Grid
destroyAndUpdate gridsToDestory currentGrid gridInList =
    let
        thisGrids =
            List.filter (\x -> checkGrid x gridInList) gridsToDestory

        oneGrid =
            case List.head thisGrids of
                Just g ->
                    if g.item == SuperWall then
                        g

                    else if g == currentGrid then
                        { g | item = Field, dir = Nothing, status = Current }

                    else
                        { g | item = Field, dir = Nothing }

                Nothing ->
                    gridInList
    in
    oneGrid



{- aktivuj swap item -}


swapItemActivated : List Grid -> Grid -> List Grid
swapItemActivated allGrids currentGrid =
    let
        {- check directions of swap and get grids to swap -}
        gridsToswap =
            case currentGrid.dir of
                Just list ->
                    let
                        swappedGrids =
                            {- Right/Left -}
                            if List.member Right list && List.member Left list then
                                let
                                    tempRightSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy, Tuple.second currentGrid.xy + 1 ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    tempLeftSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy, Tuple.second currentGrid.xy - 1 ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    newCurrent =
                                        { currentGrid | item = Field, dir = Nothing, status = Current }

                                    rightSwap =
                                        { tempRightSwap1 | item = tempLeftSwap1.item, dir = tempLeftSwap1.dir }

                                    leftSwap =
                                        { tempLeftSwap1 | item = tempRightSwap1.item, dir = tempRightSwap1.dir }

                                    updatedListOfGrids =
                                        List.map (\x -> updateAllSwappedGrids x newCurrent rightSwap leftSwap) allGrids
                                in
                                updatedListOfGrids

                            else if List.member Right list && List.member Up list then
                                let
                                    tempRightSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy, Tuple.second currentGrid.xy + 1 ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    tempUpSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy - 1, Tuple.second currentGrid.xy ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    newCurrent =
                                        { currentGrid | item = Field, dir = Nothing, status = Current }

                                    rightSwap =
                                        { tempRightSwap1 | item = tempUpSwap1.item, dir = tempUpSwap1.dir }

                                    upSwap =
                                        { tempUpSwap1 | item = tempRightSwap1.item, dir = tempRightSwap1.dir }

                                    updatedListOfGrids =
                                        List.map (\x -> updateAllSwappedGrids x newCurrent rightSwap upSwap) allGrids
                                in
                                updatedListOfGrids

                            else if List.member Right list && List.member Down list then
                                let
                                    tempRightSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy, Tuple.second currentGrid.xy + 1 ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    tempDownSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy + 1, Tuple.second currentGrid.xy ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    newCurrent =
                                        { currentGrid | item = Field, dir = Nothing, status = Current }

                                    rightSwap =
                                        { tempRightSwap1 | item = tempDownSwap1.item, dir = tempDownSwap1.dir }

                                    downSwap =
                                        { tempDownSwap1 | item = tempRightSwap1.item, dir = tempRightSwap1.dir }

                                    updatedListOfGrids =
                                        List.map (\x -> updateAllSwappedGrids x newCurrent rightSwap downSwap) allGrids
                                in
                                updatedListOfGrids

                            else if List.member Left list && List.member Up list then
                                let
                                    tempLeftSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy, Tuple.second currentGrid.xy - 1 ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    tempUpSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy - 1, Tuple.second currentGrid.xy ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    newCurrent =
                                        { currentGrid | item = Field, dir = Nothing, status = Current }

                                    leftSwap =
                                        { tempLeftSwap1 | item = tempUpSwap1.item, dir = tempUpSwap1.dir }

                                    upSwap =
                                        { tempUpSwap1 | item = tempLeftSwap1.item, dir = tempLeftSwap1.dir }

                                    updatedListOfGrids =
                                        List.map (\x -> updateAllSwappedGrids x newCurrent leftSwap upSwap) allGrids
                                in
                                updatedListOfGrids

                            else if List.member Left list && List.member Down list then
                                let
                                    tempLeftSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy, Tuple.second currentGrid.xy - 1 ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    tempDownSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy + 1, Tuple.second currentGrid.xy ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    newCurrent =
                                        { currentGrid | item = Field, dir = Nothing, status = Current }

                                    leftSwap =
                                        { tempLeftSwap1 | item = tempDownSwap1.item, dir = tempDownSwap1.dir }

                                    downSwap =
                                        { tempDownSwap1 | item = tempLeftSwap1.item, dir = tempLeftSwap1.dir }

                                    updatedListOfGrids =
                                        List.map (\x -> updateAllSwappedGrids x newCurrent leftSwap downSwap) allGrids
                                in
                                updatedListOfGrids

                            else if List.member Up list && List.member Down list then
                                let
                                    tempUpSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy - 1, Tuple.second currentGrid.xy ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    tempDownSwap1 =
                                        getNormalGrid allGrids { xy = ( Tuple.first currentGrid.xy + 1, Tuple.second currentGrid.xy ), status = currentGrid.status, item = currentGrid.item, dir = currentGrid.dir }

                                    newCurrent =
                                        { currentGrid | item = Field, dir = Nothing, status = Current }

                                    upSwap =
                                        { tempUpSwap1 | item = tempDownSwap1.item, dir = tempDownSwap1.dir }

                                    downSwap =
                                        { tempDownSwap1 | item = tempUpSwap1.item, dir = tempUpSwap1.dir }

                                    updatedListOfGrids =
                                        List.map (\x -> updateAllSwappedGrids x newCurrent upSwap downSwap) allGrids
                                in
                                updatedListOfGrids

                            else
                                allGrids
                    in
                    swappedGrids

                Nothing ->
                    allGrids

        newListOfGrids =
            gridsToswap
    in
    newListOfGrids


updateAllSwappedGrids : Grid -> Grid -> Grid -> Grid -> Grid
updateAllSwappedGrids updateThis update1 update2 update3 =
    if updateThis.xy == update1.xy then
        update1

    else if updateThis.xy == update2.xy then
        update2

    else if updateThis.xy == update3.xy then
        update3

    else
        updateThis


duplicateItem : List Grid -> Grid -> Grid -> List Grid
duplicateItem grids current selected =
    let
        helper =
            case current.dir of
                Just list ->
                    let
                        getRight =
                            if List.member Right list then
                                let
                                    getGrid =
                                        getNormalGrid grids { xy = ( Tuple.first current.xy, Tuple.second current.xy + 1 ), status = NonSelected, item = Field, dir = Nothing }

                                    changeItem =
                                        { getGrid | item = selected.item, dir = selected.dir }
                                in
                                changeItem

                            else
                                current

                        getLeft =
                            if List.member Left list then
                                let
                                    getGrid =
                                        getNormalGrid grids { xy = ( Tuple.first current.xy, Tuple.second current.xy - 1 ), status = NonSelected, item = Field, dir = Nothing }

                                    changeItem =
                                        { getGrid | item = selected.item, dir = selected.dir }
                                in
                                changeItem

                            else
                                current

                        getUp =
                            if List.member Up list then
                                let
                                    getGrid =
                                        getNormalGrid grids { xy = ( Tuple.first current.xy - 1, Tuple.second current.xy ), status = NonSelected, item = Field, dir = Nothing }

                                    changeItem =
                                        { getGrid | item = selected.item, dir = selected.dir }
                                in
                                changeItem

                            else
                                current

                        getDown =
                            if List.member Down list then
                                let
                                    getGrid =
                                        getNormalGrid grids { xy = ( Tuple.first current.xy + 1, Tuple.second current.xy ), status = NonSelected, item = Field, dir = Nothing }

                                    changeItem =
                                        { getGrid | item = selected.item, dir = selected.dir }
                                in
                                changeItem

                            else
                                current

                        temp =
                            if getRight == current then
                                grids

                            else
                                List.map (\x -> changeCurr x getRight) grids

                        temp2 =
                            if getLeft == current then
                                temp

                            else
                                List.map (\x -> changeCurr x getLeft) temp

                        temp3 =
                            if getUp == current then
                                temp2

                            else
                                List.map (\x -> changeCurr x getUp) temp2

                        temp4 =
                            if getDown == current then
                                temp3

                            else
                                List.map (\x -> changeCurr x getDown) temp3
                    in
                    temp4

                Nothing ->
                    let
                        newCurr =
                            { current | item = selected.item, dir = selected.dir }

                        newList =
                            List.map (\x -> changeCurr x newCurr) grids
                    in
                    newList
    in
    helper


changeCurr : Grid -> Grid -> Grid
changeCurr gridInList newCurr =
    if gridInList.xy == newCurr.xy then
        newCurr

    else
        gridInList
