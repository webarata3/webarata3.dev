module Work exposing (Model, Msg, WorkTab, update, viewWorkMain)

import Array exposing (Array)
import Credit exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref)



-- MODEL


type alias WorkTab =
    { title : String
    , maybeWebSite : Maybe String
    , maybeGitHub : Maybe String
    , contentType : String
    , techItems : List String
    , content : List (Html Msg)
    }


type alias Model =
    { workTabIndex : Int
    }



-- UPDATE


type Msg
    = WorkTabClick Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WorkTabClick index ->
            ( { model
                | workTabIndex = index
              }
            , Cmd.none
            )



-- FUNCTIONS


getWorkTabs : Array WorkTab
getWorkTabs =
    Array.fromList
        [ { title = "ICa残高照会"
          , maybeWebSite = Just "https://play.google.com/store/apps/details?id=dev.webarata3.app.ica_reader"
          , maybeGitHub = Just "https://github.com/webarata3/ica_reader"
          , contentType = "Androidアプリ"
          , techItems = [ "Flutter", "Dart" ]
          , content =
                [ div []
                    [ p [ class "work__description-text" ] [ text "北陸鉄道バスのICaの残高照会アプリです。" ]
                    , p [ class "work__description-text" ] [ text "以前も作っていましたが、Flutterで書き直しました。" ]
                    ]
                , img [ class "work__image", src "image/ica_reader.webp" ] []
                ]
          }
        , { title = "クリーン白山"
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



-- VIEW


viewWorkMain : Model -> Html Msg
viewWorkMain model =
    let
        workTabs =
            getWorkTabs
    in
    section [ class "work" ]
        [ viewWorkTabs model.workTabIndex workTabs
        , Array.indexedMap (viewWorkTabContent model.workTabIndex) workTabs
            |> Array.toList
            |> div [ class "work__tab-contents" ]
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
