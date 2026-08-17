:global RunAllDateTimeTests1
:global GetWeekdayTest
:global GetCurrentDateTimeTest
:global ParseDateTimeTest
:global GetUnixTimestampTest
:global FromUnixTimestampTest

:set RunAllDateTimeTests1 do={
    :global InitTestCaseState
    :global GetWeekdayTest
    :global GetCurrentDateTimeTest
    :global ParseDateTimeTest
    :global GetUnixTimestampTest
    :global FromUnixTimestampTest

    :local res [$InitTestCaseState $1]

    :put "\1B[35m=== STARTING ALL DATE AND TIME TESTS 1 ===\1B[0m"

    # Execute conversion and parsing tests
    :set res [$GetWeekdayTest $res]
    :set res [$GetCurrentDateTimeTest $res]
    :set res [$ParseDateTimeTest $res]
    :set res [$FromUnixTimestampTest $res]
    :set res [$GetUnixTimestampTest $res]

    :put "\1B[35m=== ALL DATE AND TIME TESTS 1 COMPLETED ===\1B[0m"
    :return $res
}

:set GetWeekdayTest do={
    :global InitTestCaseState
    :global RunTestCase
    :global GetWeekday

    :local res [$InitTestCaseState $1]

    :put "Starting GetWeekday tests..."

    # Epoch base cases (1970-01-01 was a Thursday)
    :set res [$RunTestCase $res $GetWeekday 0 "nothing" "nothing" "thursday" "Absolute Unix epoch start boundary"]
    :set res [$RunTestCase $res $GetWeekday 86400 "nothing" "nothing" "friday" "One day past epoch baseline"]
    :set res [$RunTestCase $res $GetWeekday 172800 "nothing" "nothing" "saturday" "Two days past epoch baseline"]
    :set res [$RunTestCase $res $GetWeekday 259200 "nothing" "nothing" "sunday" "Three days past epoch - first Sunday"]
    :set res [$RunTestCase $res $GetWeekday 345600 "nothing" "nothing" "monday" "Four days past epoch - first Monday"]

    # Mid-week sequence validation
    :set res [$RunTestCase $res $GetWeekday 1709164799 "nothing" "nothing" "wednesday" "End of February 28 before leap day 2024"]
    :set res [$RunTestCase $res $GetWeekday 1709164800 "nothing" "nothing" "thursday" "Start of leap day February 29 2024"]
    :set res [$RunTestCase $res $GetWeekday 1709251200 "nothing" "nothing" "friday" "Start of March 1 right after leap day 2024"]

    # Year 2025 targets
    :set res [$RunTestCase $res $GetWeekday 1740787199 "nothing" "nothing" "friday" "Last second of February 2025 standard year"]
    :set res [$RunTestCase $res $GetWeekday 1740787200 "nothing" "nothing" "saturday" "Start of March 1 2025 standard year"]

    # Documentation example verification
    :set res [$RunTestCase $res $GetWeekday 1750031999 "nothing" "nothing" "sunday" "Target example validation from documentation header"]

    # Year 2026 targets (Today check)
    :set res [$RunTestCase $res $GetWeekday 1767225600 "nothing" "nothing" "thursday" "Start of the year Y2026 baseline"]
    :set res [$RunTestCase $res $GetWeekday 1783639991 "nothing" "nothing" "thursday" "Current date timestamp validation anchor"]

    # Far future check (Year 2038)
    :set res [$RunTestCase $res $GetWeekday 2147483647 "nothing" "nothing" "tuesday" "Maximum 32-bit signed integer time threshold"]

    :set res [$RunTestCase $res $GetWeekday 0 "nothing" "nothing" "thursday" "Thursday"]
    :set res [$RunTestCase $res $GetWeekday 86400 "nothing" "nothing" "friday" "Friday"]
    :set res [$RunTestCase $res $GetWeekday 172800 "nothing" "nothing" "saturday" "Saturday"]
    :set res [$RunTestCase $res $GetWeekday 259200 "nothing" "nothing" "sunday" "Sunday"]
    :set res [$RunTestCase $res $GetWeekday 345600 "nothing" "nothing" "monday" "Monday"]
    :set res [$RunTestCase $res $GetWeekday 432000 "nothing" "nothing" "tuesday" "Tuesday"]
    :set res [$RunTestCase $res $GetWeekday 518400 "nothing" "nothing" "wednesday" "Wednesday"]
    :set res [$RunTestCase $res $GetWeekday 604800 "nothing" "nothing" "thursday" "Exactly one week later"]

    :set res [$RunTestCase $res $GetWeekday 0 "nothing" "nothing" "thursday" "Start of day"]
    :set res [$RunTestCase $res $GetWeekday 1 "nothing" "nothing" "thursday" "One second later"]
    :set res [$RunTestCase $res $GetWeekday 43200 "nothing" "nothing" "thursday" "Midday"]
    :set res [$RunTestCase $res $GetWeekday 86398 "nothing" "nothing" "thursday" "Penultimate second"]
    :set res [$RunTestCase $res $GetWeekday 86399 "nothing" "nothing" "thursday" "Last second of day"]
    :set res [$RunTestCase $res $GetWeekday 86400 "nothing" "nothing" "friday" "Next day begins"]

    :set res [$RunTestCase $res $GetWeekday 1709251199 "nothing" "nothing" "thursday" "Last second of leap day"]
    :set res [$RunTestCase $res $GetWeekday 1709251200 "nothing" "nothing" "friday" "First second after leap day"]

    :set res [$RunTestCase $res $GetWeekday 1735689599 "nothing" "nothing" "tuesday" "Last second of 2024"]
    :set res [$RunTestCase $res $GetWeekday 1735689600 "nothing" "nothing" "wednesday" "First second of 2025"]

    :set res [$RunTestCase $res $GetWeekday 1767225599 "nothing" "nothing" "wednesday" "Last second of 2025"]
    :set res [$RunTestCase $res $GetWeekday 1767225600 "nothing" "nothing" "thursday" "First second of 2026"]

    :set res [$RunTestCase $res $GetWeekday 951782400 "nothing" "nothing" "tuesday" "Leap century day 2000"]
    :set res [$RunTestCase $res $GetWeekday 4107542400 "nothing" "nothing" "monday" "Non-leap century 2100"]
    :set res [$RunTestCase $res $GetWeekday 13574649600 "nothing" "nothing" "wednesday" "Leap century 2400"]

    :set res [$RunTestCase $res $GetWeekday 253402300799 "nothing" "nothing" "friday" "Maximum supported date"]

    :set res [$RunTestCase $res $GetWeekday 951868800 "nothing" "nothing" "wednesday" "2000-03-01"]
    :set res [$RunTestCase $res $GetWeekday 13574649600 "nothing" "nothing" "wednesday" "2400-03-01 same weekday after 400-year cycle"]

    :set res [$RunTestCase $res $GetWeekday 0 "nothing" "nothing" "thursday" "Week 0"]
    :set res [$RunTestCase $res $GetWeekday 604800 "nothing" "nothing" "thursday" "Week 1"]
    :set res [$RunTestCase $res $GetWeekday 1209600 "nothing" "nothing" "thursday" "Week 2"]
    :set res [$RunTestCase $res $GetWeekday 1814400 "nothing" "nothing" "thursday" "Week 3"]

    :put "Testing completed."
    :return $res
}

