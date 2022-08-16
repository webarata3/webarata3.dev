module Link exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref)



-- VIEW


viewLinkMain : Html msg
viewLinkMain =
    div []
        [ a
            [ href "https://twitter.com/webarata3"
            , target "_blank"
            , class "work__icon-link"
            ]
            [ svg
                [ attribute "class" "work__icon" ]
                [ use [ xlinkHref "../image/twitter.svg#twitter" ] [] ]
            ]
        , a
            [ href "https://github.com/webarata3"
            , target "_blank"
            , class "work__icon-link"
            ]
            [ svg
                [ attribute "class" "work__icon" ]
                [ use [ xlinkHref "../image/github.svg#github" ] [] ]
            ]
        ]
