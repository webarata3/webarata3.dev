module Policy exposing (..)

import Browser.Navigation as Nav
import Delay
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref)


type alias Model =
    { key : Nav.Key
    , isViewPolicy : Bool
    , isPolicyAnim : Bool
    }


type Msg
    = ClickPolicy
    | OpenPolicy
    | ClickClosePolicy
    | ClosePolicy
    | CloseAnimEnd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickPolicy ->
            ( { model
                | isViewPolicy = True
              }
            , Delay.after 100 OpenPolicy
            )

        OpenPolicy ->
            ( { model
                | isPolicyAnim = True
              }
            , Cmd.none
            )

        ClickClosePolicy ->
            ( model, Nav.pushUrl model.key "#" )

        ClosePolicy ->
            ( { model
                | isPolicyAnim = False
              }
            , Cmd.none
            )

        CloseAnimEnd ->
            ( { model
                | isViewPolicy = False
              }
            , Cmd.none
            )


onTransitionEnd : msg -> Attribute msg
onTransitionEnd message =
    on "transitionend" <| Json.Decode.succeed message


viewPolicyLink : Html Msg
viewPolicyLink =
    a
        [ href "#policy", class "main__link" ]
        [ text "プライバシーポリシー" ]


viewPolicy : Model -> Html Msg
viewPolicy model =
    div
        [ classList [ ( "main__hidden", not model.isViewPolicy ) ] ]
        [ div
            [ class "policy__wrapper"
            , onClick ClickClosePolicy
            ]
            []
        , div
            (classList
                [ ( "policy__main", True )
                , ( "policy__main-open", model.isPolicyAnim )
                ]
                :: (if
                        model.isViewPolicy
                            && not model.isPolicyAnim
                    then
                        [ onTransitionEnd CloseAnimEnd ]

                    else
                        []
                   )
            )
            [ div [ class "policy__header" ]
                [ h2 [ class "credit__title" ] [ text "プライバシーポリシー" ]
                , svg
                    [ attribute "class" "policy__close-icon"
                    , onClick ClickClosePolicy
                    ]
                    [ use [ xlinkHref "image/close.svg#close" ] [] ]
                ]
            , div [ class "policy__content" ]
                [ p [] [ text "当サイトでは、Googleによるアクセス解析ツール「Googleアナリティクス」を使用しています。このGoogleアナリティクスはデータの収集のためにCookieを使用しています。このデータは匿名で収集されており、個人を特定するものではありません。" ]
                , p []
                    [ span [] [ text "この機能はCookieを無効にすることで収集を拒否することが出来ますので、お使いのブラウザの設定をご確認ください。この規約に関しての詳細は" ]
                    , a
                        [ href "https://marketingplatform.google.com/about/analytics/terms/jp/"
                        , target "_blank"
                        , class "main__link"
                        ]
                        [ text "Googleアナリティクスサービス利用規約のページ" ]
                    , span [] [ text "や" ]
                    , a
                        [ href "https://policies.google.com/technologies/ads?hl=ja"
                        , target "_blank"
                        , class "main__link"
                        ]
                        [ text "Googleポリシーと規約ページ" ]
                    , span [] [ text "をご覧ください。" ]
                    ]
                ]
            ]
        ]
