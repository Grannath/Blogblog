module View.Utils exposing (dateString)

import String exposing (join, padLeft)
import Time.Date exposing (Weekday(..))
import Time.ZonedDateTime as DateTime exposing (ZonedDateTime, day, hour, minute, month, year, abbreviation)


dateString : ZonedDateTime -> String
dateString date =
    weekday date
        ++ ", the "
        ++ (join "."
                [ paddedDateComp day date
                , paddedDateComp month date
                , toString (year date)
                ]
           )
        ++ ", "
        ++ (join ":"
                [ paddedDateComp hour date
                , paddedDateComp minute date
                ]
           )
        ++ " ("
        ++ abbreviation date
        ++ ")"


paddedDateComp : (ZonedDateTime -> Int) -> ZonedDateTime -> String
paddedDateComp comp date =
    comp date |> toString |> padLeft 2 '0'


weekday : ZonedDateTime -> String
weekday date =
    case DateTime.weekday date of
        Mon ->
            "Monday"

        Tue ->
            "Tuesday"

        Wed ->
            "Wednesday"

        Thu ->
            "Thursday"

        Fri ->
            "Friday"

        Sat ->
            "Saturday"

        Sun ->
            "Sunday"
