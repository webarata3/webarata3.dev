module Credit exposing (Model, Msg, getCredits, update, viewCredit, viewCreditLink)

import Delay
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref)


type alias Credit =
    { title : String
    , url : String
    , license : String
    }


type alias Model =
    { isViewCredit : Bool
    , isCreditAnim : Bool
    , credits : List Credit
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
            , div [ class "credit__content" ] <|
                List.map viewLicense model.credits
            ]
        ]


viewLicense : Credit -> Html Msg
viewLicense credit =
    div [ class "credit__license" ]
        [ h2 [ class "credit__license-title" ]
            [ a
                [ href credit.url
                , class "main__link"
                ]
                [ text credit.title ]
            ]
        , pre [ class "credit__license-content" ]
            [ text credit.license ]
        ]


getCredits : List Credit
getCredits =
    [ { title = "Elm"
      , url = "https://elm-lang.org/"
      , license = """
Copyright 2012-present Evan Czaplicki

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""
      }
    , { title = "Font Awesome Free License"
      , url = "https://fontawesome.com/license/free"
      , license = "CC BY 4.0 License"
      }
    , { title = "Noto Sans Japanese"
      , url = "https://fonts.google.com/noto/specimen/Noto+Sans+JP?query=Noto+san"
      , license = "Open Font License"
      }
    , { title = "Poiret One"
      , url = "https://fonts.google.com/specimen/Poiret+One?query=Poiret"
      , license = "Open Font License"
      }
    ]
