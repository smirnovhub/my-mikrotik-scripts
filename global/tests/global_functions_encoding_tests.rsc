:global RunAllEncodingTests
:global Base64EncodeTest
:global Base64DecodeTest
:global UrlEncodeTest
:global UrlDecodeTest

:set RunAllEncodingTests do={
    :global InitTestCaseState
    :global Base64EncodeTest
    :global Base64DecodeTest
    :global UrlEncodeTest
    :global UrlDecodeTest

    :local res [$InitTestCaseState $1]

    :put "\1B[35m=== STARTING ALL ENCODING TESTS ===\1B[0m"

    :set res [$Base64EncodeTest $res]
    :set res [$Base64DecodeTest $res]
    :set res [$UrlEncodeTest $res]
    :set res [$UrlDecodeTest $res]

    :put "\1B[35m=== ALL ENCODING TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set Base64EncodeTest do={
    :global InitTestCaseState
    :global DecToChar
    :global Base64Encode
    :global RunTestCase

    :local res [$InitTestCaseState $1]

    :put "Starting Base64Encode tests..."

    # Empty string validation
    :set res [$RunTestCase $res $Base64Encode "" "nothing" "nothing" "" "Empty string encoding baseline"]

    # Standard RFC 4648 test vectors (Standard alphabet, with padding)
    :set res [$RunTestCase $res $Base64Encode "f" "nothing" "nothing" "Zg==" "Standard alphabet single character padding check"]
    :set res [$RunTestCase $res $Base64Encode "fo" "nothing" "nothing" "Zm8=" "Standard alphabet double character padding check"]
    :set res [$RunTestCase $res $Base64Encode "foo" "nothing" "nothing" "Zm9v" "Standard alphabet exact block no padding check"]
    :set res [$RunTestCase $res $Base64Encode "foobar" "nothing" "nothing" "Zm9vYmFy" "Standard alphabet multi block encoding validation"]

    # URL-safe alphabet validation (Changes '+' to '-' and '/' to '_')
    # "subjects?" encodes to "c3ViamVjdHM/". Standard has '/', URL-safe has '_'
    :set res [$RunTestCase $res $Base64Encode "subjects?" "url" "nothing" "c3ViamVjdHM_" "URL safe alphabet special character substitution check"]

    # No padding validation (Removes '=' from the end)
    :set res [$RunTestCase $res $Base64Encode "f" "nopad" "nothing" "Zg" "Standard alphabet padding stripping validation"]
    :set res [$RunTestCase $res $Base64Encode "fo" "nopad" "nothing" "Zm8" "Standard alphabet multi byte padding stripping validation"]

    # Combined options validation (URL-safe and No padding together)
    :set res [$RunTestCase $res $Base64Encode "subjects?" "url" "nopad" "c3ViamVjdHM_" "Combined URL safe and stripped padding execution path"]

    # Longer RFC 4648 test vectors
    :set res [$RunTestCase $res $Base64Encode "sure." "nothing" "nothing" "c3VyZS4=" "Standard alphabet five byte encoding validation"]
    :set res [$RunTestCase $res $Base64Encode "sure" "nothing" "nothing" "c3VyZQ==" "Standard alphabet four byte encoding validation"]
    :set res [$RunTestCase $res $Base64Encode "sur" "nothing" "nothing" "c3Vy" "Standard alphabet exact three byte block validation"]
    :set res [$RunTestCase $res $Base64Encode "su" "nothing" "nothing" "c3U=" "Standard alphabet two byte encoding validation"]
    :set res [$RunTestCase $res $Base64Encode "s" "nothing" "nothing" "cw==" "Standard alphabet single byte encoding validation"]

    # Numeric data
    :set res [$RunTestCase $res $Base64Encode "1234567890" "nothing" "nothing" "MTIzNDU2Nzg5MA==" "Numeric ASCII encoding validation"]

    # Whitespace preservation
    :set res [$RunTestCase $res $Base64Encode "Hello World" "nothing" "nothing" "SGVsbG8gV29ybGQ=" "Space character encoding validation"]
    :set res [$RunTestCase $res $Base64Encode ("Hello\nWorld") "nothing" "nothing" "SGVsbG8KV29ybGQ=" "Line feed encoding validation"]
    :set res [$RunTestCase $res $Base64Encode ("Hello\r\nWorld") "nothing" "nothing" "SGVsbG8NCldvcmxk" "CRLF sequence encoding validation"]
    :set res [$RunTestCase $res $Base64Encode ("Hello\tWorld") "nothing" "nothing" "SGVsbG8JV29ybGQ=" "Horizontal tab encoding validation"]

    # URL-safe alphabet with padding retained
    :set res [$RunTestCase $res $Base64Encode "subjects?" "url" "nothing" "c3ViamVjdHM_" "URL-safe alphabet with naturally unpadded output validation"]

    # No-padding on values requiring no padding
    :set res [$RunTestCase $res $Base64Encode "foo" "nopad" "nothing" "Zm9v" "No padding option leaves complete block unchanged"]

    # URL-safe + no padding where padding would normally exist
    :set res [$RunTestCase $res $Base64Encode "f" "url" "nopad" "Zg" "URL-safe alphabet single byte without padding validation"]
    :set res [$RunTestCase $res $Base64Encode "fo" "url" "nopad" "Zm8" "URL-safe alphabet double byte without padding validation"]

    # Tail checks: 1-byte, 2-byte, 3-byte remainders with standard padding
    :set res [$RunTestCase $res $Base64Encode "a" "nothing" "nothing" "YQ==" "Standard alphabet tail remainder 1 byte check"]
    :set res [$RunTestCase $res $Base64Encode "ab" "nothing" "nothing" "YWI=" "Standard alphabet tail remainder 2 bytes check"]
    :set res [$RunTestCase $res $Base64Encode "abc" "nothing" "nothing" "YWJj" "Standard alphabet tail remainder 3 bytes exact block check"]
    :set res [$RunTestCase $res $Base64Encode "abcd" "nothing" "nothing" "YWJjZA==" "Standard alphabet tail remainder 4 bytes (1 byte tail) check"]
    :set res [$RunTestCase $res $Base64Encode "abcde" "nothing" "nothing" "YWJjZGU=" "Standard alphabet tail remainder 5 bytes (2 bytes tail) check"]
    :set res [$RunTestCase $res $Base64Encode "abcdef" "nothing" "nothing" "YWJjZGVm" "Standard alphabet tail remainder 6 bytes exact block check"]

    # Tail checks: URL-safe alphabet WITH padding (nopad flag IS NOT set)
    :set res [$RunTestCase $res $Base64Encode ("\FB") "url" "nothing" "-w==" "URL-safe 1-byte tail with standard padding check"]
    :set res [$RunTestCase $res $Base64Encode ("\FF") "url" "nothing" "_w==" "URL-safe 1-byte slash replacement with padding check"]
    :set res [$RunTestCase $res $Base64Encode ("\FB\FF") "url" "nothing" "-_8=" "URL-safe 2-byte tail both special characters with padding check"]

    # Special characters check for Standard '+' and '/'
    :set res [$RunTestCase $res $Base64Encode ("\FB") "nothing" "nothing" "+w==" "Standard alphabet plus character byte check"]
    :set res [$RunTestCase $res $Base64Encode ("\FF") "nothing" "nothing" "/w==" "Standard alphabet slash character byte check"]
    :set res [$RunTestCase $res $Base64Encode ("\FB\FF") "nothing" "nothing" "+/8=" "Standard alphabet consecutive special characters check"]

    # Boundary and non-printable ASCII bytes
    :set res [$RunTestCase $res $Base64Encode ("\00") "nothing" "nothing" "AA==" "Single null byte encoding check"]
    :set res [$RunTestCase $res $Base64Encode ("\00\00") "nothing" "nothing" "AAA=" "Double null byte encoding check"]
    :set res [$RunTestCase $res $Base64Encode ("\00\00\00") "nothing" "nothing" "AAAA" "Triple null byte encoding check"]
    :set res [$RunTestCase $res $Base64Encode ("\01\02\03") "nothing" "nothing" "AQID" "Low non-printable ASCII bytes encoding check"]
    :set res [$RunTestCase $res $Base64Encode ("\7F") "nothing" "nothing" "fw==" "ASCII DEL byte 0x7F encoding check"]
    :set res [$RunTestCase $res $Base64Encode ("\80") "nothing" "nothing" "gA==" "Extended ASCII byte 0x80 encoding check"]
    :set res [$RunTestCase $res $Base64Encode ("\FF") "nothing" "nothing" "/w==" "Extended ASCII byte 0xFF encoding check"]

    # Multi-block binary sequence with URL-safe and nopad options
    :set res [$RunTestCase $res $Base64Encode ("\FB\FF\FB\FF") "url" "nopad" "-__7_w" "URL-safe no-pad 4-byte complex tail check"]
    :set res [$RunTestCase $res $Base64Encode ("\FF\FB\FF\FB\FF") "url" "nopad" "__v_-_8" "URL-safe no-pad 5-byte complex tail check"]

    # All 256 byte values
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    :set res [$RunTestCase $res $Base64Encode $allChars "nothing" "nothing" "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w==" "All 256 byte values"]

    :put "Testing completed."
    :return $res
}

