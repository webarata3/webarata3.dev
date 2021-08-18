port module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser exposing (Document)
import Browser.Dom exposing (Element)
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task
import Url



-- PORTS


port getOffset : String -> Cmd msg


port getOffsetReceiver : (Offset -> msg) -> Sub msg


port getComputedHeight : String -> Cmd msg


port getComputedHeightReceiver : (Int -> msg) -> Sub msg



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


type alias SkillTab =
    { id : String
    , title : String
    , level : String
    , content : Html Msg
    }


type alias SkillContentElem =
    { height : Int
    , r : Int
    , top : Int
    , left : Int
    , betweenDeg : Int
    }


type alias SkillTitleElem =
    { width : Int
    , deg : Int
    }


type alias Offset =
    { top : Int
    , left : Int
    }


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
    , skillContent : SkillContentElem
    , skillTitleHeight : Int
    , skillTitles : List SkillTitleElem
    , isSkillTabFirstView : Bool
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
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
                , ( "skills", 180 )
                , ( "link", 90 )
                ]
      , currentDeg = 0
      , maybeBodyCss = Nothing
      , skillContent =
            { height = 0
            , r = 0
            , top = 0
            , left = 0
            , betweenDeg = 0
            }
      , skillTitleHeight = 0
      , skillTitles = []
      , isSkillTabFirstView = True
      }
    , Task.attempt Init <| Browser.Dom.getElement "main"
    )



-- UPDATE


