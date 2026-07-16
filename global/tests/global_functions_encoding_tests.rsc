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
    :global Base64Encode

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global Base64Encode

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local input [:tostr $2]
        :local opt1 [:tostr $3]
        :local opt2 [:tostr $4]
        :local expected [:tostr $5]
        :local name [:tostr $6]

        :local actual [$Base64Encode $input $opt1 $opt2]
        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
        :return $state
    }

    :put "Starting Base64Encode tests..."

    # Empty string validation
    :set res [$RunTestCase $res "" "" "" "" "Empty string encoding baseline"]

    # Standard RFC 4648 test vectors (Standard alphabet, with padding)
    :set res [$RunTestCase $res "f" "" "" "Zg==" "Standard alphabet single character padding check"]
    :set res [$RunTestCase $res "fo" "" "" "Zm8=" "Standard alphabet double character padding check"]
    :set res [$RunTestCase $res "foo" "" "" "Zm9v" "Standard alphabet exact block no padding check"]
    :set res [$RunTestCase $res "foobar" "" "" "Zm9vYmFy" "Standard alphabet multi block encoding validation"]

    # URL-safe alphabet validation (Changes '+' to '-' and '/' to '_')
    # "subjects?" encodes to "c3ViamVjdHM/". Standard has '/', URL-safe has '_'
    :set res [$RunTestCase $res "subjects?" "url" "" "c3ViamVjdHM_" "URL safe alphabet special character substitution check"]

    # No padding validation (Removes '=' from the end)
    :set res [$RunTestCase $res "f" "" "nopad" "Zg" "Standard alphabet padding stripping validation"]
    :set res [$RunTestCase $res "fo" "" "nopad" "Zm8" "Standard alphabet multi byte padding stripping validation"]

    # Combined options validation (URL-safe and No padding together)
    :set res [$RunTestCase $res "subjects?" "url" "nopad" "c3ViamVjdHM_" "Combined URL safe and stripped padding execution path"]

    # Longer RFC 4648 test vectors
    :set res [$RunTestCase $res "sure." "" "" "c3VyZS4=" "Standard alphabet five byte encoding validation"]
    :set res [$RunTestCase $res "sure" "" "" "c3VyZQ==" "Standard alphabet four byte encoding validation"]
    :set res [$RunTestCase $res "sur" "" "" "c3Vy" "Standard alphabet exact three byte block validation"]
    :set res [$RunTestCase $res "su" "" "" "c3U=" "Standard alphabet two byte encoding validation"]
    :set res [$RunTestCase $res "s" "" "" "cw==" "Standard alphabet single byte encoding validation"]

    # Numeric data
    :set res [$RunTestCase $res "1234567890" "" "" "MTIzNDU2Nzg5MA==" "Numeric ASCII encoding validation"]

    # Whitespace preservation
    :set res [$RunTestCase $res "Hello World" "" "" "SGVsbG8gV29ybGQ=" "Space character encoding validation"]
    :set res [$RunTestCase $res ("Hello\nWorld") "" "" "SGVsbG8KV29ybGQ=" "Line feed encoding validation"]
    :set res [$RunTestCase $res ("Hello\r\nWorld") "" "" "SGVsbG8NCldvcmxk" "CRLF sequence encoding validation"]
    :set res [$RunTestCase $res ("Hello\tWorld") "" "" "SGVsbG8JV29ybGQ=" "Horizontal tab encoding validation"]

    # URL-safe alphabet with padding retained
    :set res [$RunTestCase $res "subjects?" "url" "" "c3ViamVjdHM_" "URL-safe alphabet with naturally unpadded output validation"]

    # No-padding on values requiring no padding
    :set res [$RunTestCase $res "foo" "" "nopad" "Zm9v" "No padding option leaves complete block unchanged"]

    # URL-safe + no padding where padding would normally exist
    :set res [$RunTestCase $res "f" "url" "nopad" "Zg" "URL-safe alphabet single byte without padding validation"]
    :set res [$RunTestCase $res "fo" "url" "nopad" "Zm8" "URL-safe alphabet double byte without padding validation"]

    :put "Testing completed."
    :return $res
}

