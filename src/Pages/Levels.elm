module Pages.Levels exposing (..)

import Browser
import Browser.Events
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Game.GameRoute as GameRoute exposing (..)
import Game.GameUtils as GameUtils exposing (..)
import Html exposing (Html)
import Json.Decode as Decode
import Json.Encode as Encode
import Types exposing (..)
import Utils.Global as G exposing (..)



----MODEL----


getWidth : Model -> Int
getWidth model =
    100 * Tuple.second model.playField + Tuple.second model.playField + Tuple.second model.playField * 5 + 4


levels : List Int
levels =
    List.range 1 10


getMax : Int
getMax =
    case List.head (List.reverse levels) of
        Just h ->
            h

        Nothing ->
            10


type alias Model =
    { localUser : User
    , pressed : Int
    , moves : Int
    , grids : List Types.Grid
    , currentGrid : Types.Grid
    , selectedGrid : Types.Grid
    , state : Bool
    , playField : ( Int, Int )
    , errorMsg : String
    }


init : User -> ( Model, Cmd Msg )
init user =
    ( { localUser = user
      , pressed = 0
      , moves = 0
      , grids = [ { xy = ( 0, 0 ), status = NonSelected, item = Field, dir = Nothing } ]
      , currentGrid = { xy = ( 0, 0 ), status = NonSelected, item = Field, dir = Nothing }
      , selectedGrid = { xy = ( 0, 0 ), status = NonSelected, item = Field, dir = Nothing }
      , state = False
      , playField = ( 0, 0 )
      , errorMsg = "W, S, A, D - move\n R- reset level\n Enter - pick up"
      }
    , Cmd.none
    )



---UPDATE----


type Msg
    = InitLevel Int
    | DisabledButtonPressed
    | IgnoreKey
    | Move Types.Direction
    | ChangeSelected
    | InitIt


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        InitLevel level ->
            ( updateNewModel model level, Cmd.none )

        DisabledButtonPressed ->
            ( model, Cmd.none )

        IgnoreKey ->
            ( model, Cmd.none )

        Move direction ->
            ( changeDirection model direction, Cmd.none )

        ChangeSelected ->
            changeSelected model

        InitIt ->
            update (InitLevel model.pressed) model


updateNewModel : Model -> Int -> Model
updateNewModel model pressedLevel =
    let
        newList =
            GameRoute.generateLevelGrid pressedLevel

        newModel =
            { localUser = model.localUser
            , pressed = pressedLevel
            , moves = 0
            , grids = newList
            , currentGrid = GameUtils.getCurrentGrid newList
            , selectedGrid = GameRoute.getSelectedGrid pressedLevel
            , state = False
            , playField = GameRoute.getPlayField pressedLevel
            , errorMsg = "-"
            }
    in
    newModel



{-
   change direction ->
     possible cases:
       Selected empty, can move on empty field.
       Selected not empty, can't move on the field
       next move is OOM check
       next move is on field with wall
-}


changeDirection : Model -> Direction -> Model
changeDirection model direction =
    let
        oldCurr =
            model.currentGrid

        newPossition =
            {- check if we can move there -}
            if checkOOM oldCurr direction model.playField then
                { oldCurr | xy = ( Tuple.first oldCurr.xy + Tuple.first direction, Tuple.second oldCurr.xy + Tuple.second direction ) }

            else
                oldCurr

        newCurrent =
            let
                new =
                    getNewGrid model.grids newPossition oldCurr

                valid =
                    if new.item == SuperWall then
                        oldCurr

                    else if new.item == Bomb && model.selectedGrid.item == Stick then
                        new

                    else if (new.item == Stick || new.item == Bomb || new.item == Swap) && model.selectedGrid.item /= Field then
                        oldCurr

                    else
                        new
            in
            valid

        newGrids =
            if newCurrent == oldCurr then
                model.grids

            else
                List.map (\x -> updateGrids x newCurrent oldCurr model.selectedGrid) model.grids

        newError =
            if oldCurr == newCurrent then
                "You cant't move there!"

            else
                "-"

        newModel =
            { localUser = model.localUser
            , pressed = model.pressed
            , moves = model.moves + 1
            , grids = newGrids
            , currentGrid = newCurrent
            , selectedGrid = model.selectedGrid
            , state = False
            , playField = model.playField
            , errorMsg = newError
            }
    in
    newModel



