:global RunAllDateTimeTests2
:global FormatSecondsShortTest
:global FormatSecondsLongTest

:set RunAllDateTimeTests2 do={
    :global FormatSecondsShortTest
    :global FormatSecondsLongTest

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "\1B[35m=== STARTING ALL DATE AND TIME TESTS 2 ===\1B[0m"

    # Execute conversion and parsing tests
    :set res [$FormatSecondsShortTest $res]
    :set res [$FormatSecondsLongTest $res]

    :put "\1B[35m=== ALL DATE AND TIME TESTS 2 COMPLETED ===\1B[0m"
    :return $res
}

:set FormatSecondsLongTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        :global FormatSecondsLong

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local seconds [:tonum $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local actual [$FormatSecondsLong $seconds]
        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": " . $seconds . "s -> '" . $actual . "'")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": " . $seconds . "s | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
        :return $state
    }

    :put "Starting FormatSecondsLong tests..."

    # Zero threshold baseline execution
    :set res [$RunTestCase $res "0" "" "Zero seconds absolute boundary check"]

    # Single isolated time components
    :set res [$RunTestCase $res "45" "45s" "Pure seconds component evaluation"]
    :set res [$RunTestCase $res "3600" "1h" "Pure hours boundary transition validation"]
    :set res [$RunTestCase $res "86400" "1d" "Pure days boundary transition validation"]

    # Consecutive sequence combinations
    :set res [$RunTestCase $res "65" "1m 5s" "Adjacent minute and second components validation"]
    :set res [$RunTestCase $res "3615" "1h 15s" "Hour and second combination skipping empty minutes"]
    :set res [$RunTestCase $res "90000" "1d 1h" "Day and hour combination skipping minutes and seconds"]

    # Full display configuration matching documentation pattern
    :set res [$RunTestCase $res "184510" "2d 3h 15m 10s" "Complete multi component structural layout validation"]

    # Edge transitions spanning maximum nested limits
    :set res [$RunTestCase $res "86399" "23h 59m 59s" "Maximum limit directly prior to days scale shift"]

    # Pure minute boundary
    :set res [$RunTestCase $res "60" "1m" "Pure minutes boundary transition validation"]

    # Minute upper limit before hour rollover
    :set res [$RunTestCase $res "3599" "59m 59s" "Maximum minute range before hour transition"]

    # Exact hour with remaining minutes
    :set res [$RunTestCase $res "3660" "1h 1m" "Hour and minute combination without seconds"]

    # Exact hour with minute and second
    :set res [$RunTestCase $res "3661" "1h 1m 1s" "Hour minute second complete combination"]

    # Exact day with remaining minutes
    :set res [$RunTestCase $res "86460" "1d 1m" "Day and minute combination without hours and seconds"]

    # Exact day with remaining seconds
    :set res [$RunTestCase $res "86401" "1d 1s" "Day and second combination without hours and minutes"]

    # Day minute second combination
    :set res [$RunTestCase $res "86461" "1d 1m 1s" "Day minute second combination skipping hours"]

    # Day hour second combination
    :set res [$RunTestCase $res "90001" "1d 1h 1s" "Day hour second combination skipping minutes"]

    # Day hour minute combination
    :set res [$RunTestCase $res "90060" "1d 1h 1m" "Day hour minute combination without seconds"]

    # All components equal to one
    :set res [$RunTestCase $res "90061" "1d 1h 1m 1s" "Minimal nonzero value in every component"]

    # Two complete days minus one second
    :set res [$RunTestCase $res "172799" "1d 23h 59m 59s" "Upper boundary immediately before two day transition"]

    # Exact two day boundary
    :set res [$RunTestCase $res "172800" "2d" "Exact multi day boundary validation"]

    # Large value with every component
    :set res [$RunTestCase $res "987654" "11d 10h 20m 54s" "Large duration decomposition validation"]

    # Large value ending on minutes only
    :set res [$RunTestCase $res "435000" "5d 50m" "Large duration with omitted hour and second components"]

    # Double digit day count
    :set res [$RunTestCase $res "864000" "10d" "Exact double digit day count validation"]

    # Double digit days with all remaining components
    :set res [$RunTestCase $res "900610" "10d 10h 10m 10s" "Double digit day decomposition validation"]

    # Hundred day boundary
    :set res [$RunTestCase $res "8640000" "100d" "Exact hundred day boundary validation"]

    # Hundred days with all remaining components
    :set res [$RunTestCase $res "8680215" "100d 11h 10m 15s" "Hundred day duration decomposition validation"]

    # Thousand day boundary
    :set res [$RunTestCase $res "86400000" "1000d" "Exact thousand day boundary validation"]

    # Thousand days with all remaining components
    :set res [$RunTestCase $res "86440261" "1000d 11h 11m 1s" "Thousand day duration decomposition validation"]

    # Large arbitrary duration
    :set res [$RunTestCase $res "123456789" "1428d 21h 33m 9s" "Large arbitrary duration conversion validation"]

    # Very large arbitrary duration
    :set res [$RunTestCase $res "987654321" "11431d 4h 25m 21s" "Very large duration conversion validation"]

    # Maximum signed 32 bit integer
    :set res [$RunTestCase $res "2147483647" "24855d 3h 14m 7s" "Maximum signed thirty two bit integer validation"]

    # One million days
    :set res [$RunTestCase $res "86400000000" "1000000d" "Million day exact duration validation"]

    :put "Testing completed."
    :return $res
}

:set FormatSecondsShortTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        :global FormatSecondsShort

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local seconds [:tonum $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local actual [$FormatSecondsShort $seconds]
        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": " . $seconds . "s -> '" . $actual . "'")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": " . $seconds . "s | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
        :return $state
    }

    :put "Starting FormatSecondsShort tests..."

    # Test cases checking various ranges for time optimization display strings
    :set res [$RunTestCase $res "0" "0 sec" "Zero seconds threshold evaluation"]
    :set res [$RunTestCase $res "45" "45 sec" "Standard seconds scale display validation"]
    :set res [$RunTestCase $res "60" "1 min" "Exactly one minute boundary transition"]
    :set res [$RunTestCase $res "119" "1 min" "Slightly under two minutes rounding step down"]
    :set res [$RunTestCase $res "3599" "59 min" "Maximum scale value prior to hours boundary"]
    :set res [$RunTestCase $res "3600" "1 hrs" "Exactly one hour boundary transition step"]
    :set res [$RunTestCase $res "86399" "23 hrs" "Maximum scale value prior to days boundary"]
    :set res [$RunTestCase $res "86400" "1 days" "Exactly one day layout transition verification"]
    :set res [$RunTestCase $res "172800" "2 days" "Multiple whole days execution path check"]

    :put "Testing completed."
    :return $res
}
