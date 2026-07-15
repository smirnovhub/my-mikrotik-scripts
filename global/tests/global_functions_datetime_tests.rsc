:global RunAllDateTimeTests
:global GetCurrentDateTimeTest
:global GetWeekdayTest
:global GetUnixTimestampTest
:global FromUnixTimestampTest
:global ToUnixTimestampTest
:global FormatSecondsShortTest
:global FormatSecondsLongTest
:global ParseDateTimeTest

:set RunAllDateTimeTests do={
    :global GetWeekdayTest
    :global GetCurrentDateTimeTest
    :global ParseDateTimeTest
    :global GetUnixTimestampTest
    :global FromUnixTimestampTest
    :global ToUnixTimestampTest
    :global FormatSecondsShortTest
    :global FormatSecondsLongTest

    :local res {"passed"=0; "failed"=0}
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :error "Need to call with an empty array as parameter [:toarray {\"passed\"=0; \"failed\"=0}]]"
    }

    :put "\1B[35m=== STARTING ALL DATE AND TIME TESTS ===\1B[0m"

    # Execute conversion and parsing tests
    :set res [$GetWeekdayTest $res]
    :set res [$GetCurrentDateTimeTest $res]
    :set res [$ParseDateTimeTest $res]
    :set res [$FromUnixTimestampTest $res]
    :set res [$ToUnixTimestampTest $res]
    :set res [$FormatSecondsShortTest $res]
    :set res [$FormatSecondsLongTest $res]

    # Execute runtime clock tracking tests
    :set res [$GetUnixTimestampTest $res]

    :put "\1B[35m=== ALL DATE AND TIME TESTS COMPLETED ===\1B[0m"
    :return $res
}

:set GetWeekdayTest do={
    :local res {"passed"=0; "failed"=0}
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :error "Need to call with an empty array as parameter [:toarray {\"passed\"=0; \"failed\"=0}]]"
    }

    :local RunTestCase do={
        :global GetWeekday

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local ts [:tonum $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local actual [$GetWeekday $ts]
        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": " . $ts . " -> '" . $actual . "'")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": " . $ts . " | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
        :return $state
    }

    :put "Starting GetWeekday tests..."

    # Epoch base cases (1970-01-01 was a Thursday)
    :set res [$RunTestCase $res "0" "thursday" "Absolute Unix epoch start boundary"]
    :set res [$RunTestCase $res "86400" "friday" "One day past epoch baseline"]
    :set res [$RunTestCase $res "172800" "saturday" "Two days past epoch baseline"]
    :set res [$RunTestCase $res "259200" "sunday" "Three days past epoch - first Sunday"]
    :set res [$RunTestCase $res "345600" "monday" "Four days past epoch - first Monday"]

    # Mid-week sequence validation
    :set res [$RunTestCase $res "1709164799" "wednesday" "End of February 28 before leap day 2024"]
    :set res [$RunTestCase $res "1709164800" "thursday" "Start of leap day February 29 2024"]
    :set res [$RunTestCase $res "1709251200" "friday" "Start of March 1 right after leap day 2024"]

    # Year 2025 targets
    :set res [$RunTestCase $res "1740787199" "friday" "Last second of February 2025 standard year"]
    :set res [$RunTestCase $res "1740787200" "saturday" "Start of March 1 2025 standard year"]

    # Documentation example verification
    :set res [$RunTestCase $res "1750031999" "sunday" "Target example validation from documentation header"]

    # Year 2026 targets (Today check)
    :set res [$RunTestCase $res "1767225600" "thursday" "Start of the year Y2026 baseline"]
    :set res [$RunTestCase $res "1783639991" "thursday" "Current date timestamp validation anchor"]

    # Far future check (Year 2038)
    :set res [$RunTestCase $res "2147483647" "tuesday" "Maximum 32-bit signed integer time threshold"]

    :set res [$RunTestCase $res "0" "thursday" "Thursday"]
    :set res [$RunTestCase $res "86400" "friday" "Friday"]
    :set res [$RunTestCase $res "172800" "saturday" "Saturday"]
    :set res [$RunTestCase $res "259200" "sunday" "Sunday"]
    :set res [$RunTestCase $res "345600" "monday" "Monday"]
    :set res [$RunTestCase $res "432000" "tuesday" "Tuesday"]
    :set res [$RunTestCase $res "518400" "wednesday" "Wednesday"]
    :set res [$RunTestCase $res "604800" "thursday" "Exactly one week later"]

    :set res [$RunTestCase $res "0" "thursday" "Start of day"]
    :set res [$RunTestCase $res "1" "thursday" "One second later"]
    :set res [$RunTestCase $res "43200" "thursday" "Midday"]
    :set res [$RunTestCase $res "86398" "thursday" "Penultimate second"]
    :set res [$RunTestCase $res "86399" "thursday" "Last second of day"]
    :set res [$RunTestCase $res "86400" "friday" "Next day begins"]

    :set res [$RunTestCase $res "1709251199" "thursday" "Last second of leap day"]
    :set res [$RunTestCase $res "1709251200" "friday" "First second after leap day"]

    :set res [$RunTestCase $res "1735689599" "tuesday" "Last second of 2024"]
    :set res [$RunTestCase $res "1735689600" "wednesday" "First second of 2025"]

    :set res [$RunTestCase $res "1767225599" "wednesday" "Last second of 2025"]
    :set res [$RunTestCase $res "1767225600" "thursday" "First second of 2026"]

    :set res [$RunTestCase $res "951782400" "tuesday" "Leap century day 2000"]
    :set res [$RunTestCase $res "4107542400" "monday" "Non-leap century 2100"]
    :set res [$RunTestCase $res "13574649600" "wednesday" "Leap century 2400"]

    :set res [$RunTestCase $res "253402300799" "friday" "Maximum supported date"]

    :set res [$RunTestCase $res "951868800" "wednesday" "2000-03-01"]
    :set res [$RunTestCase $res "13574649600" "wednesday" "2400-03-01 same weekday after 400-year cycle"]

    :set res [$RunTestCase $res "0" "thursday" "Week 0"]
    :set res [$RunTestCase $res "604800" "thursday" "Week 1"]
    :set res [$RunTestCase $res "1209600" "thursday" "Week 2"]
    :set res [$RunTestCase $res "1814400" "thursday" "Week 3"]

    :put "Testing completed."
    :return $res
}