{-
   change sleected ->
     possible cases:
       Field is empty, Selected is empty
       Field is empty, Selected not empty
       Field has item, selected is empty -> change of  status
       Field has activate item and selected is empty
       Field has activate item selected is not empty
       Field has item, selected has item, they interact
       Field has Win item, the game ends
-}


changeSelected : Model -> ( Model, Cmd Msg )
changeSelected model =
    let
        curr =
            model.currentGrid

        sel =
            model.selectedGrid

        newGrids =
            {- Field has activate item and selected is empty -}
            if curr.item == Swap then
                swapItemActivated model.grids curr
                {- Field has activate item selected is not empty -}

            else if curr.item == Duplicator then
                duplicateItem model.grids curr sel
                {- Field is empty, Selected is empty
                   Field is empty, Selected not empty
                -}

            else if curr.item == Bomb && sel.item == Stick then
                getDestroyedGrids model.grids curr model.playField

            else if curr.item == Field && sel.item /= Field then
                List.map (\x -> swapSelectedItemWithField x sel) model.grids
                {- Field has item, selected is empty -> change of  status -}

            else if curr.item /= Field && sel.item == Field then
                List.map (\x -> swapAndChangeStatus x sel) model.grids
                {- Field has item, selected has item, they interact -}

            else
                model.grids

        newCurrent =
            {- Field has bomb selected has stick --empty them -}
            if (curr.item == Bomb && sel.item == Stick) || curr.item == Swap then
                { curr | item = Field, dir = Nothing, status = Current }

            else if model.currentGrid.item == Duplicator then
                { curr | item = sel.item, dir = sel.dir }

            else
                getCurrentGrid newGrids

        newSelected : Grid
        newSelected =
            {- Field has bombu selected has stick --empty them -}
            if (curr.item == Bomb && sel.item == Stick) || curr.item == Duplicator then
                { sel | item = Field, dir = Nothing }

            else if curr.item == Swap then
                sel

            else
                {- Field is empty Selected not empty -} {- Filed has item, selected is empty -> change status -} {- Fiel has item, selected has item, just swap -}
                { xy = model.selectedGrid.xy, status = model.selectedGrid.status, item = model.currentGrid.item, dir = model.currentGrid.dir }

        newestGrids =
            List.map (\x -> swapAndChangeStatus x newCurrent) newGrids

        newLevel : User
        newLevel =
            if model.pressed == model.localUser.level then
                if model.pressed == 10 then
                    model.localUser

                else
                    { username = model.localUser.username, level = model.localUser.level + 1 }

            else
                model.localUser

        newModel =
            if model.currentGrid.item == Win then
                ( { localUser = newLevel
                  , pressed = model.pressed
                  , moves = model.moves
                  , grids = newestGrids
                  , currentGrid = newCurrent
                  , selectedGrid = newSelected
                  , state = True
                  , playField = model.playField
                  , errorMsg = "You WIN!"
                  }
                , Cmd.none
                )

            else
                ( { localUser = model.localUser
                  , pressed = model.pressed
                  , moves = model.moves + 1
                  , grids = newestGrids
                  , currentGrid = newCurrent
                  , selectedGrid = newSelected
                  , state = False
                  , playField = model.playField
                  , errorMsg = "-"
                  }
                , Cmd.none
                )
    in
    newModel



---- SUB ----


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.state then
        Sub.none

    else
        Browser.Events.onKeyDown keyDecoder


{-| Decoder for the pressed key
-}
keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map keyToMessage (Decode.field "key" Decode.string)


{-| Classify pressed key and fire proper message.
-}
keyToMessage : String -> Msg
keyToMessage string =
    case String.uncons string of
        Just ( char, "" ) ->
            case String.toLower <| String.fromChar char of
                "a" ->
                    Move directions.left

                "d" ->
                    Move directions.right

                "w" ->
                    Move directions.up

                "s" ->
                    Move directions.down

                "r" ->
                    InitIt

                _ ->
                    IgnoreKey

        _ ->
            case string of
                "Enter" ->
                    ChangeSelected

                _ ->
                    IgnoreKey



---- VIEW ----


view : Model -> Element Msg
view model =
    column [ width fill, height fill ]
        [ row [ width fill, paddingXY 10 10, centerX, spacing 40, Background.color G.colors.blue ]
            [ el [ alignLeft, alignTop, centerX, height fill, width (px 400), Background.color G.colors.lightblue, paddingXY 20 20, Border.rounded 15, Border.width 2 ] (viewLevels model levels)
            , viewCurrentLevel model
            ]
        , G.globalBottomView
        ]


