module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Element as Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html as Html
import Html.Attributes as Attributes
import Json.Decode as Decode
import Json.Encode as Encode
import Pages.Guide
import Pages.Home
import Pages.Info
import Pages.Levels
import Ports
import Time
import Types exposing (User)
import Url
import Url.Parser as Parser exposing ((</>), Parser, custom, fragment, map, oneOf, s, top)
import Utils.Global exposing (..)



---- MODEL ----


type Page
    = Home Pages.Home.Model
    | Info Pages.Info.Model
    | Levels Pages.Levels.Model
    | Guide Pages.Guide.Model
    | Global
    | NotFound


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , page : Page
    , user : User
    }


unknownUser : User
unknownUser =
    { username = "Player"
    , level = 1
    }


init : Maybe User -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeUser url key =
    let
        user =
            case maybeUser of
                Nothing ->
                    unknownUser

                Just u ->
                    u
    in
    ( Model key url Global user, Ports.play (Encode.bool True) )



---- UPDATE ----


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Pages.Home.Msg
    | LevelsMsg Pages.Levels.Msg
    | InfoMsg Pages.Info.Msg
    | GuideMsg Pages.Guide.Msg
    | PlayMe Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            stepUrl url model

        LevelsMsg msg ->
            case model.page of
                Levels levels ->
                    let
                        ( newChildModel, newChildCmd ) =
                            Pages.Levels.update msg levels

                        ( newModel, newCmd ) =
                            stepLevels model ( newChildModel, newChildCmd )
                    in
                    if newChildModel.state then
                        let
                            newUser : User
                            newUser =
                                if newChildModel.pressed == newModel.user.level then
                                    if newChildModel.pressed == 10 then
                                        newModel.user

                                    else
                                        { username = newModel.user.username, level = newModel.user.level + 1 }

                                else
                                    newModel.user
                        in
                        ( { newModel | user = newUser }, Cmd.batch [ newCmd, encodeUser newUser ] )

                    else
                        ( newModel, newCmd )

                _ ->
                    ( model, Cmd.none )

        InfoMsg msg ->
            case model.page of
                Info info ->
                    let
                        ( newChildModel, newChildCmd ) =
                            Pages.Info.update msg info

                        ( newModel, newCmd ) =
                            stepInfo model ( newChildModel, newChildCmd )
                    in
                    if String.isEmpty newChildModel.msg then
                        ( newModel, newCmd )

                    else
                        let
                            newUser : User
                            newUser =
                                { username = newChildModel.localUser.username, level = newChildModel.localUser.level }
                        in
                        ( { newModel | user = newUser }, Cmd.batch [ newCmd, encodeUser newUser ] )

                _ ->
                    ( model, Cmd.none )

        GuideMsg msg ->
            case model.page of
                Guide guide ->
                    stepGuide model (Pages.Guide.update msg guide)

                _ ->
                    ( model, Cmd.none )

        HomeMsg msg ->
            case model.page of
                Home home ->
                    stepHome model (Pages.Home.update msg home)

                _ ->
                    ( model, Cmd.none )

        PlayMe _ ->
            ( model, Ports.play (Encode.bool True) )


stepUrl : Url.Url -> Model -> ( Model, Cmd Msg )
stepUrl url model =
    let
        parser =
            oneOf
                [ route (s "Home") (stepHome model (Pages.Home.init ()))
                , route (s "Guide") (stepGuide model (Pages.Guide.init ()))
                , route (s "Info") (stepInfo model (Pages.Info.init model.user))
                , route (s "Levels") (stepLevels model (Pages.Levels.init model.user))
                ]
    in
    case Parser.parse parser url of
        Just answer ->
            answer

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )


stepHome : Model -> ( Pages.Home.Model, Cmd Pages.Home.Msg ) -> ( Model, Cmd Msg )
stepHome model ( home, cmds ) =
    ( { model | page = Home home }
    , Cmd.map HomeMsg cmds
    )


stepGuide : Model -> ( Pages.Guide.Model, Cmd Pages.Guide.Msg ) -> ( Model, Cmd Msg )
stepGuide model ( guide, cmds ) =
    ( { model | page = Guide guide }
    , Cmd.map GuideMsg cmds
    )


stepInfo : Model -> ( Pages.Info.Model, Cmd Pages.Info.Msg ) -> ( Model, Cmd Msg )
stepInfo model ( info, cmds ) =
    ( { model | page = Info info }
    , Cmd.map InfoMsg cmds
    )


stepLevels : Model -> ( Pages.Levels.Model, Cmd Pages.Levels.Msg ) -> ( Model, Cmd Msg )
stepLevels model ( levels, cmds ) =
    ( { model | page = Levels levels }
    , Cmd.map LevelsMsg cmds
    )



{- https://github.com/elm/package.elm-lang.org/blob/master/src/frontend/Main.elm -}


route : Parser a b -> a -> Parser (b -> c) c
route parser handler =
    Parser.map handler parser



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 5000 PlayMe
        , case model.page of
            NotFound ->
                Sub.none

            Home homeModel ->
                Sub.none

            Guide guideModel ->
                Sub.none

            Info infoModel ->
                Sub.none

            Levels levelsModel ->
                Sub.map LevelsMsg (Pages.Levels.subscriptions levelsModel)

            Global ->
                Sub.none
        ]



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    { title = "BCGame"
    , body =
        [ Html.audio
            [ Attributes.id "game-song"

            -- src can be a local file too.
            , Attributes.src "sraft.mp3"
            , Attributes.controls False
            ]
            []
        , Element.layout [] (searchView model)
        ]
    }


searchView : Model -> Element Msg
searchView model =
    case model.page of
        NotFound ->
            globalHomeView

        Home homeModel ->
            Element.map HomeMsg (Pages.Home.view homeModel)

        Guide guideModel ->
            Element.map GuideMsg (Pages.Guide.view guideModel)

        Info infoModel ->
            Element.map InfoMsg (Pages.Info.view infoModel)

        Levels levelsModel ->
            Element.map LevelsMsg (Pages.Levels.view levelsModel)

        Global ->
            globalHomeView


globalHomeView : Element Msg
globalHomeView =
    column [ width fill, height fill ]
        [ row [ height fill, width fill, paddingXY 10 10, centerX, spacing 40, Background.color colors.blue ]
            [ column [ alignLeft, alignTop, centerX, height fill, width (px 400), Background.color colors.lightblue, paddingXY 20 20, Border.rounded 15, spacing 30, Border.width 2 ]
                [ Element.image [ alignTop, centerX, height (px 50), width (px 50) ] { src = "/elm.png", description = "nah" }
                , el [ alignTop, centerX, Font.size 50 ] (text "Gamesa")
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



----PORTS----


encodeUser : User -> Cmd msg
encodeUser user =
    let
        json =
            Encode.object
                [ ( "username", Encode.string user.username )
                , ( "level", Encode.int user.level )
                ]
    in
    Ports.storeUser json



---- PROGRAM ----


main : Program (Maybe User) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
