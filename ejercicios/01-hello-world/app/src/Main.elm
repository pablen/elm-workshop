module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode
import RemoteData


---- MODEL ----


type alias Model =
    { planets : RemoteData.WebData (List Planet)
    }


type alias Planet =
    { name : String
    , diameter : String
    }


init : ( Model, Cmd Msg )
init =
    ( { planets = RemoteData.NotAsked
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = FetchPlanetsClicked
    | PlanetsResponse (RemoteData.WebData (List Planet))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchPlanetsClicked ->
            ( { model | planets = RemoteData.Loading }, getPlanets )

        PlanetsResponse response ->
            ( { model | planets = response }, Cmd.none )


getPlanets : Cmd Msg
getPlanets =
    Http.get "https://swapi.co/api/planets/" responseDecoder
        |> RemoteData.sendRequest
        |> Cmd.map PlanetsResponse


responseDecoder : Json.Decode.Decoder (List Planet)
responseDecoder =
    Json.Decode.field "results"
        (Json.Decode.list planetDecoder)


planetDecoder : Json.Decode.Decoder Planet
planetDecoder =
    Json.Decode.map2 Planet
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "diameter" Json.Decode.string)



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Star Wars planets app" ]
        , button [ type_ "button", onClick FetchPlanetsClicked ] [ text "Fetch planets!" ]
        , hr [] []
        , case model.planets of
            RemoteData.NotAsked ->
                p [] [ text "Not asked yet." ]

            RemoteData.Loading ->
                p [] [ text "Loading planets..." ]

            RemoteData.Failure err ->
                p [] [ text "There was an error fetching planets!" ]

            RemoteData.Success planets ->
                ol [] (List.map (\p -> li [] [ text (p.name ++ " - " ++ p.diameter) ]) planets)
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
