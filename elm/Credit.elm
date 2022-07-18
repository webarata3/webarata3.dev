module Credit exposing (Model, Msg, update, viewCredit, viewCreditLink)

import Delay
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref)


type alias Model =
    { isViewCredit : Bool
    , isCreditAnim : Bool
    }


type Msg
    = ClickCredit
    | OpenCredit
    | CreditCloseClick
    | CreditCloseAnimEnd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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


onTransitionEnd : msg -> Attribute msg
onTransitionEnd message =
    on "transitionend" <| Json.Decode.succeed message


viewCreditLink : Html Msg
viewCreditLink =
    a
        [ href "#", class "main__link", onClick ClickCredit ]
        [ text "クレジット" ]


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
            (classList
                [ ( "credit__main", True )
                , ( "credit__main-open", model.isCreditAnim )
                ]
                :: (if
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
