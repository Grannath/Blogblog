module TimeExtra exposing (fromExtendedIso, toExtendedIso, zonedDateTime)

import List exposing (head)
import Maybe exposing (andThen, withDefault, map)
import Regex exposing (HowMany(AtMost), find, regex, split)
import Time.TimeZone exposing (TimeZone, name)
import Time.TimeZones exposing (fromName)
import Time.ZonedDateTime exposing (ZonedDateTime, fromISO8601, timeZone, toISO8601)
import Combine exposing (Parser, (<$>), (>>=))


zoneRegex =
    regex "\\[(.*)\\]"


fromExtendedIso : String -> Result String ZonedDateTime
fromExtendedIso iso =
    let
        zone =
            getZone iso

        timestamp =
            getTimestamp iso
    in
        case zone of
            Ok z ->
                case timestamp of
                    Ok ts ->
                        fromISO8601 z ts

                    Err msg ->
                        Err msg

            Err msg ->
                Err msg


getZone : String -> Result String TimeZone
getZone iso =
    let
        match =
            head <| find (AtMost 1) zoneRegex iso
    in
        case match of
            Just m ->
                head m.submatches
                    |> withDefault Nothing
                    |> andThen fromName
                    |> map Ok
                    |> withDefault (Err ("Did not recognize time zone found in string " ++ iso ++ "."))

            Nothing ->
                Err ("No time zone information in " ++ iso ++ ".")


getTimestamp : String -> Result String String
getTimestamp iso =
    let
        match =
            head <| split (AtMost 1) zoneRegex iso
    in
        case match of
            Just m ->
                Ok m

            Nothing ->
                Err ("No date-time information found in " ++ iso ++ ".")


toExtendedIso : ZonedDateTime -> String
toExtendedIso dateTime =
    toISO8601 dateTime
        ++ "["
        ++ (name <| timeZone dateTime)
        ++ "]"


zonedDateTime : Parser s ZonedDateTime
zonedDateTime =
    fromExtendedIso
        <$> Combine.while (\_ -> True)
        >>= (\res ->
                case res of
                    Ok zdt ->
                        Combine.succeed zdt

                    Err msg ->
                        Combine.fail msg
            )