:set GetCurrentDateTimeTest do={
    :global GetCurrentDateTime
    :global FromUnixTimestamp
    :global ToUnixTimestamp

    :local res {"passed"=0; "failed"=0}
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :error "Need to call with an empty array as parameter [:toarray {\"passed\"=0; \"failed\"=0}]]"
    }

    :put "Starting GetCurrentDateTime runtime tests..."

    # Executing dynamic check to confirm current live runtime fetches validate correctly
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
    :local res {"passed"=0; "failed"=0}
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :error "Need to call with an empty array as parameter [:toarray {\"passed\"=0; \"failed\"=0}]]"
    }

    :local RunTestCase do={
        :global ParseDateTime

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local input [:tostr $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]
        :local actual ""

        # Safe execution container to handle internal script :error actions
        :do {
            :set actual [$ParseDateTime $input]
            :if ($actual = $expected) do={
                :set ($state->"passed") (($state->"passed") + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
            } else={
                :set ($state->"failed") (($state->"failed") + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
            }
        } on-error={
            :if ($expected = "error") do={
                :set ($state->"passed") (($state->"passed") + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . ": Checked invalid input '" . $input . "' threw error successfully")
            } else={
                :set ($state->"failed") (($state->"failed") + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": Unexpected crash on input '" . $input . "'")
            }
        }
        :return $state
    }

    :put "Starting ParseDateTime tests..."

    # Original base cases (RouterOS format)
    :set res [$RunTestCase $res "jan/01/2026 00:00:00" "2026-01-01 00:00:00" "Midnight start of the year"]
    :set res [$RunTestCase $res "feb/28/2024 23:59:59" "2024-02-28 23:59:59" "End of day leap year February"]
    :set res [$RunTestCase $res "jul/09/2026 15:45:21" "2026-07-09 15:45:21" "Standard afternoon daytime string"]

    # Different month letter case
    :set res [$RunTestCase $res "mAy/15/2026 00:00:01" "2026-05-15 00:00:01" "Midnight start of the year"]
    :set res [$RunTestCase $res "Sep/07/2024 23:59:59" "2024-09-07 23:59:59" "End of day leap year February"]
    :set res [$RunTestCase $res "MAR/04/2026 15:45:21" "2026-03-04 15:45:21" "Standard afternoon daytime string"]

    # Extended month mapping tests (RouterOS format)
    :set res [$RunTestCase $res "mar/15/2025 08:30:00" "2025-03-15 08:30:00" "March date format conversion"]
    :set res [$RunTestCase $res "apr/30/2025 12:00:00" "2025-04-30 12:00:00" "April date format conversion"]
    :set res [$RunTestCase $res "may/01/2025 06:15:45" "2025-05-01 06:15:45" "May date format conversion"]
    :set res [$RunTestCase $res "jun/22/2025 18:40:12" "2025-06-22 18:40:12" "June date format conversion"]
    :set res [$RunTestCase $res "aug/31/2025 21:05:00" "2025-08-31 21:05:00" "August date format conversion"]
    :set res [$RunTestCase $res "sep/10/2025 09:14:23" "2025-09-10 09:14:23" "September date format conversion"]
    :set res [$RunTestCase $res "oct/05/2025 04:02:59" "2025-10-05 04:02:59" "October date format conversion"]
    :set res [$RunTestCase $res "nov/11/2025 11:11:11" "2025-11-11 11:11:11" "November date format conversion"]
    :set res [$RunTestCase $res "dec/25/2025 20:00:00" "2025-12-25 20:00:00" "December date format conversion"]

    # Native ISO format pass-through tests
    :set res [$RunTestCase $res "2025-07-25 12:31:25" "2025-07-25 12:31:25" "Standard input matching native ISO pattern"]
    :set res [$RunTestCase $res "1970-01-01 00:00:00" "1970-01-01 00:00:00" "Epoch baseline input matching native ISO pattern"]

    # Negative validation tests (Invalid layout structures)
    :set res [$RunTestCase $res "bad/12/2025 12:00:00" "error" "Rejection check for non-existent month name"]
    :set res [$RunTestCase $res "2025/07/25 12:31:25" "error" "Rejection check for slash separators in ISO style"]
    :set res [$RunTestCase $res "jul-31-2025 03:30:05" "error" "Rejection check for dash separators in ROS style"]
    :set res [$RunTestCase $res "jul/31/2025"          "error" "Rejection check for completely missing time block"]
    :set res [$RunTestCase $res "12:00:00"             "error" "Rejection check for completely missing date block"]

    :put "Testing completed."
    :return $res
}

:set FromUnixTimestampTest do={
    :local res {"passed"=0; "failed"=0}
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :error "Need to call with an empty array as parameter [:toarray {\"passed\"=0; \"failed\"=0}]]"
    }

    :local RunTestCase do={
        :global FromUnixTimestamp

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local expected [:tostr $2]
        :local inputStr [:tonum $3]
        :local name [:tostr $4]

        :local actual [$FromUnixTimestamp $inputStr]
        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputStr . "' -> " . $actual)
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputStr . "' | Expected: " . $expected . ", Got: " . $actual)
        }
        :return $state
    }

    :put "Starting extended FromUnixTimestamp tests..."

    # =========================================================================
    # Epoch (1970)
    # =========================================================================
    :set res [$RunTestCase $res "1970-01-01 00:00:00" "0" "Absolute epoch zero starting point"]
    :set res [$RunTestCase $res "1970-01-01 00:00:01" "1" "One second past epoch threshold"]
    :set res [$RunTestCase $res "1970-01-01 00:00:59" "59" "Last second of the first minute"]
    :set res [$RunTestCase $res "1970-01-01 00:01:00" "60" "Start of the second minute"]
    :set res [$RunTestCase $res "1970-01-01 00:59:59" "3599" "Last second of the first hour"]
    :set res [$RunTestCase $res "1970-01-01 01:00:00" "3600" "One hour past epoch threshold"]
    :set res [$RunTestCase $res "1970-01-01 23:59:59" "86399" "Last second of the first day"]
    :set res [$RunTestCase $res "1970-01-02 00:00:00" "86400" "Start of the second day"]
    :set res [$RunTestCase $res "1970-01-31 23:59:59" "2678399" "End of January 1970"]
    :set res [$RunTestCase $res "1970-02-01 00:00:00" "2678400" "Start of February 1970"]
    :set res [$RunTestCase $res "1970-02-28 23:59:59" "5097599" "End of February 1970"]
    :set res [$RunTestCase $res "1970-03-01 00:00:00" "5097600" "Start of March 1970"]
    :set res [$RunTestCase $res "1970-12-31 23:59:59" "31535999" "Last second of the epoch year"]

    # =========================================================================
    # First leap year after epoch (1972)
    # =========================================================================
    :set res [$RunTestCase $res "1972-02-28 23:59:59" "68169599" "Second before leap day in 1972"]
    :set res [$RunTestCase $res "1972-02-29 00:00:00" "68169600" "Leap day begins in 1972"]
    :set res [$RunTestCase $res "1972-02-29 23:59:59" "68255999" "Leap day ends in 1972"]
    :set res [$RunTestCase $res "1972-03-01 00:00:00" "68256000" "March begins after leap day in 1972"]

    # =========================================================================
    # Leap year (2024)
    # =========================================================================
    :set res [$RunTestCase $res "2024-01-31 23:59:59" "1706745599" "End of January 2024"]
    :set res [$RunTestCase $res "2024-02-01 00:00:00" "1706745600" "Start of February 2024"]
    :set res [$RunTestCase $res "2024-02-28 23:59:59" "1709164799" "Second before leap day February 29"]
    :set res [$RunTestCase $res "2024-02-29 00:00:00" "1709164800" "Start of the leap day February 29"]
    :set res [$RunTestCase $res "2024-02-29 12:34:56" "1709210096" "Middle of leap day"]
    :set res [$RunTestCase $res "2024-02-29 23:59:59" "1709251199" "End of the leap day February 29"]
    :set res [$RunTestCase $res "2024-03-01 00:00:00" "1709251200" "Start of March right after leap day"]
    :set res [$RunTestCase $res "2024-12-31 23:59:59" "1735689599" "End of leap year 2024"]

    # =========================================================================
    # Standard year (2025)
    # =========================================================================
    :set res [$RunTestCase $res "2025-01-01 00:00:00" "1735689600" "Start of 2025"]
    :set res [$RunTestCase $res "2025-02-28 23:59:59" "1740787199" "End of February in a standard year"]
    :set res [$RunTestCase $res "2025-03-01 00:00:00" "1740787200" "Start of March in a standard year"]
    :set res [$RunTestCase $res "2025-04-30 23:59:59" "1746057599" "End of April"]
    :set res [$RunTestCase $res "2025-05-01 00:00:00" "1746057600" "Start of May"]
    :set res [$RunTestCase $res "2025-06-30 23:59:59" "1751327999" "End of June"]
    :set res [$RunTestCase $res "2025-07-01 00:00:00" "1751328000" "Start of July"]
    :set res [$RunTestCase $res "2025-12-31 23:59:59" "1767225599" "End of 2025"]

    # =========================================================================
    # Arbitrary dates
    # =========================================================================
    :set res [$RunTestCase $res "1980-06-15 12:00:00" "329918400" "Midday in 1980"]
    :set res [$RunTestCase $res "1999-12-31 23:59:59" "946684799" "End of the 20th century"]
    :set res [$RunTestCase $res "2000-01-01 00:00:00" "946684800" "Start of year 2000"]
    :set res [$RunTestCase $res "2026-01-01 00:00:00" "1767225600" "Start of the year Y2026 baseline"]
    :set res [$RunTestCase $res "2026-07-09 15:45:00" "1783611900" "Arbitrary current mid-year verification"]
    :set res [$RunTestCase $res "9999-12-31 23:59:59" "253402300799" "Last possible date"]

    # =========================================================================
    # Century rules
    # =========================================================================
    :set res [$RunTestCase $res "2000-02-28 23:59:59" "951782399" "Before leap day in year 2000"]
    :set res [$RunTestCase $res "2000-02-29 00:00:00" "951782400" "Leap day in year 2000"]
    :set res [$RunTestCase $res "2000-03-01 00:00:00" "951868800" "March after leap day in year 2000"]

    :set res [$RunTestCase $res "2100-02-28 23:59:59" "4107542399" "End of February century boundary check"]
    :set res [$RunTestCase $res "2100-03-01 00:00:00" "4107542400" "Start of March century boundary check"]

    # =========================================================================
    # 32-bit boundary
    # =========================================================================
    :set res [$RunTestCase $res "2038-01-19 03:14:06" "2147483646" "One second before signed 32-bit limit"]
    :set res [$RunTestCase $res "2038-01-19 03:14:07" "2147483647" "Maximum standard 32-bit signed integer limit"]
    :set res [$RunTestCase $res "2038-01-19 03:14:08" "2147483648" "First second beyond signed 32-bit limit"]

    # =========================================================================
    # Month boundaries (1970)
    # =========================================================================
    :set res [$RunTestCase $res "1970-03-31 23:59:59" "7775999" "End of March 1970"]
    :set res [$RunTestCase $res "1970-04-01 00:00:00" "7776000" "Start of April 1970"]
    :set res [$RunTestCase $res "1970-04-30 23:59:59" "10367999" "End of April 1970"]
    :set res [$RunTestCase $res "1970-05-01 00:00:00" "10368000" "Start of May 1970"]
    :set res [$RunTestCase $res "1970-05-31 23:59:59" "13046399" "End of May 1970"]
    :set res [$RunTestCase $res "1970-06-01 00:00:00" "13046400" "Start of June 1970"]
    :set res [$RunTestCase $res "1970-06-30 23:59:59" "15638399" "End of June 1970"]
    :set res [$RunTestCase $res "1970-07-01 00:00:00" "15638400" "Start of July 1970"]
    :set res [$RunTestCase $res "1970-07-31 23:59:59" "18316799" "End of July 1970"]
    :set res [$RunTestCase $res "1970-08-01 00:00:00" "18316800" "Start of August 1970"]
    :set res [$RunTestCase $res "1970-08-31 23:59:59" "20995199" "End of August 1970"]
    :set res [$RunTestCase $res "1970-09-01 00:00:00" "20995200" "Start of September 1970"]
    :set res [$RunTestCase $res "1970-09-30 23:59:59" "23587199" "End of September 1970"]
    :set res [$RunTestCase $res "1970-10-01 00:00:00" "23587200" "Start of October 1970"]
    :set res [$RunTestCase $res "1970-10-31 23:59:59" "26265599" "End of October 1970"]
    :set res [$RunTestCase $res "1970-11-01 00:00:00" "26265600" "Start of November 1970"]
    :set res [$RunTestCase $res "1970-11-30 23:59:59" "28857599" "End of November 1970"]
    :set res [$RunTestCase $res "1970-12-01 00:00:00" "28857600" "Start of December 1970"]

    # =========================================================================
    # Leap year edge cases
    # =========================================================================
    :set res [$RunTestCase $res "1972-01-01 00:00:00" "63072000" "Start of leap year 1972"]
    :set res [$RunTestCase $res "1972-12-31 23:59:59" "94694399" "End of leap year 1972"]

    :set res [$RunTestCase $res "1996-02-28 23:59:59" "825551999" "1996 before leap day"]
    :set res [$RunTestCase $res "1996-02-29 00:00:00" "825552000" "1996 leap day"]
    :set res [$RunTestCase $res "1996-03-01 00:00:00" "825638400" "1996 after leap day"]

    :set res [$RunTestCase $res "2004-02-28 23:59:59" "1078012799" "2004 before leap day"]
    :set res [$RunTestCase $res "2004-02-29 00:00:00" "1078012800" "2004 leap day"]
    :set res [$RunTestCase $res "2004-03-01 00:00:00" "1078099200" "2004 after leap day"]

    # =========================================================================
    # Non-leap century
    # =========================================================================
    :set res [$RunTestCase $res "2100-12-31 23:59:59" "4133980799" "End of non-leap century year"]

    # =========================================================================
    # Leap century
    # =========================================================================
    :set res [$RunTestCase $res "2000-12-31 23:59:59" "978307199" "End of leap century year"]
    :set res [$RunTestCase $res "2400-02-28 23:59:59" "13574563199" "2400 before leap day"]
    :set res [$RunTestCase $res "2400-02-29 00:00:00" "13574563200" "2400 leap day"]
    :set res [$RunTestCase $res "2400-03-01 00:00:00" "13574649600" "2400 after leap day"]

    # =========================================================================
    # End/start of years
    # =========================================================================
    :set res [$RunTestCase $res "1971-12-31 23:59:59" "63071999" "End of 1971"]
    :set res [$RunTestCase $res "1972-01-01 00:00:00" "63072000" "Start of 1972"]

    :set res [$RunTestCase $res "1999-01-01 00:00:00" "915148800" "Start of 1999"]
    :set res [$RunTestCase $res "1999-12-31 23:59:58" "946684798" "Penultimate second of 1999"]
    :set res [$RunTestCase $res "1999-12-31 23:59:59" "946684799" "Last second of 1999"]
    :set res [$RunTestCase $res "2000-01-01 00:00:00" "946684800" "Start of 2000"]

    # =========================================================================
    # Time-of-day edge cases
    # =========================================================================
    :set res [$RunTestCase $res "2025-06-15 00:00:00" "1749945600" "Start of day"]
    :set res [$RunTestCase $res "2025-06-15 00:00:01" "1749945601" "Second after midnight"]
    :set res [$RunTestCase $res "2025-06-15 11:59:59" "1749988799" "Second before noon"]
    :set res [$RunTestCase $res "2025-06-15 12:00:00" "1749988800" "Exact noon"]
    :set res [$RunTestCase $res "2025-06-15 23:59:58" "1750031998" "Penultimate second of day"]
    :set res [$RunTestCase $res "2025-06-15 23:59:59" "1750031999" "Last second of day"]

    # =========================================================================
    # 400-year cycle verification
    # =========================================================================
    :set res [$RunTestCase $res "2000-03-01 00:00:00" "951868800" "Leap century 2000"]
    :set res [$RunTestCase $res "2100-03-01 00:00:00" "4107542400" "Non-leap century 2100"]
    :set res [$RunTestCase $res "2400-03-01 00:00:00" "13574649600" "Leap century 2400"]

    # =========================================================================
    # Other tests
    # =========================================================================
    :set res [$RunTestCase $res "2000-02-29 12:00:00" "951825600" "Middle of leap century day"]
    :set res [$RunTestCase $res "2100-02-28 00:00:00" "4107456000" "Start of last day before non-leap century transition"]
    :set res [$RunTestCase $res "2100-03-01 00:00:00" "4107542400" "First day after skipped leap day in 2100"]
    :set res [$RunTestCase $res "1972-01-02 00:00:00" "63158400" "Second day of leap year 1972"]
    :set res [$RunTestCase $res "2010-01-01 00:00:00" "1262304000" "Round decade boundary"]
    :set res [$RunTestCase $res "2019-12-31 23:59:59" "1577836799" "End of decade"]
    :set res [$RunTestCase $res "2020-01-01 00:00:00" "1577836800" "Start of leap decade year"]
    :set res [$RunTestCase $res "2040-01-01 00:00:00" "2208988800" "Post 32-bit future date"]
    :set res [$RunTestCase $res "2100-01-01 23:59:59" "4102531199" "Century year beginning"]
    :set res [$RunTestCase $res "9999-12-31 00:00:00" "253402214400" "Near maximum supported date"]

    :set res [$RunTestCase $res "1973-01-01 00:00:00" "94694400" "First second after leap year"]
    :set res [$RunTestCase $res "2024-01-31 23:59:59" "1706745599" "End of January"]
    :set res [$RunTestCase $res "2024-03-31 23:59:59" "1711929599" "End of March"]
    :set res [$RunTestCase $res "2024-04-30 23:59:59" "1714521599" "End of April"]
    :set res [$RunTestCase $res "2024-05-31 23:59:59" "1717199999" "End of May"]
    :set res [$RunTestCase $res "2024-06-30 23:59:59" "1719791999" "End of June"]
    :set res [$RunTestCase $res "2000-01-01 00:00:00" "946684800" "Y2K midnight"]
    :set res [$RunTestCase $res "2000-01-01 12:00:00" "946728000" "Y2K noon"]
    :set res [$RunTestCase $res "2000-01-01 23:59:59" "946771199" "Y2K end of day"]

    :put "Testing completed."
    :return $res
}

