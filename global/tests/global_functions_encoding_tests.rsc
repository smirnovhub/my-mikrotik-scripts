:global RunAllEncodingTests
:global Base64EncodeTest
:global Base64DecodeTest
:global UrlEncodeTest
:global UrlDecodeTest

:set RunAllEncodingTests do={
    :global Base64EncodeTest
    :global Base64DecodeTest
    :global UrlEncodeTest
    :global UrlDecodeTest

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "\1B[35m=== STARTING ALL ENCODING TESTS ===\1B[0m"

    :set res [$Base64EncodeTest $res]
    :set res [$Base64DecodeTest $res]
    :set res [$UrlEncodeTest $res]
    :set res [$UrlDecodeTest $res]

    :put "\1B[35m=== ALL ENCODING TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set Base64EncodeTest do={
    :global DecToChar
    :global Base64Encode
    :global RunEncodingTestCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting Base64Encode tests..."

    # Empty string validation
    :set res [$RunEncodingTestCase $res $Base64Encode "" ({}) "" "Empty string encoding baseline"]

    # Standard RFC 4648 test vectors (Standard alphabet, with padding)
    :set res [$RunEncodingTestCase $res $Base64Encode "f" ({}) "Zg==" "Standard alphabet single character padding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode "fo" ({}) "Zm8=" "Standard alphabet double character padding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode "foo" ({}) "Zm9v" "Standard alphabet exact block no padding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode "foobar" ({}) "Zm9vYmFy" "Standard alphabet multi block encoding validation"]

    # URL-safe alphabet validation (Changes '+' to '-' and '/' to '_')
    # "subjects?" encodes to "c3ViamVjdHM/". Standard has '/', URL-safe has '_'
    :set res [$RunEncodingTestCase $res $Base64Encode "subjects?" ({"url"}) "c3ViamVjdHM_" "URL safe alphabet special character substitution check"]

    # No padding validation (Removes '=' from the end)
    :set res [$RunEncodingTestCase $res $Base64Encode "f" ({""; "nopad"}) "Zg" "Standard alphabet padding stripping validation"]
    :set res [$RunEncodingTestCase $res $Base64Encode "fo" ({""; "nopad"}) "Zm8" "Standard alphabet multi byte padding stripping validation"]

    # Combined options validation (URL-safe and No padding together)
    :set res [$RunEncodingTestCase $res $Base64Encode "subjects?" ({"url"; "nopad"}) "c3ViamVjdHM_" "Combined URL safe and stripped padding execution path"]

    # Longer RFC 4648 test vectors
    :set res [$RunEncodingTestCase $res $Base64Encode "sure." ({}) "c3VyZS4=" "Standard alphabet five byte encoding validation"]
    :set res [$RunEncodingTestCase $res $Base64Encode "sure" ({}) "c3VyZQ==" "Standard alphabet four byte encoding validation"]
    :set res [$RunEncodingTestCase $res $Base64Encode "sur" ({}) "c3Vy" "Standard alphabet exact three byte block validation"]
    :set res [$RunEncodingTestCase $res $Base64Encode "su" ({}) "c3U=" "Standard alphabet two byte encoding validation"]
    :set res [$RunEncodingTestCase $res $Base64Encode "s" ({}) "cw==" "Standard alphabet single byte encoding validation"]

    # Numeric data
    :set res [$RunEncodingTestCase $res $Base64Encode "1234567890" ({}) "MTIzNDU2Nzg5MA==" "Numeric ASCII encoding validation"]

    # Whitespace preservation
    :set res [$RunEncodingTestCase $res $Base64Encode "Hello World" ({}) "SGVsbG8gV29ybGQ=" "Space character encoding validation"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("Hello\nWorld") ({}) "SGVsbG8KV29ybGQ=" "Line feed encoding validation"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("Hello\r\nWorld") ({}) "SGVsbG8NCldvcmxk" "CRLF sequence encoding validation"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("Hello\tWorld") ({}) "SGVsbG8JV29ybGQ=" "Horizontal tab encoding validation"]

    # URL-safe alphabet with padding retained
    :set res [$RunEncodingTestCase $res $Base64Encode "subjects?" ({"url"}) "c3ViamVjdHM_" "URL-safe alphabet with naturally unpadded output validation"]

    # No-padding on values requiring no padding
    :set res [$RunEncodingTestCase $res $Base64Encode "foo" ({""; "nopad"}) "Zm9v" "No padding option leaves complete block unchanged"]

    # URL-safe + no padding where padding would normally exist
    :set res [$RunEncodingTestCase $res $Base64Encode "f" ({"url"; "nopad"}) "Zg" "URL-safe alphabet single byte without padding validation"]
    :set res [$RunEncodingTestCase $res $Base64Encode "fo" ({"url"; "nopad"}) "Zm8" "URL-safe alphabet double byte without padding validation"]

    # Tail checks: 1-byte, 2-byte, 3-byte remainders with standard padding
    :set res [$RunEncodingTestCase $res $Base64Encode "a" ({}) "YQ==" "Standard alphabet tail remainder 1 byte check"]
    :set res [$RunEncodingTestCase $res $Base64Encode "ab" ({}) "YWI=" "Standard alphabet tail remainder 2 bytes check"]
    :set res [$RunEncodingTestCase $res $Base64Encode "abc" ({}) "YWJj" "Standard alphabet tail remainder 3 bytes exact block check"]
    :set res [$RunEncodingTestCase $res $Base64Encode "abcd" ({}) "YWJjZA==" "Standard alphabet tail remainder 4 bytes (1 byte tail) check"]
    :set res [$RunEncodingTestCase $res $Base64Encode "abcde" ({}) "YWJjZGU=" "Standard alphabet tail remainder 5 bytes (2 bytes tail) check"]
    :set res [$RunEncodingTestCase $res $Base64Encode "abcdef" ({}) "YWJjZGVm" "Standard alphabet tail remainder 6 bytes exact block check"]

    # Tail checks: URL-safe alphabet WITH padding (nopad flag IS NOT set)
    :set res [$RunEncodingTestCase $res $Base64Encode ("\FB") ({"url"}) "-w==" "URL-safe 1-byte tail with standard padding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\FF") ({"url"}) "_w==" "URL-safe 1-byte slash replacement with padding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\FB\FF") ({"url"}) "-_8=" "URL-safe 2-byte tail both special characters with padding check"]

    # Special characters check for Standard '+' and '/'
    :set res [$RunEncodingTestCase $res $Base64Encode ("\FB") ({}) "+w==" "Standard alphabet plus character byte check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\FF") ({}) "/w==" "Standard alphabet slash character byte check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\FB\FF") ({}) "+/8=" "Standard alphabet consecutive special characters check"]

    # Boundary and non-printable ASCII bytes
    :set res [$RunEncodingTestCase $res $Base64Encode ("\00") ({}) "AA==" "Single null byte encoding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\00\00") ({}) "AAA=" "Double null byte encoding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\00\00\00") ({}) "AAAA" "Triple null byte encoding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\01\02\03") ({}) "AQID" "Low non-printable ASCII bytes encoding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\7F") ({}) "fw==" "ASCII DEL byte 0x7F encoding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\80") ({}) "gA==" "Extended ASCII byte 0x80 encoding check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\FF") ({}) "/w==" "Extended ASCII byte 0xFF encoding check"]

    # Multi-block binary sequence with URL-safe and nopad options
    :set res [$RunEncodingTestCase $res $Base64Encode ("\FB\FF\FB\FF") ({"url"; "nopad"}) "-__7_w" "URL-safe no-pad 4-byte complex tail check"]
    :set res [$RunEncodingTestCase $res $Base64Encode ("\FF\FB\FF\FB\FF") ({"url"; "nopad"}) "__v_-_8" "URL-safe no-pad 5-byte complex tail check"]

    # All 256 byte values
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    :set res [$RunEncodingTestCase $res $Base64Encode $allChars ({}) "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w==" "All 256 byte values"]

    :put "Testing completed."
    :return $res
}