type Msg
    = Init (Result Browser.Dom.Error Browser.Dom.Element)
    | InitSkills (Result Browser.Dom.Error Browser.Dom.Element)
    | RetGetSkillOffset Offset
    | RetGetComputedHeight Int
    | TabButtonWidth (Result Browser.Dom.Error (List Browser.Dom.Element))
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | SkillTabClick Int


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
                        , ( "skills"
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
            , Task.attempt InitSkills <| Browser.Dom.getElement "skillTabContent"
            )

        Init (Err _) ->
            ( model, Cmd.none )

        InitSkills (Ok elem) ->
            ( { model
                | skillContent =
                    { height = floor elem.element.height
                    , r = floor elem.element.width // 2
                    , top = 0
                    , left = 0
                    , betweenDeg = 360 / toFloat (List.length getSkillTabs) |> floor
                    }
              }
            , getOffset "skillTabContent"
            )

        InitSkills (Err _) ->
            ( model, Cmd.none )

        RetGetSkillOffset offset ->
            ( { model
                | skillContent =
                    { height = model.skillContent.height
                    , r = model.skillContent.r
                    , top = offset.top
                    , left = offset.left
                    , betweenDeg = model.skillContent.betweenDeg
                    }
              }
            , getComputedHeight "skillTab0"
            )

        RetGetComputedHeight height ->
            let
                tabIds =
                    List.map (\e -> e.id) getSkillTabs
            in
            ( { model
                | skillTitleHeight = height
              }
            , List.map getTabButtonWidth tabIds
                |> Task.sequence
                |> Task.attempt TabButtonWidth
            )

        TabButtonWidth (Ok elems) ->
            let
                widths =
                    List.map (\e -> e.element.width) elems
                        |> List.map (\e -> floor e)

                height =
                    List.map (\e -> e.element.height) elems
                        |> List.head
                        |> Maybe.withDefault 0.0
                        |> floor

                count =
                    List.range 0 <| List.length widths - 1

                degs =
                    List.map (\c -> c * model.skillContent.betweenDeg) count

                skillTitles =
                    List.map2
                        (\w d ->
                            { width = w
                            , deg = d
                            }
                        )
                        widths
                        degs
            in
            ( { model
                | skillTitleHeight = height
                , skillTitles = skillTitles
              }
            , Cmd.none
            )

        TabButtonWidth (Err e) ->
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

        SkillTabClick clickDeg ->
            let
                changeDeg =
                    360 - clickDeg

                skillTitles =
                    List.map
                        (\e ->
                            { deg = modBy 360 (e.deg + changeDeg + 360)
                            , width = e.width
                            }
                        )
                        model.skillTitles
            in
            ( { model
                | skillTitles = skillTitles
                , isSkillTabFirstView = False
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ getOffsetReceiver RetGetSkillOffset
        , getComputedHeightReceiver RetGetComputedHeight
        ]



-- FUNCTIONS


getTabButtonWidth : String -> Task.Task Browser.Dom.Error Browser.Dom.Element
getTabButtonWidth id =
    Browser.Dom.getElement id


urlToRoute : Url.Url -> String
urlToRoute url =
    case url.fragment of
        Just "work" ->
            "work"

        Just "skills" ->
            "skills"

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


getSkillTabs : List SkillTab
getSkillTabs =
    [ { id = "skillTab0"
      , title = "Java"
      , level = "★★★"
      , content =
            div []
                [ p [ class "skill__content-p" ] [ text "java 1.1から使っています。" ]
                , p [ class "skill__content-p" ]
                    [ span [] [ text "10年程度Webアプリを作っていました。Webのフレームワークとしては" ]
                    , a [ href "https://struts.apache.org/", class "main__link" ] [ text "SAStruts" ]
                    , span [] [ text "、" ]
                    , a [ href "https://spring.io/", class "main__link" ] [ text "Spring MVC" ]
                    , span [] [ text "あたり。ORマッパは" ]
                    , a [ href "http://s2dao.seasar.org/ja/", class "main__link" ] [ text "S2Dao" ]
                    , span [] [ text "と、" ]
                    , a [ href "https://blog.mybatis.org/", class "main__link" ] [ text "MyBatis" ]
                    , span [] [ text "を使っていました。" ]
                    ]
                , p [ class "skill__content-p" ]
                    [ span [] [ text "最近は" ]
                    , a [ href "https://micronaut.io/", class "main__link" ] [ text "Micronaut" ]
                    , span [] [ text "を使うことが多いです。" ]
                    ]
                , p [ class "skill__content-p" ]
                    [ a [ href "https://openjdk.java.net/jeps/392", class "main__link" ] [ text "Packaging Tool" ]
                    , span [] [ text "が出てからはSwingアプリを作ったりもしています。" ]
                    ]
                ]
      }
    , { id = "skillTab1"
      , title = "HTML / CSS"
      , level = "★★★"
      , content = div [] []
      }
    , { id = "skillTab2"
      , title = "JavaScript"
      , level = "★★☆"
      , content = div [] []
      }
    , { id = "skillTab3"
      , title = "Elm"
      , level = "★★☆"
      , content = div [] []
      }
    , { id = "skillTab4"
      , title = "Python"
      , level = "★☆☆"
      , content = div [] []
      }
    , { id = "skillTab5"
      , title = "Flutter / Dart"
      , level = "★☆☆"
      , content = div [] []
      }
    ]



-- VIEW


view : Model -> Document Msg
view model =
    { title = "URL Interceptor"
    , body =
        [ viewHeader
        , viewMain model
        ]
    }


viewHeader : Html Msg
viewHeader =
    header [ class "header" ]
        [ div [ class "header__innder" ]
            [ h1 [ class "header__title" ]
                [ img [ src "image/neko.png", class "header__logo" ] []
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
        , viewSkills model
        , viewLink model
        ]


viewMainHeader : String -> Html Msg
viewMainHeader currentPage =
    let
        allLinks =
            [ { page = "home"
              , linkText = "ホーム"
              }
            , { page = "work"
              , linkText = "作ったもの"
              }
            , { page = "skills"
              , linkText = "skills"
              }
            , { page = "link"
              , linkText = "リンク"
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
                            [ a [ href "#skills", class "main__nav-link" ] [ text "skills" ]
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
                            [ href "#", class "footer__link" ]
                            [ text "プライバシーポリシー" ]
                        , a
                            [ href "#", class "footer__link" ]
                            [ text "クレジット" ]
                        ]
                    , p []
                        [ small [] [ text "©2021 webarata3（ARATA Shinichi）" ]
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
            , div [] [ text "作ったもの" ]
            ]
        ]


viewSkills : Model -> Html Msg
viewSkills model =
    let
        skillTabs =
            getSkillTabs
    in
    article
        (class "main__content" :: mainStyle model "skills")
        [ viewMainHeader model.currentPage
        , section []
            [ div [ class "skill" ]
                [ viewSkillTabButtons model skillTabs
                , div
                    [ id "skillTabContent"
                    , class "skill__tab-content"
                    ]
                    []
                ]
            ]
        ]


viewSkillTabButtons : Model -> List SkillTab -> Html Msg
viewSkillTabButtons model skillTabs =
    let
        skillTitles =
            if List.isEmpty model.skillTitles then
                List.repeat (List.length skillTabs)
                    { width = 0
                    , deg = 0
                    }

            else
                model.skillTitles
    in
    ul [ class "skill__tab-buttons" ] <|
        List.map2 (viewSkillTabButton model) skillTabs skillTitles


viewSkillTabButton : Model -> SkillTab -> SkillTitleElem -> Html Msg
viewSkillTabButton model skillTab skillTitle =
    let
        skillContent =
            model.skillContent

        isSkillTabFirstView =
            model.isSkillTabFirstView

        styleWidth =
            if skillTitle.width == 0 then
                []

            else
                [ style "width" <| String.fromInt skillTitle.width ++ "px" ]

        animationStyle =
            if isSkillTabFirstView then
                []

            else
                [ style "transition" "transform 0.5s ease-out" ]

        appendStyle =
            List.append styleWidth animationStyle

        baseLeft =
            skillContent.left + skillContent.r
    in
    li
        (List.append
            appendStyle
            [ id skillTab.id
            , class "skill__tab-button"
            , style "top" <| String.fromInt (skillContent.top - model.skillTitleHeight // 2) ++ "px"
            , style "left" <| String.fromInt (baseLeft - (skillTitle.width // 2)) ++ "px"
            , style "transform" <| "rotate(" ++ String.fromInt skillTitle.deg ++ "deg)"
            , style "transform-origin" <| "0 " ++ String.fromInt skillContent.r ++ "px"
            , onClick <| SkillTabClick skillTitle.deg
            ]
        )
        [ p
            (List.append animationStyle
                [ class "skill__tab-button-inner"
                , style "transform" <| "rotate(-" ++ String.fromInt skillTitle.deg ++ "deg)"
                , style "transform-origin" "0 0"
                ]
            )
            [ text skillTab.title ]
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