:set ToUnixTimestampTest do={
    :local res {"passed"=0; "failed"=0}
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :error "Need to call with an empty array as parameter [:toarray {\"passed\"=0; \"failed\"=0}]]"
    }

    :local RunTestCase do={
        :global ToUnixTimestamp

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local inputStr [:tostr $2]
        :local expected [:tonum $3]
        :local name [:tostr $4]

        :local actual [$ToUnixTimestamp $inputStr]
        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputStr . "' -> " . $actual)
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputStr . "' | Expected: " . $expected . ", Got: " . $actual)
        }
        :return $state
    }

    :put "Starting extended ToUnixTimestamp tests..."

    # =========================================================================
    # Epoch (1970)
    # =========================================================================
    :set res [$RunTestCase $res "1970-01-01 00:00:00" "0" "Absolute epoch zero starting point"]
    :set res [$RunTestCase $res "1970-01-01 00:00:01" "1" "One second past epoch threshold"]
    :set res [$RunTestCase $res "1970-01-01 00:00:59" "59" "Last second of the first minute"]
    :set res [$RunTestCase $res "1970-01-01 00:01:00" "60" "Start of the second minute"]
    :set res [$RunTestCase $res "1970-01-01 00:59:59" "3599" "Last second of the first hour"]
    :set res [$RunTestCase $res "1970-01-01 01:00:00" "3600" "One hour past epoch threshold"]
    :set res [$RunTestCase $res "1970-01-01 23:59:59" "86399" "Last second of the first day"]
    :set res [$RunTestCase $res "1970-01-02 00:00:00" "86400" "Start of the second day"]
    :set res [$RunTestCase $res "1970-01-31 23:59:59" "2678399" "End of January 1970"]
    :set res [$RunTestCase $res "1970-02-01 00:00:00" "2678400" "Start of February 1970"]
    :set res [$RunTestCase $res "1970-02-28 23:59:59" "5097599" "End of February 1970"]
    :set res [$RunTestCase $res "1970-03-01 00:00:00" "5097600" "Start of March 1970"]
    :set res [$RunTestCase $res "1970-12-31 23:59:59" "31535999" "Last second of the epoch year"]

    # =========================================================================
    # First leap year after epoch (1972)
    # =========================================================================
    :set res [$RunTestCase $res "1972-02-28 23:59:59" "68169599" "Second before leap day in 1972"]
    :set res [$RunTestCase $res "1972-02-29 00:00:00" "68169600" "Leap day begins in 1972"]
    :set res [$RunTestCase $res "1972-02-29 23:59:59" "68255999" "Leap day ends in 1972"]
    :set res [$RunTestCase $res "1972-03-01 00:00:00" "68256000" "March begins after leap day in 1972"]

    # =========================================================================
    # Leap year (2024)
    # =========================================================================
    :set res [$RunTestCase $res "2024-01-31 23:59:59" "1706745599" "End of January 2024"]
    :set res [$RunTestCase $res "2024-02-01 00:00:00" "1706745600" "Start of February 2024"]
    :set res [$RunTestCase $res "2024-02-28 23:59:59" "1709164799" "Second before leap day February 29"]
    :set res [$RunTestCase $res "2024-02-29 00:00:00" "1709164800" "Start of the leap day February 29"]
    :set res [$RunTestCase $res "2024-02-29 12:34:56" "1709210096" "Middle of leap day"]
    :set res [$RunTestCase $res "2024-02-29 23:59:59" "1709251199" "End of the leap day February 29"]
    :set res [$RunTestCase $res "2024-03-01 00:00:00" "1709251200" "Start of March right after leap day"]
    :set res [$RunTestCase $res "2024-12-31 23:59:59" "1735689599" "End of leap year 2024"]

    # =========================================================================
    # Standard year (2025)
    # =========================================================================
    :set res [$RunTestCase $res "2025-01-01 00:00:00" "1735689600" "Start of 2025"]
    :set res [$RunTestCase $res "2025-02-28 23:59:59" "1740787199" "End of February in a standard year"]
    :set res [$RunTestCase $res "2025-03-01 00:00:00" "1740787200" "Start of March in a standard year"]
    :set res [$RunTestCase $res "2025-04-30 23:59:59" "1746057599" "End of April"]
    :set res [$RunTestCase $res "2025-05-01 00:00:00" "1746057600" "Start of May"]
    :set res [$RunTestCase $res "2025-06-30 23:59:59" "1751327999" "End of June"]
    :set res [$RunTestCase $res "2025-07-01 00:00:00" "1751328000" "Start of July"]
    :set res [$RunTestCase $res "2025-12-31 23:59:59" "1767225599" "End of 2025"]

    # =========================================================================
    # Arbitrary dates
    # =========================================================================
    :set res [$RunTestCase $res "1980-06-15 12:00:00" "329918400" "Midday in 1980"]
    :set res [$RunTestCase $res "1999-12-31 23:59:59" "946684799" "End of the 20th century"]
    :set res [$RunTestCase $res "2000-01-01 00:00:00" "946684800" "Start of year 2000"]
    :set res [$RunTestCase $res "2026-01-01 00:00:00" "1767225600" "Start of the year Y2026 baseline"]
    :set res [$RunTestCase $res "2026-07-09 15:45:00" "1783611900" "Arbitrary current mid-year verification"]
    :set res [$RunTestCase $res "9999-12-31 23:59:59" "253402300799" "Last possible date"]

    # =========================================================================
    # Century rules
    # =========================================================================
    :set res [$RunTestCase $res "2000-02-28 23:59:59" "951782399" "Before leap day in year 2000"]
    :set res [$RunTestCase $res "2000-02-29 00:00:00" "951782400" "Leap day in year 2000"]
    :set res [$RunTestCase $res "2000-03-01 00:00:00" "951868800" "March after leap day in year 2000"]

    :set res [$RunTestCase $res "2100-02-28 23:59:59" "4107542399" "End of February century boundary check"]
    :set res [$RunTestCase $res "2100-03-01 00:00:00" "4107542400" "Start of March century boundary check"]

    # =========================================================================
    # 32-bit boundary
    # =========================================================================
    :set res [$RunTestCase $res "2038-01-19 03:14:06" "2147483646" "One second before signed 32-bit limit"]
    :set res [$RunTestCase $res "2038-01-19 03:14:07" "2147483647" "Maximum standard 32-bit signed integer limit"]
    :set res [$RunTestCase $res "2038-01-19 03:14:08" "2147483648" "First second beyond signed 32-bit limit"]

    # =========================================================================
    # Month boundaries (1970)
    # =========================================================================
    :set res [$RunTestCase $res "1970-03-31 23:59:59" "7775999" "End of March 1970"]
    :set res [$RunTestCase $res "1970-04-01 00:00:00" "7776000" "Start of April 1970"]
    :set res [$RunTestCase $res "1970-04-30 23:59:59" "10367999" "End of April 1970"]
    :set res [$RunTestCase $res "1970-05-01 00:00:00" "10368000" "Start of May 1970"]
    :set res [$RunTestCase $res "1970-05-31 23:59:59" "13046399" "End of May 1970"]
    :set res [$RunTestCase $res "1970-06-01 00:00:00" "13046400" "Start of June 1970"]
    :set res [$RunTestCase $res "1970-06-30 23:59:59" "15638399" "End of June 1970"]
    :set res [$RunTestCase $res "1970-07-01 00:00:00" "15638400" "Start of July 1970"]
    :set res [$RunTestCase $res "1970-07-31 23:59:59" "18316799" "End of July 1970"]
    :set res [$RunTestCase $res "1970-08-01 00:00:00" "18316800" "Start of August 1970"]
    :set res [$RunTestCase $res "1970-08-31 23:59:59" "20995199" "End of August 1970"]
    :set res [$RunTestCase $res "1970-09-01 00:00:00" "20995200" "Start of September 1970"]
    :set res [$RunTestCase $res "1970-09-30 23:59:59" "23587199" "End of September 1970"]
    :set res [$RunTestCase $res "1970-10-01 00:00:00" "23587200" "Start of October 1970"]
    :set res [$RunTestCase $res "1970-10-31 23:59:59" "26265599" "End of October 1970"]
    :set res [$RunTestCase $res "1970-11-01 00:00:00" "26265600" "Start of November 1970"]
    :set res [$RunTestCase $res "1970-11-30 23:59:59" "28857599" "End of November 1970"]
    :set res [$RunTestCase $res "1970-12-01 00:00:00" "28857600" "Start of December 1970"]

    # =========================================================================
    # Leap year edge cases
    # =========================================================================
    :set res [$RunTestCase $res "1972-01-01 00:00:00" "63072000" "Start of leap year 1972"]
    :set res [$RunTestCase $res "1972-12-31 23:59:59" "94694399" "End of leap year 1972"]

    :set res [$RunTestCase $res "1996-02-28 23:59:59" "825551999" "1996 before leap day"]
    :set res [$RunTestCase $res "1996-02-29 00:00:00" "825552000" "1996 leap day"]
    :set res [$RunTestCase $res "1996-03-01 00:00:00" "825638400" "1996 after leap day"]

    :set res [$RunTestCase $res "2004-02-28 23:59:59" "1078012799" "2004 before leap day"]
    :set res [$RunTestCase $res "2004-02-29 00:00:00" "1078012800" "2004 leap day"]
    :set res [$RunTestCase $res "2004-03-01 00:00:00" "1078099200" "2004 after leap day"]

    # =========================================================================
    # Non-leap century
    # =========================================================================
    :set res [$RunTestCase $res "2100-12-31 23:59:59" "4133980799" "End of non-leap century year"]

    # =========================================================================
    # Leap century
    # =========================================================================
    :set res [$RunTestCase $res "2000-12-31 23:59:59" "978307199" "End of leap century year"]
    :set res [$RunTestCase $res "2400-02-28 23:59:59" "13574563199" "2400 before leap day"]
    :set res [$RunTestCase $res "2400-02-29 00:00:00" "13574563200" "2400 leap day"]
    :set res [$RunTestCase $res "2400-03-01 00:00:00" "13574649600" "2400 after leap day"]

    # =========================================================================
    # End/start of years
    # =========================================================================
    :set res [$RunTestCase $res "1971-12-31 23:59:59" "63071999" "End of 1971"]
    :set res [$RunTestCase $res "1972-01-01 00:00:00" "63072000" "Start of 1972"]

    :set res [$RunTestCase $res "1999-01-01 00:00:00" "915148800" "Start of 1999"]
    :set res [$RunTestCase $res "1999-12-31 23:59:58" "946684798" "Penultimate second of 1999"]
    :set res [$RunTestCase $res "1999-12-31 23:59:59" "946684799" "Last second of 1999"]
    :set res [$RunTestCase $res "2000-01-01 00:00:00" "946684800" "Start of 2000"]

    # =========================================================================
    # Time-of-day edge cases
    # =========================================================================
    :set res [$RunTestCase $res "2025-06-15 00:00:00" "1749945600" "Start of day"]
    :set res [$RunTestCase $res "2025-06-15 00:00:01" "1749945601" "Second after midnight"]
    :set res [$RunTestCase $res "2025-06-15 11:59:59" "1749988799" "Second before noon"]
    :set res [$RunTestCase $res "2025-06-15 12:00:00" "1749988800" "Exact noon"]
    :set res [$RunTestCase $res "2025-06-15 23:59:58" "1750031998" "Penultimate second of day"]
    :set res [$RunTestCase $res "2025-06-15 23:59:59" "1750031999" "Last second of day"]

    # =========================================================================
    # 400-year cycle verification
    # =========================================================================
    :set res [$RunTestCase $res "2000-03-01 00:00:00" "951868800" "Leap century 2000"]
    :set res [$RunTestCase $res "2100-03-01 00:00:00" "4107542400" "Non-leap century 2100"]
    :set res [$RunTestCase $res "2400-03-01 00:00:00" "13574649600" "Leap century 2400"]

    # =========================================================================
    # Other tests
    # =========================================================================
    :set res [$RunTestCase $res "2000-02-29 12:00:00" "951825600" "Middle of leap century day"]
    :set res [$RunTestCase $res "2100-02-28 00:00:00" "4107456000" "Start of last day before non-leap century transition"]
    :set res [$RunTestCase $res "2100-03-01 00:00:00" "4107542400" "First day after skipped leap day in 2100"]
    :set res [$RunTestCase $res "1972-01-02 00:00:00" "63158400" "Second day of leap year 1972"]
    :set res [$RunTestCase $res "2010-01-01 00:00:00" "1262304000" "Round decade boundary"]
    :set res [$RunTestCase $res "2019-12-31 23:59:59" "1577836799" "End of decade"]
    :set res [$RunTestCase $res "2020-01-01 00:00:00" "1577836800" "Start of leap decade year"]
    :set res [$RunTestCase $res "2040-01-01 00:00:00" "2208988800" "Post 32-bit future date"]
    :set res [$RunTestCase $res "2100-01-01 23:59:59" "4102531199" "Century year beginning"]
    :set res [$RunTestCase $res "9999-12-31 00:00:00" "253402214400" "Near maximum supported date"]

    :set res [$RunTestCase $res "1973-01-01 00:00:00" "94694400" "First second after leap year"]
    :set res [$RunTestCase $res "2024-01-31 23:59:59" "1706745599" "End of January"]
    :set res [$RunTestCase $res "2024-03-31 23:59:59" "1711929599" "End of March"]
    :set res [$RunTestCase $res "2024-04-30 23:59:59" "1714521599" "End of April"]
    :set res [$RunTestCase $res "2024-05-31 23:59:59" "1717199999" "End of May"]
    :set res [$RunTestCase $res "2024-06-30 23:59:59" "1719791999" "End of June"]
    :set res [$RunTestCase $res "2000-01-01 00:00:00" "946684800" "Y2K midnight"]
    :set res [$RunTestCase $res "2000-01-01 12:00:00" "946728000" "Y2K noon"]
    :set res [$RunTestCase $res "2000-01-01 23:59:59" "946771199" "Y2K end of day"]

    # =========================================================================
    # Epoch (1970)
    # =========================================================================
    :set res [$RunTestCase $res "jan/01/1970 00:00:00" "0" "Absolute epoch zero starting point"]
    :set res [$RunTestCase $res "jan/01/1970 00:00:01" "1" "One second past epoch threshold"]
    :set res [$RunTestCase $res "jan/01/1970 00:00:59" "59" "Last second of the first minute"]
    :set res [$RunTestCase $res "jan/01/1970 00:01:00" "60" "Start of the second minute"]
    :set res [$RunTestCase $res "jan/01/1970 00:59:59" "3599" "Last second of the first hour"]
    :set res [$RunTestCase $res "jan/01/1970 01:00:00" "3600" "One hour past epoch threshold"]
    :set res [$RunTestCase $res "jan/01/1970 23:59:59" "86399" "Last second of the first day"]
    :set res [$RunTestCase $res "jan/02/1970 00:00:00" "86400" "Start of the second day"]
    :set res [$RunTestCase $res "jan/31/1970 23:59:59" "2678399" "End of January 1970"]
    :set res [$RunTestCase $res "feb/01/1970 00:00:00" "2678400" "Start of February 1970"]
    :set res [$RunTestCase $res "feb/28/1970 23:59:59" "5097599" "End of February 1970"]
    :set res [$RunTestCase $res "mar/01/1970 00:00:00" "5097600" "Start of March 1970"]
    :set res [$RunTestCase $res "dec/31/1970 23:59:59" "31535999" "Last second of the epoch year"]

    # =========================================================================
    # First leap year after epoch (1972)
    # =========================================================================
    :set res [$RunTestCase $res "feb/28/1972 23:59:59" "68169599" "Second before leap day in 1972"]
    :set res [$RunTestCase $res "feb/29/1972 00:00:00" "68169600" "Leap day begins in 1972"]
    :set res [$RunTestCase $res "feb/29/1972 23:59:59" "68255999" "Leap day ends in 1972"]
    :set res [$RunTestCase $res "mar/01/1972 00:00:00" "68256000" "March begins after leap day in 1972"]

    # =========================================================================
    # Leap year (2024)
    # =========================================================================
    :set res [$RunTestCase $res "jan/31/2024 23:59:59" "1706745599" "End of January 2024"]
    :set res [$RunTestCase $res "feb/01/2024 00:00:00" "1706745600" "Start of February 2024"]
    :set res [$RunTestCase $res "feb/28/2024 23:59:59" "1709164799" "Second before leap day February 29"]
    :set res [$RunTestCase $res "feb/29/2024 00:00:00" "1709164800" "Start of the leap day February 29"]
    :set res [$RunTestCase $res "feb/29/2024 12:34:56" "1709210096" "Middle of leap day"]
    :set res [$RunTestCase $res "feb/29/2024 23:59:59" "1709251199" "End of the leap day February 29"]
    :set res [$RunTestCase $res "mar/01/2024 00:00:00" "1709251200" "Start of March right after leap day"]
    :set res [$RunTestCase $res "dec/31/2024 23:59:59" "1735689599" "End of leap year 2024"]

    # =========================================================================
    # Standard year (2025)
    # =========================================================================
    :set res [$RunTestCase $res "jan/01/2025 00:00:00" "1735689600" "Start of 2025"]
    :set res [$RunTestCase $res "feb/28/2025 23:59:59" "1740787199" "End of February in a standard year"]
    :set res [$RunTestCase $res "mar/01/2025 00:00:00" "1740787200" "Start of March in a standard year"]
    :set res [$RunTestCase $res "apr/30/2025 23:59:59" "1746057599" "End of April"]
    :set res [$RunTestCase $res "may/01/2025 00:00:00" "1746057600" "Start of May"]
    :set res [$RunTestCase $res "jun/30/2025 23:59:59" "1751327999" "End of June"]
    :set res [$RunTestCase $res "jul/01/2025 00:00:00" "1751328000" "Start of July"]
    :set res [$RunTestCase $res "dec/31/2025 23:59:59" "1767225599" "End of 2025"]

    # =========================================================================
    # Different month letter case
    # =========================================================================
    :set res [$RunTestCase $res "jAn/01/2025 00:00:00" "1735689600" "Start of 2025"]
    :set res [$RunTestCase $res "feB/28/2025 23:59:59" "1740787199" "End of February in a standard year"]
    :set res [$RunTestCase $res "Mar/01/2025 00:00:00" "1740787200" "Start of March in a standard year"]
    :set res [$RunTestCase $res "APR/30/2025 23:59:59" "1746057599" "End of April"]
    :set res [$RunTestCase $res "mAY/01/2025 00:00:00" "1746057600" "Start of May"]
    :set res [$RunTestCase $res "JUn/30/2025 23:59:59" "1751327999" "End of June"]

    # =========================================================================
    # Arbitrary dates
    # =========================================================================
    :set res [$RunTestCase $res "jun/15/1980 12:00:00" "329918400" "Midday in 1980"]
    :set res [$RunTestCase $res "dec/31/1999 23:59:59" "946684799" "End of the 20th century"]
    :set res [$RunTestCase $res "jan/01/2000 00:00:00" "946684800" "Start of year 2000"]
    :set res [$RunTestCase $res "jan/01/2026 00:00:00" "1767225600" "Start of the year Y2026 baseline"]
    :set res [$RunTestCase $res "jul/09/2026 15:45:00" "1783611900" "Arbitrary current mid-year verification"]
    :set res [$RunTestCase $res "dec/31/9999 23:59:59" "253402300799" "Last possible date"]

    # =========================================================================
    # Century rules
    # =========================================================================
    :set res [$RunTestCase $res "feb/28/2000 23:59:59" "951782399" "Before leap day in year 2000"]
    :set res [$RunTestCase $res "feb/29/2000 00:00:00" "951782400" "Leap day in year 2000"]
    :set res [$RunTestCase $res "mar/01/2000 00:00:00" "951868800" "March after leap day in year 2000"]

    :set res [$RunTestCase $res "feb/28/2100 23:59:59" "4107542399" "End of February century boundary check"]
    :set res [$RunTestCase $res "mar/01/2100 00:00:00" "4107542400" "Start of March century boundary check"]

    # =========================================================================
    # 32-bit boundary
    # =========================================================================
    :set res [$RunTestCase $res "jan/19/2038 03:14:06" "2147483646" "One second before signed 32-bit limit"]
    :set res [$RunTestCase $res "jan/19/2038 03:14:07" "2147483647" "Maximum standard 32-bit signed integer limit"]
    :set res [$RunTestCase $res "jan/19/2038 03:14:08" "2147483648" "First second beyond signed 32-bit limit"]

    # =========================================================================
    # Month boundaries (1970)
    # =========================================================================
    :set res [$RunTestCase $res "mar/31/1970 23:59:59" "7775999" "End of March 1970"]
    :set res [$RunTestCase $res "apr/01/1970 00:00:00" "7776000" "Start of April 1970"]
    :set res [$RunTestCase $res "apr/30/1970 23:59:59" "10367999" "End of April 1970"]
    :set res [$RunTestCase $res "may/01/1970 00:00:00" "10368000" "Start of May 1970"]
    :set res [$RunTestCase $res "may/31/1970 23:59:59" "13046399" "End of May 1970"]
    :set res [$RunTestCase $res "jun/01/1970 00:00:00" "13046400" "Start of June 1970"]
    :set res [$RunTestCase $res "jun/30/1970 23:59:59" "15638399" "End of June 1970"]
    :set res [$RunTestCase $res "jul/01/1970 00:00:00" "15638400" "Start of July 1970"]
    :set res [$RunTestCase $res "jul/31/1970 23:59:59" "18316799" "End of July 1970"]
    :set res [$RunTestCase $res "aug/01/1970 00:00:00" "18316800" "Start of August 1970"]
    :set res [$RunTestCase $res "aug/31/1970 23:59:59" "20995199" "End of August 1970"]
    :set res [$RunTestCase $res "sep/01/1970 00:00:00" "20995200" "Start of September 1970"]
    :set res [$RunTestCase $res "sep/30/1970 23:59:59" "23587199" "End of September 1970"]
    :set res [$RunTestCase $res "oct/01/1970 00:00:00" "23587200" "Start of October 1970"]
    :set res [$RunTestCase $res "oct/31/1970 23:59:59" "26265599" "End of October 1970"]
    :set res [$RunTestCase $res "nov/01/1970 00:00:00" "26265600" "Start of November 1970"]
    :set res [$RunTestCase $res "nov/30/1970 23:59:59" "28857599" "End of November 1970"]
    :set res [$RunTestCase $res "dec/01/1970 00:00:00" "28857600" "Start of December 1970"]

    # =========================================================================
    # Leap year edge cases
    # =========================================================================
    :set res [$RunTestCase $res "jan/01/1972 00:00:00" "63072000" "Start of leap year 1972"]
    :set res [$RunTestCase $res "dec/31/1972 23:59:59" "94694399" "End of leap year 1972"]

    :set res [$RunTestCase $res "feb/28/1996 23:59:59" "825551999" "1996 before leap day"]
    :set res [$RunTestCase $res "feb/29/1996 00:00:00" "825552000" "1996 leap day"]
    :set res [$RunTestCase $res "mar/01/1996 00:00:00" "825638400" "1996 after leap day"]

    :set res [$RunTestCase $res "feb/28/2004 23:59:59" "1078012799" "2004 before leap day"]
    :set res [$RunTestCase $res "feb/29/2004 00:00:00" "1078012800" "2004 leap day"]
    :set res [$RunTestCase $res "mar/01/2004 00:00:00" "1078099200" "2004 after leap day"]

    # =========================================================================
    # Non-leap century
    # =========================================================================
    :set res [$RunTestCase $res "dec/31/2100 23:59:59" "4133980799" "End of non-leap century year"]

    # =========================================================================
    # Leap century
    # =========================================================================
    :set res [$RunTestCase $res "dec/31/2000 23:59:59" "978307199" "End of leap century year"]
    :set res [$RunTestCase $res "feb/28/2400 23:59:59" "13574563199" "2400 before leap day"]
    :set res [$RunTestCase $res "feb/29/2400 00:00:00" "13574563200" "2400 leap day"]
    :set res [$RunTestCase $res "mar/01/2400 00:00:00" "13574649600" "2400 after leap day"]

    # =========================================================================
    # End/start of years
    # =========================================================================
    :set res [$RunTestCase $res "dec/31/1971 23:59:59" "63071999" "End of 1971"]
    :set res [$RunTestCase $res "jan/01/1972 00:00:00" "63072000" "Start of 1972"]

    :set res [$RunTestCase $res "jan/01/1999 00:00:00" "915148800" "Start of 1999"]
    :set res [$RunTestCase $res "dec/31/1999 23:59:58" "946684798" "Penultimate second of 1999"]
    :set res [$RunTestCase $res "dec/31/1999 23:59:59" "946684799" "Last second of 1999"]
    :set res [$RunTestCase $res "jan/01/2000 00:00:00" "946684800" "Start of 2000"]

    # =========================================================================
    # Time-of-day edge cases
    # =========================================================================
    :set res [$RunTestCase $res "jun/15/2025 00:00:00" "1749945600" "Start of day"]
    :set res [$RunTestCase $res "jun/15/2025 00:00:01" "1749945601" "Second after midnight"]
    :set res [$RunTestCase $res "jun/15/2025 11:59:59" "1749988799" "Second before noon"]
    :set res [$RunTestCase $res "jun/15/2025 12:00:00" "1749988800" "Exact noon"]
    :set res [$RunTestCase $res "jun/15/2025 23:59:58" "1750031998" "Penultimate second of day"]
    :set res [$RunTestCase $res "jun/15/2025 23:59:59" "1750031999" "Last second of day"]

    # =========================================================================
    # 400-year cycle verification
    # =========================================================================
    :set res [$RunTestCase $res "mar/01/2000 00:00:00" "951868800" "Leap century 2000"]
    :set res [$RunTestCase $res "mar/01/2100 00:00:00" "4107542400" "Non-leap century 2100"]
    :set res [$RunTestCase $res "mar/01/2400 00:00:00" "13574649600" "Leap century 2400"]

    :put "Testing completed."
    :return $res
}

:set FormatSecondsLongTest do={
    :local res {"passed"=0; "failed"=0}
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :error "Need to call with an empty array as parameter [:toarray {\"passed\"=0; \"failed\"=0}]]"
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
    :local res {"passed"=0; "failed"=0}
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :error "Need to call with an empty array as parameter [:toarray {\"passed\"=0; \"failed\"=0}]]"
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

:set GetUnixTimestampTest do={
    :global GetUnixTimestamp
    :global FromUnixTimestamp
    :global ToUnixTimestamp

    :local res {"passed"=0; "failed"=0}
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :error "Need to call with an empty array as parameter [:toarray {\"passed\"=0; \"failed\"=0}]]"
    }

    :put "Starting GetUnixTimestamp runtime tests..."

    # Executing dynamic check to confirm current live runtime fetches validate correctly
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
