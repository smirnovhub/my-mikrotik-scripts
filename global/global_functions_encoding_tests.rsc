:global Base64EncodeTest
:global Base64DecodeTest
:global UrlEncodeTest
:global UrlDecodeTest

:set Base64EncodeTest do={
    :global Base64Encode

    :local RunTestCase do={
        :global Base64Encode

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return ""
        }

        :local input [:tostr $1]
        :local opt1 [:tostr $2]
        :local opt2 [:tostr $3]
        :local expected [:tostr $4]
        :local name [:tostr $5]

        :local actual [$Base64Encode $input $opt1 $opt2]
        :if ($actual = $expected) do={
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
        } else={
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting Base64Encode tests..."

    # Empty string validation
    [$RunTestCase "" "" "" "" "Empty string encoding baseline"]

    # Standard RFC 4648 test vectors (Standard alphabet, with padding)
    [$RunTestCase "f" "" "" "Zg==" "Standard alphabet single character padding check"]
    [$RunTestCase "fo" "" "" "Zm8=" "Standard alphabet double character padding check"]
    [$RunTestCase "foo" "" "" "Zm9v" "Standard alphabet exact block no padding check"]
    [$RunTestCase "foobar" "" "" "Zm9vYmFy" "Standard alphabet multi block encoding validation"]

    # URL-safe alphabet validation (Changes '+' to '-' and '/' to '_')
    # "subjects?" encodes to "c3ViamVjdHM/". Standard has '/', URL-safe has '_'
    [$RunTestCase "subjects?" "url" "" "c3ViamVjdHM_" "URL safe alphabet special character substitution check"]

    # No padding validation (Removes '=' from the end)
    [$RunTestCase "f" "" "nopad" "Zg" "Standard alphabet padding stripping validation"]
    [$RunTestCase "fo" "" "nopad" "Zm8" "Standard alphabet multi byte padding stripping validation"]

    # Combined options validation (URL-safe and No padding together)
    [$RunTestCase "subjects?" "url" "nopad" "c3ViamVjdHM_" "Combined URL safe and stripped padding execution path"]

    # Longer RFC 4648 test vectors
    [$RunTestCase "sure." "" "" "c3VyZS4=" "Standard alphabet five byte encoding validation"]
    [$RunTestCase "sure" "" "" "c3VyZQ==" "Standard alphabet four byte encoding validation"]
    [$RunTestCase "sur" "" "" "c3Vy" "Standard alphabet exact three byte block validation"]
    [$RunTestCase "su" "" "" "c3U=" "Standard alphabet two byte encoding validation"]
    [$RunTestCase "s" "" "" "cw==" "Standard alphabet single byte encoding validation"]

    # Numeric data
    [$RunTestCase "1234567890" "" "" "MTIzNDU2Nzg5MA==" "Numeric ASCII encoding validation"]

    # Whitespace preservation
    [$RunTestCase "Hello World" "" "" "SGVsbG8gV29ybGQ=" "Space character encoding validation"]
    [$RunTestCase ("Hello\nWorld") "" "" "SGVsbG8KV29ybGQ=" "Line feed encoding validation"]
    [$RunTestCase ("Hello\r\nWorld") "" "" "SGVsbG8NCldvcmxk" "CRLF sequence encoding validation"]
    [$RunTestCase ("Hello\tWorld") "" "" "SGVsbG8JV29ybGQ=" "Horizontal tab encoding validation"]

    # URL-safe alphabet with padding retained
    [$RunTestCase "subjects?" "url" "" "c3ViamVjdHM_" "URL-safe alphabet with naturally unpadded output validation"]

    # No-padding on values requiring no padding
    [$RunTestCase "foo" "" "nopad" "Zm9v" "No padding option leaves complete block unchanged"]

    # URL-safe + no padding where padding would normally exist
    [$RunTestCase "f" "url" "nopad" "Zg" "URL-safe alphabet single byte without padding validation"]
    [$RunTestCase "fo" "url" "nopad" "Zm8" "URL-safe alphabet double byte without padding validation"]

    :put "Testing completed."
}

:set Base64DecodeTest do={
    :global Base64Encode
    :global Base64Decode

    :local RunTestCase do={
        :global Base64Decode

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return ""
        }

        :local input [:tostr $1]
        :local opt1 [:tostr $2]
        :local opt2 [:tostr $3]
        :local opt3 [:tostr $4]
        :local expected [:tostr $5]
        :local name [:tostr $6]

        # Safe execution container to handle internal script :error actions
        :do {
            :local actual [$Base64Decode $input $opt1 $opt2 $opt3]
            :if ($actual = $expected) do={
                :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
            } else={
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
            }
        } on-error={
            :if ($expected = "error") do={
                :put ("  \1B[32m[PASS]\1B[0m " . $name . ": Checked invalid input '" . $input . "' threw error successfully")
            } else={
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": Unexpected crash on input '" . $input . "'")
            }
        }
    }

    :put "Starting Base64Decode tests..."

    # Empty string validation
    [$RunTestCase "" "" "" "" "" "Empty string decoding baseline"]

    # Standard RFC 4648 validation
    [$RunTestCase "Zg==" "" "" "" "f" "Standard decode single byte with full padding"]
    [$RunTestCase "Zm8=" "" "" "" "fo" "Standard decode double byte with full padding"]
    [$RunTestCase "Zm9v" "" "" "" "foo" "Standard decode complete block without padding"]

    # URL-safe alphabet decoding
    [$RunTestCase "c3ViamVjdHM_" "url" "" "" "subjects?" "URL safe alphabet conversion decoding target"]

    # Optional padding omission handling
    [$RunTestCase "Zg" "" "" "" "f" "Implicit tolerance decode with missing padding characters"]

    # Strict padding enforcement validation
    # If "mustpad" flag is present, unpadded string should either trigger error or return empty block depending on core strategy
    [$RunTestCase "Zg" "" "mustpad" "" "error" "Strict padding enforcement rejection baseline check"]

    # Ignore invalid characters handling (skips spaces, line breaks, etc.)
    [$RunTestCase "Zm 9v" "" "" "ignoreotherchr" "foo" "Ignore invalid character spaces option check"]

    # Additional RFC 4648 vectors
    [$RunTestCase "cw==" "" "" "" "s" "Standard decode single byte vector"]
    [$RunTestCase "c3U=" "" "" "" "su" "Standard decode two byte vector"]
    [$RunTestCase "c3Vy" "" "" "" "sur" "Standard decode exact block vector"]
    [$RunTestCase "c3VyZQ==" "" "" "" "sure" "Standard decode four byte vector"]
    [$RunTestCase "c3VyZS4=" "" "" "" "sure." "Standard decode five byte vector"]

    # Numeric data
    [$RunTestCase "MTIzNDU2Nzg5MA==" "" "" "" "1234567890" "Numeric ASCII decoding validation"]

    # Whitespace preservation
    [$RunTestCase "SGVsbG8gV29ybGQ=" "" "" "" "Hello World" "Space character decoding validation"]
    [$RunTestCase "SGVsbG8KV29ybGQ=" "" "" "" ("Hello\nWorld") "Line feed decoding validation"]
    [$RunTestCase "SGVsbG8NCldvcmxk" "" "" "" ("Hello\r\nWorld") "CRLF sequence decoding validation"]
    [$RunTestCase "SGVsbG8JV29ybGQ=" "" "" "" ("Hello\tWorld") "Horizontal tab decoding validation"]

    # Missing padding (multiple cases)
    [$RunTestCase "Zm8" "" "" "" "fo" "Implicit tolerance decode with one missing padding character"]
    [$RunTestCase "c3VyZQ" "" "" "" "sure" "Implicit tolerance decode four byte vector without padding"]
    [$RunTestCase "c3VyZS4" "" "" "" "sure." "Implicit tolerance decode five byte vector without padding"]

    # Ignore invalid characters
    [$RunTestCase "Zm9v!!" "" "" "ignoreotherchr" "foo" "Ignore trailing invalid characters"]
    [$RunTestCase ("Zm\t9v") "" "" "ignoreotherchr" "foo" "Ignore tab character during decoding"]
    [$RunTestCase ("Zm9v\r\n") "" "" "ignoreotherchr" "foo" "Ignore CRLF during decoding"]
    [$RunTestCase " Zm9v " "" "" "ignoreotherchr" "foo" "Ignore leading and trailing spaces"]

    # Additional ASCII strings
    [$RunTestCase "YQ==" "" "" "" "a" "Standard decode lowercase single character"]
    [$RunTestCase "YWI=" "" "" "" "ab" "Standard decode lowercase two characters"]
    [$RunTestCase "YWJj" "" "" "" "abc" "Standard decode lowercase three characters"]
    [$RunTestCase "YWJjZA==" "" "" "" "abcd" "Standard decode lowercase four characters"]
    [$RunTestCase "YWJjZGU=" "" "" "" "abcde" "Standard decode lowercase five characters"]
    [$RunTestCase "YWJjZGVm" "" "" "" "abcdef" "Standard decode lowercase six characters"]

    # Uppercase
    [$RunTestCase "QUJD" "" "" "" "ABC" "Standard decode uppercase exact block"]
    [$RunTestCase "QUJDRA==" "" "" "" "ABCD" "Standard decode uppercase four characters"]

    # Digits
    [$RunTestCase "MA==" "" "" "" "0" "Standard decode single digit"]
    [$RunTestCase "MDEyMzQ1Njc4OQ==" "" "" "" "0123456789" "Standard decode decimal digit sequence"]

    # Punctuation
    [$RunTestCase "IQ==" "" "" "" "!" "Standard decode exclamation mark"]
    [$RunTestCase "Py8r" "" "" "" "?/+" "Standard decode punctuation characters"]
    [$RunTestCase "Oi0p" "" "" "" ":-)" "Standard decode ASCII emoticon"]

    # Missing padding
    [$RunTestCase "YQ" "" "" "" "a" "Implicit tolerance decode single character without padding"]
    [$RunTestCase "YWI" "" "" "" "ab" "Implicit tolerance decode two characters without padding"]
    [$RunTestCase "YWJjZA" "" "" "" "abcd" "Implicit tolerance decode four characters without padding"]
    [$RunTestCase "YWJjZGU" "" "" "" "abcde" "Implicit tolerance decode five characters without padding"]

    # Ignore invalid characters
    [$RunTestCase "Y W J j" "" "" "ignoreotherchr" "abc" "Ignore embedded spaces"]
    [$RunTestCase "YWJj***" "" "" "ignoreotherchr" "abc" "Ignore trailing asterisk characters"]
    [$RunTestCase "***YWJj" "" "" "ignoreotherchr" "abc" "Ignore leading asterisk characters"]
    [$RunTestCase "YW@J#j" "" "" "ignoreotherchr" "abc" "Ignore mixed invalid punctuation"]
    [$RunTestCase ("YW\nJj") "" "" "ignoreotherchr" "abc" "Ignore embedded line feed"]
    [$RunTestCase ("YW\rJj") "" "" "ignoreotherchr" "abc" "Ignore embedded carriage return"]
    [$RunTestCase ("YW\r\nJj") "" "" "ignoreotherchr" "abc" "Ignore embedded CRLF sequence"]
    [$RunTestCase ("YW\tJj") "" "" "ignoreotherchr" "abc" "Ignore embedded horizontal tab"]

    # URL-safe without padding
    [$RunTestCase "c3ViamVjdHM_" "url" "" "" "subjects?" "URL-safe decode without padding"]

    # Strict padding
    [$RunTestCase "YQ" "" "mustpad" "" "error" "Strict padding rejection single character"]
    [$RunTestCase "YWI" "" "mustpad" "" "error" "Strict padding rejection two characters"]
    [$RunTestCase "YWJjZA" "" "mustpad" "" "error" "Strict padding rejection four characters"]
    [$RunTestCase "YWJjZGU" "" "mustpad" "" "error" "Strict padding rejection five characters"]

    # Invalid length (Length % 4 == 1)
    [$RunTestCase "A" "" "" "" "error" "Single Base64 character cannot form a valid quantum"]
    [$RunTestCase "AAAAA" "" "" "" "error" "Length modulo four equals one rejection"]
    [$RunTestCase "AAAAAAAAA" "" "" "" "error" "Long input with invalid modulo one length rejection"]

    # Invalid padding placement
    [$RunTestCase "Z===" "" "" "" "error" "Three padding characters are invalid"]
    [$RunTestCase "Z=g=" "" "" "" "error" "Padding inside encoded block rejection"]
    [$RunTestCase "Zm9v=" "" "" "" "error" "Trailing padding after completed block rejection"]

    # Invalid characters
    [$RunTestCase "Zm9!" "" "" "" "error" "Invalid punctuation character rejection"]
    [$RunTestCase "Zm9*" "" "" "" "error" "Invalid asterisk character rejection"]
    [$RunTestCase "Zm9," "" "" "" "error" "Invalid comma character rejection"]
    [$RunTestCase "Zm9:" "" "" "" "error" "Invalid colon character rejection"]
    [$RunTestCase "Zm9;" "" "" "" "error" "Invalid semicolon character rejection"]
    [$RunTestCase ("Zm9\"") "" "" "" "error" "Invalid quotation mark rejection"]

    # URL-safe mode rejects standard alphabet
    [$RunTestCase "c3ViamVjdHM/" "url" "" "" "error" "Standard slash rejected in URL-safe mode"]
    [$RunTestCase "c3ViamVjdHM+" "url" "" "" "error" "Standard plus rejected in URL-safe mode"]

    # Standard mode rejects URL-safe alphabet
    [$RunTestCase "c3ViamVjdHM_" "" "" "" "error" "Underscore rejected in standard alphabet"]
    [$RunTestCase "c3ViamVjdHM-" "" "" "" "error" "Dash rejected in standard alphabet"]

    # Ignore invalid characters
    [$RunTestCase "***Zm9v***" "" "" "ignoreotherchr" "foo" "Ignore invalid characters on both sides"]
    [$RunTestCase "@@@Zm9v###" "" "" "ignoreotherchr" "foo" "Ignore mixed leading and trailing invalid characters"]
    [$RunTestCase ("Z\$m9^v") "" "" "ignoreotherchr" "foo" "Ignore embedded punctuation"]
    [$RunTestCase ("Z m\t9\nv\r") "" "" "ignoreotherchr" "foo" "Ignore mixed whitespace characters"]

    # Only ignored characters
    [$RunTestCase "***" "" "" "ignoreotherchr" "" "Only invalid characters produce empty output"]
    [$RunTestCase "   " "" "" "ignoreotherchr" "" "Only whitespace produces empty output"]
    [$RunTestCase ("\r\n\t") "" "" "ignoreotherchr" "" "Only control whitespace produces empty output"]

    # Additional valid vectors
    [$RunTestCase "TWFu" "" "" "" "Man" "RFC 4648 complete four character block"]
    [$RunTestCase "VGVzdA==" "" "" "" "Test" "Standard four letter word decoding"]
    [$RunTestCase "SGVsbG8=" "" "" "" "Hello" "Standard five letter word decoding"]
    [$RunTestCase "V29ybGQ=" "" "" "" "World" "Standard word decoding"]

    # Binary round-trip validation for all possible byte values (0x00-0xFF)
    :local input ""
    
    :for i from=0 to=255 do={
        :local hex "$[:pick "0123456789ABCDEF" ($i >> 4) (($i >> 4) + 1)]$[:pick "0123456789ABCDEF" ($i & 15) (($i & 15) + 1)]"
        :set input "$input$[[:parse "(\"\\$hex\")"]]"
    }
    
    :local encoded [$Base64Encode $input]
    :local decoded [$Base64Decode $encoded]
    
    :if ($decoded = $input) do={
        :put "  \1B[32m[PASS]\1B[0m Full binary round-trip validation (0x00-0xFF)"
    } else={
        :put "  \1B[31m[FAIL]\1B[0m Full binary round-trip validation (0x00-0xFF)"
        :put ("Expected length: " . [:len $input])
        :put ("Actual length: " . [:len $decoded])
    
        :for i from=0 to=255 do={
            :if ([:pick $input $i ($i + 1)] != [:pick $decoded $i ($i + 1)]) do={
                :put ("First mismatch at byte index " . $i)
                :break
            }
        }
    }
    
    :put "Testing completed."
}

