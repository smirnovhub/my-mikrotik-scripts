:global RunAllDateTimeTests
:global GetUnixTimestampTest
:global ToUnixTimestampTest
:global FormatSecondsShortTest
:global ParseDateTimeTest

:set RunAllDateTimeTests do={
    :global GetUnixTimestampTest
    :global ToUnixTimestampTest
    :global FormatSecondsShortTest
    :global ParseDateTimeTest

    :put "\1B[35m=== STARTING ALL DATETIME TESTS ===\1B[0m"

    # Execute conversion and parsing tests
    $ParseDateTimeTest
    $ToUnixTimestampTest
    $FormatSecondsShortTest
    
    # Execute runtime clock tracking tests
    $GetUnixTimestampTest

    :put "\1B[35m=== ALL DATETIME TESTS EXECUTED ===\1B[0m"
}

:set ParseDateTimeTest do={
    :global ParseDateTime

    :local RunTestCase do={
        :global ParseDateTime
        :local inputStr [:tostr $1]
        :local expectedStr [:tostr $2]
        :local name [:tostr $3]

        # Ignore phantom calls from engine bugs or broken line endings
        :if ([:len $inputStr] > 0) do={
            :local actual [$ParseDateTime $inputStr]
            :local actualStr [:tostr $actual]
            
            :if ($actualStr = $expectedStr) do={
                :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputStr . "' -> '" . $actualStr . "'")
            } else={
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputStr . "' | Expected: '" . $expectedStr . "', Got: '" . $actualStr . "'")
            }
        }
    }

    :put "Starting ParseDateTime tests..."

    # Test cases matching the actual ISO string output of the function
    [$RunTestCase "jan/01/2026 00:00:00" "2026-01-01 00:00:00" "Midnight start of the year"]
    [$RunTestCase "feb/28/2024 23:59:59" "2024-02-28 23:59:59" "End of day leap year February"]
    [$RunTestCase "jul/09/2026 15:45:21" "2026-07-09 15:45:21" "Standard afternoon daytime string"]

    :put "Testing completed."
}