:set GetCurrentDateTimeTest do={
    :global InitTestCaseState
    :global GetCurrentDateTime
    :global FromUnixTimestamp
    :global ToUnixTimestamp

    :local res [$InitTestCaseState $1]

    :put "Starting GetCurrentDateTime runtime tests..."

    # Dynamic check to confirm current live runtime fetches validate correctly
    :local date1 [$GetCurrentDateTime]
    :local ts1 [$ToUnixTimestamp $date1]
    :local date2 [$FromUnixTimestamp $ts1]

    :if ([:typeof $ts1] = "num" && $ts1 > 1783628648) do={
        :set ($res->"passed") (($res->"passed") + 1)
        :put ("  \1B[32m[PASS]\1B[0m Live system date/time fetched successfully: " . $date1)
    } else={
        :set ($res->"failed") (($res->"failed") + 1)
        :put ("  \1B[31m[FAIL]\1B[0m Live system date/time fetch resulted in invalid structure: " . [:tostr $date1])
    }

    :if ($date1 = $date2 && $ts1 > 1783628648) do={
        :set ($res->"passed") (($res->"passed") + 1)
        :put ("  \1B[32m[PASS]\1B[0m Conversion to timestamp successful: " . $ts1)
    } else={
        :set ($res->"failed") (($res->"failed") + 1)
        :put ("  \1B[31m[FAIL]\1B[0m Conversion to timestamp failed: " . [:tostr $ts1])
    }

    :put "Testing completed."
    :return $res
}

