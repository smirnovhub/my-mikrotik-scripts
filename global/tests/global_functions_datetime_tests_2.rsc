:global RunAllDateTimeTests2
:global FormatSecondsShortTest
:global FormatSecondsLongTest
:global ToUnixTimestampTest

:set RunAllDateTimeTests2 do={
    :global InitTestCaseState
    :global FormatSecondsShortTest
    :global FormatSecondsLongTest
    :global ToUnixTimestampTest

    :local res [$InitTestCaseState $1]

    :put "\1B[35m=== STARTING ALL DATE AND TIME TESTS 2 ===\1B[0m"

    # Execute conversion and parsing tests
    :set res [$FormatSecondsShortTest $res]
    :set res [$FormatSecondsLongTest $res]
    :set res [$ToUnixTimestampTest $res]

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

:set ToUnixTimestampTest do={
    :global InitTestCaseState
    :global RunTestCase
    :global ToUnixTimestamp

    :local res [$InitTestCaseState $1]

    :put "Starting extended ToUnixTimestamp tests..."

    # Epoch (1970)
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-01-01 00:00:00" "nothing" "nothing" 0 "Absolute epoch zero starting point"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-01-01 00:00:01" "nothing" "nothing" 1 "One second past epoch threshold"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-01-01 00:00:59" "nothing" "nothing" 59 "Last second of the first minute"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-01-01 00:01:00" "nothing" "nothing" 60 "Start of the second minute"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-01-01 00:59:59" "nothing" "nothing" 3599 "Last second of the first hour"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-01-01 01:00:00" "nothing" "nothing" 3600 "One hour past epoch threshold"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-01-01 23:59:59" "nothing" "nothing" 86399 "Last second of the first day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-01-02 00:00:00" "nothing" "nothing" 86400 "Start of the second day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-01-31 23:59:59" "nothing" "nothing" 2678399 "End of January 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-02-01 00:00:00" "nothing" "nothing" 2678400 "Start of February 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-02-28 23:59:59" "nothing" "nothing" 5097599 "End of February 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-03-01 00:00:00" "nothing" "nothing" 5097600 "Start of March 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-12-31 23:59:59" "nothing" "nothing" 31535999 "Last second of the epoch year"]

    # First leap year after epoch (1972)
    :set res [$RunTestCase $res $ToUnixTimestamp "1972-02-28 23:59:59" "nothing" "nothing" 68169599 "Second before leap day in 1972"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1972-02-29 00:00:00" "nothing" "nothing" 68169600 "Leap day begins in 1972"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1972-02-29 23:59:59" "nothing" "nothing" 68255999 "Leap day ends in 1972"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1972-03-01 00:00:00" "nothing" "nothing" 68256000 "March begins after leap day in 1972"]

    # Leap year (2024)
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-01-31 23:59:59" "nothing" "nothing" 1706745599 "End of January 2024"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-02-01 00:00:00" "nothing" "nothing" 1706745600 "Start of February 2024"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-02-28 23:59:59" "nothing" "nothing" 1709164799 "Second before leap day February 29"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-02-29 00:00:00" "nothing" "nothing" 1709164800 "Start of the leap day February 29"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-02-29 12:34:56" "nothing" "nothing" 1709210096 "Middle of leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-02-29 23:59:59" "nothing" "nothing" 1709251199 "End of the leap day February 29"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-03-01 00:00:00" "nothing" "nothing" 1709251200 "Start of March right after leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-12-31 23:59:59" "nothing" "nothing" 1735689599 "End of leap year 2024"]

    # Standard year (2025)
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-01-01 00:00:00" "nothing" "nothing" 1735689600 "Start of 2025"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-02-28 23:59:59" "nothing" "nothing" 1740787199 "End of February in a standard year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-03-01 00:00:00" "nothing" "nothing" 1740787200 "Start of March in a standard year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-04-30 23:59:59" "nothing" "nothing" 1746057599 "End of April"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-05-01 00:00:00" "nothing" "nothing" 1746057600 "Start of May"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-06-30 23:59:59" "nothing" "nothing" 1751327999 "End of June"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-07-01 00:00:00" "nothing" "nothing" 1751328000 "Start of July"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-12-31 23:59:59" "nothing" "nothing" 1767225599 "End of 2025"]

    # Arbitrary dates
    :set res [$RunTestCase $res $ToUnixTimestamp "1980-06-15 12:00:00" "nothing" "nothing" 329918400 "Midday in 1980"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1999-12-31 23:59:59" "nothing" "nothing" 946684799 "End of the 20th century"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-01-01 00:00:00" "nothing" "nothing" 946684800 "Start of year 2000"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2026-01-01 00:00:00" "nothing" "nothing" 1767225600 "Start of the year Y2026 baseline"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2026-07-09 15:45:00" "nothing" "nothing" 1783611900 "Arbitrary current mid-year verification"]
    :set res [$RunTestCase $res $ToUnixTimestamp "9999-12-31 23:59:59" "nothing" "nothing" 253402300799 "Last possible date"]

    # Century rules
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-02-28 23:59:59" "nothing" "nothing" 951782399 "Before leap day in year 2000"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-02-29 00:00:00" "nothing" "nothing" 951782400 "Leap day in year 2000"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-03-01 00:00:00" "nothing" "nothing" 951868800 "March after leap day in year 2000"]

    :set res [$RunTestCase $res $ToUnixTimestamp "2100-02-28 23:59:59" "nothing" "nothing" 4107542399 "End of February century boundary check"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2100-03-01 00:00:00" "nothing" "nothing" 4107542400 "Start of March century boundary check"]

    # 32-bit boundary
    :set res [$RunTestCase $res $ToUnixTimestamp "2038-01-19 03:14:06" "nothing" "nothing" 2147483646 "One second before signed 32-bit limit"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2038-01-19 03:14:07" "nothing" "nothing" 2147483647 "Maximum standard 32-bit signed integer limit"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2038-01-19 03:14:08" "nothing" "nothing" 2147483648 "First second beyond signed 32-bit limit"]

    # Month boundaries (1970)
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-03-31 23:59:59" "nothing" "nothing" 7775999 "End of March 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-04-01 00:00:00" "nothing" "nothing" 7776000 "Start of April 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-04-30 23:59:59" "nothing" "nothing" 10367999 "End of April 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-05-01 00:00:00" "nothing" "nothing" 10368000 "Start of May 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-05-31 23:59:59" "nothing" "nothing" 13046399 "End of May 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-06-01 00:00:00" "nothing" "nothing" 13046400 "Start of June 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-06-30 23:59:59" "nothing" "nothing" 15638399 "End of June 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-07-01 00:00:00" "nothing" "nothing" 15638400 "Start of July 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-07-31 23:59:59" "nothing" "nothing" 18316799 "End of July 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-08-01 00:00:00" "nothing" "nothing" 18316800 "Start of August 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-08-31 23:59:59" "nothing" "nothing" 20995199 "End of August 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-09-01 00:00:00" "nothing" "nothing" 20995200 "Start of September 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-09-30 23:59:59" "nothing" "nothing" 23587199 "End of September 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-10-01 00:00:00" "nothing" "nothing" 23587200 "Start of October 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-10-31 23:59:59" "nothing" "nothing" 26265599 "End of October 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-11-01 00:00:00" "nothing" "nothing" 26265600 "Start of November 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-11-30 23:59:59" "nothing" "nothing" 28857599 "End of November 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1970-12-01 00:00:00" "nothing" "nothing" 28857600 "Start of December 1970"]

    # Leap year edge cases
    :set res [$RunTestCase $res $ToUnixTimestamp "1972-01-01 00:00:00" "nothing" "nothing" 63072000 "Start of leap year 1972"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1972-12-31 23:59:59" "nothing" "nothing" 94694399 "End of leap year 1972"]

    :set res [$RunTestCase $res $ToUnixTimestamp "1996-02-28 23:59:59" "nothing" "nothing" 825551999 "1996 before leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1996-02-29 00:00:00" "nothing" "nothing" 825552000 "1996 leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1996-03-01 00:00:00" "nothing" "nothing" 825638400 "1996 after leap day"]

    :set res [$RunTestCase $res $ToUnixTimestamp "2004-02-28 23:59:59" "nothing" "nothing" 1078012799 "2004 before leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2004-02-29 00:00:00" "nothing" "nothing" 1078012800 "2004 leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2004-03-01 00:00:00" "nothing" "nothing" 1078099200 "2004 after leap day"]

    # Non-leap century
    :set res [$RunTestCase $res $ToUnixTimestamp "2100-12-31 23:59:59" "nothing" "nothing" 4133980799 "End of non-leap century year"]

    # Leap century
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-12-31 23:59:59" "nothing" "nothing" 978307199 "End of leap century year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2400-02-28 23:59:59" "nothing" "nothing" 13574563199 "2400 before leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2400-02-29 00:00:00" "nothing" "nothing" 13574563200 "2400 leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2400-03-01 00:00:00" "nothing" "nothing" 13574649600 "2400 after leap day"]

    # End/start of years
    :set res [$RunTestCase $res $ToUnixTimestamp "1971-12-31 23:59:59" "nothing" "nothing" 63071999 "End of 1971"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1972-01-01 00:00:00" "nothing" "nothing" 63072000 "Start of 1972"]

    :set res [$RunTestCase $res $ToUnixTimestamp "1999-01-01 00:00:00" "nothing" "nothing" 915148800 "Start of 1999"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1999-12-31 23:59:58" "nothing" "nothing" 946684798 "Penultimate second of 1999"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1999-12-31 23:59:59" "nothing" "nothing" 946684799 "Last second of 1999"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-01-01 00:00:00" "nothing" "nothing" 946684800 "Start of 2000"]

    # Time-of-day edge cases
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-06-15 00:00:00" "nothing" "nothing" 1749945600 "Start of day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-06-15 00:00:01" "nothing" "nothing" 1749945601 "Second after midnight"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-06-15 11:59:59" "nothing" "nothing" 1749988799 "Second before noon"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-06-15 12:00:00" "nothing" "nothing" 1749988800 "Exact noon"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-06-15 23:59:58" "nothing" "nothing" 1750031998 "Penultimate second of day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2025-06-15 23:59:59" "nothing" "nothing" 1750031999 "Last second of day"]

    # 400-year cycle verification
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-03-01 00:00:00" "nothing" "nothing" 951868800 "Leap century 2000"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2100-03-01 00:00:00" "nothing" "nothing" 4107542400 "Non-leap century 2100"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2400-03-01 00:00:00" "nothing" "nothing" 13574649600 "Leap century 2400"]

    # Other tests
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-02-29 12:00:00" "nothing" "nothing" 951825600 "Middle of leap century day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2100-02-28 00:00:00" "nothing" "nothing" 4107456000 "Start of last day before non-leap century transition"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2100-03-01 00:00:00" "nothing" "nothing" 4107542400 "First day after skipped leap day in 2100"]
    :set res [$RunTestCase $res $ToUnixTimestamp "1972-01-02 00:00:00" "nothing" "nothing" 63158400 "Second day of leap year 1972"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2010-01-01 00:00:00" "nothing" "nothing" 1262304000 "Round decade boundary"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2019-12-31 23:59:59" "nothing" "nothing" 1577836799 "End of decade"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2020-01-01 00:00:00" "nothing" "nothing" 1577836800 "Start of leap decade year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2040-01-01 00:00:00" "nothing" "nothing" 2208988800 "Post 32-bit future date"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2100-01-01 23:59:59" "nothing" "nothing" 4102531199 "Century year beginning"]
    :set res [$RunTestCase $res $ToUnixTimestamp "9999-12-31 00:00:00" "nothing" "nothing" 253402214400 "Near maximum supported date"]

    :set res [$RunTestCase $res $ToUnixTimestamp "1973-01-01 00:00:00" "nothing" "nothing" 94694400 "First second after leap year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-01-31 23:59:59" "nothing" "nothing" 1706745599 "End of January"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-03-31 23:59:59" "nothing" "nothing" 1711929599 "End of March"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-04-30 23:59:59" "nothing" "nothing" 1714521599 "End of April"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-05-31 23:59:59" "nothing" "nothing" 1717199999 "End of May"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2024-06-30 23:59:59" "nothing" "nothing" 1719791999 "End of June"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-01-01 00:00:00" "nothing" "nothing" 946684800 "Y2K midnight"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-01-01 12:00:00" "nothing" "nothing" 946728000 "Y2K noon"]
    :set res [$RunTestCase $res $ToUnixTimestamp "2000-01-01 23:59:59" "nothing" "nothing" 946771199 "Y2K end of day"]

    # Epoch (1970)
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1970 00:00:00" "nothing" "nothing" 0 "Absolute epoch zero starting point"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1970 00:00:01" "nothing" "nothing" 1 "One second past epoch threshold"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1970 00:00:59" "nothing" "nothing" 59 "Last second of the first minute"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1970 00:01:00" "nothing" "nothing" 60 "Start of the second minute"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1970 00:59:59" "nothing" "nothing" 3599 "Last second of the first hour"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1970 01:00:00" "nothing" "nothing" 3600 "One hour past epoch threshold"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1970 23:59:59" "nothing" "nothing" 86399 "Last second of the first day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/02/1970 00:00:00" "nothing" "nothing" 86400 "Start of the second day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/31/1970 23:59:59" "nothing" "nothing" 2678399 "End of January 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/01/1970 00:00:00" "nothing" "nothing" 2678400 "Start of February 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/28/1970 23:59:59" "nothing" "nothing" 5097599 "End of February 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/1970 00:00:00" "nothing" "nothing" 5097600 "Start of March 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/1970 23:59:59" "nothing" "nothing" 31535999 "Last second of the epoch year"]

    # First leap year after epoch (1972)
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/28/1972 23:59:59" "nothing" "nothing" 68169599 "Second before leap day in 1972"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/29/1972 00:00:00" "nothing" "nothing" 68169600 "Leap day begins in 1972"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/29/1972 23:59:59" "nothing" "nothing" 68255999 "Leap day ends in 1972"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/1972 00:00:00" "nothing" "nothing" 68256000 "March begins after leap day in 1972"]

    # Leap year (2024)
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/31/2024 23:59:59" "nothing" "nothing" 1706745599 "End of January 2024"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/01/2024 00:00:00" "nothing" "nothing" 1706745600 "Start of February 2024"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/28/2024 23:59:59" "nothing" "nothing" 1709164799 "Second before leap day February 29"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/29/2024 00:00:00" "nothing" "nothing" 1709164800 "Start of the leap day February 29"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/29/2024 12:34:56" "nothing" "nothing" 1709210096 "Middle of leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/29/2024 23:59:59" "nothing" "nothing" 1709251199 "End of the leap day February 29"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/2024 00:00:00" "nothing" "nothing" 1709251200 "Start of March right after leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/2024 23:59:59" "nothing" "nothing" 1735689599 "End of leap year 2024"]

    # Standard year (2025)
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/2025 00:00:00" "nothing" "nothing" 1735689600 "Start of 2025"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/28/2025 23:59:59" "nothing" "nothing" 1740787199 "End of February in a standard year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/2025 00:00:00" "nothing" "nothing" 1740787200 "Start of March in a standard year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "apr/30/2025 23:59:59" "nothing" "nothing" 1746057599 "End of April"]
    :set res [$RunTestCase $res $ToUnixTimestamp "may/01/2025 00:00:00" "nothing" "nothing" 1746057600 "Start of May"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/30/2025 23:59:59" "nothing" "nothing" 1751327999 "End of June"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jul/01/2025 00:00:00" "nothing" "nothing" 1751328000 "Start of July"]
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/2025 23:59:59" "nothing" "nothing" 1767225599 "End of 2025"]

    # Different month letter case
    :set res [$RunTestCase $res $ToUnixTimestamp "jAn/01/2025 00:00:00" "nothing" "nothing" 1735689600 "Start of 2025"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feB/28/2025 23:59:59" "nothing" "nothing" 1740787199 "End of February in a standard year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "Mar/01/2025 00:00:00" "nothing" "nothing" 1740787200 "Start of March in a standard year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "APR/30/2025 23:59:59" "nothing" "nothing" 1746057599 "End of April"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mAY/01/2025 00:00:00" "nothing" "nothing" 1746057600 "Start of May"]
    :set res [$RunTestCase $res $ToUnixTimestamp "JUn/30/2025 23:59:59" "nothing" "nothing" 1751327999 "End of June"]

    # Arbitrary dates
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/15/1980 12:00:00" "nothing" "nothing" 329918400 "Midday in 1980"]
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/1999 23:59:59" "nothing" "nothing" 946684799 "End of the 20th century"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/2000 00:00:00" "nothing" "nothing" 946684800 "Start of year 2000"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/2026 00:00:00" "nothing" "nothing" 1767225600 "Start of the year Y2026 baseline"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jul/09/2026 15:45:00" "nothing" "nothing" 1783611900 "Arbitrary current mid-year verification"]
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/9999 23:59:59" "nothing" "nothing" 253402300799 "Last possible date"]

    # Century rules
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/28/2000 23:59:59" "nothing" "nothing" 951782399 "Before leap day in year 2000"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/29/2000 00:00:00" "nothing" "nothing" 951782400 "Leap day in year 2000"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/2000 00:00:00" "nothing" "nothing" 951868800 "March after leap day in year 2000"]

    :set res [$RunTestCase $res $ToUnixTimestamp "feb/28/2100 23:59:59" "nothing" "nothing" 4107542399 "End of February century boundary check"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/2100 00:00:00" "nothing" "nothing" 4107542400 "Start of March century boundary check"]

    # 32-bit boundary
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/19/2038 03:14:06" "nothing" "nothing" 2147483646 "One second before signed 32-bit limit"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/19/2038 03:14:07" "nothing" "nothing" 2147483647 "Maximum standard 32-bit signed integer limit"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/19/2038 03:14:08" "nothing" "nothing" 2147483648 "First second beyond signed 32-bit limit"]

    # Month boundaries (1970)
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/31/1970 23:59:59" "nothing" "nothing" 7775999 "End of March 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "apr/01/1970 00:00:00" "nothing" "nothing" 7776000 "Start of April 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "apr/30/1970 23:59:59" "nothing" "nothing" 10367999 "End of April 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "may/01/1970 00:00:00" "nothing" "nothing" 10368000 "Start of May 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "may/31/1970 23:59:59" "nothing" "nothing" 13046399 "End of May 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/01/1970 00:00:00" "nothing" "nothing" 13046400 "Start of June 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/30/1970 23:59:59" "nothing" "nothing" 15638399 "End of June 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jul/01/1970 00:00:00" "nothing" "nothing" 15638400 "Start of July 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jul/31/1970 23:59:59" "nothing" "nothing" 18316799 "End of July 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "aug/01/1970 00:00:00" "nothing" "nothing" 18316800 "Start of August 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "aug/31/1970 23:59:59" "nothing" "nothing" 20995199 "End of August 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "sep/01/1970 00:00:00" "nothing" "nothing" 20995200 "Start of September 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "sep/30/1970 23:59:59" "nothing" "nothing" 23587199 "End of September 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "oct/01/1970 00:00:00" "nothing" "nothing" 23587200 "Start of October 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "oct/31/1970 23:59:59" "nothing" "nothing" 26265599 "End of October 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "nov/01/1970 00:00:00" "nothing" "nothing" 26265600 "Start of November 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "nov/30/1970 23:59:59" "nothing" "nothing" 28857599 "End of November 1970"]
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/01/1970 00:00:00" "nothing" "nothing" 28857600 "Start of December 1970"]

    # Leap year edge cases
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1972 00:00:00" "nothing" "nothing" 63072000 "Start of leap year 1972"]
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/1972 23:59:59" "nothing" "nothing" 94694399 "End of leap year 1972"]

    :set res [$RunTestCase $res $ToUnixTimestamp "feb/28/1996 23:59:59" "nothing" "nothing" 825551999 "1996 before leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/29/1996 00:00:00" "nothing" "nothing" 825552000 "1996 leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/1996 00:00:00" "nothing" "nothing" 825638400 "1996 after leap day"]

    :set res [$RunTestCase $res $ToUnixTimestamp "feb/28/2004 23:59:59" "nothing" "nothing" 1078012799 "2004 before leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/29/2004 00:00:00" "nothing" "nothing" 1078012800 "2004 leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/2004 00:00:00" "nothing" "nothing" 1078099200 "2004 after leap day"]

    # Non-leap century
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/2100 23:59:59" "nothing" "nothing" 4133980799 "End of non-leap century year"]

    # Leap century
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/2000 23:59:59" "nothing" "nothing" 978307199 "End of leap century year"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/28/2400 23:59:59" "nothing" "nothing" 13574563199 "2400 before leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "feb/29/2400 00:00:00" "nothing" "nothing" 13574563200 "2400 leap day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/2400 00:00:00" "nothing" "nothing" 13574649600 "2400 after leap day"]

    # End/start of years
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/1971 23:59:59" "nothing" "nothing" 63071999 "End of 1971"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1972 00:00:00" "nothing" "nothing" 63072000 "Start of 1972"]

    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/1999 00:00:00" "nothing" "nothing" 915148800 "Start of 1999"]
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/1999 23:59:58" "nothing" "nothing" 946684798 "Penultimate second of 1999"]
    :set res [$RunTestCase $res $ToUnixTimestamp "dec/31/1999 23:59:59" "nothing" "nothing" 946684799 "Last second of 1999"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jan/01/2000 00:00:00" "nothing" "nothing" 946684800 "Start of 2000"]

    # Time-of-day edge cases
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/15/2025 00:00:00" "nothing" "nothing" 1749945600 "Start of day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/15/2025 00:00:01" "nothing" "nothing" 1749945601 "Second after midnight"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/15/2025 11:59:59" "nothing" "nothing" 1749988799 "Second before noon"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/15/2025 12:00:00" "nothing" "nothing" 1749988800 "Exact noon"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/15/2025 23:59:58" "nothing" "nothing" 1750031998 "Penultimate second of day"]
    :set res [$RunTestCase $res $ToUnixTimestamp "jun/15/2025 23:59:59" "nothing" "nothing" 1750031999 "Last second of day"]

    # 400-year cycle verification
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/2000 00:00:00" "nothing" "nothing" 951868800 "Leap century 2000"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/2100 00:00:00" "nothing" "nothing" 4107542400 "Non-leap century 2100"]
    :set res [$RunTestCase $res $ToUnixTimestamp "mar/01/2400 00:00:00" "nothing" "nothing" 13574649600 "Leap century 2400"]

    # Testing invalid month names with varying dates and times that should cause an error
    :set res [$RunTestCase $res $ToUnixTimestamp "fgh/14/2023 08:15:30" "nothing" "nothing" "error" "Invalid month name fgh"]
    :set res [$RunTestCase $res $ToUnixTimestamp "some/07/2024 16:23:05" "nothing" "nothing" "error" "Invalid month name some"]
    :set res [$RunTestCase $res $ToUnixTimestamp "wrong/03/2025 16:20:01" "nothing" "nothing" "error" "Invalid month name wrong"]
    :set res [$RunTestCase $res $ToUnixTimestamp "xyz/22/2021 03:05:45" "nothing" "nothing" "error" "Invalid three-letter month name xyz"]
    :set res [$RunTestCase $res $ToUnixTimestamp "123/09/2028 21:10:00" "nothing" "nothing" "error" "Numeric instead of literal month name"]
    :set res [$RunTestCase $res $ToUnixTimestamp "qwe/28/2025 11:33:22" "nothing" "nothing" "error" "Invalid month name qwe"]

    :put "Testing completed."
    :return $res
}
