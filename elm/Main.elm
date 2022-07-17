port module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Array exposing (Array)
import Browser exposing (Document)
import Browser.Dom
import Browser.Navigation as Nav
import Delay
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref)
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


type alias WorkTab =
    { title : String
    , maybeWebSite : Maybe String
    , maybeGitHub : Maybe String
    , contentType : String
    , techItems : List String
    , content : List (Html Msg)
    }


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
    , workTabIndex : Int
    , selectedSkillTabId : String
    , isViewCredit : Bool
    , isCreditAnim : Bool
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
      , workTabIndex = 0
      , selectedSkillTabId = "skillTab0"
      , isViewCredit = False
      , isCreditAnim = False
      }
    , Task.attempt Init <| Browser.Dom.getElement "main"
    )



-- UPDATE


type Msg
    = Init (Result Browser.Dom.Error Browser.Dom.Element)
    | InitSkill (Result Browser.Dom.Error Browser.Dom.Element)
    | RetGetSkillOffset Offset
    | RetGetComputedHeight Int
    | TabButtonWidth (Result Browser.Dom.Error (List Browser.Dom.Element))
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | WorkTabClick Int
    | SkillTabClick String Int
    | ClickCredit
    | OpenCredit
    | CreditCloseClick
    | CreditCloseAnimEnd


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
            , Task.attempt InitSkill <| Browser.Dom.getElement "skillTabContent"
            )

        Init (Err _) ->
            ( model, Cmd.none )

        InitSkill (Ok elem) ->
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

        InitSkill (Err _) ->
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

        TabButtonWidth (Err _) ->
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

        WorkTabClick index ->
            ( { model
                | workTabIndex = index
              }
            , Cmd.none
            )

        SkillTabClick skillTabId clickDeg ->
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
                , selectedSkillTabId = skillTabId
              }
            , Cmd.none
            )

        ClickCredit ->
            ( { model
                | isViewCredit = True
              }
            , Delay.after 100 OpenCredit
            )

        OpenCredit ->
            ( { model
                | isCreditAnim = True
              }
            , Cmd.none
            )

        CreditCloseClick ->
            ( { model
                | isCreditAnim = False
              }
            , Cmd.none
            )

        CreditCloseAnimEnd ->
            ( { model | isViewCredit = False }
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

        Just "skill" ->
            "skill"

        Just "link" ->
            "link"

        _ ->
            "home"


onTransitionEnd : msg -> Attribute msg
onTransitionEnd message =
    on "transitionend" <| Json.Decode.succeed message


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


getWorkTabs : Array WorkTab
getWorkTabs =
    Array.fromList
        [ { title = "クリーン白山"
          , maybeWebSite = Just "https://clean.hakusan.app"
          , maybeGitHub = Just "https://github.com/webarata3/clean-hakusan"
          , contentType = "Webアプリ"
          , techItems = [ "HTML", "CSS", "Elm", "JavaScript", "Java" ]
          , content =
                [ div []
                    [ p [ class "work__description-text" ] [ text "石川県白山市のゴミ収集日程のアプリです。" ]
                    , p [ class "work__description-text" ]
                        [ span [] [ text "データの取得は市のサイトをスクレイピングしています。スクレイピングには" ]
                        , a
                            [ href "https://jsoup.org"
                            , class "main__link"
                            ]
                            [ text "jsoup" ]
                        , span [] [ text "を使用しています。" ]
                        ]
                    , p [ class "work__description-text" ] [ text "アプリ自体はPWAとして作成しています。" ]
                    ]
                , img [ class "work__image", src "image/clean-hakusan-app.webp" ] []
                ]
          }
        , { title = "KExcelAPI"
          , maybeWebSite = Nothing
          , maybeGitHub = Just "https://github.com/webarata3/KExcelAPI"
          , contentType = "ライブラリ"
          , techItems = [ "Kotlin", "Apache POI" ]
          , content =
                [ div []
                    [ p [ class "workd__description-text" ] [ text "POIをかんたんに扱うためのライブラリです。" ]
                    ]
                ]
          }
        ]


getSkillTabs : List SkillTab
getSkillTabs =
    [ { id = "skillTab0"
      , title = "Java"
      , level = "★★★"
      , content =
            div []
                [ p [ class "skill__content-p" ] [ text "Java 1.1から使っています。" ]
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
      , content =
            div []
                [ p [ class "skill__content-p" ] [ text "このサイトくらいのHTMLやCSSは書けます。" ]
                , p [ class "skill__content-p" ]
                    [ span [] [ text "Webアプリを作っていたこともあるので、HTMLやCSSで困ることは（新しいものは日々勉強ですが）あまりありません。" ]
                    ]
                ]
      }
    , { id = "skillTab2"
      , title = "JavaScript"
      , level = "★★☆"
      , content =
            div []
                [ p [ class "skill__content-p" ] [ text "バニラJavaScriptはそこそこ書けます。" ]
                , p [ class "skill__content-p" ]
                    [ span [] [ text "規模が大きいものを作るときはElmで作ることが多いです。" ]
                    ]
                ]
      }
    , { id = "skillTab3"
      , title = "Elm"
      , level = "★★☆"
      , content =
            div []
                [ p [ class "skill__content-p" ]
                    [ span [] [ text "このサイトや" ]
                    , a [ href "https://clean.hakusan.app/", class "main__link" ] [ text "クリーン白山" ]
                    , span [] [ text "でも使っています。" ]
                    ]
                ]
      }
    , { id = "skillTab4"
      , title = "Python"
      , level = "★☆☆"
      , content =
            div []
                [ p [ class "skill__content-p" ] [ text "文法を一通り勉強して、Flaskを使ったWebアプリを作ったことがあります。" ]
                , p [ class "skill__content-p" ] [ text "使い方を知っているという程度のレベルです。" ]
                ]
      }
    , { id = "skillTab5"
      , title = "Flutter / Dart"
      , level = "★☆☆"
      , content =
            div []
                [ p [ class "skill__content-p" ] [ text "勉強中です。" ]
                ]
      }
    ]



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
        , viewCredit model
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
                        , a
                            [ href "#", class "main__link", onClick ClickCredit ]
                            [ text "クレジット" ]
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
    let
        workTabs =
            getWorkTabs
    in
    article
        (class "main__content" :: mainStyle model "work")
        [ div [ class "main__inner" ]
            [ viewMainHeader model.currentPage
            , section [ class "work" ]
                [ viewWorkTabs model.workTabIndex workTabs
                , Array.indexedMap (viewWorkTabContent model.workTabIndex) workTabs
                    |> Array.toList
                    |> div [ class "work__tab-contents" ]
                ]
            ]
        ]


viewWorkTabs : Int -> Array WorkTab -> Html Msg
viewWorkTabs center workTabs =
    Array.indexedMap (viewWorkTab center) workTabs
        |> Array.toList
        |> ul [ class "work__buttons" ]


viewWorkTab : Int -> Int -> WorkTab -> Html Msg
viewWorkTab center index workTab =
    let
        className =
            "work__buttons-item"
                ++ (if center == index then
                        " work__buttons-item--selected"

                    else
                        ""
                   )
    in
    li
        [ class className
        , onClick <| WorkTabClick index
        ]
        [ text workTab.title ]


viewWorkTabContent : Int -> Int -> WorkTab -> Html Msg
viewWorkTabContent center index workTab =
    let
        webSite =
            viewWorkIcon workTab.maybeWebSite "image/open.svg#open"

        github =
            viewWorkIcon workTab.maybeGitHub "image/github.svg#github"
    in
    div
        (class "work__content"
            :: viewWorkTabStyle center index
        )
        [ h3 [ class "work__content-title" ]
            [ span [] [ text workTab.title ]
            , span [ class "work__content-type" ] [ text workTab.contentType ]
            , div [ class "work__icon-area" ] <|
                List.concat
                    [ webSite
                    , github
                    ]
            ]
        , div [ class "work__tech" ]
            [ h3 [ class "work__tech-title" ] [ text "使用技術" ]
            , ul [ class "work__tech-list" ] <|
                List.map viewWorkTech workTab.techItems
            ]
        , div [ class "work__description" ] workTab.content
        ]


viewWorkIcon : Maybe String -> String -> List (Html Msg)
viewWorkIcon maybeLink iconFile =
    case maybeLink of
        Just link ->
            [ a
                [ href link
                , target "_blank"
                , class "work__icon-link"
                ]
                [ svg
                    [ attribute "class" "work__icon" ]
                    [ use [ xlinkHref iconFile ] [] ]
                ]
            ]

        _ ->
            []


viewWorkTabStyle : Int -> Int -> List (Attribute msg)
viewWorkTabStyle center index =
    let
        left =
            200 + (index - center) * 500

        scale =
            if index == center then
                "1.0"

            else if
                (index - 1 == center)
                    || (index + 1 == center)
            then
                "0.333"

            else
                "0"

        scaleStyle =
            String.concat
                [ "scale("
                , scale
                , ", "
                , scale
                , ")"
                ]

        filter =
            if index == center then
                "none"

            else
                -- "grayscale(80%)"
                "blur(5px)"
    in
    [ style "bottom" "0"
    , String.fromInt left ++ "px" |> style "left"
    , style "transform" scaleStyle
    , style "filter" filter
    ]


viewWorkTech : String -> Html Msg
viewWorkTech techItem =
    li [ class "work__tech-item" ] [ text techItem ]


viewSkill : Model -> Html Msg
viewSkill model =
    let
        skillTabs =
            getSkillTabs

        maybeContent =
            List.filter (\e -> e.id == model.selectedSkillTabId) skillTabs |> List.head
    in
    article
        (class "main__content" :: mainStyle model "skill")
        [ viewMainHeader model.currentPage
        , div [ class "main__inner" ]
            [ section []
                [ div [ class "skill" ]
                    [ viewSkillTabButtons model skillTabs
                    , div
                        [ id "skillTabContent"
                        , class "skill__tab-content"
                        ]
                      <|
                        case maybeContent of
                            Just content ->
                                viewSkillTabContent content

                            Nothing ->
                                []
                    ]
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

        classList =
            if model.selectedSkillTabId == skillTab.id then
                "skill__tab-button-inner skill__tab-button-inner--selected"

            else
                "skill__tab-button-inner"

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
            , onClick <| SkillTabClick skillTab.id skillTitle.deg
            ]
        )
        [ p
            (List.append animationStyle
                [ class classList
                , style "transform" <| "rotate(-" ++ String.fromInt skillTitle.deg ++ "deg)"
                , style "transform-origin" "0 0"
                ]
            )
            [ text skillTab.title ]
        ]


viewSkillTabContent : SkillTab -> List (Html Msg)
viewSkillTabContent skillTab =
    [ div [ class "skill__content" ]
        [ h3 [ class "skill__tab-title" ] [ text skillTab.title ]
        , div [ class "skill__level" ]
            [ span [ class "skill__level-title" ] [ text "レベル" ]
            , span [ class "skill__level-star" ] [ text skillTab.level ]
            ]
        , skillTab.content
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


viewCredit : Model -> Html Msg
viewCredit model =
    div
        [ classList [ ( "main__hidden", not model.isViewCredit ) ] ]
        [ div
            [ class "credit__wrapper"
            , onClick CreditCloseClick
            ]
            []
        , div
            ([ classList
                [ ( "credit__main", True )
                , ( "credit__main-open", model.isCreditAnim )
                ]
             ]
                ++ (if
                        model.isViewCredit
                            && not model.isCreditAnim
                    then
                        [ onTransitionEnd CreditCloseAnimEnd ]

                    else
                        []
                   )
            )
            [ div [ class "credit__header" ]
                [ h2 [ class "credit__title" ] [ text "クレジット" ]
                , svg
                    [ attribute "class" "credit__close-icon"
                    , onClick CreditCloseClick
                    ]
                    [ use [ xlinkHref "image/close.svg#close" ] [] ]
                ]
            ]
        ]