:set ParseDateTimeTest do={
    :global InitTestCaseState
    :global RunTestCase
    :global ParseDateTime

    :local res [$InitTestCaseState $1]

    :put "Starting ParseDateTime tests..."

    # Original base cases (RouterOS format)
    :set res [$RunTestCase $res $ParseDateTime "jan/01/2026 00:00:00" "nothing" "nothing" "2026-01-01 00:00:00" "Midnight start of the year"]
    :set res [$RunTestCase $res $ParseDateTime "feb/28/2024 23:59:59" "nothing" "nothing" "2024-02-28 23:59:59" "End of day leap year February"]
    :set res [$RunTestCase $res $ParseDateTime "jul/09/2026 15:45:21" "nothing" "nothing" "2026-07-09 15:45:21" "Standard afternoon daytime string"]

    # Different month letter case
    :set res [$RunTestCase $res $ParseDateTime "mAy/15/2026 00:00:01" "nothing" "nothing" "2026-05-15 00:00:01" "Midnight start of the year"]
    :set res [$RunTestCase $res $ParseDateTime "Sep/07/2024 23:59:59" "nothing" "nothing" "2024-09-07 23:59:59" "End of day leap year February"]
    :set res [$RunTestCase $res $ParseDateTime "MAR/04/2026 15:45:21" "nothing" "nothing" "2026-03-04 15:45:21" "Standard afternoon daytime string"]

    # Extended month mapping tests (RouterOS format)
    :set res [$RunTestCase $res $ParseDateTime "mar/15/2025 08:30:00" "nothing" "nothing" "2025-03-15 08:30:00" "March date format conversion"]
    :set res [$RunTestCase $res $ParseDateTime "apr/30/2025 12:00:00" "nothing" "nothing" "2025-04-30 12:00:00" "April date format conversion"]
    :set res [$RunTestCase $res $ParseDateTime "may/01/2025 06:15:45" "nothing" "nothing" "2025-05-01 06:15:45" "May date format conversion"]
    :set res [$RunTestCase $res $ParseDateTime "jun/22/2025 18:40:12" "nothing" "nothing" "2025-06-22 18:40:12" "June date format conversion"]
    :set res [$RunTestCase $res $ParseDateTime "aug/31/2025 21:05:00" "nothing" "nothing" "2025-08-31 21:05:00" "August date format conversion"]
    :set res [$RunTestCase $res $ParseDateTime "sep/10/2025 09:14:23" "nothing" "nothing" "2025-09-10 09:14:23" "September date format conversion"]
    :set res [$RunTestCase $res $ParseDateTime "oct/05/2025 04:02:59" "nothing" "nothing" "2025-10-05 04:02:59" "October date format conversion"]
    :set res [$RunTestCase $res $ParseDateTime "nov/11/2025 11:11:11" "nothing" "nothing" "2025-11-11 11:11:11" "November date format conversion"]
    :set res [$RunTestCase $res $ParseDateTime "dec/25/2025 20:00:00" "nothing" "nothing" "2025-12-25 20:00:00" "December date format conversion"]

    # Native ISO format pass-through tests
    :set res [$RunTestCase $res $ParseDateTime "2025-07-25 12:31:25" "nothing" "nothing" "2025-07-25 12:31:25" "Standard input matching native ISO pattern"]
    :set res [$RunTestCase $res $ParseDateTime "1970-01-01 00:00:00" "nothing" "nothing" "1970-01-01 00:00:00" "Epoch baseline input matching native ISO pattern"]

    :set res [$RunTestCase $res $ParseDateTime "bad/12/2025 12:00:00" "nothing" "nothing" "error" "Rejection check for non-existent month name"]
    :set res [$RunTestCase $res $ParseDateTime "2025/07/25 12:31:25" "nothing" "nothing" "error" "Rejection check for slash separators in ISO style"]
    :set res [$RunTestCase $res $ParseDateTime "jul-31-2025 03:30:05" "nothing" "nothing" "error" "Rejection check for dash separators in ROS style"]
    :set res [$RunTestCase $res $ParseDateTime "jul/31/2025" "nothing" "nothing" "error" "Rejection check for completely missing time block"]
    :set res [$RunTestCase $res $ParseDateTime "12:00:00" "nothing" "nothing" "error" "Rejection check for completely missing date block"]

    # Testing invalid month names with varying dates and times that should cause an error
    :set res [$RunTestCase $res $ParseDateTime "fgh/14/2023 08:15:30" "nothing" "nothing" "error" "Invalid month name fgh"]
    :set res [$RunTestCase $res $ParseDateTime "some/07/2024 16:23:05" "nothing" "nothing" "error" "Invalid month name some"]
    :set res [$RunTestCase $res $ParseDateTime "wrong/03/2025 16:20:01" "nothing" "nothing" "error" "Invalid month name wrong"]
    :set res [$RunTestCase $res $ParseDateTime "xyz/22/2021 03:05:45" "nothing" "nothing" "error" "Invalid three-letter month name xyz"]
    :set res [$RunTestCase $res $ParseDateTime "123/09/2028 21:10:00" "nothing" "nothing" "error" "Numeric instead of literal month name"]
    :set res [$RunTestCase $res $ParseDateTime "qwe/28/2025 11:33:22" "nothing" "nothing" "error" "Invalid month name qwe"]

    # Testing invalid day numbers (out of range and negative) that should cause an error
    :set res [$RunTestCase $res $ParseDateTime "Jan/0/2023 08:15:30" "nothing" "nothing" "error" "Day out of range"]
    :set res [$RunTestCase $res $ParseDateTime "Jan/-1/2024 16:23:05" "nothing" "nothing" "error" "Negative day value"]
    :set res [$RunTestCase $res $ParseDateTime "Dec/-15/2021 05:45:30" "nothing" "nothing" "error" "Negative day value"]

    # Testing invalid hours, minutes, and seconds that should cause an error
    :set res [$RunTestCase $res $ParseDateTime "Apr/22/2021 -1:05:45" "nothing" "nothing" "error" "Negative hour value"]
    :set res [$RunTestCase $res $ParseDateTime "May/09/2028 -05:30:00" "nothing" "nothing" "error" "Negative hour value"]

    :set res [$RunTestCase $res $ParseDateTime "Sep/22/2021 03:-1:45" "nothing" "nothing" "error" "Negative minute value"]
    :set res [$RunTestCase $res $ParseDateTime "Oct/09/2028 21:-15:00" "nothing" "nothing" "error" "Negative minute value"]

    :set res [$RunTestCase $res $ParseDateTime "Feb/22/2021 03:05:-1" "nothing" "nothing" "error" "Negative second value"]
    :set res [$RunTestCase $res $ParseDateTime "Mar/09/2028 11:33:-30" "nothing" "nothing" "error" "Negative second value"]

    :put "Testing completed."
    :return $res
}