:set Base64DecodeTest do={
    :global IsPrintableStr
    :global Base64Encode
    :global Base64Decode
    :global RunEncodingTestCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting Base64Decode tests..."

    # Empty string validation
    :set res [$RunEncodingTestCase $res $Base64Decode "" ({}) "" "Empty string decoding baseline"]

    # Standard RFC 4648 validation
    :set res [$RunEncodingTestCase $res $Base64Decode "Zg==" ({}) "f" "Standard decode single byte with full padding"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm8=" ({}) "fo" "Standard decode double byte with full padding"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm9v" ({}) "foo" "Standard decode complete block without padding"]

    # URL-safe alphabet decoding
    :set res [$RunEncodingTestCase $res $Base64Decode "c3ViamVjdHM_" ({"url"}) "subjects?" "URL safe alphabet conversion decoding target"]

    # Optional padding omission handling
    :set res [$RunEncodingTestCase $res $Base64Decode "Zg" ({}) "f" "Implicit tolerance decode with missing padding characters"]

    # Strict padding enforcement validation
    # If "mustpad" flag is present, unpadded string should either trigger error or return empty block depending on core strategy
    :set res [$RunEncodingTestCase $res $Base64Decode "Zg" ({""; "mustpad"}) "error" "Strict padding enforcement rejection baseline check"]

    # Ignore invalid characters handling (skips spaces, line breaks, etc.)
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm 9v" ({""; ""; "ignoreotherchr"}) "foo" "Ignore invalid character spaces option check"]

    # Additional RFC 4648 vectors
    :set res [$RunEncodingTestCase $res $Base64Decode "cw==" ({}) "s" "Standard decode single byte vector"]
    :set res [$RunEncodingTestCase $res $Base64Decode "c3U=" ({}) "su" "Standard decode two byte vector"]
    :set res [$RunEncodingTestCase $res $Base64Decode "c3Vy" ({}) "sur" "Standard decode exact block vector"]
    :set res [$RunEncodingTestCase $res $Base64Decode "c3VyZQ==" ({}) "sure" "Standard decode four byte vector"]
    :set res [$RunEncodingTestCase $res $Base64Decode "c3VyZS4=" ({}) "sure." "Standard decode five byte vector"]

    # Numeric data
    :set res [$RunEncodingTestCase $res $Base64Decode "MTIzNDU2Nzg5MA==" ({}) "1234567890" "Numeric ASCII decoding validation"]

    # Whitespace preservation
    :set res [$RunEncodingTestCase $res $Base64Decode "SGVsbG8gV29ybGQ=" ({}) "Hello World" "Space character decoding validation"]
    :set res [$RunEncodingTestCase $res $Base64Decode "SGVsbG8KV29ybGQ=" ({}) ("Hello\nWorld") "Line feed decoding validation"]
    :set res [$RunEncodingTestCase $res $Base64Decode "SGVsbG8NCldvcmxk" ({}) ("Hello\r\nWorld") "CRLF sequence decoding validation"]
    :set res [$RunEncodingTestCase $res $Base64Decode "SGVsbG8JV29ybGQ=" ({}) ("Hello\tWorld") "Horizontal tab decoding validation"]

    # Missing padding (multiple cases)
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm8" ({}) "fo" "Implicit tolerance decode with one missing padding character"]
    :set res [$RunEncodingTestCase $res $Base64Decode "c3VyZQ" ({}) "sure" "Implicit tolerance decode four byte vector without padding"]
    :set res [$RunEncodingTestCase $res $Base64Decode "c3VyZS4" ({}) "sure." "Implicit tolerance decode five byte vector without padding"]

    # Ignore invalid characters
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm9v!!" ({""; ""; "ignoreotherchr"}) "foo" "Ignore trailing invalid characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("Zm\t9v") ({""; ""; "ignoreotherchr"}) "foo" "Ignore tab character during decoding"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("Zm9v\r\n") ({""; ""; "ignoreotherchr"}) "foo" "Ignore CRLF during decoding"]
    :set res [$RunEncodingTestCase $res $Base64Decode " Zm9v " ({""; ""; "ignoreotherchr"}) "foo" "Ignore leading and trailing spaces"]

    # Additional ASCII strings
    :set res [$RunEncodingTestCase $res $Base64Decode "YQ==" ({}) "a" "Standard decode lowercase single character"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWI=" ({}) "ab" "Standard decode lowercase two characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWJj" ({}) "abc" "Standard decode lowercase three characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWJjZA==" ({}) "abcd" "Standard decode lowercase four characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWJjZGU=" ({}) "abcde" "Standard decode lowercase five characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWJjZGVm" ({}) "abcdef" "Standard decode lowercase six characters"]

    # Uppercase
    :set res [$RunEncodingTestCase $res $Base64Decode "QUJD" ({}) "ABC" "Standard decode uppercase exact block"]
    :set res [$RunEncodingTestCase $res $Base64Decode "QUJDRA==" ({}) "ABCD" "Standard decode uppercase four characters"]

    # Digits
    :set res [$RunEncodingTestCase $res $Base64Decode "MA==" ({}) "0" "Standard decode single digit"]
    :set res [$RunEncodingTestCase $res $Base64Decode "MDEyMzQ1Njc4OQ==" ({}) "0123456789" "Standard decode decimal digit sequence"]

    # Punctuation
    :set res [$RunEncodingTestCase $res $Base64Decode "IQ==" ({}) "!" "Standard decode exclamation mark"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Py8r" ({}) "?/+" "Standard decode punctuation characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Oi0p" ({}) ":-)" "Standard decode ASCII emoticon"]

    # Missing padding
    :set res [$RunEncodingTestCase $res $Base64Decode "YQ" ({}) "a" "Implicit tolerance decode single character without padding"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWI" ({}) "ab" "Implicit tolerance decode two characters without padding"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWJjZA" ({}) "abcd" "Implicit tolerance decode four characters without padding"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWJjZGU" ({}) "abcde" "Implicit tolerance decode five characters without padding"]

    # Ignore invalid characters
    :set res [$RunEncodingTestCase $res $Base64Decode "Y W J j" ({""; ""; "ignoreotherchr"}) "abc" "Ignore embedded spaces"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWJj***" ({""; ""; "ignoreotherchr"}) "abc" "Ignore trailing asterisk characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode "***YWJj" ({""; ""; "ignoreotherchr"}) "abc" "Ignore leading asterisk characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YW@J#j" ({""; ""; "ignoreotherchr"}) "abc" "Ignore mixed invalid punctuation"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("YW\nJj") ({""; ""; "ignoreotherchr"}) "abc" "Ignore embedded line feed"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("YW\rJj") ({""; ""; "ignoreotherchr"}) "abc" "Ignore embedded carriage return"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("YW\r\nJj") ({""; ""; "ignoreotherchr"}) "abc" "Ignore embedded CRLF sequence"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("YW\tJj") ({""; ""; "ignoreotherchr"}) "abc" "Ignore embedded horizontal tab"]

    # URL-safe without padding
    :set res [$RunEncodingTestCase $res $Base64Decode "c3ViamVjdHM_" ({"url"}) "subjects?" "URL-safe decode without padding"]

    # Strict padding
    :set res [$RunEncodingTestCase $res $Base64Decode "YQ" ({""; "mustpad"}) "error" "Strict padding rejection single character"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWI" ({""; "mustpad"}) "error" "Strict padding rejection two characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWJjZA" ({""; "mustpad"}) "error" "Strict padding rejection four characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode "YWJjZGU" ({""; "mustpad"}) "error" "Strict padding rejection five characters"]

    # Invalid length (Length % 4 == 1)
    :set res [$RunEncodingTestCase $res $Base64Decode "A" ({}) "error" "Single Base64 character cannot form a valid quantum"]
    :set res [$RunEncodingTestCase $res $Base64Decode "AAAAA" ({}) "error" "Length modulo four equals one rejection"]
    :set res [$RunEncodingTestCase $res $Base64Decode "AAAAAAAAA" ({}) "error" "Long input with invalid modulo one length rejection"]

    # Invalid padding placement
    :set res [$RunEncodingTestCase $res $Base64Decode "Z===" ({}) "error" "Three padding characters are invalid"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Z=g=" ({}) "error" "Padding inside encoded block rejection"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm9v=" ({}) "error" "Trailing padding after completed block rejection"]

    # Invalid characters
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm9!" ({}) "error" "Invalid punctuation character rejection"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm9*" ({}) "error" "Invalid asterisk character rejection"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm9," ({}) "error" "Invalid comma character rejection"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm9:" ({}) "error" "Invalid colon character rejection"]
    :set res [$RunEncodingTestCase $res $Base64Decode "Zm9;" ({}) "error" "Invalid semicolon character rejection"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("Zm9\"") ({}) "error" "Invalid quotation mark rejection"]

    # URL-safe mode rejects standard alphabet
    :set res [$RunEncodingTestCase $res $Base64Decode "c3ViamVjdHM/" ({"url"}) "error" "Standard slash rejected in URL-safe mode"]
    :set res [$RunEncodingTestCase $res $Base64Decode "c3ViamVjdHM+" ({"url"}) "error" "Standard plus rejected in URL-safe mode"]

    # Standard mode rejects URL-safe alphabet
    :set res [$RunEncodingTestCase $res $Base64Decode "c3ViamVjdHM_" ({}) "error" "Underscore rejected in standard alphabet"]
    :set res [$RunEncodingTestCase $res $Base64Decode "c3ViamVjdHM-" ({}) "error" "Dash rejected in standard alphabet"]

    # Ignore invalid characters
    :set res [$RunEncodingTestCase $res $Base64Decode "***Zm9v***" ({""; ""; "ignoreotherchr"}) "foo" "Ignore invalid characters on both sides"]
    :set res [$RunEncodingTestCase $res $Base64Decode "@@@Zm9v###" ({""; ""; "ignoreotherchr"}) "foo" "Ignore mixed leading and trailing invalid characters"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("Z\$m9^v") ({""; ""; "ignoreotherchr"}) "foo" "Ignore embedded punctuation"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("Z m\t9\nv\r") ({""; ""; "ignoreotherchr"}) "foo" "Ignore mixed whitespace characters"]

    # Only ignored characters
    :set res [$RunEncodingTestCase $res $Base64Decode "***" ({""; ""; "ignoreotherchr"}) "" "Only invalid characters produce empty output"]
    :set res [$RunEncodingTestCase $res $Base64Decode "   " ({""; ""; "ignoreotherchr"}) "" "Only whitespace produces empty output"]
    :set res [$RunEncodingTestCase $res $Base64Decode ("\r\n\t") ({""; ""; "ignoreotherchr"}) "" "Only control whitespace produces empty output"]

    # Additional valid vectors
    :set res [$RunEncodingTestCase $res $Base64Decode "TWFu" ({}) "Man" "RFC 4648 complete four character block"]
    :set res [$RunEncodingTestCase $res $Base64Decode "VGVzdA==" ({}) "Test" "Standard four letter word decoding"]
    :set res [$RunEncodingTestCase $res $Base64Decode "SGVsbG8=" ({}) "Hello" "Standard five letter word decoding"]
    :set res [$RunEncodingTestCase $res $Base64Decode "V29ybGQ=" ({}) "World" "Standard word decoding"]

    # Binary round-trip validation for all possible byte values (0x00-0xFF)
    :local input ""

    :for i from=0 to=255 do={
        :local hex "$[:pick "0123456789ABCDEF" ($i >> 4) (($i >> 4) + 1)]$[:pick "0123456789ABCDEF" ($i & 15) (($i & 15) + 1)]"
        :set input "$input$[[:parse "(\"\\$hex\")"]]"
    }

    :local encoded [$Base64Encode $input]
    :local decoded [$Base64Decode $encoded]

    :if ($decoded = $input) do={
        :set ($res->"passed") (($res->"passed") + 1)
        :put "  \1B[32m[PASS]\1B[0m Full binary round-trip validation (0x00-0xFF)"
    } else={
        :set ($res->"failed") (($res->"failed") + 1)
        :put "  \1B[31m[FAIL]\1B[0m Full binary round-trip validation (0x00-0xFF)"
        :put ("Expected length: " . [:len $input])
        :put ("Actual length: " . [:len $decoded])

        :for i from=0 to=255 do={
            :if ([:pick $input $i ($i + 1)] != [:pick $decoded $i ($i + 1)]) do={
                :put ("First mismatch at byte index " . $i)
            }
        }
    }

    # Unpadded Base64 vectors (testing remaining tail characters logic)
    :set res [$RunEncodingTestCase $res $Base64Decode "TWFuU3VuTQ" ({}) "ManSunM" "Unpadded tail with 2 characters (rem=2)"]
    :set res [$RunEncodingTestCase $res $Base64Decode "TQ" ({}) "M" "Minimal unpadded tail with 2 characters (rem=2)"]

    :set res [$RunEncodingTestCase $res $Base64Decode "TWFuU3VuTWE" ({}) "ManSunMa" "Unpadded tail with 3 characters (rem=3)"]
    :set res [$RunEncodingTestCase $res $Base64Decode "TWE" ({}) "Ma" "Minimal unpadded tail with 3 characters (rem=3)"]

    :put "Testing completed."
    :return $res
}

