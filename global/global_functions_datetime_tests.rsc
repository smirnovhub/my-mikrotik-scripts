:global RunAllDateTimeTests
:global GetWeekdayTest
:global GetUnixTimestampTest
:global FromUnixTimestampTest
:global ToUnixTimestampTest
:global FormatSecondsShortTest
:global ParseDateTimeTest

:set RunAllDateTimeTests do={
    :global GetWeekdayTest
    :global GetUnixTimestampTest
    :global FromUnixTimestampTest
    :global ToUnixTimestampTest
    :global FormatSecondsShortTest
    :global ParseDateTimeTest

    :put "\1B[35m=== STARTING ALL DATETIME TESTS ===\1B[0m"

    # Execute conversion and parsing tests
    $GetWeekdayTest
    $ParseDateTimeTest
    $FromUnixTimestampTest
    $ToUnixTimestampTest
    $FormatSecondsShortTest
    
    # Execute runtime clock tracking tests
    $GetUnixTimestampTest

    :put "\1B[35m=== ALL DATETIME TESTS EXECUTED ===\1B[0m"
}

:set GetWeekdayTest do={
    :local RunTestCase do={
        :global GetWeekday
        :local ts [:tonum $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        # Ignore phantom calls from engine bugs or broken line endings
        :if ([:len $1] > 0) do={
            :local actual [$GetWeekday $ts]
            :if ($actual = $expected) do={
                :put ("  \1B[32m[PASS]\1B[0m " . $name . ": " . $ts . " -> '" . $actual . "'")
            } else={
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": " . $ts . " | Expected: '" . $expected . "', Got: '" . $actual . "'")
            }
        }
    }

    :put "Starting GetWeekday tests..."

    # Epoch base cases (1970-01-01 was a Thursday)
    [$RunTestCase "0" "thursday" "Absolute Unix epoch start boundary"]
    [$RunTestCase "86400" "friday" "One day past epoch baseline"]
    [$RunTestCase "172800" "saturday" "Two days past epoch baseline"]
    [$RunTestCase "259200" "sunday" "Three days past epoch - first Sunday"]
    [$RunTestCase "345600" "monday" "Four days past epoch - first Monday"]

    # Mid-week sequence validation
    [$RunTestCase "1709164799" "wednesday" "End of February 28 before leap day 2024"]
    [$RunTestCase "1709164800" "thursday" "Start of leap day February 29 2024"]
    [$RunTestCase "1709251200" "friday" "Start of March 1 right after leap day 2024"]

    # Year 2025 targets
    [$RunTestCase "1740787199" "friday" "Last second of February 2025 standard year"]
    [$RunTestCase "1740787200" "saturday" "Start of March 1 2025 standard year"]

    # Documentation example verification
    [$RunTestCase "1750031999" "sunday" "Target example validation from documentation header"]

    # Year 2026 targets (Today check)
    [$RunTestCase "1767225600" "thursday" "Start of the year Y2026 baseline"]
    [$RunTestCase "1783639991" "thursday" "Current date timestamp validation anchor"]

    # Far future check (Year 2038)
    [$RunTestCase "2147483647" "tuesday" "Maximum 32-bit signed integer time threshold"]

    [$RunTestCase "0" "thursday" "Thursday"]
    [$RunTestCase "86400" "friday" "Friday"]
    [$RunTestCase "172800" "saturday" "Saturday"]
    [$RunTestCase "259200" "sunday" "Sunday"]
    [$RunTestCase "345600" "monday" "Monday"]
    [$RunTestCase "432000" "tuesday" "Tuesday"]
    [$RunTestCase "518400" "wednesday" "Wednesday"]
    [$RunTestCase "604800" "thursday" "Exactly one week later"]
    
    [$RunTestCase "0" "thursday" "Start of day"]
    [$RunTestCase "1" "thursday" "One second later"]
    [$RunTestCase "43200" "thursday" "Midday"]
    [$RunTestCase "86398" "thursday" "Penultimate second"]
    [$RunTestCase "86399" "thursday" "Last second of day"]
    [$RunTestCase "86400" "friday" "Next day begins"]
    
    [$RunTestCase "1709251199" "thursday" "Last second of leap day"]
    [$RunTestCase "1709251200" "friday" "First second after leap day"]
    
    [$RunTestCase "1735689599" "tuesday" "Last second of 2024"]
    [$RunTestCase "1735689600" "wednesday" "First second of 2025"]
    
    [$RunTestCase "1767225599" "wednesday" "Last second of 2025"]
    [$RunTestCase "1767225600" "thursday" "First second of 2026"]
    
    [$RunTestCase "951782400" "tuesday" "Leap century day 2000"]
    [$RunTestCase "4107542400" "monday" "Non-leap century 2100"]
    [$RunTestCase "13574649600" "wednesday" "Leap century 2400"]
    
    [$RunTestCase "253402300799" "friday" "Maximum supported date"]
    
    [$RunTestCase "951868800" "wednesday" "2000-03-01"]
    [$RunTestCase "13574649600" "wednesday" "2400-03-01 same weekday after 400-year cycle"]
    
    [$RunTestCase "0" "thursday" "Week 0"]
    [$RunTestCase "604800" "thursday" "Week 1"]
    [$RunTestCase "1209600" "thursday" "Week 2"]
    [$RunTestCase "1814400" "thursday" "Week 3"]
    
    :put "Testing completed."
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

:set FromUnixTimestampTest do={
    :global FromUnixTimestamp

    :local RunTestCase do={
        :global FromUnixTimestamp
        :local expected [:tostr $1]
        :local inputStr [:tonum $2]
        :local name [:tostr $3]

        # Ignore phantom calls from engine bugs or broken line endings
        :if ([:len $inputStr] > 0) do={
            :local actual [$FromUnixTimestamp $inputStr]
            :if ($actual = $expected) do={
                :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputStr . "' -> " . $actual)
            } else={
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputStr . "' | Expected: " . $expected . ", Got: " . $actual)
            }
        }
    }

    :put "Starting extended FromUnixTimestamp tests..."

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
    [$RunTestCase "9999-12-31 23:59:59" "253402300799" "Last possible date"]

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

    # =========================================================================
    # Other tests
    # =========================================================================
    [$RunTestCase "2000-02-29 12:00:00" "951825600" "Middle of leap century day"]
    [$RunTestCase "2100-02-28 00:00:00" "4107456000" "Start of last day before non-leap century transition"]
    [$RunTestCase "2100-03-01 00:00:00" "4107542400" "First day after skipped leap day in 2100"]
    [$RunTestCase "1972-01-02 00:00:00" "63158400" "Second day of leap year 1972"]
    [$RunTestCase "2010-01-01 00:00:00" "1262304000" "Round decade boundary"]
    [$RunTestCase "2019-12-31 23:59:59" "1577836799" "End of decade"]
    [$RunTestCase "2020-01-01 00:00:00" "1577836800" "Start of leap decade year"]
    [$RunTestCase "2040-01-01 00:00:00" "2208988800" "Post 32-bit future date"]
    [$RunTestCase "2100-01-01 23:59:59" "4102531199" "Century year beginning"]
    [$RunTestCase "9999-12-31 00:00:00" "253402214400" "Near maximum supported date"]

    [$RunTestCase "1973-01-01 00:00:00" "94694400" "First second after leap year"]
    [$RunTestCase "2024-01-31 23:59:59" "1706745599" "End of January"]
    [$RunTestCase "2024-03-31 23:59:59" "1711929599" "End of March"]
    [$RunTestCase "2024-04-30 23:59:59" "1714521599" "End of April"]
    [$RunTestCase "2024-05-31 23:59:59" "1717199999" "End of May"]
    [$RunTestCase "2024-06-30 23:59:59" "1719791999" "End of June"]
    [$RunTestCase "2000-01-01 00:00:00" "946684800" "Y2K midnight"]
    [$RunTestCase "2000-01-01 12:00:00" "946728000" "Y2K noon"]
    [$RunTestCase "2000-01-01 23:59:59" "946771199" "Y2K end of day"]

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
    [$RunTestCase "9999-12-31 23:59:59" "253402300799" "Last possible date"]

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

    # =========================================================================
    # Other tests
    # =========================================================================
    [$RunTestCase "2000-02-29 12:00:00" "951825600" "Middle of leap century day"]
    [$RunTestCase "2100-02-28 00:00:00" "4107456000" "Start of last day before non-leap century transition"]
    [$RunTestCase "2100-03-01 00:00:00" "4107542400" "First day after skipped leap day in 2100"]
    [$RunTestCase "1972-01-02 00:00:00" "63158400" "Second day of leap year 1972"]
    [$RunTestCase "2010-01-01 00:00:00" "1262304000" "Round decade boundary"]
    [$RunTestCase "2019-12-31 23:59:59" "1577836799" "End of decade"]
    [$RunTestCase "2020-01-01 00:00:00" "1577836800" "Start of leap decade year"]
    [$RunTestCase "2040-01-01 00:00:00" "2208988800" "Post 32-bit future date"]
    [$RunTestCase "2100-01-01 23:59:59" "4102531199" "Century year beginning"]
    [$RunTestCase "9999-12-31 00:00:00" "253402214400" "Near maximum supported date"]

    [$RunTestCase "1973-01-01 00:00:00" "94694400" "First second after leap year"]
    [$RunTestCase "2024-01-31 23:59:59" "1706745599" "End of January"]
    [$RunTestCase "2024-03-31 23:59:59" "1711929599" "End of March"]
    [$RunTestCase "2024-04-30 23:59:59" "1714521599" "End of April"]
    [$RunTestCase "2024-05-31 23:59:59" "1717199999" "End of May"]
    [$RunTestCase "2024-06-30 23:59:59" "1719791999" "End of June"]
    [$RunTestCase "2000-01-01 00:00:00" "946684800" "Y2K midnight"]
    [$RunTestCase "2000-01-01 12:00:00" "946728000" "Y2K noon"]
    [$RunTestCase "2000-01-01 23:59:59" "946771199" "Y2K end of day"]

    # =========================================================================
    # Epoch (1970)
    # =========================================================================
    [$RunTestCase "jan/01/1970 00:00:00" "0" "Absolute epoch zero starting point"]
    [$RunTestCase "jan/01/1970 00:00:01" "1" "One second past epoch threshold"]
    [$RunTestCase "jan/01/1970 00:00:59" "59" "Last second of the first minute"]
    [$RunTestCase "jan/01/1970 00:01:00" "60" "Start of the second minute"]
    [$RunTestCase "jan/01/1970 00:59:59" "3599" "Last second of the first hour"]
    [$RunTestCase "jan/01/1970 01:00:00" "3600" "One hour past epoch threshold"]
    [$RunTestCase "jan/01/1970 23:59:59" "86399" "Last second of the first day"]
    [$RunTestCase "jan/02/1970 00:00:00" "86400" "Start of the second day"]
    [$RunTestCase "jan/31/1970 23:59:59" "2678399" "End of January 1970"]
    [$RunTestCase "feb/01/1970 00:00:00" "2678400" "Start of February 1970"]
    [$RunTestCase "feb/28/1970 23:59:59" "5097599" "End of February 1970"]
    [$RunTestCase "mar/01/1970 00:00:00" "5097600" "Start of March 1970"]
    [$RunTestCase "dec/31/1970 23:59:59" "31535999" "Last second of the epoch year"]

    # =========================================================================
    # First leap year after epoch (1972)
    # =========================================================================
    [$RunTestCase "feb/28/1972 23:59:59" "68169599" "Second before leap day in 1972"]
    [$RunTestCase "feb/29/1972 00:00:00" "68169600" "Leap day begins in 1972"]
    [$RunTestCase "feb/29/1972 23:59:59" "68255999" "Leap day ends in 1972"]
    [$RunTestCase "mar/01/1972 00:00:00" "68256000" "March begins after leap day in 1972"]

    # =========================================================================
    # Leap year (2024)
    # =========================================================================
    [$RunTestCase "jan/31/2024 23:59:59" "1706745599" "End of January 2024"]
    [$RunTestCase "feb/01/2024 00:00:00" "1706745600" "Start of February 2024"]
    [$RunTestCase "feb/28/2024 23:59:59" "1709164799" "Second before leap day February 29"]
    [$RunTestCase "feb/29/2024 00:00:00" "1709164800" "Start of the leap day February 29"]
    [$RunTestCase "feb/29/2024 12:34:56" "1709210096" "Middle of leap day"]
    [$RunTestCase "feb/29/2024 23:59:59" "1709251199" "End of the leap day February 29"]
    [$RunTestCase "mar/01/2024 00:00:00" "1709251200" "Start of March right after leap day"]
    [$RunTestCase "dec/31/2024 23:59:59" "1735689599" "End of leap year 2024"]

    # =========================================================================
    # Standard year (2025)
    # =========================================================================
    [$RunTestCase "jan/01/2025 00:00:00" "1735689600" "Start of 2025"]
    [$RunTestCase "feb/28/2025 23:59:59" "1740787199" "End of February in a standard year"]
    [$RunTestCase "mar/01/2025 00:00:00" "1740787200" "Start of March in a standard year"]
    [$RunTestCase "apr/30/2025 23:59:59" "1746057599" "End of April"]
    [$RunTestCase "may/01/2025 00:00:00" "1746057600" "Start of May"]
    [$RunTestCase "jun/30/2025 23:59:59" "1751327999" "End of June"]
    [$RunTestCase "jul/01/2025 00:00:00" "1751328000" "Start of July"]
    [$RunTestCase "dec/31/2025 23:59:59" "1767225599" "End of 2025"]

    # =========================================================================
    # Arbitrary dates
    # =========================================================================
    [$RunTestCase "jun/15/1980 12:00:00" "329918400" "Midday in 1980"]
    [$RunTestCase "dec/31/1999 23:59:59" "946684799" "End of the 20th century"]
    [$RunTestCase "jan/01/2000 00:00:00" "946684800" "Start of year 2000"]
    [$RunTestCase "jan/01/2026 00:00:00" "1767225600" "Start of the year Y2026 baseline"]
    [$RunTestCase "jul/09/2026 15:45:00" "1783611900" "Arbitrary current mid-year verification"]
    [$RunTestCase "dec/31/9999 23:59:59" "253402300799" "Last possible date"]

    # =========================================================================
    # Century rules
    # =========================================================================
    [$RunTestCase "feb/28/2000 23:59:59" "951782399" "Before leap day in year 2000"]
    [$RunTestCase "feb/29/2000 00:00:00" "951782400" "Leap day in year 2000"]
    [$RunTestCase "mar/01/2000 00:00:00" "951868800" "March after leap day in year 2000"]

    [$RunTestCase "feb/28/2100 23:59:59" "4107542399" "End of February century boundary check"]
    [$RunTestCase "mar/01/2100 00:00:00" "4107542400" "Start of March century boundary check"]

    # =========================================================================
    # 32-bit boundary
    # =========================================================================
    [$RunTestCase "jan/19/2038 03:14:06" "2147483646" "One second before signed 32-bit limit"]
    [$RunTestCase "jan/19/2038 03:14:07" "2147483647" "Maximum standard 32-bit signed integer limit"]
    [$RunTestCase "jan/19/2038 03:14:08" "2147483648" "First second beyond signed 32-bit limit"]

    # =========================================================================
    # Month boundaries (1970)
    # =========================================================================
    [$RunTestCase "mar/31/1970 23:59:59" "7775999" "End of March 1970"]
    [$RunTestCase "apr/01/1970 00:00:00" "7776000" "Start of April 1970"]
    [$RunTestCase "apr/30/1970 23:59:59" "10367999" "End of April 1970"]
    [$RunTestCase "may/01/1970 00:00:00" "10368000" "Start of May 1970"]
    [$RunTestCase "may/31/1970 23:59:59" "13046399" "End of May 1970"]
    [$RunTestCase "jun/01/1970 00:00:00" "13046400" "Start of June 1970"]
    [$RunTestCase "jun/30/1970 23:59:59" "15638399" "End of June 1970"]
    [$RunTestCase "jul/01/1970 00:00:00" "15638400" "Start of July 1970"]
    [$RunTestCase "jul/31/1970 23:59:59" "18316799" "End of July 1970"]
    [$RunTestCase "aug/01/1970 00:00:00" "18316800" "Start of August 1970"]
    [$RunTestCase "aug/31/1970 23:59:59" "20995199" "End of August 1970"]
    [$RunTestCase "sep/01/1970 00:00:00" "20995200" "Start of September 1970"]
    [$RunTestCase "sep/30/1970 23:59:59" "23587199" "End of September 1970"]
    [$RunTestCase "oct/01/1970 00:00:00" "23587200" "Start of October 1970"]
    [$RunTestCase "oct/31/1970 23:59:59" "26265599" "End of October 1970"]
    [$RunTestCase "nov/01/1970 00:00:00" "26265600" "Start of November 1970"]
    [$RunTestCase "nov/30/1970 23:59:59" "28857599" "End of November 1970"]
    [$RunTestCase "dec/01/1970 00:00:00" "28857600" "Start of December 1970"]

    # =========================================================================
    # Leap year edge cases
    # =========================================================================
    [$RunTestCase "jan/01/1972 00:00:00" "63072000" "Start of leap year 1972"]
    [$RunTestCase "dec/31/1972 23:59:59" "94694399" "End of leap year 1972"]

    [$RunTestCase "feb/28/1996 23:59:59" "825551999" "1996 before leap day"]
    [$RunTestCase "feb/29/1996 00:00:00" "825552000" "1996 leap day"]
    [$RunTestCase "mar/01/1996 00:00:00" "825638400" "1996 after leap day"]

    [$RunTestCase "feb/28/2004 23:59:59" "1078012799" "2004 before leap day"]
    [$RunTestCase "feb/29/2004 00:00:00" "1078012800" "2004 leap day"]
    [$RunTestCase "mar/01/2004 00:00:00" "1078099200" "2004 after leap day"]

    # =========================================================================
    # Non-leap century
    # =========================================================================
    [$RunTestCase "dec/31/2100 23:59:59" "4133980799" "End of non-leap century year"]

    # =========================================================================
    # Leap century
    # =========================================================================
    [$RunTestCase "dec/31/2000 23:59:59" "978307199" "End of leap century year"]
    [$RunTestCase "feb/28/2400 23:59:59" "13574563199" "2400 before leap day"]
    [$RunTestCase "feb/29/2400 00:00:00" "13574563200" "2400 leap day"]
    [$RunTestCase "mar/01/2400 00:00:00" "13574649600" "2400 after leap day"]

    # =========================================================================
    # End/start of years
    # =========================================================================
    [$RunTestCase "dec/31/1971 23:59:59" "63071999" "End of 1971"]
    [$RunTestCase "jan/01/1972 00:00:00" "63072000" "Start of 1972"]

    [$RunTestCase "jan/01/1999 00:00:00" "915148800" "Start of 1999"]
    [$RunTestCase "dec/31/1999 23:59:58" "946684798" "Penultimate second of 1999"]
    [$RunTestCase "dec/31/1999 23:59:59" "946684799" "Last second of 1999"]
    [$RunTestCase "jan/01/2000 00:00:00" "946684800" "Start of 2000"]

    # =========================================================================
    # Time-of-day edge cases
    # =========================================================================
    [$RunTestCase "jun/15/2025 00:00:00" "1749945600" "Start of day"]
    [$RunTestCase "jun/15/2025 00:00:01" "1749945601" "Second after midnight"]
    [$RunTestCase "jun/15/2025 11:59:59" "1749988799" "Second before noon"]
    [$RunTestCase "jun/15/2025 12:00:00" "1749988800" "Exact noon"]
    [$RunTestCase "jun/15/2025 23:59:58" "1750031998" "Penultimate second of day"]
    [$RunTestCase "jun/15/2025 23:59:59" "1750031999" "Last second of day"]

    # =========================================================================
    # 400-year cycle verification
    # =========================================================================
    [$RunTestCase "mar/01/2000 00:00:00" "951868800" "Leap century 2000"]
    [$RunTestCase "mar/01/2100 00:00:00" "4107542400" "Non-leap century 2100"]
    [$RunTestCase "mar/01/2400 00:00:00" "13574649600" "Leap century 2400"]

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
    :global FromUnixTimestamp
    :global ToUnixTimestamp

    :put "Starting GetUnixTimestamp runtime tests..."

    # Executing dynamic check to confirm current live runtime fetches validate correctly
    :local ts1 [$GetUnixTimestamp]
    :local date [$FromUnixTimestamp $ts1]
    :local ts2 [$ToUnixTimestamp $date]

    :if ([:typeof $ts1] = "num" && $ts1 > 1783628648) do={
        :put ("  \1B[32m[PASS]\1B[0m Live system timestamp fetched successfully: " . $ts1)
    } else={
        :put ("  \1B[31m[FAIL]\1B[0m Live system timestamp fetch resulted in invalid structure: " . [:tostr $ts1])
    }

    :if ($ts1 = $ts2) do={
        :put ("  \1B[32m[PASS]\1B[0m Conversion to date successful: " . $date)
    } else={
        :put ("  \1B[31m[FAIL]\1B[0m Conversion to date failed: " . [:tostr $date])
    }

    :put "Testing completed."
}
