module Pages.Guide exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Utils.Global exposing (..)



----MODEL----


type alias Model =
    { pageIndex : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { pageIndex = 1 }, Cmd.none )



---UPDATE----


type Msg
    = Next Int
    | Undo Int


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Next newIndex ->
            if model.pageIndex < 6 then
                ( { model | pageIndex = newIndex + 1 }, Cmd.none )

            else
                ( model, Cmd.none )

        Undo newIndex ->
            if model.pageIndex > 1 then
                ( { model | pageIndex = newIndex - 1 }, Cmd.none )

            else
                ( model, Cmd.none )



---- VIEW ----


view : Model -> Element Msg
view model =
    column [ width fill, height fill ]
        [ row [ height fill, width fill, paddingXY 10 10, centerX, spacing 40, Background.color colors.blue ]
            [ column [ alignLeft, alignTop, centerX, height fill, width (px 400), Background.color colors.lightblue, paddingXY 20 20, Border.rounded 15, spacing 30, Border.width 2 ]
                [ Element.image [ alignTop, centerX, height (px 50), width (px 50) ] { src = "/elm.png", description = "nah" }
                , el [ alignTop, centerX, Font.size 50 ] (text "Tutorial")
                , row [ centerX ]
                    [ Input.button styles.nextButton
                        { onPress = Just (Undo model.pageIndex)
                        , label = text "<"
                        }
                    , Element.link styles.playButton
                        { label = text "Menu"
                        , url = "Home"
                        }
                    , Input.button styles.nextButton
                        { onPress = Just (Next model.pageIndex)
                        , label = text ">"
                        }
                    ]
                , formView model
                ]
            ]
        , globalBottomView
        ]


formView : Model -> Element Msg
formView model =
    row [ centerY, centerX, spacing 10, padding 15, Border.width 2, Border.rounded 15, Background.color colors.greener ]
        [ column
            [ centerX
            , centerY
            , spacing 10
            , width (px 250)
            , height fill
            ]
            (case model.pageIndex of
                1 ->
                    firstPage

                2 ->
                    secondPage

                3 ->
                    thirdPage

                4 ->
                    fourthPage

                5 ->
                    fifthPage

                _ ->
                    sixthPage
            )
        ]


firstPage : List (Element Msg)
firstPage =
    [ el [ centerX ] (text "Welcome! \n  You can use the <- and -> \narrows to go through\n this tutorial ")
    , el [ centerX ] (text "Level example:")
    , Element.image [ width (px 170), height (px 200), centerX ]
        { src = "/tutorialPicture.png"
        , description = "level example"
        }
    , el [ centerX ] (text "You can move around the map\n pressing W,S,A,D keys.\n You can restart the level\n with R key\n by pressing Enter you \n can move the item from field\n  to the inventary\n  ")
    ]


secondPage : List (Element Msg)
secondPage =
    [ el [ centerX ] (text "the game field comprises \nthe fields, which are either \nempty or with an item.")
    , el [ centerX ] (text "You can see one additional \nfield which represents \nthe inventory. ")
    , el [ centerX ] (text "Some items from game fields\n can be stored into inventory\n in order to unleash the field:")
    , row [ centerX ]
        [ Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/Bomb.png"
            , description = "Bomb Example"
            }
        , Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/Stick.png"
            , description = "Stick Example"
            }
        ]
    , el [ centerX ] (text "You can place the item\n into the empty field or you can\n activate another item with\n the item from inventory.")
    , el [ centerX ] (text "When you already have\n an item in inventory you are\n unable to move through \nthe fields with items!\n The exception is a stick,\n which is necessary to \nactivate the dynamit,\n so you can move through it.")
    ]


thirdPage : List (Element Msg)
thirdPage =
    [ el [ centerX ] (text "The main task is to reach\n the following item:")
    , Element.image [ width (px 50), height (px 50), centerX ]
        { src = "/win.png"
        , description = "Win Example"
        }
    , el [ centerX ] (text "The winning cup is surrounded\n by the walls \nat the beginning of the level:")
    , Element.image [ width (px 50), height (px 50), centerX ]
        { src = "/wall.png"
        , description = "nah"
        }
    , el [ centerX ] (text " You can use dynamite\n which cas destroy every\n item and opens the field\n for you: ")
    , Element.image [ width (px 50), height (px 50), centerX ]
        { src = "/bomb.png"
        , description = "nah"
        }
    ]


fourthPage : List (Element Msg)
fourthPage =
    [ el [ centerX ] (text "Each activation field has\n its own defined direction\n in which it is activated:")
    , Element.image [ width (px 50), height (px 50), centerX ]
        { src = "/tutorialPicture2.png"
        , description = "Dynamite example"
        }
    , el [ centerX ] (text "In this case, dynamite destroys\n the bottom and right field\n items when activated.")
    , el [ centerX ] (text "We activate dynamite with \na stick by placing a stick from \nthe inventory on dynamite.")
    , el [ centerX ] (text "An explosion of dynamite\n can activate another dynamite!")
    ]


fifthPage : List (Element Msg)
fifthPage =
    [ el [ centerX ] (text "The game contains \nseveral other activation items:")
    , row [ centerX ]
        [ Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/copy.png"
            , description = "Copy Example"
            }
        , Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/swap.png"
            , description = "Swap Example"
            }
        ]
    , el [ centerX ] (text "These are immediately \nactivated with the Enter key\n in the defined directions.")
    , el [ centerX ] (text "When we activate the first item,\n the item will be replaced with\n the item from the inventory. \nMorover the item from inventory\n will be copied in \nthe defined directions.")
    , el [ centerX ] (text "The second item can only\n be activated with empty \ninventory. It always has \n2 defined directions, in which\n it looks and swaps the items")
    ]


sixthPage : List (Element Msg)
sixthPage =
    [ el [ centerX ] (text "During the game \nwe count the number of moves\n that will be displayed \nafter passing the level.\n Good Luck! ")
    , Element.link styles.playButton
        { label = text "PLAY!"
        , url = "Levels"
        }
    ]