:set ToUnixTimestampTest do={
    :global ToUnixTimestamp

    :local RunTestCase do={
        :global ToUnixTimestamp
        :local inputStr [:tostr $1]
        :local expected [:tonum $2]
        :local name [:tostr $3]

        # Ignore phantom calls from engine bugs or broken line endings
        :if ([:len $inputStr] > 0) do={
            :local actual [$ToUnixTimestamp $inputStr]
            :if ($actual = $expected) do={
                :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputStr . "' -> " . $actual)
            } else={
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputStr . "' | Expected: " . $expected . ", Got: " . $actual)
            }
        }
    }

    :put "Starting extended ToUnixTimestamp tests..."

    # =========================================================================
    # Epoch (1970)
    # =========================================================================
    [$RunTestCase "1970-01-01 00:00:00" "0" "Absolute epoch zero starting point"]
    [$RunTestCase "1970-01-01 00:00:01" "1" "One second past epoch threshold"]
    [$RunTestCase "1970-01-01 00:00:59" "59" "Last second of the first minute"]
    [$RunTestCase "1970-01-01 00:01:00" "60" "Start of the second minute"]
    [$RunTestCase "1970-01-01 00:59:59" "3599" "Last second of the first hour"]
    [$RunTestCase "1970-01-01 01:00:00" "3600" "One hour past epoch threshold"]
    [$RunTestCase "1970-01-01 23:59:59" "86399" "Last second of the first day"]
    [$RunTestCase "1970-01-02 00:00:00" "86400" "Start of the second day"]
    [$RunTestCase "1970-01-31 23:59:59" "2678399" "End of January 1970"]
    [$RunTestCase "1970-02-01 00:00:00" "2678400" "Start of February 1970"]
    [$RunTestCase "1970-02-28 23:59:59" "5097599" "End of February 1970"]
    [$RunTestCase "1970-03-01 00:00:00" "5097600" "Start of March 1970"]
    [$RunTestCase "1970-12-31 23:59:59" "31535999" "Last second of the epoch year"]

    # =========================================================================
    # First leap year after epoch (1972)
    # =========================================================================
    [$RunTestCase "1972-02-28 23:59:59" "68169599" "Second before leap day in 1972"]
    [$RunTestCase "1972-02-29 00:00:00" "68169600" "Leap day begins in 1972"]
    [$RunTestCase "1972-02-29 23:59:59" "68255999" "Leap day ends in 1972"]
    [$RunTestCase "1972-03-01 00:00:00" "68256000" "March begins after leap day in 1972"]

    # =========================================================================
    # Leap year (2024)
    # =========================================================================
    [$RunTestCase "2024-01-31 23:59:59" "1706745599" "End of January 2024"]
    [$RunTestCase "2024-02-01 00:00:00" "1706745600" "Start of February 2024"]
    [$RunTestCase "2024-02-28 23:59:59" "1709164799" "Second before leap day February 29"]
    [$RunTestCase "2024-02-29 00:00:00" "1709164800" "Start of the leap day February 29"]
    [$RunTestCase "2024-02-29 12:34:56" "1709210096" "Middle of leap day"]
    [$RunTestCase "2024-02-29 23:59:59" "1709251199" "End of the leap day February 29"]
    [$RunTestCase "2024-03-01 00:00:00" "1709251200" "Start of March right after leap day"]
    [$RunTestCase "2024-12-31 23:59:59" "1735689599" "End of leap year 2024"]

    # =========================================================================
    # Standard year (2025)
    # =========================================================================
    [$RunTestCase "2025-01-01 00:00:00" "1735689600" "Start of 2025"]
    [$RunTestCase "2025-02-28 23:59:59" "1740787199" "End of February in a standard year"]
    [$RunTestCase "2025-03-01 00:00:00" "1740787200" "Start of March in a standard year"]
    [$RunTestCase "2025-04-30 23:59:59" "1746057599" "End of April"]
    [$RunTestCase "2025-05-01 00:00:00" "1746057600" "Start of May"]
    [$RunTestCase "2025-06-30 23:59:59" "1751327999" "End of June"]
    [$RunTestCase "2025-07-01 00:00:00" "1751328000" "Start of July"]
    [$RunTestCase "2025-12-31 23:59:59" "1767225599" "End of 2025"]

    # =========================================================================
    # Arbitrary dates
    # =========================================================================
    [$RunTestCase "1980-06-15 12:00:00" "329918400" "Midday in 1980"]
    [$RunTestCase "1999-12-31 23:59:59" "946684799" "End of the 20th century"]
    [$RunTestCase "2000-01-01 00:00:00" "946684800" "Start of year 2000"]
    [$RunTestCase "2026-01-01 00:00:00" "1767225600" "Start of the year Y2026 baseline"]
    [$RunTestCase "2026-07-09 15:45:00" "1783611900" "Arbitrary current mid-year verification"]

    # =========================================================================
    # Century rules
    # =========================================================================
    [$RunTestCase "2000-02-28 23:59:59" "951782399" "Before leap day in year 2000"]
    [$RunTestCase "2000-02-29 00:00:00" "951782400" "Leap day in year 2000"]
    [$RunTestCase "2000-03-01 00:00:00" "951868800" "March after leap day in year 2000"]

    [$RunTestCase "2100-02-28 23:59:59" "4107542399" "End of February century boundary check"]
    [$RunTestCase "2100-03-01 00:00:00" "4107542400" "Start of March century boundary check"]

    # =========================================================================
    # 32-bit boundary
    # =========================================================================
    [$RunTestCase "2038-01-19 03:14:06" "2147483646" "One second before signed 32-bit limit"]
    [$RunTestCase "2038-01-19 03:14:07" "2147483647" "Maximum standard 32-bit signed integer limit"]
    [$RunTestCase "2038-01-19 03:14:08" "2147483648" "First second beyond signed 32-bit limit"]

    # =========================================================================
    # Month boundaries (1970)
    # =========================================================================
    [$RunTestCase "1970-03-31 23:59:59" "7775999" "End of March 1970"]
    [$RunTestCase "1970-04-01 00:00:00" "7776000" "Start of April 1970"]
    [$RunTestCase "1970-04-30 23:59:59" "10367999" "End of April 1970"]
    [$RunTestCase "1970-05-01 00:00:00" "10368000" "Start of May 1970"]
    [$RunTestCase "1970-05-31 23:59:59" "13046399" "End of May 1970"]
    [$RunTestCase "1970-06-01 00:00:00" "13046400" "Start of June 1970"]
    [$RunTestCase "1970-06-30 23:59:59" "15638399" "End of June 1970"]
    [$RunTestCase "1970-07-01 00:00:00" "15638400" "Start of July 1970"]
    [$RunTestCase "1970-07-31 23:59:59" "18316799" "End of July 1970"]
    [$RunTestCase "1970-08-01 00:00:00" "18316800" "Start of August 1970"]
    [$RunTestCase "1970-08-31 23:59:59" "20995199" "End of August 1970"]
    [$RunTestCase "1970-09-01 00:00:00" "20995200" "Start of September 1970"]
    [$RunTestCase "1970-09-30 23:59:59" "23587199" "End of September 1970"]
    [$RunTestCase "1970-10-01 00:00:00" "23587200" "Start of October 1970"]
    [$RunTestCase "1970-10-31 23:59:59" "26265599" "End of October 1970"]
    [$RunTestCase "1970-11-01 00:00:00" "26265600" "Start of November 1970"]
    [$RunTestCase "1970-11-30 23:59:59" "28857599" "End of November 1970"]
    [$RunTestCase "1970-12-01 00:00:00" "28857600" "Start of December 1970"]

    # =========================================================================
    # Leap year edge cases
    # =========================================================================
    [$RunTestCase "1972-01-01 00:00:00" "63072000" "Start of leap year 1972"]
    [$RunTestCase "1972-12-31 23:59:59" "94694399" "End of leap year 1972"]

    [$RunTestCase "1996-02-28 23:59:59" "825551999" "1996 before leap day"]
    [$RunTestCase "1996-02-29 00:00:00" "825552000" "1996 leap day"]
    [$RunTestCase "1996-03-01 00:00:00" "825638400" "1996 after leap day"]

    [$RunTestCase "2004-02-28 23:59:59" "1078012799" "2004 before leap day"]
    [$RunTestCase "2004-02-29 00:00:00" "1078012800" "2004 leap day"]
    [$RunTestCase "2004-03-01 00:00:00" "1078099200" "2004 after leap day"]

    # =========================================================================
    # Non-leap century
    # =========================================================================
    [$RunTestCase "2100-12-31 23:59:59" "4133980799" "End of non-leap century year"]

    # =========================================================================
    # Leap century
    # =========================================================================
    [$RunTestCase "2000-12-31 23:59:59" "978307199" "End of leap century year"]
    [$RunTestCase "2400-02-28 23:59:59" "13574563199" "2400 before leap day"]
    [$RunTestCase "2400-02-29 00:00:00" "13574563200" "2400 leap day"]
    [$RunTestCase "2400-03-01 00:00:00" "13574649600" "2400 after leap day"]

    # =========================================================================
    # End/start of years
    # =========================================================================
    [$RunTestCase "1971-12-31 23:59:59" "63071999" "End of 1971"]
    [$RunTestCase "1972-01-01 00:00:00" "63072000" "Start of 1972"]

    [$RunTestCase "1999-01-01 00:00:00" "915148800" "Start of 1999"]
    [$RunTestCase "1999-12-31 23:59:58" "946684798" "Penultimate second of 1999"]
    [$RunTestCase "1999-12-31 23:59:59" "946684799" "Last second of 1999"]
    [$RunTestCase "2000-01-01 00:00:00" "946684800" "Start of 2000"]

    # =========================================================================
    # Time-of-day edge cases
    # =========================================================================
    [$RunTestCase "2025-06-15 00:00:00" "1749945600" "Start of day"]
    [$RunTestCase "2025-06-15 00:00:01" "1749945601" "Second after midnight"]
    [$RunTestCase "2025-06-15 11:59:59" "1749988799" "Second before noon"]
    [$RunTestCase "2025-06-15 12:00:00" "1749988800" "Exact noon"]
    [$RunTestCase "2025-06-15 23:59:58" "1750031998" "Penultimate second of day"]
    [$RunTestCase "2025-06-15 23:59:59" "1750031999" "Last second of day"]

    # =========================================================================
    # 400-year cycle verification
    # =========================================================================
    [$RunTestCase "2000-03-01 00:00:00" "951868800" "Leap century 2000"]
    [$RunTestCase "2100-03-01 00:00:00" "4107542400" "Non-leap century 2100"]
    [$RunTestCase "2400-03-01 00:00:00" "13574649600" "Leap century 2400"]

    :put "Testing completed."
}

