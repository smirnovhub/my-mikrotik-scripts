:global RunAllDateTimeTests2
:global FormatSecondsShortTest
:global FormatSecondsLongTest

:set RunAllDateTimeTests2 do={
    :global InitTestCaseState
    :global FormatSecondsShortTest
    :global FormatSecondsLongTest

    :local res [$InitTestCaseState $1]

    :put "\1B[35m=== STARTING ALL DATE AND TIME TESTS 2 ===\1B[0m"

    # Execute conversion and parsing tests
    :set res [$FormatSecondsShortTest $res]
    :set res [$FormatSecondsLongTest $res]

    :put "\1B[35m=== ALL DATE AND TIME TESTS 2 COMPLETED ===\1B[0m"
    :return $res
}

:set FormatSecondsLongTest do={
    :global InitTestCaseState
    :global RunTestCase
    :global FormatSecondsLong

    :local res [$InitTestCaseState $1]

    :put "Starting FormatSecondsLong tests..."

    # Zero threshold baseline execution
    :set res [$RunTestCase $res $FormatSecondsLong "0" "nothing" "nothing" "0s" "Zero seconds absolute boundary check"]

    # Negative values validation suite
    :set res [$RunTestCase $res $FormatSecondsLong "-1" "nothing" "nothing" "0s" "Negative boundary check (-1s)"]
    :set res [$RunTestCase $res $FormatSecondsLong "-60" "nothing" "nothing" "0s" "Negative minute threshold (-60s)"]
    :set res [$RunTestCase $res $FormatSecondsLong "-3600" "nothing" "nothing" "0s" "Negative hour threshold (-3600s)"]
    :set res [$RunTestCase $res $FormatSecondsLong "-86400" "nothing" "nothing" "0s" "Negative day threshold (-86400s)"]
    :set res [$RunTestCase $res $FormatSecondsLong "-2147483648" "nothing" "nothing" "0s" "Extreme negative int32 boundary check"]

    # Single isolated time components
    :set res [$RunTestCase $res $FormatSecondsLong "45" "nothing" "nothing" "45s" "Pure seconds component evaluation"]
    :set res [$RunTestCase $res $FormatSecondsLong "3600" "nothing" "nothing" "1h" "Pure hours boundary transition validation"]
    :set res [$RunTestCase $res $FormatSecondsLong "86400" "nothing" "nothing" "1d" "Pure days boundary transition validation"]

    # Consecutive sequence combinations
    :set res [$RunTestCase $res $FormatSecondsLong "65" "nothing" "nothing" "1m 5s" "Adjacent minute and second components validation"]
    :set res [$RunTestCase $res $FormatSecondsLong "3615" "nothing" "nothing" "1h 15s" "Hour and second combination skipping empty minutes"]
    :set res [$RunTestCase $res $FormatSecondsLong "90000" "nothing" "nothing" "1d 1h" "Day and hour combination skipping minutes and seconds"]

    # Full display configuration matching documentation pattern
    :set res [$RunTestCase $res $FormatSecondsLong "184510" "nothing" "nothing" "2d 3h 15m 10s" "Complete multi component structural layout validation"]

    # Edge transitions spanning maximum nested limits
    :set res [$RunTestCase $res $FormatSecondsLong "86399" "nothing" "nothing" "23h 59m 59s" "Maximum limit directly prior to days scale shift"]

    # Pure minute boundary
    :set res [$RunTestCase $res $FormatSecondsLong "60" "nothing" "nothing" "1m" "Pure minutes boundary transition validation"]

    # Minute upper limit before hour rollover
    :set res [$RunTestCase $res $FormatSecondsLong "3599" "nothing" "nothing" "59m 59s" "Maximum minute range before hour transition"]

    # Exact hour with remaining minutes
    :set res [$RunTestCase $res $FormatSecondsLong "3660" "nothing" "nothing" "1h 1m" "Hour and minute combination without seconds"]

    # Exact hour with minute and second
    :set res [$RunTestCase $res $FormatSecondsLong "3661" "nothing" "nothing" "1h 1m 1s" "Hour minute second complete combination"]

    # Exact day with remaining minutes
    :set res [$RunTestCase $res $FormatSecondsLong "86460" "nothing" "nothing" "1d 1m" "Day and minute combination without hours and seconds"]

    # Exact day with remaining seconds
    :set res [$RunTestCase $res $FormatSecondsLong "86401" "nothing" "nothing" "1d 1s" "Day and second combination without hours and minutes"]

    # Day minute second combination
    :set res [$RunTestCase $res $FormatSecondsLong "86461" "nothing" "nothing" "1d 1m 1s" "Day minute second combination skipping hours"]

    # Day hour second combination
    :set res [$RunTestCase $res $FormatSecondsLong "90001" "nothing" "nothing" "1d 1h 1s" "Day hour second combination skipping minutes"]

    # Day hour minute combination
    :set res [$RunTestCase $res $FormatSecondsLong "90060" "nothing" "nothing" "1d 1h 1m" "Day hour minute combination without seconds"]

    # All components equal to one
    :set res [$RunTestCase $res $FormatSecondsLong "90061" "nothing" "nothing" "1d 1h 1m 1s" "Minimal nonzero value in every component"]

    # Two complete days minus one second
    :set res [$RunTestCase $res $FormatSecondsLong "172799" "nothing" "nothing" "1d 23h 59m 59s" "Upper boundary immediately before two day transition"]

    # Exact two day boundary
    :set res [$RunTestCase $res $FormatSecondsLong "172800" "nothing" "nothing" "2d" "Exact multi day boundary validation"]

    # Large value with every component
    :set res [$RunTestCase $res $FormatSecondsLong "987654" "nothing" "nothing" "11d 10h 20m 54s" "Large duration decomposition validation"]

    # Large value ending on minutes only
    :set res [$RunTestCase $res $FormatSecondsLong "435000" "nothing" "nothing" "5d 50m" "Large duration with omitted hour and second components"]

    # Double digit day count
    :set res [$RunTestCase $res $FormatSecondsLong "864000" "nothing" "nothing" "10d" "Exact double digit day count validation"]

    # Double digit days with all remaining components
    :set res [$RunTestCase $res $FormatSecondsLong "900610" "nothing" "nothing" "10d 10h 10m 10s" "Double digit day decomposition validation"]

    # Hundred day boundary
    :set res [$RunTestCase $res $FormatSecondsLong "8640000" "nothing" "nothing" "100d" "Exact hundred day boundary validation"]

    # Hundred days with all remaining components
    :set res [$RunTestCase $res $FormatSecondsLong "8680215" "nothing" "nothing" "100d 11h 10m 15s" "Hundred day duration decomposition validation"]

    # Thousand day boundary
    :set res [$RunTestCase $res $FormatSecondsLong "86400000" "nothing" "nothing" "1000d" "Exact thousand day boundary validation"]

    # Thousand days with all remaining components
    :set res [$RunTestCase $res $FormatSecondsLong "86440261" "nothing" "nothing" "1000d 11h 11m 1s" "Thousand day duration decomposition validation"]

    # Large arbitrary duration
    :set res [$RunTestCase $res $FormatSecondsLong "123456789" "nothing" "nothing" "1428d 21h 33m 9s" "Large arbitrary duration conversion validation"]

    # Very large arbitrary duration
    :set res [$RunTestCase $res $FormatSecondsLong "987654321" "nothing" "nothing" "11431d 4h 25m 21s" "Very large duration conversion validation"]

    # Maximum signed 32 bit integer
    :set res [$RunTestCase $res $FormatSecondsLong "2147483647" "nothing" "nothing" "24855d 3h 14m 7s" "Maximum signed thirty two bit integer validation"]

    # One million days
    :set res [$RunTestCase $res $FormatSecondsLong "86400000000" "nothing" "nothing" "1000000d" "Million day exact duration validation"]

    :put "Testing completed."
    :return $res
}