:set FromUnixTimestampTest do={
    :global InitTestCaseState
    :global RunTestCase
    :global FromUnixTimestamp

    :local res [$InitTestCaseState $1]

    :put "Starting extended FromUnixTimestamp tests..."

    # Epoch (1970)
    :set res [$RunTestCase $res $FromUnixTimestamp 0 "nothing" "nothing" "1970-01-01 00:00:00" "Absolute epoch zero starting point"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1 "nothing" "nothing" "1970-01-01 00:00:01" "One second past epoch threshold"]
    :set res [$RunTestCase $res $FromUnixTimestamp 59 "nothing" "nothing" "1970-01-01 00:00:59" "Last second of the first minute"]
    :set res [$RunTestCase $res $FromUnixTimestamp 60 "nothing" "nothing" "1970-01-01 00:01:00" "Start of the second minute"]
    :set res [$RunTestCase $res $FromUnixTimestamp 3599 "nothing" "nothing" "1970-01-01 00:59:59" "Last second of the first hour"]
    :set res [$RunTestCase $res $FromUnixTimestamp 3600 "nothing" "nothing" "1970-01-01 01:00:00" "One hour past epoch threshold"]
    :set res [$RunTestCase $res $FromUnixTimestamp 86399 "nothing" "nothing" "1970-01-01 23:59:59" "Last second of the first day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 86400 "nothing" "nothing" "1970-01-02 00:00:00" "Start of the second day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 2678399 "nothing" "nothing" "1970-01-31 23:59:59" "End of January 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 2678400 "nothing" "nothing" "1970-02-01 00:00:00" "Start of February 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 5097599 "nothing" "nothing" "1970-02-28 23:59:59" "End of February 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 5097600 "nothing" "nothing" "1970-03-01 00:00:00" "Start of March 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 31535999 "nothing" "nothing" "1970-12-31 23:59:59" "Last second of the epoch year"]

    # First leap year after epoch (1972)
    :set res [$RunTestCase $res $FromUnixTimestamp 68169599 "nothing" "nothing" "1972-02-28 23:59:59" "Second before leap day in 1972"]
    :set res [$RunTestCase $res $FromUnixTimestamp 68169600 "nothing" "nothing" "1972-02-29 00:00:00" "Leap day begins in 1972"]
    :set res [$RunTestCase $res $FromUnixTimestamp 68255999 "nothing" "nothing" "1972-02-29 23:59:59" "Leap day ends in 1972"]
    :set res [$RunTestCase $res $FromUnixTimestamp 68256000 "nothing" "nothing" "1972-03-01 00:00:00" "March begins after leap day in 1972"]

    # Leap year (2024)
    :set res [$RunTestCase $res $FromUnixTimestamp 1706745599 "nothing" "nothing" "2024-01-31 23:59:59" "End of January 2024"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1706745600 "nothing" "nothing" "2024-02-01 00:00:00" "Start of February 2024"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1709164799 "nothing" "nothing" "2024-02-28 23:59:59" "Second before leap day February 29"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1709164800 "nothing" "nothing" "2024-02-29 00:00:00" "Start of the leap day February 29"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1709210096 "nothing" "nothing" "2024-02-29 12:34:56" "Middle of leap day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1709251199 "nothing" "nothing" "2024-02-29 23:59:59" "End of the leap day February 29"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1709251200 "nothing" "nothing" "2024-03-01 00:00:00" "Start of March right after leap day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1735689599 "nothing" "nothing" "2024-12-31 23:59:59" "End of leap year 2024"]

    # Standard year (2025)
    :set res [$RunTestCase $res $FromUnixTimestamp 1735689600 "nothing" "nothing" "2025-01-01 00:00:00" "Start of 2025"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1740787199 "nothing" "nothing" "2025-02-28 23:59:59" "End of February in a standard year"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1740787200 "nothing" "nothing" "2025-03-01 00:00:00" "Start of March in a standard year"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1746057599 "nothing" "nothing" "2025-04-30 23:59:59" "End of April"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1746057600 "nothing" "nothing" "2025-05-01 00:00:00" "Start of May"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1751327999 "nothing" "nothing" "2025-06-30 23:59:59" "End of June"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1751328000 "nothing" "nothing" "2025-07-01 00:00:00" "Start of July"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1767225599 "nothing" "nothing" "2025-12-31 23:59:59" "End of 2025"]

    # Arbitrary dates
    :set res [$RunTestCase $res $FromUnixTimestamp 329918400 "nothing" "nothing" "1980-06-15 12:00:00" "Midday in 1980"]
    :set res [$RunTestCase $res $FromUnixTimestamp 946684799 "nothing" "nothing" "1999-12-31 23:59:59" "End of the 20th century"]
    :set res [$RunTestCase $res $FromUnixTimestamp 946684800 "nothing" "nothing" "2000-01-01 00:00:00" "Start of year 2000"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1767225600 "nothing" "nothing" "2026-01-01 00:00:00" "Start of the year Y2026 baseline"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1783611900 "nothing" "nothing" "2026-07-09 15:45:00" "Arbitrary current mid-year verification"]
    :set res [$RunTestCase $res $FromUnixTimestamp 253402300799 "nothing" "nothing" "9999-12-31 23:59:59" "Last possible date"]

    # Century rules
    :set res [$RunTestCase $res $FromUnixTimestamp 951782399 "nothing" "nothing" "2000-02-28 23:59:59" "Before leap day in year 2000"]
    :set res [$RunTestCase $res $FromUnixTimestamp 951782400 "nothing" "nothing" "2000-02-29 00:00:00" "Leap day in year 2000"]
    :set res [$RunTestCase $res $FromUnixTimestamp 951868800 "nothing" "nothing" "2000-03-01 00:00:00" "March after leap day in year 2000"]

    :set res [$RunTestCase $res $FromUnixTimestamp 4107542399 "nothing" "nothing" "2100-02-28 23:59:59" "End of February century boundary check"]
    :set res [$RunTestCase $res $FromUnixTimestamp 4107542400 "nothing" "nothing" "2100-03-01 00:00:00" "Start of March century boundary check"]

    # 32-bit boundary
    :set res [$RunTestCase $res $FromUnixTimestamp 2147483646 "nothing" "nothing" "2038-01-19 03:14:06" "One second before signed 32-bit limit"]
    :set res [$RunTestCase $res $FromUnixTimestamp 2147483647 "nothing" "nothing" "2038-01-19 03:14:07" "Maximum standard 32-bit signed integer limit"]
    :set res [$RunTestCase $res $FromUnixTimestamp 2147483648 "nothing" "nothing" "2038-01-19 03:14:08" "First second beyond signed 32-bit limit"]

    # Month boundaries (1970)
    :set res [$RunTestCase $res $FromUnixTimestamp 7775999 "nothing" "nothing" "1970-03-31 23:59:59" "End of March 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 7776000 "nothing" "nothing" "1970-04-01 00:00:00" "Start of April 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 10367999 "nothing" "nothing" "1970-04-30 23:59:59" "End of April 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 10368000 "nothing" "nothing" "1970-05-01 00:00:00" "Start of May 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 13046399 "nothing" "nothing" "1970-05-31 23:59:59" "End of May 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 13046400 "nothing" "nothing" "1970-06-01 00:00:00" "Start of June 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 15638399 "nothing" "nothing" "1970-06-30 23:59:59" "End of June 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 15638400 "nothing" "nothing" "1970-07-01 00:00:00" "Start of July 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 18316799 "nothing" "nothing" "1970-07-31 23:59:59" "End of July 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 18316800 "nothing" "nothing" "1970-08-01 00:00:00" "Start of August 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 20995199 "nothing" "nothing" "1970-08-31 23:59:59" "End of August 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 20995200 "nothing" "nothing" "1970-09-01 00:00:00" "Start of September 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 23587199 "nothing" "nothing" "1970-09-30 23:59:59" "End of September 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 23587200 "nothing" "nothing" "1970-10-01 00:00:00" "Start of October 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 26265599 "nothing" "nothing" "1970-10-31 23:59:59" "End of October 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 26265600 "nothing" "nothing" "1970-11-01 00:00:00" "Start of November 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 28857599 "nothing" "nothing" "1970-11-30 23:59:59" "End of November 1970"]
    :set res [$RunTestCase $res $FromUnixTimestamp 28857600 "nothing" "nothing" "1970-12-01 00:00:00" "Start of December 1970"]

    # Leap year edge cases
    :set res [$RunTestCase $res $FromUnixTimestamp 63072000 "nothing" "nothing" "1972-01-01 00:00:00" "Start of leap year 1972"]
    :set res [$RunTestCase $res $FromUnixTimestamp 94694399 "nothing" "nothing" "1972-12-31 23:59:59" "End of leap year 1972"]

    :set res [$RunTestCase $res $FromUnixTimestamp 825551999 "nothing" "nothing" "1996-02-28 23:59:59" "1996 before leap day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 825552000 "nothing" "nothing" "1996-02-29 00:00:00" "1996 leap day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 825638400 "nothing" "nothing" "1996-03-01 00:00:00" "1996 after leap day"]

    :set res [$RunTestCase $res $FromUnixTimestamp 1078012799 "nothing" "nothing" "2004-02-28 23:59:59" "2004 before leap day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1078012800 "nothing" "nothing" "2004-02-29 00:00:00" "2004 leap day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1078099200 "nothing" "nothing" "2004-03-01 00:00:00" "2004 after leap day"]

    # Non-leap century
    :set res [$RunTestCase $res $FromUnixTimestamp 4133980799 "nothing" "nothing" "2100-12-31 23:59:59" "End of non-leap century year"]

    # Leap century
    :set res [$RunTestCase $res $FromUnixTimestamp 978307199 "nothing" "nothing" "2000-12-31 23:59:59" "End of leap century year"]
    :set res [$RunTestCase $res $FromUnixTimestamp 13574563199 "nothing" "nothing" "2400-02-28 23:59:59" "2400 before leap day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 13574563200 "nothing" "nothing" "2400-02-29 00:00:00" "2400 leap day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 13574649600 "nothing" "nothing" "2400-03-01 00:00:00" "2400 after leap day"]

    # End/start of years
    :set res [$RunTestCase $res $FromUnixTimestamp 63071999 "nothing" "nothing" "1971-12-31 23:59:59" "End of 1971"]
    :set res [$RunTestCase $res $FromUnixTimestamp 63072000 "nothing" "nothing" "1972-01-01 00:00:00" "Start of 1972"]

    :set res [$RunTestCase $res $FromUnixTimestamp 915148800 "nothing" "nothing" "1999-01-01 00:00:00" "Start of 1999"]
    :set res [$RunTestCase $res $FromUnixTimestamp 946684798 "nothing" "nothing" "1999-12-31 23:59:58" "Penultimate second of 1999"]
    :set res [$RunTestCase $res $FromUnixTimestamp 946684799 "nothing" "nothing" "1999-12-31 23:59:59" "Last second of 1999"]
    :set res [$RunTestCase $res $FromUnixTimestamp 946684800 "nothing" "nothing" "2000-01-01 00:00:00" "Start of 2000"]

    # Time-of-day edge cases
    :set res [$RunTestCase $res $FromUnixTimestamp 1749945600 "nothing" "nothing" "2025-06-15 00:00:00" "Start of day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1749945601 "nothing" "nothing" "2025-06-15 00:00:01" "Second after midnight"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1749988799 "nothing" "nothing" "2025-06-15 11:59:59" "Second before noon"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1749988800 "nothing" "nothing" "2025-06-15 12:00:00" "Exact noon"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1750031998 "nothing" "nothing" "2025-06-15 23:59:58" "Penultimate second of day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1750031999 "nothing" "nothing" "2025-06-15 23:59:59" "Last second of day"]

    # 400-year cycle verification
    :set res [$RunTestCase $res $FromUnixTimestamp 951868800 "nothing" "nothing" "2000-03-01 00:00:00" "Leap century 2000"]
    :set res [$RunTestCase $res $FromUnixTimestamp 4107542400 "nothing" "nothing" "2100-03-01 00:00:00" "Non-leap century 2100"]
    :set res [$RunTestCase $res $FromUnixTimestamp 13574649600 "nothing" "nothing" "2400-03-01 00:00:00" "Leap century 2400"]

    # Other tests
    :set res [$RunTestCase $res $FromUnixTimestamp 951825600 "nothing" "nothing" "2000-02-29 12:00:00" "Middle of leap century day"]
    :set res [$RunTestCase $res $FromUnixTimestamp 4107456000 "nothing" "nothing" "2100-02-28 00:00:00" "Start of last day before non-leap century transition"]
    :set res [$RunTestCase $res $FromUnixTimestamp 4107542400 "nothing" "nothing" "2100-03-01 00:00:00" "First day after skipped leap day in 2100"]
    :set res [$RunTestCase $res $FromUnixTimestamp 63158400 "nothing" "nothing" "1972-01-02 00:00:00" "Second day of leap year 1972"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1262304000 "nothing" "nothing" "2010-01-01 00:00:00" "Round decade boundary"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1577836799 "nothing" "nothing" "2019-12-31 23:59:59" "End of decade"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1577836800 "nothing" "nothing" "2020-01-01 00:00:00" "Start of leap decade year"]
    :set res [$RunTestCase $res $FromUnixTimestamp 2208988800 "nothing" "nothing" "2040-01-01 00:00:00" "Post 32-bit future date"]
    :set res [$RunTestCase $res $FromUnixTimestamp 4102531199 "nothing" "nothing" "2100-01-01 23:59:59" "Century year beginning"]
    :set res [$RunTestCase $res $FromUnixTimestamp 253402214400 "nothing" "nothing" "9999-12-31 00:00:00" "Near maximum supported date"]

    :set res [$RunTestCase $res $FromUnixTimestamp 94694400 "nothing" "nothing" "1973-01-01 00:00:00" "First second after leap year"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1706745599 "nothing" "nothing" "2024-01-31 23:59:59" "End of January"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1711929599 "nothing" "nothing" "2024-03-31 23:59:59" "End of March"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1714521599 "nothing" "nothing" "2024-04-30 23:59:59" "End of April"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1717199999 "nothing" "nothing" "2024-05-31 23:59:59" "End of May"]
    :set res [$RunTestCase $res $FromUnixTimestamp 1719791999 "nothing" "nothing" "2024-06-30 23:59:59" "End of June"]
    :set res [$RunTestCase $res $FromUnixTimestamp 946684800 "nothing" "nothing" "2000-01-01 00:00:00" "Y2K midnight"]
    :set res [$RunTestCase $res $FromUnixTimestamp 946728000 "nothing" "nothing" "2000-01-01 12:00:00" "Y2K noon"]
    :set res [$RunTestCase $res $FromUnixTimestamp 946771199 "nothing" "nothing" "2000-01-01 23:59:59" "Y2K end of day"]

    :put "Testing completed."
    :return $res
}

