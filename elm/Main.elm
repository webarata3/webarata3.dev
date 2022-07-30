module Main exposing (Model, Msg(..), init, main, mainRotateStyle, mainStyle, subscriptions, update, urlToRoute, view, viewHeader, viewHome, viewLink, viewMain, viewMainHeader, viewMainHeaderLink, viewSkill, viewWork)

import Browser exposing (Document)
import Browser.Dom
import Browser.Navigation as Nav
import Credit exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Skill
import Task
import Url
import Work



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , currentPage : String
    , maybeCenter :
        Maybe
            { x : Int
            , y : Int
            }
    , locationDict :
        Dict
            String
            { deg : String
            , left : String
            , top : String
            }
    , pageDegDict : Dict String Int
    , currentDeg : Int
    , maybeBodyCss :
        Maybe
            { transform : String
            , transformOrigin : String
            }
    , workModel : Work.Model
    , skillModel : Skill.Model
    , creditModel : Credit.Model
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , url = url
      , currentPage = "Home"
      , maybeCenter = Nothing
      , locationDict = Dict.empty
      , pageDegDict =
            Dict.fromList
                [ ( "", 0 )
                , ( "home", 0 )
                , ( "work", -90 )
                , ( "skill", 180 )
                , ( "link", 90 )
                ]
      , currentDeg = 0
      , maybeBodyCss = Nothing
      , workModel =
            { workTabIndex = 0
            }
      , skillModel =
            { skillContent =
                { height = 0
                , r = 0
                , top = 0
                , left = 0
                , betweenDeg = 0
                }
            , skillTitleHeight = 0
            , skillTitles = []
            , isSkillTabFirstView = True
            , selectedSkillTabId = "skillTab0"
            }
      , creditModel =
            { isViewCredit = False
            , isCreditAnim = False
            , credits = getCredits
            }
      }
    , Task.attempt Init <| Browser.Dom.getElement "main"
    )



-- UPDATE