:set FormatSecondsShortTest do={
    :global InitTestCaseState
    :global RunTestCase
    :global FormatSecondsShort

    :local res [$InitTestCaseState $1]

    :put "Starting FormatSecondsShort tests..."

    # Test cases checking various ranges for time optimization display strings
    :set res [$RunTestCase $res $FormatSecondsShort "0" "nothing" "nothing" "0 sec" "Zero seconds threshold evaluation"]
    :set res [$RunTestCase $res $FormatSecondsShort "45" "nothing" "nothing" "45 sec" "Standard seconds scale display validation"]
    :set res [$RunTestCase $res $FormatSecondsShort "60" "nothing" "nothing" "1 min" "Exactly one minute boundary transition"]
    :set res [$RunTestCase $res $FormatSecondsShort "119" "nothing" "nothing" "1 min" "Slightly under two minutes rounding step down"]
    :set res [$RunTestCase $res $FormatSecondsShort "3599" "nothing" "nothing" "59 min" "Maximum scale value prior to hours boundary"]
    :set res [$RunTestCase $res $FormatSecondsShort "3600" "nothing" "nothing" "1 hrs" "Exactly one hour boundary transition step"]
    :set res [$RunTestCase $res $FormatSecondsShort "86399" "nothing" "nothing" "23 hrs" "Maximum scale value prior to days boundary"]
    :set res [$RunTestCase $res $FormatSecondsShort "86400" "nothing" "nothing" "1 days" "Exactly one day layout transition verification"]
    :set res [$RunTestCase $res $FormatSecondsShort "172800" "nothing" "nothing" "2 days" "Multiple whole days execution path check"]

    # Negative and zero values boundary tests
    :set res [$RunTestCase $res $FormatSecondsShort "-1" "nothing" "nothing" "0 sec" "Negative boundary check (-1s)"]
    :set res [$RunTestCase $res $FormatSecondsShort "-60" "nothing" "nothing" "0 sec" "Negative minute threshold (-60s)"]
    :set res [$RunTestCase $res $FormatSecondsShort "-3600" "nothing" "nothing" "0 sec" "Negative hour threshold (-3600s)"]
    :set res [$RunTestCase $res $FormatSecondsShort "-86400" "nothing" "nothing" "0 sec" "Negative day threshold (-86400s)"]
    :set res [$RunTestCase $res $FormatSecondsShort "-2147483648" "nothing" "nothing" "0 sec" "Extreme negative int32 lower bound"]

    :put "Testing completed."
    :return $res
}
