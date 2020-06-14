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
            if model.pageIndex < 5 then
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

                _ ->
                    fifthPage
            )
        ]


firstPage : List (Element Msg)
firstPage =
    [ el [ centerX ] (text "Welcome!")
    , Element.image [ width (px 170), height (px 200), centerX ]
        { src = "/tutorialPicture.png"
        , description = "level example"
        }
    , el [ centerX ] (text "W S A D - Move around\n R - Reset level\n Enter - Pick up/Drop/Activate \nitem  ")
    ]


thirdPage : List (Element Msg)
thirdPage =
    [ el [ centerX ] (text "ARROWS!!!")
    , row [ centerX ]
        [ Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/Stick.png"
            , description = "Stick Example"
            }
        , el [] (text " + ")
        , Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/tutorialPicture2.png"
            , description = "Tutorial Example"
            }
        ]
    , el [ centerX ] (text "Destroys the items\n in left and bottom ")
    , row [ centerX ]
        [ Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/Stick.png"
            , description = "Stick Example"
            }
        , el [] (text " OR ")
        , Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/Bomb.png"
            , description = "Tutorial Example"
            }
        , el [] (text " + ")
        , Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/tutorialPicture4.png"
            , description = "Tutorial Example"
            }
        ]
    , el [ centerX ] (text "Displaces Duplicator \nand copies item\n in left and right")
    , row [ centerX ]
        [ Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/Stick.png"
            , description = "Stick Example"
            }
        , Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/tutorialPicture5.png"
            , description = "Tutorial Example"
            }
        , Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/Bomb.png"
            , description = "Tutorial Example"
            }
        ]
    , el [ centerX ] (text "Swaps the items")
    ]


secondPage : List (Element Msg)
secondPage =
    [ el [ centerX ] (text "You want to get this:")
    , Element.image [ width (px 50), height (px 50), centerX ]
        { src = "/win.png"
        , description = "Win Example"
        }
    , el [ centerX ] (text "It's surrounded by this:")
    , Element.image [ width (px 50), height (px 50), centerX ]
        { src = "/wall.png"
        , description = "nah"
        }
    , el [ centerX ] (text "Destroy them with this: ")
    , row [ centerX ]
        [ Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/Stick.png"
            , description = "Bomb Example"
            }
        , el [ centerX ] (text " + ")
        , Element.image [ width (px 50), height (px 50), centerX ]
            { src = "/Bomb.png"
            , description = "Stick Example"
            }
        ]
    , el [ centerX ] (text "Duplicate items with this: ")
    , Element.image [ width (px 50), height (px 50), centerX ]
        { src = "/copy.png"
        , description = "Copy Example"
        }
    , el [ centerX ] (text "Swap items with this: ")
    , Element.image [ width (px 50), height (px 50), centerX ]
        { src = "/swap.png"
        , description = "Swap Example"
        }
    ]


fourthPage : List (Element Msg)
fourthPage =
    [ el [ centerX ] (text "Attention!!")
    , Element.image [ width (px 170), height (px 200), centerX ]
        { src = "/tutorialPicture3.png"
        , description = "Dynamite example"
        }
    , el [ centerX ] (text "You have item in inventory!\n Now you can't move.\n BUT")
    , Element.image [ width (px 170), height (px 200), centerX ]
        { src = "/tutorialPicture6.png"
        , description = "Dynamite example"
        }
    , el [ centerX ] (text "You can move with match stick\n through bombs.")
    ]


fifthPage : List (Element Msg)
fifthPage =
    [ el [ centerX ] (text "You moves are counts.\n I'm sure you will handle this!\n Have fun.")
    , Element.link styles.playButton
        { label = text "PLAY!"
        , url = "Levels"
        }
    ]