:set GetUnixTimestampTest do={
    :global InitTestCaseState
    :global GetUnixTimestamp
    :global FromUnixTimestamp
    :global ToUnixTimestamp

    :local res [$InitTestCaseState $1]

    :put "Starting GetUnixTimestamp runtime tests..."

    # Dynamic check to confirm current live runtime fetches validate correctly
    :local ts1 [$GetUnixTimestamp]
    :local date [$FromUnixTimestamp $ts1]
    :local ts2 [$ToUnixTimestamp $date]

    :if ([:typeof $ts1] = "num" && $ts1 > 1783628648) do={
        :set ($res->"passed") (($res->"passed") + 1)
        :put ("  \1B[32m[PASS]\1B[0m Live system timestamp fetched successfully: " . $ts1)
    } else={
        :set ($res->"failed") (($res->"failed") + 1)
        :put ("  \1B[31m[FAIL]\1B[0m Live system timestamp fetch resulted in invalid structure: " . [:tostr $ts1])
    }

    :if ($ts1 = $ts2 && $ts1 > 1783628648) do={
        :set ($res->"passed") (($res->"passed") + 1)
        :put ("  \1B[32m[PASS]\1B[0m Conversion to date successful: " . $date)
    } else={
        :set ($res->"failed") (($res->"failed") + 1)
        :put ("  \1B[31m[FAIL]\1B[0m Conversion to date failed: " . [:tostr $date])
    }

    :put "Testing completed."
    :return $res
}
