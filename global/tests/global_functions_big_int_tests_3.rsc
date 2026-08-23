:global RunAllBigIntTests3
:global BigIntHexToDecTest

:set RunAllBigIntTests3 do={
    :global InitTestCaseState
    :global BigIntHexToDecTest

    :local res [$InitTestCaseState $1]

    :put "\1B[35m=== STARTING ALL BIG INT 3 TESTS ===\1B[0m"

    :set res [$BigIntHexToDecTest $res]

    :put "\1B[35m=== ALL BIG INT 3 TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set BigIntHexToDecTest do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntHexToDec
    :global BigIntDecToHex
    :global GetRandom20CharHex
    :global GetSha1Sum
    :global GetSha256Sum
    :global GetSha512Sum

    :local res [$InitTestCaseState $1]

    :put "Starting BigIntHexToDec tests..."

    :set res [$RunTestCase $res $BigIntHexToDec "" "nothing" "nothing" "0" "Empty string"]
    :set res [$RunTestCase $res $BigIntHexToDec "0" "nothing" "nothing" "0" "Zero hex value"]
    :set res [$RunTestCase $res $BigIntHexToDec "1" "nothing" "nothing" "1" "Single digit one"]
    :set res [$RunTestCase $res $BigIntHexToDec "9" "nothing" "nothing" "9" "Single digit nine"]
    :set res [$RunTestCase $res $BigIntHexToDec "A" "nothing" "nothing" "10" "Single digit A uppercase"]
    :set res [$RunTestCase $res $BigIntHexToDec "a" "nothing" "nothing" "10" "Single digit a lowercase"]
    :set res [$RunTestCase $res $BigIntHexToDec "F" "nothing" "nothing" "15" "Single digit F uppercase"]
    :set res [$RunTestCase $res $BigIntHexToDec "f" "nothing" "nothing" "15" "Single digit f lowercase"]
    :set res [$RunTestCase $res $BigIntHexToDec "10" "nothing" "nothing" "16" "Hex 10 to decimal"]
    :set res [$RunTestCase $res $BigIntHexToDec "FF" "nothing" "nothing" "255" "Byte max FF"]
    :set res [$RunTestCase $res $BigIntHexToDec "100" "nothing" "nothing" "256" "Hex 100"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFF" "nothing" "nothing" "4095" "Three nibbles FFF"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFF" "nothing" "nothing" "65535" "Word max FFFF"]
    :set res [$RunTestCase $res $BigIntHexToDec "10000" "nothing" "nothing" "65536" "Hex 10000"]
    :set res [$RunTestCase $res $BigIntHexToDec "7FFFFFFF" "nothing" "nothing" "2147483647" "Signed 32-bit max"]
    :set res [$RunTestCase $res $BigIntHexToDec "80000000" "nothing" "nothing" "2147483648" "Signed 32-bit overflow boundary"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFFFFFF" "nothing" "nothing" "4294967295" "DWord max FFFFFFFF"]
    :set res [$RunTestCase $res $BigIntHexToDec "100000000" "nothing" "nothing" "4294967296" "DWord plus one hex"]
    :set res [$RunTestCase $res $BigIntHexToDec "12345678" "nothing" "nothing" "305419896" "Standard 4-byte sequence"]
    :set res [$RunTestCase $res $BigIntHexToDec "abcdef01" "nothing" "nothing" "2882400001" "Lowercase hex test"]
    :set res [$RunTestCase $res $BigIntHexToDec "ABCDEF01" "nothing" "nothing" "2882400001" "Uppercase hex test"]

    :set res [$RunTestCase $res $BigIntHexToDec "0000000000000001" "nothing" "nothing" "1" "Leading zeros test"]
    :set res [$RunTestCase $res $BigIntHexToDec "00000000FFFFFFFF" "nothing" "nothing" "4294967295" "Padding with DWord max"]
    :set res [$RunTestCase $res $BigIntHexToDec "10000000000000000" "nothing" "nothing" "18446744073709551616" "Eight-byte boundary"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFFFFFFFFFFFFFF" "nothing" "nothing" "18446744073709551615" "QWord max FFFFFFFFFFFFFFFF"]
    :set res [$RunTestCase $res $BigIntHexToDec "10000000000000001" "nothing" "nothing" "18446744073709551617" "QWord max plus one"]
    :set res [$RunTestCase $res $BigIntHexToDec "ABCDEF0123456789" "nothing" "nothing" "12379813738877118345" "Mixed large hex string"]
    :set res [$RunTestCase $res $BigIntHexToDec "9876543210FEDCBA" "nothing" "nothing" "10986060915027139770" "Another large mixed hex string"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFFFFFFFFFFFFFFFFFFFFFF" "nothing" "nothing" "79228162514264337593543950335" "24-hex-digits string"]
    :set res [$RunTestCase $res $BigIntHexToDec "1234567890ABCDEF1234567890ABCDEF" "nothing" "nothing" "24197857200151252728969465429440056815" "32-hex-digits string"]

    :set res [$RunTestCase $res $BigIntHexToDec "00" "nothing" "nothing" "0" "Two zero bytes padding"]
    :set res [$RunTestCase $res $BigIntHexToDec "000" "nothing" "nothing" "0" "Three zero bytes padding"]
    :set res [$RunTestCase $res $BigIntHexToDec "0000" "nothing" "nothing" "0" "Four zero bytes padding"]
    :set res [$RunTestCase $res $BigIntHexToDec "00000" "nothing" "nothing" "0" "Five zero bytes padding"]
    :set res [$RunTestCase $res $BigIntHexToDec "000000" "nothing" "nothing" "0" "Six zero bytes padding"]
    :set res [$RunTestCase $res $BigIntHexToDec "0000000" "nothing" "nothing" "0" "Seven zero bytes padding"]
    :set res [$RunTestCase $res $BigIntHexToDec "00000000" "nothing" "nothing" "0" "Eight zero bytes padding"]
    :set res [$RunTestCase $res $BigIntHexToDec "01" "nothing" "nothing" "1" "Leading zero with one"]
    :set res [$RunTestCase $res $BigIntHexToDec "001" "nothing" "nothing" "1" "Multiple leading zeros with one"]
    :set res [$RunTestCase $res $BigIntHexToDec "0001" "nothing" "nothing" "1" "Four-length leading zero"]
    :set res [$RunTestCase $res $BigIntHexToDec "00001" "nothing" "nothing" "1" "Five-length leading zero"]
    :set res [$RunTestCase $res $BigIntHexToDec "00000001" "nothing" "nothing" "1" "Eight-length leading zero"]
    :set res [$RunTestCase $res $BigIntHexToDec "0000000001" "nothing" "nothing" "1" "Ten-length leading zero"]
    :set res [$RunTestCase $res $BigIntHexToDec "0000000000000001" "nothing" "nothing" "1" "Sixteen-length leading zero"]
    :set res [$RunTestCase $res $BigIntHexToDec "0F" "nothing" "nothing" "15" "Leading zero with F"]
    :set res [$RunTestCase $res $BigIntHexToDec "00F" "nothing" "nothing" "15" "Multiple leading zeros with F"]
    :set res [$RunTestCase $res $BigIntHexToDec "000F" "nothing" "nothing" "15" "Four-length leading zero with F"]
    :set res [$RunTestCase $res $BigIntHexToDec "0000000F" "nothing" "nothing" "15" "Eight-length leading zero with F"]
    :set res [$RunTestCase $res $BigIntHexToDec "0100" "nothing" "nothing" "256" "Leading zero with 100"]
    :set res [$RunTestCase $res $BigIntHexToDec "000100" "nothing" "nothing" "256" "Multiple leading zeros with 100"]
    :set res [$RunTestCase $res $BigIntHexToDec "00000100" "nothing" "nothing" "256" "Eight-length leading zero with 100"]
    :set res [$RunTestCase $res $BigIntHexToDec "000000000100" "nothing" "nothing" "256" "Twelve-length leading zero with 100"]
    :set res [$RunTestCase $res $BigIntHexToDec "0FFFFFFF" "nothing" "nothing" "268435455" "Boundary just below 7FFFFFFF with zero"]
    :set res [$RunTestCase $res $BigIntHexToDec "00FFFFFFF" "nothing" "nothing" "268435455" "Nine length with leading zero below max"]
    :set res [$RunTestCase $res $BigIntHexToDec "00000000FFFFFFFF" "nothing" "nothing" "4294967295" "Sixteen length leading zeros full DWORD"]
    :set res [$RunTestCase $res $BigIntHexToDec "0000000000000000FFFFFFFF" "nothing" "nothing" "4294967295" "Twenty-four length leading zeros full DWORD"]
    :set res [$RunTestCase $res $BigIntHexToDec "01234567" "nothing" "nothing" "19088743" "Leading zero with structured sequence"]
    :set res [$RunTestCase $res $BigIntHexToDec "001234567" "nothing" "nothing" "19088743" "Nine length sequence with leading zero"]
    :set res [$RunTestCase $res $BigIntHexToDec "0000000012345678" "nothing" "nothing" "305419896" "Sixteen length sequence with leading zero"]
    :set res [$RunTestCase $res $BigIntHexToDec "000000000000000012345678" "nothing" "nothing" "305419896" "Twenty-four length sequence with leading zero"]

    :set res [$RunTestCase $res $BigIntHexToDec "aBcdEf" "nothing" "nothing" "11259375" "Mixed case aBcdEf"]
    :set res [$RunTestCase $res $BigIntHexToDec "AbCdEf" "nothing" "nothing" "11259375" "Mixed case AbCdEf"]
    :set res [$RunTestCase $res $BigIntHexToDec "a1b2C3d4E5f6" "nothing" "nothing" "177789161760246" "Complex mixed case string"]
    :set res [$RunTestCase $res $BigIntHexToDec "FfFfFfFf" "nothing" "nothing" "4294967295" "Mixed case Ff 32-bit max"]
    :set res [$RunTestCase $res $BigIntHexToDec "1a2B3c4D" "nothing" "nothing" "439041101" "Alternating case blocks"]
    :set res [$RunTestCase $res $BigIntHexToDec "00aBcD" "nothing" "nothing" "43981" "Padding with mixed case"]
    :set res [$RunTestCase $res $BigIntHexToDec "DeAdBeEf" "nothing" "nothing" "3735928559" "Classic hex word DeAdBeEf"]
    :set res [$RunTestCase $res $BigIntHexToDec "cAfEbAbE" "nothing" "nothing" "3405691582" "Classic hex word cAfEbAbE"]

    :set res [$RunTestCase $res $BigIntHexToDec "16345785d8a0000" "nothing" "nothing" "100000000000000000" "Hex exact 10^17 target"]
    :set res [$RunTestCase $res $BigIntHexToDec "16345785D8A0000" "nothing" "nothing" "100000000000000000" "Uppercase Hex exact 10^17 target"]
    :set res [$RunTestCase $res $BigIntHexToDec "016345785d8a0000" "nothing" "nothing" "100000000000000000" "Padded Hex exact 10^17 target"]
    :set res [$RunTestCase $res $BigIntHexToDec "de0b6b3a7640000" "nothing" "nothing" "1000000000000000000" "Hex exact 10^18 target"]
    :set res [$RunTestCase $res $BigIntHexToDec "DE0B6B3A7640000" "nothing" "nothing" "1000000000000000000" "Uppercase Hex exact 10^18 target"]
    :set res [$RunTestCase $res $BigIntHexToDec "8AC7230489E80000" "nothing" "nothing" "10000000000000000000" "Hex exact 10^19 target"]
    :set res [$RunTestCase $res $BigIntHexToDec "8ac7230489e80000" "nothing" "nothing" "10000000000000000000" "Lowercase Hex exact 10^19 target"]

    # Chunk boundary tests
    :set res [$RunTestCase $res $BigIntHexToDec "0000000F" "nothing" "nothing" "15" "Eight-digit chunk low value"]
    :set res [$RunTestCase $res $BigIntHexToDec "00000010" "nothing" "nothing" "16" "Eight-digit chunk carry boundary"]
    :set res [$RunTestCase $res $BigIntHexToDec "000000FF" "nothing" "nothing" "255" "Eight-digit chunk FF"]
    :set res [$RunTestCase $res $BigIntHexToDec "00000100" "nothing" "nothing" "256" "Eight-digit chunk 100"]
    :set res [$RunTestCase $res $BigIntHexToDec "0000FFFF" "nothing" "nothing" "65535" "Eight-digit chunk FFFF"]
    :set res [$RunTestCase $res $BigIntHexToDec "007FFFFF" "nothing" "nothing" "8388607" "Eight-digit chunk below 32-bit boundary"]
    :set res [$RunTestCase $res $BigIntHexToDec "00800000" "nothing" "nothing" "8388608" "Eight-digit chunk boundary"]
    :set res [$RunTestCase $res $BigIntHexToDec "7FFFFFFF" "nothing" "nothing" "2147483647" "Eight-digit signed max"]
    :set res [$RunTestCase $res $BigIntHexToDec "80000000" "nothing" "nothing" "2147483648" "Eight-digit signed boundary"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFFFFFF" "nothing" "nothing" "4294967295" "Eight-digit unsigned max"]

    # Multiple 32-bit chunk tests
    :set res [$RunTestCase $res $BigIntHexToDec "0000000100000000" "nothing" "nothing" "4294967296" "Two chunks first one"]
    :set res [$RunTestCase $res $BigIntHexToDec "0000000100000001" "nothing" "nothing" "4294967297" "Two chunks first and last one"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFFFFFF00000000" "nothing" "nothing" "18446744069414584320" "Two chunks high max low zero"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFFFFFF00000001" "nothing" "nothing" "18446744069414584321" "Two chunks high max low one"]
    :set res [$RunTestCase $res $BigIntHexToDec "00000000FFFFFFFF00000000FFFFFFFF" "nothing" "nothing" "79228162495817593524129366015" "Four chunks with zero high chunks"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFFFFFF00000000FFFFFFFF00000000" "nothing" "nothing" "340282366841710300967557013907638845440" "Four chunks alternating max and zero"]

    # Decimal block boundary tests
    :set res [$RunTestCase $res $BigIntHexToDec "3B9ACA00" "nothing" "nothing" "1000000000" "Exact decimal block base 1e9"]
    :set res [$RunTestCase $res $BigIntHexToDec "3B9ACA01" "nothing" "nothing" "1000000001" "Decimal block base plus one"]
    :set res [$RunTestCase $res $BigIntHexToDec "77359400" "nothing" "nothing" "2000000000" "Two decimal blocks"]
    :set res [$RunTestCase $res $BigIntHexToDec "2540BE400" "nothing" "nothing" "10000000000" "Exact 10^10"]
    :set res [$RunTestCase $res $BigIntHexToDec "E8D4A51000" "nothing" "nothing" "1000000000000" "Exact 10^12"]
    :set res [$RunTestCase $res $BigIntHexToDec "3635C9ADC5DEA00000" "nothing" "nothing" "1000000000000000000000" "Exact 10^21"]

    # Values designed to produce decimal blocks with leading zeros
    :set res [$RunTestCase $res $BigIntHexToDec "1000000000000000001" "nothing" "nothing" "4722366482869645213697" "Internal decimal block leading zeros"]
    :set res [$RunTestCase $res $BigIntHexToDec "100000000000000000000000001" "nothing" "nothing" "20282409603651670423947251286017" "Long value with sparse digits"]
    :set res [$RunTestCase $res $BigIntHexToDec "100000000000000000000000000000001" "nothing" "nothing" "340282366920938463463374607431768211457" "Very sparse long value"]

    # Large fixed-width values
    :set res [$RunTestCase $res $BigIntHexToDec "0123456789ABCDEF" "nothing" "nothing" "81985529216486895" "64-bit structured value"]
    :set res [$RunTestCase $res $BigIntHexToDec "FEDCBA9876543210" "nothing" "nothing" "18364758544493064720" "64-bit reverse structured value"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" "nothing" "nothing" "340282366920938463463374607431768211455" "128-bit maximum"]
    :set res [$RunTestCase $res $BigIntHexToDec "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" "nothing" "nothing" "115792089237316195423570985008687907853269984665640564039457584007913129639935" "256-bit maximum"]
    :set res [$RunTestCase $res $BigIntHexToDec "1234567890ABCDEF112233445566778899AABBCCDDEEFF00" "nothing" "nothing" "446371678903360124660323715264983901177100019043954261760" "Large structured 56-digit value"]

    :set res [$RunTestCase $res $BigIntHexToDec \
        "899504AE72497EBA6A06494A791C53A84E3BBF4FE9744598E258D618CD571081D59C03A9D34A86CA0000000000000000000000000000000000" \
        "nothing" "nothing" \
        "100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" \
        "Filling with zeros"]

    :for i from=1 to=35 do={
        :local originalHex [$GetRandom20CharHex]

        :if (($i % 2) = 0) do={
            :put "SHA1"
            :set originalHex [$GetSha1Sum $originalHex]
        } else={
            :if (($i % 3) = 0) do={
                :put "SHA512"
                :set originalHex [$GetSha512Sum $originalHex]
            } else={
                :if (($i % 5) = 0) do={
                    :put "SHA256"
                    :set originalHex [$GetSha256Sum $originalHex]
                }
            }
        }

        # Strip leading zeros because BigIntDecToHex and BigIntHexToDec
        # work with numeric values and do not preserve fixed-width padding
        :local cleanHex $originalHex
        :while ([:len $cleanHex] > 1 && [:pick $cleanHex 0 1] = "0") do={
            :set cleanHex [:pick $cleanHex 1 [:len $cleanHex]]
        }

        :local decimalValue [$BigIntHexToDec $cleanHex]
        :set res [$RunTestCase $res [$BigIntDecToHex $decimalValue] $originalHex "nothing" "nothing" $cleanHex ("Roundtrip test iteration " . $i)]
    }

    :put "Testing completed."
    :return $res
}