:set FormatSecondsShortTest do={
    :global FormatSecondsShort

    :local RunTestCase do={
        :global FormatSecondsShort
        :local seconds [:tonum $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        # Ignore phantom calls from engine bugs or broken line endings
        :if ([:len $1] > 0) do={
            :local actual [$FormatSecondsShort $seconds]
            :if ($actual = $expected) do={
                :put ("  \1B[32m[PASS]\1B[0m " . $name . ": " . $seconds . "s -> '" . $actual . "'")
            } else={
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": " . $seconds . "s | Expected: '" . $expected . "', Got: '" . $actual . "'")
            }
        }
    }

    :put "Starting FormatSecondsShort tests..."

    # Test cases checking various ranges for time optimization display strings
    [$RunTestCase "0" "0 sec" "Zero seconds threshold evaluation"]
    [$RunTestCase "45" "45 sec" "Standard seconds scale display validation"]
    [$RunTestCase "60" "1 min" "Exactly one minute boundary transition"]
    [$RunTestCase "119" "1 min" "Slightly under two minutes rounding step down"]
    [$RunTestCase "3599" "59 min" "Maximum scale value prior to hours boundary"]
    [$RunTestCase "3600" "1 hrs" "Exactly one hour boundary transition step"]
    [$RunTestCase "86399" "23 hrs" "Maximum scale value prior to days boundary"]
    [$RunTestCase "86400" "1 days" "Exactly one day layout transition verification"]
    [$RunTestCase "172800" "2 days" "Multiple whole days execution path check"]

    :put "Testing completed."
}

:set GetUnixTimestampTest do={
    :global GetUnixTimestamp

    :put "Starting GetUnixTimestamp runtime tests..."

    # Executing dynamic check to confirm current live runtime fetches validate correctly
    :local ts1 [$GetUnixTimestamp]
    :if ([:typeof $ts1] = "num" && $ts1 > 1700000000) do={
        :put ("  \1B[32m[PASS]\1B[0m Live system timestamp fetched successfully: " . $ts1)
    } else={
        :put ("  \1B[31m[FAIL]\1B[0m Live system timestamp fetch resulted in invalid structure: " . [:tostr $ts1])
    }

    :put "Testing completed."
}
