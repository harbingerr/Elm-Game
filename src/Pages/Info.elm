module Pages.Info exposing (..)

import Browser
import Char exposing (..)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html exposing (Html)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import String exposing (..)
import Types exposing (..)
import Utils.Global exposing (..)



----MODEL----


type alias Model =
    { localUser : User
    , msg : String
    }


init : User -> ( Model, Cmd Msg )
init user =
    ( { localUser = user, msg = "" }
    , Cmd.none
    )



---UPDATE----


type Msg
    = Name String
    | Levels Int
    | UpdateInfo User


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Name name ->
            let
                newUser =
                    { username = name, level = model.localUser.level }
            in
            ( { model | localUser = newUser }, Cmd.none )

        Levels level ->
            let
                newUser =
                    { username = model.localUser.username, level = level }
            in
            ( { model | localUser = newUser }, Cmd.none )

        UpdateInfo user ->
            ( { model | msg = "Succesfully updated" }, Cmd.none )



---- VIEW ----


view : Model -> Element Msg
view model =
    column [ width fill, height fill ]
        [ row [ height fill, width fill, paddingXY 10 10, centerX, spacing 40, Background.color colors.blue ]
            [ column [ alignLeft, alignTop, centerX, height fill, width (px 400), Background.color colors.lightblue, paddingXY 20 20, Border.rounded 15, spacing 30, Border.width 2 ]
                [ Element.image [ alignTop, centerX, height (px 50), width (px 50) ] { src = "/elm.png", description = "nah" }
                , el [ alignTop, centerX, Font.size 50 ] (text "Info")
                , Element.link styles.playButton
                    { label = text "Menu"
                    , url = "Home"
                    }
                , formView model
                , showMsg model
                ]
            ]
        , globalBottomView
        ]


showMsg : Model -> Element Msg
showMsg model =
    el [ centerX ] (text model.msg)


formView : Model -> Element Msg
formView model =
    row [ centerY, centerX, spacing 10, padding 15, Border.width 2, Border.rounded 15, Background.color colors.gray3 ]
        [ column
            [ centerX
            , centerY
            , spacing 10
            , width (px 250)
            , height fill
            ]
            [ el [ centerX ] (text "Info")
            , Input.username [ centerY, Border.rounded 15, Border.width 2, Font.center ]
                { label = Input.labelHidden "Name"
                , onChange = \newName -> Name newName
                , placeholder = Just (Input.placeholder [] (text "username"))
                , text = model.localUser.username
                }
            , showSlider model
            , Input.button
                styles.menuButton
                { onPress = Just (UpdateInfo model.localUser)
                , label = text "Update"
                }
            ]
        ]


showSlider : Model -> Element Msg
showSlider model =
    Input.slider
        [ centerY
        , Element.behindContent
            (Element.el
                [ Element.width Element.fill
                , Element.height (Element.px 2)
                , Element.centerY
                , Background.color colors.blue
                , Border.rounded 2
                ]
                Element.none
            )
        ]
        { onChange = round >> Levels
        , label =
            Input.labelAbove []
                (text ("Unlocked levels: " ++ String.fromInt model.localUser.level))
        , min = 1
        , max = 10
        , step = Just 1
        , value = Basics.toFloat model.localUser.level
        , thumb =
            Input.defaultThumb
        }