viewLevels : Model -> List Int -> Element Msg
viewLevels levelsFinished listOfLevels =
    column [ spacing 5, alignTop, centerX, height fill ]
        (viewMenu :: viewTutorial :: List.indexedMap (viewLevel levelsFinished) listOfLevels)


viewTutorial : Element msg
viewTutorial =
    Element.link styles.menuButton
        { label = text "Tutorial"
        , url = "Guide"
        }


viewMenu : Element msg
viewMenu =
    Element.link styles.playButton
        { label = text "Menu"
        , url = "Home"
        }


viewLevel : Model -> Int -> Int -> Element Msg
viewLevel levelsFinished currentLevelIndex currentLevel =
    if currentLevel < levelsFinished.localUser.level + 1 then
        viewFinishedLevel currentLevel levelsFinished

    else
        viewUnfinishedLevel currentLevel


viewFinishedLevel : Int -> Model -> Element Msg
viewFinishedLevel level model =
    Input.button
        G.styles.button
        { onPress =
            if model.pressed == level then
                Nothing

            else
                Just (InitLevel level)
        , label = text ("Level " ++ String.fromInt level)
        }


viewUnfinishedLevel : Int -> Element Msg
viewUnfinishedLevel level =
    Input.button
        G.styles.badButton
        { onPress = Nothing
        , label = text ("Level " ++ String.fromInt level)
        }


viewCurrentLevel : Model -> Element Msg
viewCurrentLevel model =
    if model.pressed == 0 then
        Element.none

    else
        column [ alignTop, centerX, spacing 20 ] [ el [ centerX, Font.bold ] (text ("LEVEL" ++ String.fromInt model.pressed)), el [ centerX, Font.italic, Font.color G.colors.red ] (text model.errorMsg), generateRow model, viewDebuge model ]


generateRow : Model -> Element Msg
generateRow model =
    wrappedRow [ spacing 5, padding 5, showStatus model, Border.width 1, Background.color (rgb255 186 145 73), centerX, centerY, width (px (getWidth model)) ] (List.map GameUtils.generateSrc model.grids)


viewGrid : Maybe Types.Grid -> Element msg
viewGrid grid =
    case grid of
        Just g ->
            generateSrc g

        Nothing ->
            Element.none


viewDebuge : Model -> Element msg
viewDebuge model =
    if model.pressed == 0 then
        Element.none

    else
        column [ centerX, centerY, paddingXY 15 15 ] [ showSelected model, showMoves model, showGrid model ]


showMoves : Model -> Element msg
showMoves model =
    text ("Moves:" ++ String.fromInt model.moves)


showSelected : Model -> Element msg
showSelected model =
    generateSrc model.selectedGrid


showGrid : Model -> Element msg
showGrid model =
    column [ centerX, centerY ]
        [ text ("Width:" ++ String.fromInt (Tuple.first model.playField) ++ ",Height" ++ String.fromInt (Tuple.second model.playField))
        , text ("Curr. position:" ++ String.fromInt (Tuple.first model.currentGrid.xy) ++ "," ++ String.fromInt (Tuple.second model.currentGrid.xy))
        ]


showStatus : Model -> Attribute Msg
showStatus model =
    if model.state then
        Element.inFront
            (column
                [ Border.width 3
                , Background.color G.colors.lightblue
                , centerX
                , centerY
                , spacing 10
                , width (px 250)
                , height (px 300)
                , Border.rounded 15
                ]
                [ el [ centerX, paddingXY 10 10 ] (text ("Congrats, " ++ model.localUser.username))
                , el [ centerX, centerY ] (text ("Moves: " ++ String.fromInt model.moves))
                , generateSentence model
                , generateButton model
                ]
            )

    else
        Element.inFront Element.none


generateButton : Model -> Element Msg
generateButton model =
    if model.pressed /= getMax then
        Input.button
            G.styles.badButton
            { onPress = Just (InitLevel (model.pressed + 1))
            , label = text "Next level"
            }

    else
        Input.button
            G.styles.badButton
            { onPress = Just (InitLevel model.pressed)
            , label = text "Reset level"
            }


generateSentence : Model -> Element msg
generateSentence model =
    if model.pressed /= getMax then
        el [ centerX, centerY ] (text ("Unlocked levels :" ++ String.fromInt model.localUser.level))

    else
        el [ centerX, centerY ] (text "Thank you for playing!!")