:set UrlEncodeTest do={
    :global UrlEncode

    :local RunTestCase do={
        :global UrlEncode

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return ""
        }

        :local input [:tostr $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        :local actual [$UrlEncode $input]
        :if ($actual = $expected) do={
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
        } else={
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting UrlEncode tests..."

    # Empty and alpha numeric baseline validation
    [$RunTestCase "" "" "Empty string encoding baseline"]
    [$RunTestCase "RouterOS123" "RouterOS123" "Alphanumeric string unescaped pass through check"]

    # Space character handling (Standard percent encoding targets %20)
    [$RunTestCase "Hello World" "Hello%20World" "Space character encoding to percent twenty"]

    # Common URL parameter delimiters and separators
    [$RunTestCase "foo=bar" "foo%3Dbar" "Equals sign character encoding validation"]
    [$RunTestCase "a&b" "a%26b" "Ampersand sign character encoding validation"]
    [$RunTestCase "path/to/file" "path/to/file" "Forward slash character encoding validation"]
    [$RunTestCase "search?q=test" "search%3Fq%3Dtest" "Question mark character encoding validation"]

    # Extended punctuation and reserved character sets
    [$RunTestCase "!" "%21" "Exclamation mark encoding validation"]
    [$RunTestCase "@" "%40" "At sign symbol encoding validation"]
    [$RunTestCase "#" "%23" "Hash sign symbol encoding validation"]
    [$RunTestCase ("\$") "%24" "Dollar sign symbol encoding validation"]
    [$RunTestCase "%" "%25" "Percent sign self encoding validation"]

    # Plus sign and arithmetic symbols
    [$RunTestCase "a+b" "a%2Bb" "Plus sign character encoding validation"]
    [$RunTestCase "1-2_3.4~5" "1-2_3.4~5" "Unreserved RFC 3986 character pass through validation"]

    # Brackets and quotes
    [$RunTestCase "()" "%28%29" "Parenthesis character encoding validation"]
    [$RunTestCase "[]" "%5B%5D" "Square bracket character encoding validation"]
    [$RunTestCase "{}" "%7B%7D" "Curly brace character encoding validation"]
    [$RunTestCase ("\"") "%22" "Quotation mark character encoding validation"]
    [$RunTestCase "'" "%27" "Apostrophe character encoding validation"]

    # Delimiters
    [$RunTestCase ":" "%3A" "Colon character encoding validation"]
    [$RunTestCase ";" "%3B" "Semicolon character encoding validation"]
    [$RunTestCase "," "%2C" "Comma character encoding validation"]

    # Miscellaneous reserved characters
    [$RunTestCase "<>" "%3C%3E" "Angle bracket character encoding validation"]
    [$RunTestCase "|" "%7C" "Vertical bar character encoding validation"]
    [$RunTestCase ("\\") "%5C" "Backslash character encoding validation"]
    [$RunTestCase "^" "%5E" "Caret character encoding validation"]
    [$RunTestCase "`" "%60" "Backtick character encoding validation"]

    # Mixed string
    [$RunTestCase "A+B=C&D" "A%2BB%3DC%26D" "Mixed reserved character encoding validation"]

    :put "Testing completed."
}

:set UrlDecodeTest do={
    :global UrlDecode

    :local RunTestCase do={
        :global UrlDecode

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return ""
        }

        :local input [:tostr $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        :local actual [$UrlDecode $input]
        :if ($actual = $expected) do={
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
        } else={
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting UrlDecode tests..."

    # Empty and clean baseline strings
    [$RunTestCase "" "" "Empty string decoding baseline"]
    [$RunTestCase "MikroTik" "MikroTik" "Pure alphanumeric string decoding bypass verification"]

    # Escape sequence conversions
    [$RunTestCase "Hello%20World" "Hello World" "Percent twenty sequence decoding back to standard space"]
    [$RunTestCase "foo%3Dbar" "foo=bar" "Percent 3D hexadecimal decoding back to equals sign"]
    [$RunTestCase "a%26b" "a&b" "Percent 26 hexadecimal decoding back to ampersand sign"]
    [$RunTestCase "path%2Fto%2Ffile" "path/to/file" "Percent 2F hexadecimal decoding back to forward slash"]
    [$RunTestCase "search%3Fq%3Dtest" "search?q=test" "Percent 3F hexadecimal decoding back to question mark"]

    # Combined complex sequences
    [$RunTestCase "%21%40%23%24%25" ("!@#\$%") "Consecutive compound percent hex sequence block decoding"]

    # Case insensitivity layout check (RFC compliance checks for hex characters)
    [$RunTestCase "foo%3dbar" "foo=bar" "Lowercase hexadecimal sequence fallback tolerance check"]

    # Plus sign and arithmetic symbols
    [$RunTestCase "a%2Bb" "a+b" "Percent 2B hexadecimal decoding back to plus sign"]
    [$RunTestCase "1-2_3.4~5" "1-2_3.4~5" "Unreserved RFC 3986 character decoding bypass validation"]

    # Brackets and quotes
    [$RunTestCase "%28%29" "()" "Percent 28 and 29 hexadecimal decoding back to parentheses"]
    [$RunTestCase "%5B%5D" "[]" "Percent 5B and 5D hexadecimal decoding back to square brackets"]
    [$RunTestCase "%7B%7D" "{}" "Percent 7B and 7D hexadecimal decoding back to curly brackets"]
    [$RunTestCase "%22" ("\"") "Percent 22 hexadecimal decoding back to quotation mark"]
    [$RunTestCase "%27" "'" "Percent 27 hexadecimal decoding back to apostrophe"]

    # Delimiters
    [$RunTestCase "%3A" ":" "Percent 3A hexadecimal decoding back to colon"]
    [$RunTestCase "%3B" ";" "Percent 3B hexadecimal decoding back to semicolon"]
    [$RunTestCase "%2C" "," "Percent 2C hexadecimal decoding back to comma"]

    # Miscellaneous reserved characters
    [$RunTestCase "%3C%3E" "<>" "Percent 3C and 3E hexadecimal decoding back to angle brackets"]
    [$RunTestCase "%7C" "|" "Percent 7C hexadecimal decoding back to vertical bar"]
    [$RunTestCase "%5C" ("\\") "Percent 5C hexadecimal decoding back to backslash"]
    [$RunTestCase "%5E" "^" "Percent 5E hexadecimal decoding back to caret"]
    [$RunTestCase "%60" "`" "Percent 60 hexadecimal decoding back to backtick"]

    # Mixed string
    [$RunTestCase "A%2BB%3DC%26D" "A+B=C&D" "Mixed reserved character decoding validation"]

    # Lowercase hexadecimal
    [$RunTestCase "%2b%3a%3b%2c" "+:;," "Lowercase hexadecimal reserved character decoding validation"]

    :put "Testing completed."
}