:set Base64DecodeTest do={
    :global InitTestCaseState
    :global DecToChar
    :global Base64Encode
    :global Base64Decode
    :global RunTestCase

    :local res [$InitTestCaseState $1]

    :put "Starting Base64Decode tests..."

    # Empty string validation
    :set res [$RunTestCase $res $Base64Decode "" "nothing" "nothing" "" "Empty string decoding baseline"]

    # Standard RFC 4648 validation
    :set res [$RunTestCase $res $Base64Decode "Zg==" "nothing" "nothing" "f" "Standard decode single byte with full padding"]
    :set res [$RunTestCase $res $Base64Decode "Zm8=" "nothing" "nothing" "fo" "Standard decode double byte with full padding"]
    :set res [$RunTestCase $res $Base64Decode "Zm9v" "nothing" "nothing" "foo" "Standard decode complete block without padding"]

    # URL-safe alphabet decoding
    :set res [$RunTestCase $res $Base64Decode "c3ViamVjdHM_" "url" "nothing" "subjects?" "URL safe alphabet conversion decoding target"]

    # Optional padding omission handling
    :set res [$RunTestCase $res $Base64Decode "Zg" "nothing" "nothing" "f" "Implicit tolerance decode with missing padding characters"]

    # Strict padding enforcement validation
    # If "mustpad" flag is present, unpadded string should either trigger error or return empty block depending on core strategy
    :set res [$RunTestCase $res $Base64Decode "Zg" "mustpad" "nothing" "error" "Strict padding enforcement rejection baseline check"]

    # Ignore invalid characters handling (skips spaces, line breaks, etc.)
    :set res [$RunTestCase $res $Base64Decode "Zm 9v" "ignoreotherchr" "nothing" "foo" "Ignore invalid character spaces option check"]

    # Additional RFC 4648 vectors
    :set res [$RunTestCase $res $Base64Decode "cw==" "nothing" "nothing" "s" "Standard decode single byte vector"]
    :set res [$RunTestCase $res $Base64Decode "c3U=" "nothing" "nothing" "su" "Standard decode two byte vector"]
    :set res [$RunTestCase $res $Base64Decode "c3Vy" "nothing" "nothing" "sur" "Standard decode exact block vector"]
    :set res [$RunTestCase $res $Base64Decode "c3VyZQ==" "nothing" "nothing" "sure" "Standard decode four byte vector"]
    :set res [$RunTestCase $res $Base64Decode "c3VyZS4=" "nothing" "nothing" "sure." "Standard decode five byte vector"]

    # Numeric data
    :set res [$RunTestCase $res $Base64Decode "MTIzNDU2Nzg5MA==" "nothing" "nothing" "1234567890" "Numeric ASCII decoding validation"]

    # Whitespace preservation
    :set res [$RunTestCase $res $Base64Decode "SGVsbG8gV29ybGQ=" "nothing" "nothing" "Hello World" "Space character decoding validation"]
    :set res [$RunTestCase $res $Base64Decode "SGVsbG8KV29ybGQ=" "nothing" "nothing" ("Hello\nWorld") "Line feed decoding validation"]
    :set res [$RunTestCase $res $Base64Decode "SGVsbG8NCldvcmxk" "nothing" "nothing" ("Hello\r\nWorld") "CRLF sequence decoding validation"]
    :set res [$RunTestCase $res $Base64Decode "SGVsbG8JV29ybGQ=" "nothing" "nothing" ("Hello\tWorld") "Horizontal tab decoding validation"]

    # Missing padding (multiple cases)
    :set res [$RunTestCase $res $Base64Decode "Zm8" "nothing" "nothing" "fo" "Implicit tolerance decode with one missing padding character"]
    :set res [$RunTestCase $res $Base64Decode "c3VyZQ" "nothing" "nothing" "sure" "Implicit tolerance decode four byte vector without padding"]
    :set res [$RunTestCase $res $Base64Decode "c3VyZS4" "nothing" "nothing" "sure." "Implicit tolerance decode five byte vector without padding"]

    # Ignore invalid characters
    :set res [$RunTestCase $res $Base64Decode "Zm9v!!" "ignoreotherchr" "nothing" "foo" "Ignore trailing invalid characters"]
    :set res [$RunTestCase $res $Base64Decode ("Zm\t9v") "ignoreotherchr" "nothing" "foo" "Ignore tab character during decoding"]
    :set res [$RunTestCase $res $Base64Decode ("Zm9v\r\n") "ignoreotherchr" "nothing" "foo" "Ignore CRLF during decoding"]
    :set res [$RunTestCase $res $Base64Decode " Zm9v " "ignoreotherchr" "nothing" "foo" "Ignore leading and trailing spaces"]

    # Additional ASCII strings
    :set res [$RunTestCase $res $Base64Decode "YQ==" "nothing" "nothing" "a" "Standard decode lowercase single character"]
    :set res [$RunTestCase $res $Base64Decode "YWI=" "nothing" "nothing" "ab" "Standard decode lowercase two characters"]
    :set res [$RunTestCase $res $Base64Decode "YWJj" "nothing" "nothing" "abc" "Standard decode lowercase three characters"]
    :set res [$RunTestCase $res $Base64Decode "YWJjZA==" "nothing" "nothing" "abcd" "Standard decode lowercase four characters"]
    :set res [$RunTestCase $res $Base64Decode "YWJjZGU=" "nothing" "nothing" "abcde" "Standard decode lowercase five characters"]
    :set res [$RunTestCase $res $Base64Decode "YWJjZGVm" "nothing" "nothing" "abcdef" "Standard decode lowercase six characters"]

    # Uppercase
    :set res [$RunTestCase $res $Base64Decode "QUJD" "nothing" "nothing" "ABC" "Standard decode uppercase exact block"]
    :set res [$RunTestCase $res $Base64Decode "QUJDRA==" "nothing" "nothing" "ABCD" "Standard decode uppercase four characters"]

    # Digits
    :set res [$RunTestCase $res $Base64Decode "MA==" "nothing" "nothing" "0" "Standard decode single digit"]
    :set res [$RunTestCase $res $Base64Decode "MDEyMzQ1Njc4OQ==" "nothing" "nothing" "0123456789" "Standard decode decimal digit sequence"]

    # Punctuation
    :set res [$RunTestCase $res $Base64Decode "IQ==" "nothing" "nothing" "!" "Standard decode exclamation mark"]
    :set res [$RunTestCase $res $Base64Decode "Py8r" "nothing" "nothing" "?/+" "Standard decode punctuation characters"]
    :set res [$RunTestCase $res $Base64Decode "Oi0p" "nothing" "nothing" ":-)" "Standard decode ASCII emoticon"]

    # Missing padding
    :set res [$RunTestCase $res $Base64Decode "YQ" "nothing" "nothing" "a" "Implicit tolerance decode single character without padding"]
    :set res [$RunTestCase $res $Base64Decode "YWI" "nothing" "nothing" "ab" "Implicit tolerance decode two characters without padding"]
    :set res [$RunTestCase $res $Base64Decode "YWJjZA" "nothing" "nothing" "abcd" "Implicit tolerance decode four characters without padding"]
    :set res [$RunTestCase $res $Base64Decode "YWJjZGU" "nothing" "nothing" "abcde" "Implicit tolerance decode five characters without padding"]

    # Ignore invalid characters
    :set res [$RunTestCase $res $Base64Decode "Y W J j" "ignoreotherchr" "nothing" "abc" "Ignore embedded spaces"]
    :set res [$RunTestCase $res $Base64Decode "YWJj***" "ignoreotherchr" "nothing" "abc" "Ignore trailing asterisk characters"]
    :set res [$RunTestCase $res $Base64Decode "***YWJj" "ignoreotherchr" "nothing" "abc" "Ignore leading asterisk characters"]
    :set res [$RunTestCase $res $Base64Decode "YW@J#j" "ignoreotherchr" "nothing" "abc" "Ignore mixed invalid punctuation"]
    :set res [$RunTestCase $res $Base64Decode ("YW\nJj") "ignoreotherchr" "nothing" "abc" "Ignore embedded line feed"]
    :set res [$RunTestCase $res $Base64Decode ("YW\rJj") "ignoreotherchr" "nothing" "abc" "Ignore embedded carriage return"]
    :set res [$RunTestCase $res $Base64Decode ("YW\r\nJj") "ignoreotherchr" "nothing" "abc" "Ignore embedded CRLF sequence"]
    :set res [$RunTestCase $res $Base64Decode ("YW\tJj") "ignoreotherchr" "nothing" "abc" "Ignore embedded horizontal tab"]

    # URL-safe without padding
    :set res [$RunTestCase $res $Base64Decode "c3ViamVjdHM_" "url" "nothing" "subjects?" "URL-safe decode without padding"]

    # Strict padding
    :set res [$RunTestCase $res $Base64Decode "YQ" "mustpad" "nothing" "error" "Strict padding rejection single character"]
    :set res [$RunTestCase $res $Base64Decode "YWI" "mustpad" "nothing" "error" "Strict padding rejection two characters"]
    :set res [$RunTestCase $res $Base64Decode "YWJjZA" "mustpad" "nothing" "error" "Strict padding rejection four characters"]
    :set res [$RunTestCase $res $Base64Decode "YWJjZGU" "mustpad" "nothing" "error" "Strict padding rejection five characters"]

    # Invalid length (Length % 4 == 1)
    :set res [$RunTestCase $res $Base64Decode "A" "nothing" "nothing" "error" "Single Base64 character cannot form a valid quantum"]
    :set res [$RunTestCase $res $Base64Decode "AAAAA" "nothing" "nothing" "error" "Length modulo four equals one rejection"]
    :set res [$RunTestCase $res $Base64Decode "AAAAAAAAA" "nothing" "nothing" "error" "Long input with invalid modulo one length rejection"]

    # Invalid padding placement
    :set res [$RunTestCase $res $Base64Decode "Z===" "nothing" "nothing" "error" "Three padding characters are invalid"]
    :set res [$RunTestCase $res $Base64Decode "Z=g=" "nothing" "nothing" "error" "Padding inside encoded block rejection"]
    :set res [$RunTestCase $res $Base64Decode "Zm9v=" "nothing" "nothing" "error" "Trailing padding after completed block rejection"]

    # Invalid characters
    :set res [$RunTestCase $res $Base64Decode "Zm9!" "nothing" "nothing" "error" "Invalid punctuation character rejection"]
    :set res [$RunTestCase $res $Base64Decode "Zm9*" "nothing" "nothing" "error" "Invalid asterisk character rejection"]
    :set res [$RunTestCase $res $Base64Decode "Zm9," "nothing" "nothing" "error" "Invalid comma character rejection"]
    :set res [$RunTestCase $res $Base64Decode "Zm9:" "nothing" "nothing" "error" "Invalid colon character rejection"]
    :set res [$RunTestCase $res $Base64Decode "Zm9;" "nothing" "nothing" "error" "Invalid semicolon character rejection"]
    :set res [$RunTestCase $res $Base64Decode ("Zm9\"") "nothing" "nothing" "error" "Invalid quotation mark rejection"]

    # URL-safe mode rejects standard alphabet
    :set res [$RunTestCase $res $Base64Decode "c3ViamVjdHM/" "url" "nothing" "error" "Standard slash rejected in URL-safe mode"]
    :set res [$RunTestCase $res $Base64Decode "c3ViamVjdHM+" "url" "nothing" "error" "Standard plus rejected in URL-safe mode"]

    # Standard mode rejects URL-safe alphabet
    :set res [$RunTestCase $res $Base64Decode "c3ViamVjdHM_" "nothing" "nothing" "error" "Underscore rejected in standard alphabet"]
    :set res [$RunTestCase $res $Base64Decode "c3ViamVjdHM-" "nothing" "nothing" "error" "Dash rejected in standard alphabet"]

    # Ignore invalid characters
    :set res [$RunTestCase $res $Base64Decode "***Zm9v***" "ignoreotherchr" "nothing" "foo" "Ignore invalid characters on both sides"]
    :set res [$RunTestCase $res $Base64Decode "@@@Zm9v###" "ignoreotherchr" "nothing" "foo" "Ignore mixed leading and trailing invalid characters"]
    :set res [$RunTestCase $res $Base64Decode ("Z\$m9^v") "ignoreotherchr" "nothing" "foo" "Ignore embedded punctuation"]
    :set res [$RunTestCase $res $Base64Decode ("Z m\t9\nv\r") "ignoreotherchr" "nothing" "foo" "Ignore mixed whitespace characters"]

    # Only ignored characters
    :set res [$RunTestCase $res $Base64Decode "***" "ignoreotherchr" "nothing" "" "Only invalid characters produce empty output"]
    :set res [$RunTestCase $res $Base64Decode "   " "ignoreotherchr" "nothing" "" "Only whitespace produces empty output"]
    :set res [$RunTestCase $res $Base64Decode ("\r\n\t") "ignoreotherchr" "nothing" "" "Only control whitespace produces empty output"]

    # Additional valid vectors
    :set res [$RunTestCase $res $Base64Decode "TWFu" "nothing" "nothing" "Man" "RFC 4648 complete four character block"]
    :set res [$RunTestCase $res $Base64Decode "VGVzdA==" "nothing" "nothing" "Test" "Standard four letter word decoding"]
    :set res [$RunTestCase $res $Base64Decode "SGVsbG8=" "nothing" "nothing" "Hello" "Standard five letter word decoding"]
    :set res [$RunTestCase $res $Base64Decode "V29ybGQ=" "nothing" "nothing" "World" "Standard word decoding"]

    # Binary round-trip validation for all possible byte values (0x00-0xFF)
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    :local encoded [$Base64Encode $allChars]
    :local decoded [$Base64Decode $encoded]

    :if ($decoded = $allChars) do={
        :set ($res->"passed") (($res->"passed") + 1)
        :put "  \1B[32m[PASS]\1B[0m Full binary round-trip validation (0x00-0xFF)"
    } else={
        :set ($res->"failed") (($res->"failed") + 1)
        :put "  \1B[31m[FAIL]\1B[0m Full binary round-trip validation (0x00-0xFF)"
        :put ("Expected length: " . [:len $allChars])
        :put ("Actual length: " . [:len $decoded])

        :for i from=0 to=255 do={
            :if ([:pick $allChars $i ($i + 1)] != [:pick $decoded $i ($i + 1)]) do={
                :put ("First mismatch at byte index " . $i)
            }
        }
    }

    # Unpadded Base64 vectors (testing remaining tail characters logic)
    :set res [$RunTestCase $res $Base64Decode "TWFuU3VuTQ" "nothing" "nothing" "ManSunM" "Unpadded tail with 2 characters (rem=2)"]
    :set res [$RunTestCase $res $Base64Decode "TQ" "nothing" "nothing" "M" "Minimal unpadded tail with 2 characters (rem=2)"]

    :set res [$RunTestCase $res $Base64Decode "TWFuU3VuTWE" "nothing" "nothing" "ManSunMa" "Unpadded tail with 3 characters (rem=3)"]
    :set res [$RunTestCase $res $Base64Decode "TWE" "nothing" "nothing" "Ma" "Minimal unpadded tail with 3 characters (rem=3)"]

    :put "Testing completed."
    :return $res
}

