port module Skill exposing (..)

import Browser.Dom
import Credit exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task



-- PORT


port getOffset : String -> Cmd msg


port getOffsetReceiver : (Offset -> msg) -> Sub msg


port getComputedHeight : String -> Cmd msg


port getComputedHeightReceiver : (Int -> msg) -> Sub msg



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


type alias Model =
    { skillContent : SkillContentElem
    , skillTitleHeight : Int
    , skillTitles : List SkillTitleElem
    , isSkillTabFirstView : Bool
    , selectedSkillTabId : String
    }


type alias Offset =
    { top : Int
    , left : Int
    }



-- UPDATE


type Msg
    = InitSkill (Result Browser.Dom.Error Browser.Dom.Element)
    | RetGetComputedHeight Int
    | RetGetSkillOffset Offset
    | TabButtonWidth (Result Browser.Dom.Error (List Browser.Dom.Element))
    | SkillTabClick String Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

        SkillTabClick skillTabId clickDeg ->
            let
                changeDeg =
                    360 - clickDeg

                skillTitles =
                    List.map
                        (\e ->
                            { deg = e.deg + changeDeg
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



-- FUNCTIONS


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
                [ p [ class "skill__content-p" ] [ text "最低限アプリは作れるレベルです" ]
                ]
      }
    ]


getTabButtonWidth : String -> Task.Task Browser.Dom.Error Browser.Dom.Element
getTabButtonWidth id =
    Browser.Dom.getElement id



-- VIEW


viewSkillMain : Model -> Html Msg
viewSkillMain model =
    let
        skillTabs =
            getSkillTabs

        maybeContent =
            List.filter (\e -> e.id == model.selectedSkillTabId) skillTabs |> List.head
    in
    section []
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