:set Base64DecodeTest do={
    :global Base64Encode
    :global Base64Decode

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global Base64Decode

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local input [:tostr $2]
        :local opt1 [:tostr $3]
        :local opt2 [:tostr $4]
        :local opt3 [:tostr $5]
        :local expected [:tostr $6]
        :local name [:tostr $7]

        # Safe execution container to handle internal script :error actions
        :do {
            :local actual [$Base64Decode $input $opt1 $opt2 $opt3]
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

    :put "Starting Base64Decode tests..."

    # Empty string validation
    :set res [$RunTestCase $res "" "" "" "" "" "Empty string decoding baseline"]

    # Standard RFC 4648 validation
    :set res [$RunTestCase $res "Zg==" "" "" "" "f" "Standard decode single byte with full padding"]
    :set res [$RunTestCase $res "Zm8=" "" "" "" "fo" "Standard decode double byte with full padding"]
    :set res [$RunTestCase $res "Zm9v" "" "" "" "foo" "Standard decode complete block without padding"]

    # URL-safe alphabet decoding
    :set res [$RunTestCase $res "c3ViamVjdHM_" "url" "" "" "subjects?" "URL safe alphabet conversion decoding target"]

    # Optional padding omission handling
    :set res [$RunTestCase $res "Zg" "" "" "" "f" "Implicit tolerance decode with missing padding characters"]

    # Strict padding enforcement validation
    # If "mustpad" flag is present, unpadded string should either trigger error or return empty block depending on core strategy
    :set res [$RunTestCase $res "Zg" "" "mustpad" "" "error" "Strict padding enforcement rejection baseline check"]

    # Ignore invalid characters handling (skips spaces, line breaks, etc.)
    :set res [$RunTestCase $res "Zm 9v" "" "" "ignoreotherchr" "foo" "Ignore invalid character spaces option check"]

    # Additional RFC 4648 vectors
    :set res [$RunTestCase $res "cw==" "" "" "" "s" "Standard decode single byte vector"]
    :set res [$RunTestCase $res "c3U=" "" "" "" "su" "Standard decode two byte vector"]
    :set res [$RunTestCase $res "c3Vy" "" "" "" "sur" "Standard decode exact block vector"]
    :set res [$RunTestCase $res "c3VyZQ==" "" "" "" "sure" "Standard decode four byte vector"]
    :set res [$RunTestCase $res "c3VyZS4=" "" "" "" "sure." "Standard decode five byte vector"]

    # Numeric data
    :set res [$RunTestCase $res "MTIzNDU2Nzg5MA==" "" "" "" "1234567890" "Numeric ASCII decoding validation"]

    # Whitespace preservation
    :set res [$RunTestCase $res "SGVsbG8gV29ybGQ=" "" "" "" "Hello World" "Space character decoding validation"]
    :set res [$RunTestCase $res "SGVsbG8KV29ybGQ=" "" "" "" ("Hello\nWorld") "Line feed decoding validation"]
    :set res [$RunTestCase $res "SGVsbG8NCldvcmxk" "" "" "" ("Hello\r\nWorld") "CRLF sequence decoding validation"]
    :set res [$RunTestCase $res "SGVsbG8JV29ybGQ=" "" "" "" ("Hello\tWorld") "Horizontal tab decoding validation"]

    # Missing padding (multiple cases)
    :set res [$RunTestCase $res "Zm8" "" "" "" "fo" "Implicit tolerance decode with one missing padding character"]
    :set res [$RunTestCase $res "c3VyZQ" "" "" "" "sure" "Implicit tolerance decode four byte vector without padding"]
    :set res [$RunTestCase $res "c3VyZS4" "" "" "" "sure." "Implicit tolerance decode five byte vector without padding"]

    # Ignore invalid characters
    :set res [$RunTestCase $res "Zm9v!!" "" "" "ignoreotherchr" "foo" "Ignore trailing invalid characters"]
    :set res [$RunTestCase $res ("Zm\t9v") "" "" "ignoreotherchr" "foo" "Ignore tab character during decoding"]
    :set res [$RunTestCase $res ("Zm9v\r\n") "" "" "ignoreotherchr" "foo" "Ignore CRLF during decoding"]
    :set res [$RunTestCase $res " Zm9v " "" "" "ignoreotherchr" "foo" "Ignore leading and trailing spaces"]

    # Additional ASCII strings
    :set res [$RunTestCase $res "YQ==" "" "" "" "a" "Standard decode lowercase single character"]
    :set res [$RunTestCase $res "YWI=" "" "" "" "ab" "Standard decode lowercase two characters"]
    :set res [$RunTestCase $res "YWJj" "" "" "" "abc" "Standard decode lowercase three characters"]
    :set res [$RunTestCase $res "YWJjZA==" "" "" "" "abcd" "Standard decode lowercase four characters"]
    :set res [$RunTestCase $res "YWJjZGU=" "" "" "" "abcde" "Standard decode lowercase five characters"]
    :set res [$RunTestCase $res "YWJjZGVm" "" "" "" "abcdef" "Standard decode lowercase six characters"]

    # Uppercase
    :set res [$RunTestCase $res "QUJD" "" "" "" "ABC" "Standard decode uppercase exact block"]
    :set res [$RunTestCase $res "QUJDRA==" "" "" "" "ABCD" "Standard decode uppercase four characters"]

    # Digits
    :set res [$RunTestCase $res "MA==" "" "" "" "0" "Standard decode single digit"]
    :set res [$RunTestCase $res "MDEyMzQ1Njc4OQ==" "" "" "" "0123456789" "Standard decode decimal digit sequence"]

    # Punctuation
    :set res [$RunTestCase $res "IQ==" "" "" "" "!" "Standard decode exclamation mark"]
    :set res [$RunTestCase $res "Py8r" "" "" "" "?/+" "Standard decode punctuation characters"]
    :set res [$RunTestCase $res "Oi0p" "" "" "" ":-)" "Standard decode ASCII emoticon"]

    # Missing padding
    :set res [$RunTestCase $res "YQ" "" "" "" "a" "Implicit tolerance decode single character without padding"]
    :set res [$RunTestCase $res "YWI" "" "" "" "ab" "Implicit tolerance decode two characters without padding"]
    :set res [$RunTestCase $res "YWJjZA" "" "" "" "abcd" "Implicit tolerance decode four characters without padding"]
    :set res [$RunTestCase $res "YWJjZGU" "" "" "" "abcde" "Implicit tolerance decode five characters without padding"]

    # Ignore invalid characters
    :set res [$RunTestCase $res "Y W J j" "" "" "ignoreotherchr" "abc" "Ignore embedded spaces"]
    :set res [$RunTestCase $res "YWJj***" "" "" "ignoreotherchr" "abc" "Ignore trailing asterisk characters"]
    :set res [$RunTestCase $res "***YWJj" "" "" "ignoreotherchr" "abc" "Ignore leading asterisk characters"]
    :set res [$RunTestCase $res "YW@J#j" "" "" "ignoreotherchr" "abc" "Ignore mixed invalid punctuation"]
    :set res [$RunTestCase $res ("YW\nJj") "" "" "ignoreotherchr" "abc" "Ignore embedded line feed"]
    :set res [$RunTestCase $res ("YW\rJj") "" "" "ignoreotherchr" "abc" "Ignore embedded carriage return"]
    :set res [$RunTestCase $res ("YW\r\nJj") "" "" "ignoreotherchr" "abc" "Ignore embedded CRLF sequence"]
    :set res [$RunTestCase $res ("YW\tJj") "" "" "ignoreotherchr" "abc" "Ignore embedded horizontal tab"]

    # URL-safe without padding
    :set res [$RunTestCase $res "c3ViamVjdHM_" "url" "" "" "subjects?" "URL-safe decode without padding"]

    # Strict padding
    :set res [$RunTestCase $res "YQ" "" "mustpad" "" "error" "Strict padding rejection single character"]
    :set res [$RunTestCase $res "YWI" "" "mustpad" "" "error" "Strict padding rejection two characters"]
    :set res [$RunTestCase $res "YWJjZA" "" "mustpad" "" "error" "Strict padding rejection four characters"]
    :set res [$RunTestCase $res "YWJjZGU" "" "mustpad" "" "error" "Strict padding rejection five characters"]

    # Invalid length (Length % 4 == 1)
    :set res [$RunTestCase $res "A" "" "" "" "error" "Single Base64 character cannot form a valid quantum"]
    :set res [$RunTestCase $res "AAAAA" "" "" "" "error" "Length modulo four equals one rejection"]
    :set res [$RunTestCase $res "AAAAAAAAA" "" "" "" "error" "Long input with invalid modulo one length rejection"]

    # Invalid padding placement
    :set res [$RunTestCase $res "Z===" "" "" "" "error" "Three padding characters are invalid"]
    :set res [$RunTestCase $res "Z=g=" "" "" "" "error" "Padding inside encoded block rejection"]
    :set res [$RunTestCase $res "Zm9v=" "" "" "" "error" "Trailing padding after completed block rejection"]

    # Invalid characters
    :set res [$RunTestCase $res "Zm9!" "" "" "" "error" "Invalid punctuation character rejection"]
    :set res [$RunTestCase $res "Zm9*" "" "" "" "error" "Invalid asterisk character rejection"]
    :set res [$RunTestCase $res "Zm9," "" "" "" "error" "Invalid comma character rejection"]
    :set res [$RunTestCase $res "Zm9:" "" "" "" "error" "Invalid colon character rejection"]
    :set res [$RunTestCase $res "Zm9;" "" "" "" "error" "Invalid semicolon character rejection"]
    :set res [$RunTestCase $res ("Zm9\"") "" "" "" "error" "Invalid quotation mark rejection"]

    # URL-safe mode rejects standard alphabet
    :set res [$RunTestCase $res "c3ViamVjdHM/" "url" "" "" "error" "Standard slash rejected in URL-safe mode"]
    :set res [$RunTestCase $res "c3ViamVjdHM+" "url" "" "" "error" "Standard plus rejected in URL-safe mode"]

    # Standard mode rejects URL-safe alphabet
    :set res [$RunTestCase $res "c3ViamVjdHM_" "" "" "" "error" "Underscore rejected in standard alphabet"]
    :set res [$RunTestCase $res "c3ViamVjdHM-" "" "" "" "error" "Dash rejected in standard alphabet"]

    # Ignore invalid characters
    :set res [$RunTestCase $res "***Zm9v***" "" "" "ignoreotherchr" "foo" "Ignore invalid characters on both sides"]
    :set res [$RunTestCase $res "@@@Zm9v###" "" "" "ignoreotherchr" "foo" "Ignore mixed leading and trailing invalid characters"]
    :set res [$RunTestCase $res ("Z\$m9^v") "" "" "ignoreotherchr" "foo" "Ignore embedded punctuation"]
    :set res [$RunTestCase $res ("Z m\t9\nv\r") "" "" "ignoreotherchr" "foo" "Ignore mixed whitespace characters"]

    # Only ignored characters
    :set res [$RunTestCase $res "***" "" "" "ignoreotherchr" "" "Only invalid characters produce empty output"]
    :set res [$RunTestCase $res "   " "" "" "ignoreotherchr" "" "Only whitespace produces empty output"]
    :set res [$RunTestCase $res ("\r\n\t") "" "" "ignoreotherchr" "" "Only control whitespace produces empty output"]

    # Additional valid vectors
    :set res [$RunTestCase $res "TWFu" "" "" "" "Man" "RFC 4648 complete four character block"]
    :set res [$RunTestCase $res "VGVzdA==" "" "" "" "Test" "Standard four letter word decoding"]
    :set res [$RunTestCase $res "SGVsbG8=" "" "" "" "Hello" "Standard five letter word decoding"]
    :set res [$RunTestCase $res "V29ybGQ=" "" "" "" "World" "Standard word decoding"]

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

    :put "Testing completed."
    :return $res
}

:set UrlEncodeTest do={
    :global UrlEncode

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global UrlEncode

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local input [:tostr $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local actual [$UrlEncode $input]
        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
        :return $state
    }

    :put "Starting UrlEncode tests..."

    # Empty and alpha numeric baseline validation
    :set res [$RunTestCase $res "" "" "Empty string encoding baseline"]
    :set res [$RunTestCase $res "RouterOS123" "RouterOS123" "Alphanumeric string unescaped pass through check"]

    # Space character handling (Standard percent encoding targets %20)
    :set res [$RunTestCase $res "Hello World" "Hello%20World" "Space character encoding to percent twenty"]

    # Common URL parameter delimiters and separators
    :set res [$RunTestCase $res "foo=bar" "foo%3Dbar" "Equals sign character encoding validation"]
    :set res [$RunTestCase $res "a&b" "a%26b" "Ampersand sign character encoding validation"]
    :set res [$RunTestCase $res "path/to/file" "path/to/file" "Forward slash character encoding validation"]
    :set res [$RunTestCase $res "search?q=test" "search%3Fq%3Dtest" "Question mark character encoding validation"]

    # Extended punctuation and reserved character sets
    :set res [$RunTestCase $res "!" "%21" "Exclamation mark encoding validation"]
    :set res [$RunTestCase $res "@" "%40" "At sign symbol encoding validation"]
    :set res [$RunTestCase $res "#" "%23" "Hash sign symbol encoding validation"]
    :set res [$RunTestCase $res ("\$") "%24" "Dollar sign symbol encoding validation"]
    :set res [$RunTestCase $res "%" "%25" "Percent sign self encoding validation"]

    # Plus sign and arithmetic symbols
    :set res [$RunTestCase $res "a+b" "a%2Bb" "Plus sign character encoding validation"]
    :set res [$RunTestCase $res "1-2_3.4~5" "1-2_3.4~5" "Unreserved RFC 3986 character pass through validation"]

    # Brackets and quotes
    :set res [$RunTestCase $res "()" "%28%29" "Parenthesis character encoding validation"]
    :set res [$RunTestCase $res "[]" "%5B%5D" "Square bracket character encoding validation"]
    :set res [$RunTestCase $res "{}" "%7B%7D" "Curly brace character encoding validation"]
    :set res [$RunTestCase $res ("\"") "%22" "Quotation mark character encoding validation"]
    :set res [$RunTestCase $res "'" "%27" "Apostrophe character encoding validation"]

    # Delimiters
    :set res [$RunTestCase $res ":" "%3A" "Colon character encoding validation"]
    :set res [$RunTestCase $res ";" "%3B" "Semicolon character encoding validation"]
    :set res [$RunTestCase $res "," "%2C" "Comma character encoding validation"]

    # Miscellaneous reserved characters
    :set res [$RunTestCase $res "<>" "%3C%3E" "Angle bracket character encoding validation"]
    :set res [$RunTestCase $res "|" "%7C" "Vertical bar character encoding validation"]
    :set res [$RunTestCase $res ("\\") "%5C" "Backslash character encoding validation"]
    :set res [$RunTestCase $res "^" "%5E" "Caret character encoding validation"]
    :set res [$RunTestCase $res "`" "%60" "Backtick character encoding validation"]

    # Mixed string
    :set res [$RunTestCase $res "A+B=C&D" "A%2BB%3DC%26D" "Mixed reserved character encoding validation"]

    :put "Testing completed."
    :return $res
}

:set UrlDecodeTest do={
    :global DecToChar
    :global UrlEncode
    :global UrlDecode
    :global IsPrintableStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global UrlDecode
        :global IsPrintableStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local input [:tostr $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local actual [$UrlDecode $input]

        :local inputDisplay $input
        :if (![$IsPrintableStr $inputDisplay]) do={
            :set inputDisplay "<binary string>"
        }

        :local actualDisplay $actual
        :if (![$IsPrintableStr $actualDisplay]) do={
            :set actualDisplay "<binary string>"
        }

        :local expectedDisplay $expected
        :if (![$IsPrintableStr $expectedDisplay]) do={
            :set expectedDisplay "<binary string>"
        }

        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputDisplay . "' -> '" . $actualDisplay . "'")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputDisplay . "' | Expected: '" . $expectedDisplay . "', Got: '" . $actualDisplay . "'")
        }
        :return $state
    }

    :put "Starting UrlDecode tests..."

    # Empty and clean baseline strings
    :set res [$RunTestCase $res "" "" "Empty string decoding baseline"]
    :set res [$RunTestCase $res "MikroTik" "MikroTik" "Pure alphanumeric string decoding bypass verification"]

    # Escape sequence conversions
    :set res [$RunTestCase $res "Hello%20World" "Hello World" "Percent twenty sequence decoding back to standard space"]
    :set res [$RunTestCase $res "foo%3Dbar" "foo=bar" "Percent 3D hexadecimal decoding back to equals sign"]
    :set res [$RunTestCase $res "a%26b" "a&b" "Percent 26 hexadecimal decoding back to ampersand sign"]
    :set res [$RunTestCase $res "path%2Fto%2Ffile" "path/to/file" "Percent 2F hexadecimal decoding back to forward slash"]
    :set res [$RunTestCase $res "search%3Fq%3Dtest" "search?q=test" "Percent 3F hexadecimal decoding back to question mark"]

    # Combined complex sequences
    :set res [$RunTestCase $res "%21%40%23%24%25" ("!@#\$%") "Consecutive compound percent hex sequence block decoding"]

    # Case insensitivity layout check (RFC compliance checks for hex characters)
    :set res [$RunTestCase $res "foo%3dbar" "foo=bar" "Lowercase hexadecimal sequence fallback tolerance check"]

    # Plus sign and arithmetic symbols
    :set res [$RunTestCase $res "a%2Bb" "a+b" "Percent 2B hexadecimal decoding back to plus sign"]
    :set res [$RunTestCase $res "1-2_3.4~5" "1-2_3.4~5" "Unreserved RFC 3986 character decoding bypass validation"]

    # Brackets and quotes
    :set res [$RunTestCase $res "%28%29" "()" "Percent 28 and 29 hexadecimal decoding back to parentheses"]
    :set res [$RunTestCase $res "%5B%5D" "[]" "Percent 5B and 5D hexadecimal decoding back to square brackets"]
    :set res [$RunTestCase $res "%7B%7D" "{}" "Percent 7B and 7D hexadecimal decoding back to curly brackets"]
    :set res [$RunTestCase $res "%22" ("\"") "Percent 22 hexadecimal decoding back to quotation mark"]
    :set res [$RunTestCase $res "%27" "'" "Percent 27 hexadecimal decoding back to apostrophe"]

    # Delimiters
    :set res [$RunTestCase $res "%3A" ":" "Percent 3A hexadecimal decoding back to colon"]
    :set res [$RunTestCase $res "%3B" ";" "Percent 3B hexadecimal decoding back to semicolon"]
    :set res [$RunTestCase $res "%2C" "," "Percent 2C hexadecimal decoding back to comma"]

    # Miscellaneous reserved characters
    :set res [$RunTestCase $res "%3C%3E" "<>" "Percent 3C and 3E hexadecimal decoding back to angle brackets"]
    :set res [$RunTestCase $res "%7C" "|" "Percent 7C hexadecimal decoding back to vertical bar"]
    :set res [$RunTestCase $res "%5C" ("\\") "Percent 5C hexadecimal decoding back to backslash"]
    :set res [$RunTestCase $res "%5E" "^" "Percent 5E hexadecimal decoding back to caret"]
    :set res [$RunTestCase $res "%60" "`" "Percent 60 hexadecimal decoding back to backtick"]

    # Mixed string
    :set res [$RunTestCase $res "A%2BB%3DC%26D" "A+B=C&D" "Mixed reserved character decoding validation"]

    # Lowercase hexadecimal
    :set res [$RunTestCase $res "%2b%3a%3b%2c" "+:;," "Lowercase hexadecimal reserved character decoding validation"]

    # --- Test: All 256 byte values ---
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }
    :set res [$RunTestCase $res [$UrlEncode $allChars] $allChars "All 256 byte values"]

    :put "Testing completed."
    :return $res
}