:set UrlEncodeTest do={
    :global InitTestCaseState
    :global DecToChar
    :global UrlEncode
    :global RunTestCase

    :local res [$InitTestCaseState $1]

    :put "Starting UrlEncode tests..."

    # Empty and alpha numeric baseline validation
    :set res [$RunTestCase $res $UrlEncode "" "nothing" "nothing" "" "Empty string encoding baseline"]
    :set res [$RunTestCase $res $UrlEncode "RouterOS123" "nothing" "nothing" "RouterOS123" "Alphanumeric string unescaped pass through check"]

    # Space character handling (Standard percent encoding targets %20)
    :set res [$RunTestCase $res $UrlEncode "Hello World" "nothing" "nothing" "Hello%20World" "Space character encoding to percent twenty"]

    # Common URL parameter delimiters and separators
    :set res [$RunTestCase $res $UrlEncode "foo=bar" "nothing" "nothing" "foo%3Dbar" "Equals sign character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "a&b" "nothing" "nothing" "a%26b" "Ampersand sign character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "path/to/file" "nothing" "nothing" "path/to/file" "Forward slash character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "search?q=test" "nothing" "nothing" "search%3Fq%3Dtest" "Question mark character encoding validation"]

    # Extended punctuation and reserved character sets
    :set res [$RunTestCase $res $UrlEncode "!" "nothing" "nothing" "%21" "Exclamation mark encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "@" "nothing" "nothing" "%40" "At sign symbol encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "#" "nothing" "nothing" "%23" "Hash sign symbol encoding validation"]
    :set res [$RunTestCase $res $UrlEncode ("\$") "nothing" "nothing" "%24" "Dollar sign symbol encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "%" "nothing" "nothing" "%25" "Percent sign self encoding validation"]

    # Plus sign and arithmetic symbols
    :set res [$RunTestCase $res $UrlEncode "a+b" "nothing" "nothing" "a%2Bb" "Plus sign character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "1-2_3.4~5" "nothing" "nothing" "1-2_3.4~5" "Unreserved RFC 3986 character pass through validation"]

    # Brackets and quotes
    :set res [$RunTestCase $res $UrlEncode "()" "nothing" "nothing" "%28%29" "Parenthesis character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "[]" "nothing" "nothing" "%5B%5D" "Square bracket character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "{}" "nothing" "nothing" "%7B%7D" "Curly brace character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode ("\"") "nothing" "nothing" "%22" "Quotation mark character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "'" "nothing" "nothing" "%27" "Apostrophe character encoding validation"]

    # Delimiters
    :set res [$RunTestCase $res $UrlEncode ":" "nothing" "nothing" "%3A" "Colon character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode ";" "nothing" "nothing" "%3B" "Semicolon character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "," "nothing" "nothing" "%2C" "Comma character encoding validation"]

    # Miscellaneous reserved characters
    :set res [$RunTestCase $res $UrlEncode "<>" "nothing" "nothing" "%3C%3E" "Angle bracket character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "|" "nothing" "nothing" "%7C" "Vertical bar character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode ("\\") "nothing" "nothing" "%5C" "Backslash character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "^" "nothing" "nothing" "%5E" "Caret character encoding validation"]
    :set res [$RunTestCase $res $UrlEncode "`" "nothing" "nothing" "%60" "Backtick character encoding validation"]

    # Mixed string
    :set res [$RunTestCase $res $UrlEncode "A+B=C&D" "nothing" "nothing" "A%2BB%3DC%26D" "Mixed reserved character encoding validation"]

    # Test encoding for all unreserved ASCII characters
    :local unreserved "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-/_.~"
    :set res [$RunTestCase $res $UrlEncode $unreserved "nothing" "nothing" $unreserved "Do not encode unreserved ASCII characters"]

    # Test encoding for all reserved / special ASCII bytes (0x00 to 0xFF)
    :local hexDigits "0123456789ABCDEF"

    :local inputToEncode ""
    :local expectedResult ""

    :for byteVal from=0 to=255 do={
        :local char [$DecToChar $byteVal]

        # Check if the character is in unreserved list
        :local isUnreserved false
        :for i from=0 to=([:len $unreserved] - 1) do={
            :if ([:pick $unreserved $i] = $char) do={
                :set isUnreserved true
            }
        }

        # If character is not unreserved, build input and expected %XX string
        :if (!$isUnreserved) do={
            :local highNibble ($byteVal / 16)
            :local lowNibble ($byteVal % 16)
            :local hexCode ("%" . [:pick $hexDigits $highNibble] . [:pick $hexDigits $lowNibble])

            :set inputToEncode ($inputToEncode . $char)
            :set expectedResult ($expectedResult . $hexCode)
        }
    }

    :set res [$RunTestCase $res $UrlEncode $inputToEncode "nothing" "nothing" $expectedResult "Encode all reserved and non-printable ASCII characters"]

    :put "Testing completed."
    :return $res
}

:set UrlDecodeTest do={
    :global InitTestCaseState
    :global DecToChar
    :global UrlEncode
    :global UrlDecode
    :global RunTestCase

    :local res [$InitTestCaseState $1]

    :put "Starting UrlDecode tests..."

    # Empty and clean baseline strings
    :set res [$RunTestCase $res $UrlDecode "" "nothing" "nothing" "" "Empty string decoding baseline"]
    :set res [$RunTestCase $res $UrlDecode "MikroTik" "nothing" "nothing" "MikroTik" "Pure alphanumeric string decoding bypass verification"]

    # Escape sequence conversions
    :set res [$RunTestCase $res $UrlDecode "Hello%20World" "nothing" "nothing" "Hello World" "Percent twenty sequence decoding back to standard space"]
    :set res [$RunTestCase $res $UrlDecode "foo%3Dbar" "nothing" "nothing" "foo=bar" "Percent 3D hexadecimal decoding back to equals sign"]
    :set res [$RunTestCase $res $UrlDecode "a%26b" "nothing" "nothing" "a&b" "Percent 26 hexadecimal decoding back to ampersand sign"]
    :set res [$RunTestCase $res $UrlDecode "path%2Fto%2Ffile" "nothing" "nothing" "path/to/file" "Percent 2F hexadecimal decoding back to forward slash"]
    :set res [$RunTestCase $res $UrlDecode "search%3Fq%3Dtest" "nothing" "nothing" "search?q=test" "Percent 3F hexadecimal decoding back to question mark"]

    # Combined complex sequences
    :set res [$RunTestCase $res $UrlDecode "%21%40%23%24%25" "nothing" "nothing" ("!@#\$%") "Consecutive compound percent hex sequence block decoding"]

    # Case insensitivity layout check (RFC compliance checks for hex characters)
    :set res [$RunTestCase $res $UrlDecode "foo%3dbar" "nothing" "nothing" "foo=bar" "Lowercase hexadecimal sequence fallback tolerance check"]

    # Plus sign and arithmetic symbols
    :set res [$RunTestCase $res $UrlDecode "a%2Bb" "nothing" "nothing" "a+b" "Percent 2B hexadecimal decoding back to plus sign"]
    :set res [$RunTestCase $res $UrlDecode "1-2_3.4~5" "nothing" "nothing" "1-2_3.4~5" "Unreserved RFC 3986 character decoding bypass validation"]

    # Brackets and quotes
    :set res [$RunTestCase $res $UrlDecode "%28%29" "nothing" "nothing" "()" "Percent 28 and 29 hexadecimal decoding back to parentheses"]
    :set res [$RunTestCase $res $UrlDecode "%5B%5D" "nothing" "nothing" "[]" "Percent 5B and 5D hexadecimal decoding back to square brackets"]
    :set res [$RunTestCase $res $UrlDecode "%7B%7D" "nothing" "nothing" "{}" "Percent 7B and 7D hexadecimal decoding back to curly brackets"]
    :set res [$RunTestCase $res $UrlDecode "%22" "nothing" "nothing" ("\"") "Percent 22 hexadecimal decoding back to quotation mark"]
    :set res [$RunTestCase $res $UrlDecode "%27" "nothing" "nothing" "'" "Percent 27 hexadecimal decoding back to apostrophe"]

    # Delimiters
    :set res [$RunTestCase $res $UrlDecode "%3A" "nothing" "nothing" ":" "Percent 3A hexadecimal decoding back to colon"]
    :set res [$RunTestCase $res $UrlDecode "%3B" "nothing" "nothing" ";" "Percent 3B hexadecimal decoding back to semicolon"]
    :set res [$RunTestCase $res $UrlDecode "%2C" "nothing" "nothing" "," "Percent 2C hexadecimal decoding back to comma"]

    # Miscellaneous reserved characters
    :set res [$RunTestCase $res $UrlDecode "%3C%3E" "nothing" "nothing" "<>" "Percent 3C and 3E hexadecimal decoding back to angle brackets"]
    :set res [$RunTestCase $res $UrlDecode "%7C" "nothing" "nothing" "|" "Percent 7C hexadecimal decoding back to vertical bar"]
    :set res [$RunTestCase $res $UrlDecode "%5C" "nothing" "nothing" ("\\") "Percent 5C hexadecimal decoding back to backslash"]
    :set res [$RunTestCase $res $UrlDecode "%5E" "nothing" "nothing" "^" "Percent 5E hexadecimal decoding back to caret"]
    :set res [$RunTestCase $res $UrlDecode "%60" "nothing" "nothing" "`" "Percent 60 hexadecimal decoding back to backtick"]

    # Mixed string
    :set res [$RunTestCase $res $UrlDecode "A%2BB%3DC%26D" "nothing" "nothing" "A+B=C&D" "Mixed reserved character decoding validation"]

    # Lowercase hexadecimal
    :set res [$RunTestCase $res $UrlDecode "%2b%3a%3b%2c" "nothing" "nothing" "+:;," "Lowercase hexadecimal reserved character decoding validation"]

    # Test: All 256 byte values
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }
    :set res [$RunTestCase $res $UrlDecode [$UrlEncode $allChars] "nothing" "nothing" $allChars "All 256 byte values"]

    :put "Testing completed."
    :return $res
}
