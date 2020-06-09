module Utils.Global exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html exposing (Html)



---- VIEW ----


globalBottomView : Element msg
globalBottomView =
    row [ width fill, Background.color colors.gray, spacing 32, paddingXY 5 5 ]
        [ el [ Font.size 24, Font.bold, centerX ] (text "2020") ]


link : String -> Element msg
link label =
    Element.link styles.link
        { label = text label
        , url = label
        }


linkLevel : String -> Int -> Element msg
linkLevel label level =
    Element.link [ centerX, centerY ]
        { label = text ("Level " ++ String.fromInt level)
        , url = label
        }



-- STYLES


colors : { blue : Color, black : Color, white : Color, red : Color, lightblue : Color, lighterblue : Color, green : Color, greener : Color, customC : Color, gray : Color }
colors =
    { white = rgb 1 1 1
    , black = rgb255 225 176 126
    , red = rgb255 85 91 110
    , blue = rgb255 0 78 137
    , lightblue = rgb255 137 176 174
    , lighterblue = rgb255 229 190 158
    , green = rgb 0 1 0
    , greener = rgb255 166 156 172
    , customC = rgb255 186 145 73
    , gray = rgb255 175 180 195
    }


styles :
    { link : List (Element.Attribute msg)
    , menuButton : List (Element.Attribute msg)
    , playButton : List (Element.Attribute msg)
    , button : List (Element.Attribute msg)
    , badButton : List (Element.Attribute msg)
    , nextButton : List (Element.Attribute msg)
    }
styles =
    { link =
        [ Font.underline
        , Font.color colors.blue
        , mouseOver [ alpha 0.6 ]
        ]
    , menuButton =
        [ Font.color colors.white
        , Font.variant Font.smallCaps
        , Font.size 30
        , Font.center
        , Background.color colors.black
        , mouseOver [ alpha 0.6 ]
        , width (px 200)
        , height (px 50)
        , paddingXY 25 10
        , Border.rounded 20
        , centerX
        , centerY
        , spacing 20
        , Border.width 1
        ]
    , playButton =
        [ Font.color colors.white
        , Font.variant Font.smallCaps
        , Font.size 30
        , Font.center
        , Background.color colors.customC
        , mouseOver [ alpha 0.6 ]
        , width (px 200)
        , height (px 50)
        , paddingXY 25 10
        , Border.rounded 20
        , centerX
        , centerY
        , Border.width 1
        ]
    , button =
        [ Font.color colors.white
        , Background.color colors.greener
        , Border.rounded 4
        , centerX
        , centerY
        , width (px 200)
        , height (px 50)
        , paddingXY 24 10
        , mouseOver [ alpha 0.6 ]
        , Border.rounded 20
        , Border.width 1
        ]
    , nextButton =
        [ Font.color colors.white
        , Font.variant Font.smallCaps
        , Font.size 30
        , Background.color colors.black
        , mouseOver [ alpha 0.6 ]
        , width (px 50)
        , height (px 50)
        , paddingXY 25 10
        , Border.rounded 20
        , centerX
        , centerY
        , spacing 20
        , Border.width 1
        ]
    , badButton =
        [ Font.color colors.white
        , Background.color colors.red
        , Border.rounded 4
        , width (px 200)
        , height (px 50)
        , paddingXY 24 10
        , Border.rounded 20
        , centerX
        , centerY
        , Border.width 1
        ]
    }
