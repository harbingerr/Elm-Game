module Pages.Home exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html exposing (Html)
import Utils.Global as G exposing (..)



----MODEL----


type alias Model =
    { start : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { start = 1 }, Cmd.none )



---UPDATE----


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        None ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Element Msg
view model =
    column [ width fill, height fill ]
        [ row [ height fill, width fill, paddingXY 10 10, centerX, spacing 40, Background.color colors.blue ]
            [ column [ alignLeft, alignTop, centerX, height fill, width (px 400), Background.color colors.lightblue, paddingXY 20 20, Border.rounded 15, spacing 30, Border.width 2 ]
                [ Element.image [ alignTop, centerX, height (px 50), width (px 50) ] { src = "/elm.png", description = "nah" }
                , el [ alignTop, centerX, Font.size 50 ] (text "Menu")
                , Element.link styles.playButton
                    { label = text "PLAY"
                    , url = "Levels"
                    }
                , Element.link styles.menuButton
                    { label = text "TUTORIAL"
                    , url = "Guide"
                    }
                , Element.link styles.menuButton
                    { label = text "INFO"
                    , url = "Info"
                    }
                ]
            ]
        , globalBottomView
        ]