type Msg
    = Init (Result Browser.Dom.Error Browser.Dom.Element)
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | WorkMsg Work.Msg
    | SkillMsg Skill.Msg
    | CreditMsg Credit.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init (Ok elem) ->
            let
                y =
                    floor elem.element.y
            in
            ( { model
                | maybeCenter =
                    Just
                        { x = 2000 + y
                        , y = 2000 + y
                        }
                , locationDict =
                    Dict.fromList
                        [ ( "home"
                          , { deg = "0"
                            , top = "0"
                            , left = "0"
                            }
                          )
                        , ( "work"
                          , { deg = "90deg"
                            , top = String.fromInt (2000 + y) ++ "px"
                            , left = String.fromInt (2000 + y) ++ "px"
                            }
                          )
                        , ( "skill"
                          , { deg = "180deg"
                            , top = String.fromInt ((2000 + y) * 2) ++ "px"
                            , left = "0"
                            }
                          )
                        , ( "link"
                          , { deg = "270deg"
                            , top = String.fromInt (2000 + y) ++ "px"
                            , left = "-" ++ String.fromInt (2000 + y) ++ "px"
                            }
                          )
                        ]
              }
            , Browser.Dom.getElement "skillTabContent"
                |> Task.attempt Skill.InitSkill
                |> Cmd.map SkillMsg
            )

        Init (Err _) ->
            ( model, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                page =
                    urlToRoute url

                maybeBodyCss =
                    if page == model.currentPage then
                        model.maybeBodyCss

                    else
                        let
                            deg =
                                Maybe.withDefault 0 <|
                                    Dict.get page model.pageDegDict

                            y =
                                case model.maybeCenter of
                                    Just center ->
                                        center.y

                                    Nothing ->
                                        0
                        in
                        Just
                            { transform = "rotate(" ++ String.fromInt deg ++ "deg)"
                            , transformOrigin = "0px " ++ String.fromInt y ++ "px"
                            }
            in
            ( { model
                | url = url
                , currentPage = page
                , maybeBodyCss = maybeBodyCss
              }
            , Cmd.none
            )

        WorkMsg msg_ ->
            let
                ( m_, cmd ) =
                    Work.update msg_ model.workModel
            in
            ( { model | workModel = m_ }, Cmd.map WorkMsg cmd )

        SkillMsg msg_ ->
            let
                ( m_, cmd ) =
                    Skill.update msg_ model.skillModel
            in
            ( { model | skillModel = m_ }, Cmd.map SkillMsg cmd )

        CreditMsg msg_ ->
            let
                ( m_, cmd ) =
                    Credit.update msg_ model.creditModel
            in
            ( { model | creditModel = m_ }, Cmd.map CreditMsg cmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Skill.getOffsetReceiver Skill.RetGetSkillOffset
            |> Sub.map SkillMsg
        , Skill.getComputedHeightReceiver Skill.RetGetComputedHeight
            |> Sub.map SkillMsg
        ]



-- FUNCTIONS


urlToRoute : Url.Url -> String
urlToRoute url =
    case url.fragment of
        Just "work" ->
            "work"

        Just "skill" ->
            "skill"

        Just "link" ->
            "link"

        _ ->
            "home"


mainStyle : Model -> String -> List (Attribute msg)
mainStyle model name =
    case Dict.get name model.locationDict of
        Just location ->
            [ style "position" "absolute"
            , style "left" location.left
            , style "top" location.top
            , style "transform" <| "rotate(" ++ location.deg ++ ")"
            , style "transformOrigin" "left top"
            ]

        Nothing ->
            []


mainRotateStyle : Model -> List (Attribute msg)
mainRotateStyle model =
    case model.maybeBodyCss of
        Just bodyCss ->
            [ style "transform" bodyCss.transform
            , style "transformOrigin" bodyCss.transformOrigin
            , style "transition" "all 1s ease-out"
            ]

        Nothing ->
            []



-- VIEW


view : Model -> Document Msg
view model =
    let
        pageTitle =
            (if model.currentPage == "Home" then
                ""

             else
                model.currentPage ++ " - "
            )
                ++ "webarata3.dev"
    in
    { title = pageTitle
    , body =
        [ viewHeader
        , viewMain model
        , viewCredit model.creditModel |> Html.map CreditMsg
        ]
    }


viewHeader : Html Msg
viewHeader =
    header [ class "header" ]
        [ div [ class "header__inner" ]
            [ h1 [ class "header__title" ]
                [ img [ src "image/neko.webp", class "header__logo" ] []
                , p [] [ text "webarata3.dev" ]
                ]
            ]
        ]


viewMain : Model -> Html Msg
viewMain model =
    main_
        (List.append
            [ class "main", id "main" ]
            (mainRotateStyle model)
        )
        [ viewHome model
        , viewWork model
        , viewSkill model
        , viewLink model
        ]


viewMainHeader : String -> Html Msg
viewMainHeader currentPage =
    let
        allLinks =
            [ { page = "home"
              , linkText = "home"
              }
            , { page = "work"
              , linkText = "work"
              }
            , { page = "skill"
              , linkText = "skill"
              }
            , { page = "link"
              , linkText = "link"
              }
            ]

        links =
            List.filter (\l -> l.page /= currentPage) allLinks

        currentLink =
            List.filter (\l -> l.page == currentPage) allLinks
                |> List.map (\e -> e.linkText)
                |> List.head
                |> Maybe.withDefault ""
    in
    header [ class "main__header" ]
        [ h2 [ class "main__title" ] [ text currentLink ]
        , nav [ class "nav" ]
            [ ul [ class "header__nav" ] <|
                List.map viewMainHeaderLink links
            ]
        ]


viewMainHeaderLink : { page : String, linkText : String } -> Html Msg
viewMainHeaderLink link =
    li [ class "header__nav-item" ]
        [ a
            [ href <| "#" ++ link.page
            , class "header__nav-link"
            ]
            [ text link.linkText ]
        ]


viewHome : Model -> Html Msg
viewHome model =
    article
        (class "main__content" :: mainStyle model "Home")
        [ div [ class "main__inner" ]
            [ div [ class "home__main" ]
                [ nav [ class "nav main__nav" ]
                    [ ul []
                        [ li [ class "main__nav-item" ]
                            [ a [ href "#work", class "main__nav-link" ] [ text "work" ]
                            ]
                        , li [ class "main__nav-item" ]
                            [ a [ href "#skill", class "main__nav-link" ] [ text "skill" ]
                            ]
                        , li [ class "main__nav-item" ]
                            [ a [ href "#link", class "main__nav-link" ] [ text "link" ]
                            ]
                        ]
                    ]
                , section [ class "history" ]
                    [ h3 [ class "history__title" ] [ text "更新履歴" ]
                    , ul []
                        [ li []
                            [ time [ datetime "2021-08-16", class "history__time" ] [ text "2021/8/16" ]
                            , span [] [ text "デザインの変更" ]
                            ]
                        ]
                    ]
                ]
            , footer [ class "footer" ]
                [ div [ class "footer__inner" ]
                    [ div [ class "footer__credit" ]
                        [ a
                            [ href "#", class "main__link" ]
                            [ text "プライバシーポリシー" ]
                        , viewCreditLink |> Html.map CreditMsg
                        ]
                    , p []
                        [ small [] [ text "©2022 webarata3（ARATA Shinichi）" ]
                        ]
                    ]
                ]
            ]
        ]


viewWork : Model -> Html Msg
viewWork model =
    article
        (class "main__content" :: mainStyle model "work")
        [ div [ class "main__inner" ]
            [ viewMainHeader model.currentPage
            , Work.viewWorkMain model.workModel |> Html.map WorkMsg
            ]
        ]


viewSkill : Model -> Html Msg
viewSkill model =
    article
        (class "main__content" :: mainStyle model "skill")
        [ viewMainHeader model.currentPage
        , div [ class "main__inner" ]
            [ Skill.viewSkillMain model.skillModel |> Html.map SkillMsg
            ]
        ]


viewLink : Model -> Html Msg
viewLink model =
    article
        (class "main__content" :: mainStyle model "link")
        [ div [ class "main__inner" ]
            [ viewMainHeader model.currentPage
            , div [] [ text "リンク" ]
            ]
        ]