:set UrlEncodeTest do={
    :global DecToChar
    :global UrlEncode
    :global RunEncodingTestCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting UrlEncode tests..."

    # Empty and alpha numeric baseline validation
    :set res [$RunEncodingTestCase $res $UrlEncode "" ({}) "" "Empty string encoding baseline"]
    :set res [$RunEncodingTestCase $res $UrlEncode "RouterOS123" ({}) "RouterOS123" "Alphanumeric string unescaped pass through check"]

    # Space character handling (Standard percent encoding targets %20)
    :set res [$RunEncodingTestCase $res $UrlEncode "Hello World" ({}) "Hello%20World" "Space character encoding to percent twenty"]

    # Common URL parameter delimiters and separators
    :set res [$RunEncodingTestCase $res $UrlEncode "foo=bar" ({}) "foo%3Dbar" "Equals sign character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "a&b" ({}) "a%26b" "Ampersand sign character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "path/to/file" ({}) "path/to/file" "Forward slash character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "search?q=test" ({}) "search%3Fq%3Dtest" "Question mark character encoding validation"]

    # Extended punctuation and reserved character sets
    :set res [$RunEncodingTestCase $res $UrlEncode "!" ({}) "%21" "Exclamation mark encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "@" ({}) "%40" "At sign symbol encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "#" ({}) "%23" "Hash sign symbol encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode ("\$") ({}) "%24" "Dollar sign symbol encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "%" ({}) "%25" "Percent sign self encoding validation"]

    # Plus sign and arithmetic symbols
    :set res [$RunEncodingTestCase $res $UrlEncode "a+b" ({}) "a%2Bb" "Plus sign character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "1-2_3.4~5" ({}) "1-2_3.4~5" "Unreserved RFC 3986 character pass through validation"]

    # Brackets and quotes
    :set res [$RunEncodingTestCase $res $UrlEncode "()" ({}) "%28%29" "Parenthesis character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "[]" ({}) "%5B%5D" "Square bracket character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "{}" ({}) "%7B%7D" "Curly brace character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode ("\"") ({}) "%22" "Quotation mark character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "'" ({}) "%27" "Apostrophe character encoding validation"]

    # Delimiters
    :set res [$RunEncodingTestCase $res $UrlEncode ":" ({}) "%3A" "Colon character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode ";" ({}) "%3B" "Semicolon character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "," ({}) "%2C" "Comma character encoding validation"]

    # Miscellaneous reserved characters
    :set res [$RunEncodingTestCase $res $UrlEncode "<>" ({}) "%3C%3E" "Angle bracket character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "|" ({}) "%7C" "Vertical bar character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode ("\\") ({}) "%5C" "Backslash character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "^" ({}) "%5E" "Caret character encoding validation"]
    :set res [$RunEncodingTestCase $res $UrlEncode "`" ({}) "%60" "Backtick character encoding validation"]

    # Mixed string
    :set res [$RunEncodingTestCase $res $UrlEncode "A+B=C&D" ({}) "A%2BB%3DC%26D" "Mixed reserved character encoding validation"]

    # Test encoding for all unreserved ASCII characters
    :local unreserved "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-/_.~"
    :set res [$RunEncodingTestCase $res $UrlEncode $unreserved ({}) $unreserved "Do not encode unreserved ASCII characters"]

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

    :set res [$RunEncodingTestCase $res $UrlEncode $inputToEncode ({}) $expectedResult "Encode all reserved and non-printable ASCII characters"]

    :put "Testing completed."
    :return $res
}

:set UrlDecodeTest do={
    :global DecToChar
    :global UrlEncode
    :global UrlDecode
    :global RunEncodingTestCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting UrlDecode tests..."

    # Empty and clean baseline strings
    :set res [$RunEncodingTestCase $res $UrlDecode "" ({}) "" "Empty string decoding baseline"]
    :set res [$RunEncodingTestCase $res $UrlDecode "MikroTik" ({}) "MikroTik" "Pure alphanumeric string decoding bypass verification"]

    # Escape sequence conversions
    :set res [$RunEncodingTestCase $res $UrlDecode "Hello%20World" ({}) "Hello World" "Percent twenty sequence decoding back to standard space"]
    :set res [$RunEncodingTestCase $res $UrlDecode "foo%3Dbar" ({}) "foo=bar" "Percent 3D hexadecimal decoding back to equals sign"]
    :set res [$RunEncodingTestCase $res $UrlDecode "a%26b" ({}) "a&b" "Percent 26 hexadecimal decoding back to ampersand sign"]
    :set res [$RunEncodingTestCase $res $UrlDecode "path%2Fto%2Ffile" ({}) "path/to/file" "Percent 2F hexadecimal decoding back to forward slash"]
    :set res [$RunEncodingTestCase $res $UrlDecode "search%3Fq%3Dtest" ({}) "search?q=test" "Percent 3F hexadecimal decoding back to question mark"]

    # Combined complex sequences
    :set res [$RunEncodingTestCase $res $UrlDecode "%21%40%23%24%25" ({}) ("!@#\$%") "Consecutive compound percent hex sequence block decoding"]

    # Case insensitivity layout check (RFC compliance checks for hex characters)
    :set res [$RunEncodingTestCase $res $UrlDecode "foo%3dbar" ({}) "foo=bar" "Lowercase hexadecimal sequence fallback tolerance check"]

    # Plus sign and arithmetic symbols
    :set res [$RunEncodingTestCase $res $UrlDecode "a%2Bb" ({}) "a+b" "Percent 2B hexadecimal decoding back to plus sign"]
    :set res [$RunEncodingTestCase $res $UrlDecode "1-2_3.4~5" ({}) "1-2_3.4~5" "Unreserved RFC 3986 character decoding bypass validation"]

    # Brackets and quotes
    :set res [$RunEncodingTestCase $res $UrlDecode "%28%29" ({}) "()" "Percent 28 and 29 hexadecimal decoding back to parentheses"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%5B%5D" ({}) "[]" "Percent 5B and 5D hexadecimal decoding back to square brackets"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%7B%7D" ({}) "{}" "Percent 7B and 7D hexadecimal decoding back to curly brackets"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%22" ({}) ("\"") "Percent 22 hexadecimal decoding back to quotation mark"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%27" ({}) "'" "Percent 27 hexadecimal decoding back to apostrophe"]

    # Delimiters
    :set res [$RunEncodingTestCase $res $UrlDecode "%3A" ({}) ":" "Percent 3A hexadecimal decoding back to colon"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%3B" ({}) ";" "Percent 3B hexadecimal decoding back to semicolon"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%2C" ({}) "," "Percent 2C hexadecimal decoding back to comma"]

    # Miscellaneous reserved characters
    :set res [$RunEncodingTestCase $res $UrlDecode "%3C%3E" ({}) "<>" "Percent 3C and 3E hexadecimal decoding back to angle brackets"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%7C" ({}) "|" "Percent 7C hexadecimal decoding back to vertical bar"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%5C" ({}) ("\\") "Percent 5C hexadecimal decoding back to backslash"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%5E" ({}) "^" "Percent 5E hexadecimal decoding back to caret"]
    :set res [$RunEncodingTestCase $res $UrlDecode "%60" ({}) "`" "Percent 60 hexadecimal decoding back to backtick"]

    # Mixed string
    :set res [$RunEncodingTestCase $res $UrlDecode "A%2BB%3DC%26D" ({}) "A+B=C&D" "Mixed reserved character decoding validation"]

    # Lowercase hexadecimal
    :set res [$RunEncodingTestCase $res $UrlDecode "%2b%3a%3b%2c" ({}) "+:;," "Lowercase hexadecimal reserved character decoding validation"]

    # Test: All 256 byte values
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }
    :set res [$RunEncodingTestCase $res $UrlDecode [$UrlEncode $allChars] ({}) $allChars "All 256 byte values"]

    :put "Testing completed."
    :return $res
}
