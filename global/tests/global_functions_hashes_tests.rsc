:global RunAllHashesTests
:global GetMd5SumTest
:global GetCrc32SumTest

:set RunAllHashesTests do={
    :global GetMd5SumTest
    :global GetCrc32SumTest

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :put "\1B[35m=== STARTING ALL HASHES TESTS ===\1B[0m"

    :set res [$GetMd5SumTest $res]
    :set res [$GetCrc32SumTest $res]

    :put "\1B[35m=== ALL HASHES TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set GetMd5SumTest do={
    :global GetMd5Sum
    :global DecToChar
    :global IsPrintableStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global GetMd5Sum
        :global IsPrintableStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local inputStr [:tostr $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local inputDisplay $inputStr
        :if (![$IsPrintableStr $inputDisplay]) do={
            :set inputDisplay "<binary string>"
        }

        # Use an explicit check for the test execution block to handle empty strings safely
        :local actual [$GetMd5Sum $inputStr]
        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputDisplay . "' -> '" . $actual . "'")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputDisplay . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
        :return $state
    }

    :put "Starting GetMd5Sum tests..."

    # Empty string validation (Standard MD5 for empty input)
    :set res [$RunTestCase $res "" "d41d8cd98f00b204e9800998ecf8427e" "Empty string boundary hash verification"]

    # Short basic strings
    :set res [$RunTestCase $res "a" "0cc175b9c0f1b6a831c399e269772661" "Single lowercase character string hash"]
    :set res [$RunTestCase $res "abc" "900150983cd24fb0d6963f7d28e17f72" "Short lowercase alphabetical sequence hash"]
    :set res [$RunTestCase $res "message digest" "f96b697d7cb7938d525a2f31aaf161d0" "Standard spaced alphabetical phrase hash"]

    # Numeric and special character sequences
    :set res [$RunTestCase $res "1234567890" "e807f1fcf82d132f9bb018ca6738a19f" "Numeric sequence data hash validation"]
    :set res [$RunTestCase $res "admin" "21232f297a57a5a743894a0e4a801fc3" "Common administrative identifier string hash"]
    :set res [$RunTestCase $res "RouterOS" "7e08a36aac8e952ec66f3f28bd384bc0" "Mixed case application specific string hash"]

    # Single character inputs
    :set res [$RunTestCase $res "A" "7fc56270e7a70fa81a5935b72eacbe29" "Single uppercase character string hash"]

    # Standard RFC 1321 test vectors
    :set res [$RunTestCase $res "abcdefghijklmnopqrstuvwxyz" "c3fcd3d76192e4007dfb496cca67e13b" "Complete lowercase alphabet hash"]
    :set res [$RunTestCase $res "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" "d174ab98d277d9f5a5611c2c9f419d9f" "Uppercase lowercase and digit sequence hash"]
    :set res [$RunTestCase $res "12345678901234567890123456789012345678901234567890123456789012345678901234567890" "57edf4a22be3c955ac49da2e2107b67a" "Long numeric sequence RFC validation hash"]

    # Common strings
    :set res [$RunTestCase $res "password" "5f4dcc3b5aa765d61d8327deb882cf99" "Common password string hash"]

    # Case sensitivity
    :set res [$RunTestCase $res "hello" "5d41402abc4b2a76b9719d911017c592" "Lowercase word hash"]
    :set res [$RunTestCase $res "Hello" "8b1a9953c4611296a827abf8c47804d7" "Capitalized word hash"]
    :set res [$RunTestCase $res "HELLO" "eb61eead90e3b899c6bcbe27ac581660" "Uppercase word hash"]

    # Whitespace handling
    :set res [$RunTestCase $res " " "7215ee9c7d9dc229d2921a40e899ec5f" "Single space character hash"]
    :set res [$RunTestCase $res "  " "23b58def11b45727d3351702515f86af" "Two consecutive space characters hash"]
    :set res [$RunTestCase $res "abc " "28a53e303da9f5742476fd6b62434540" "Trailing space preservation hash"]
    :set res [$RunTestCase $res " abc" "12cfaf7fd98f33be8038b3d56c18f061" "Leading space preservation hash"]
    :set res [$RunTestCase $res "abc 123" "c89cfdb5dd9f56836f59fba6c062dda4" "Embedded space preservation hash"]

    # Repeated character sequences
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "5eca9bd3eb07c006cd43ae48dfde7fd3" "Repeated lowercase character block hash"]
    :set res [$RunTestCase $res "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" "8b4f9ea16de4bcf5bbfc0ff1ea237934" "Repeated lowercase character block hash"]

    # Special characters
    :set res [$RunTestCase $res ("!@#\$%^&*()") "05b28d17a7b6e7024b6e5d8cc43a8bf7" "Common punctuation character sequence hash"]
    :set res [$RunTestCase $res ("~`[]{}|\\:;") "a5264c255ab316bcff01963a084ec8a0" "Mixed punctuation character sequence hash"]

    # 55-byte message (Last message length fitting before length field)
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "ef1772b6dff9a122358552954ad0df65" "55-byte message block boundary hash"]

    # 56-byte message (First message requiring an additional block)
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "3b0c8ac703f828b04c6c197006d17218" "56-byte message block boundary hash"]

    # 57-byte message
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "652b906d60af96844ebd21b674f35e93" "57-byte message block boundary hash"]

    # 63-byte message
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "b06521f39153d618550606be297466d5" "63-byte message block boundary hash"]

    # 64-byte message (Exactly one complete MD5 block)
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "014842d480b571495a4a0363793f7367" "64-byte message exact block hash"]

    # 65-byte message (One full block plus one byte)
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "c743a45e0d2e6a95cb859adae0248435" "65-byte message block overflow hash"]

    # 127-byte message
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "020406e1d05cdc2aa287641f7ae2cc39" "127-byte message double block boundary hash"]

    # 128-byte message (Exactly two complete MD5 blocks)
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "e510683b3f5ffe4093d021808bc6ff70" "128-byte message exact double block hash"]

    # 129-byte message
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "b325dc1c6f5e7a2b7cf465b9feab7948" "129-byte message double block overflow hash"]

    # --- Test: All 256 byte values ---
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    :set res [$RunTestCase $res $allChars "e2c865db4162bed963bfaa9ef6ac18f0" "All 256 byte values hash"]

    # Short remaining-byte packing tests
    :set res [$RunTestCase $res "aa" "4124bc0a9335c27f086f24ba207a4912" "Two-byte message packing validation"]
    :set res [$RunTestCase $res "aaa" "47bce5c74f589f4867dbd57e9ca9f808" "Three-byte message packing validation"]
    :set res [$RunTestCase $res "aaaa" "74b87337454200d4d33f80c4663dc5e5" "Four-byte message word boundary validation"]
    :set res [$RunTestCase $res "aaaaa" "594f803b380a41396ed63dca39503542" "Five-byte message packing validation"]

    # 119/120/121-byte padding boundary
    :local testStr ""

    :for i from=1 to=119 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $testStr "8a7bd0732ed6a28ce75f6dabc90e1613" "119-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $testStr "5f61c0ccad4cac44c75ff505e1f1e537" "120-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $testStr "f6acfca2d47c87f2b14ca038234d3614" "121-byte message padding boundary hash"]

    # 191/192/193-byte multi-block boundary
    :set testStr ""

    :for i from=1 to=191 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $testStr "16e2824f7a3f00ef0028994182071953" "191-byte message multi-block boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $testStr "234c07907df5019d5f40f03936939bce" "192-byte message exact three-block hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $testStr "8ea3af1d9476fa0b6c04ce4f3a336c03" "193-byte message multi-block overflow hash"]

    # 255/256/257-byte boundary
    :set testStr ""

    :for i from=1 to=255 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $testStr "46bc249a5a8fc5d622cf12c42c463ae0" "255-byte message boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $testStr "81109eec5aa1a284fb5327b10e9c16b9" "256-byte message exact boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $testStr "b7958df91b9413477491e9b6e27f1bac" "257-byte message boundary overflow hash"]

    # Long multi-block messages
    :set testStr ""

    :for i from=1 to=512 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $testStr "56907396339ca2b099bd12245f936ddc" "512-byte multi-block message hash"]

    :set testStr ""

    :for i from=1 to=1024 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $testStr "c9a34cfc85d982698c6ac89f76071abd" "1024-byte multi-block message hash"]

    # Zero-byte handling
    :set testStr ""

    :for i from=1 to=64 do={
        :set testStr ($testStr . [$DecToChar 0])
    }
    :set res [$RunTestCase $res $testStr "3b5d3c7d207e37dceeedd301e35e2e58" "64 zero-byte message hash"]

    :put "Testing completed."
    :return $res
}

:set GetCrc32SumTest do={
    :global GetCrc32Sum
    :global DecToChar
    :global IsPrintableStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global GetCrc32Sum
        :global IsPrintableStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local inputStr [:tostr $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local inputDisplay $inputStr
        :if (![$IsPrintableStr $inputDisplay]) do={
            :set inputDisplay "<binary string>"
        }

        # Use an explicit check for the test execution block to handle empty strings safely
        :local actual [$GetCrc32Sum $inputStr]
        :if ($actual = $expected) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputDisplay . "' -> '" . $actual . "'")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputDisplay . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
        :return $state
    }

    :put "Starting GetCrc32Sum tests..."

    # Empty string validation (Standard Crc32 for empty input)
    :set res [$RunTestCase $res "" "00000000" "Empty string boundary hash verification"]

    # Short basic strings
    :set res [$RunTestCase $res "a" "e8b7be43" "Single lowercase character string hash"]
    :set res [$RunTestCase $res "abc" "352441c2" "Short lowercase alphabetical sequence hash"]
    :set res [$RunTestCase $res "message digest" "20159d7f" "Standard spaced alphabetical phrase hash"]

    # Numeric and special character sequences
    :set res [$RunTestCase $res "1234567890" "261daee5" "Numeric sequence data hash validation"]
    :set res [$RunTestCase $res "admin" "880e0d76" "Common administrative identifier string hash"]
    :set res [$RunTestCase $res "RouterOS" "866c2528" "Mixed case application specific string hash"]

    # Single character inputs
    :set res [$RunTestCase $res "A" "d3d99e8b" "Single uppercase character string hash"]

    # Standard RFC 1321 test vectors
    :set res [$RunTestCase $res "abcdefghijklmnopqrstuvwxyz" "4c2750bd" "Complete lowercase alphabet hash"]
    :set res [$RunTestCase $res "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" "1fc2e6d2" "Uppercase lowercase and digit sequence hash"]
    :set res [$RunTestCase $res "12345678901234567890123456789012345678901234567890123456789012345678901234567890" "7ca94a72" "Long numeric sequence RFC validation hash"]

    # Common strings
    :set res [$RunTestCase $res "password" "35c246d5" "Common password string hash"]

    # Case sensitivity
    :set res [$RunTestCase $res "hello" "3610a686" "Lowercase word hash"]
    :set res [$RunTestCase $res "Hello" "f7d18982" "Capitalized word hash"]
    :set res [$RunTestCase $res "HELLO" "c1446436" "Uppercase word hash"]

    # Whitespace handling
    :set res [$RunTestCase $res " " "e96ccf45" "Single space character hash"]
    :set res [$RunTestCase $res "  " "ef331695" "Two consecutive space characters hash"]
    :set res [$RunTestCase $res "abc " "9c334898" "Trailing space preservation hash"]
    :set res [$RunTestCase $res " abc" "4b13e8f2" "Leading space preservation hash"]
    :set res [$RunTestCase $res "abc 123" "fc382e1d" "Embedded space preservation hash"]

    # Repeated character sequences
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "cab11777" "Repeated lowercase character block hash"]
    :set res [$RunTestCase $res "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" "47fd49d4" "Repeated lowercase character block hash"]

    # Special characters
    :set res [$RunTestCase $res ("!@#\$%^&*()") "aea29b98" "Common punctuation character sequence hash"]
    :set res [$RunTestCase $res ("~`[]{}|\\:;") "ad6d1dcf" "Mixed punctuation character sequence hash"]

    # --- Test: All 256 byte values ---
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    :set res [$RunTestCase $res $allChars "29058c73" "All 256 byte values hash"]

    # Standard CRC32 test vector
    :set res [$RunTestCase $res "123456789" "cbf43926" "Canonical CRC32 standard test vector"]

    # Common text
    :set res [$RunTestCase $res "The quick brown fox jumps over the lazy dog" "414fa339" "Common pangram CRC32 validation"]
    :set res [$RunTestCase $res "The quick brown fox jumps over the lazy dog." "519025e9" "Common pangram with trailing punctuation hash"]

    # Numeric boundary values
    :set res [$RunTestCase $res "0" "f4dbdf21" "Single zero digit hash"]
    :set res [$RunTestCase $res "00" "b84614a0" "Repeated zero digits hash"]
    :set res [$RunTestCase $res "00000000" "c0088d03" "Eight zero digits hash"]
    :set res [$RunTestCase $res "-1" "302d482a" "Negative numeric string hash"]
    :set res [$RunTestCase $res "+1" "6677efac" "Signed positive numeric string hash"]
    :set res [$RunTestCase $res "1.0" "f7366f35" "Decimal numeric string hash"]
    :set res [$RunTestCase $res "0xFF" "b2111273" "Hexadecimal notation string hash"]

    # Case sensitivity
    :set res [$RunTestCase $res "aA" "3ce4391f" "Adjacent lowercase and uppercase character hash"]
    :set res [$RunTestCase $res "Aa" "920e3d75" "Reversed case ordering hash"]
    :set res [$RunTestCase $res "abcABC" "e4c9dbc6" "Lowercase followed by uppercase hash"]
    :set res [$RunTestCase $res "ABCabc" "14311c40" "Uppercase followed by lowercase hash"]

    # Character ordering
    :set res [$RunTestCase $res "abc" "352441c2" "Ascending lowercase sequence hash"]
    :set res [$RunTestCase $res "cba" "d8aef480" "Reversed lowercase sequence hash"]
    :set res [$RunTestCase $res "123456789" "cbf43926" "Ascending numeric sequence hash"]
    :set res [$RunTestCase $res "987654321" "015f0201" "Reversed numeric sequence hash"]

    # Whitespace and control characters
    :set res [$RunTestCase $res ("\t") "abde5729" "Single tab character hash"]
    :set res [$RunTestCase $res ("\r") "acb39330" "Single carriage return hash"]
    :set res [$RunTestCase $res ("\n") "32d70693" "Single line feed hash"]
    :set res [$RunTestCase $res ("\r\n") "14a285ac" "CRLF sequence hash"]
    :set res [$RunTestCase $res ("abc\n") "4788814e" "Trailing line feed preservation hash"]
    :set res [$RunTestCase $res ("abc\r\n") "ecb57442" "Trailing CRLF preservation hash"]
    :set res [$RunTestCase $res ("abc\tdef") "a58e4c1a" "Embedded tab preservation hash"]
    :set res [$RunTestCase $res ("a\nb") "ef0790fb" "Embedded line feed preservation hash"]
    :set res [$RunTestCase $res ("a\rb") "a046063c" "Embedded carriage return preservation hash"]

    # Null byte handling
    :set res [$RunTestCase $res ("a\00b") "15e87871" "Embedded null byte hash"]
    :set res [$RunTestCase $res ("\00") "d202ef8d" "Single null byte hash"]

    # Mixed character classes
    :set res [$RunTestCase $res "abcABC123" "9d1eef04" "Mixed lowercase uppercase and numeric hash"]
    :set res [$RunTestCase $res "ABC123!@#" "ac73d39f" "Mixed alphanumeric and punctuation hash"]
    :set res [$RunTestCase $res "A1b2C3d4" "9f750047" "Alternating case and numeric hash"]

    # Repeated character boundary lengths
    :set res [$RunTestCase $res "a" "e8b7be43" "One repeated character hash"]
    :set res [$RunTestCase $res "aa" "078a19d7" "Two repeated characters hash"]
    :set res [$RunTestCase $res "aaa" "f007732d" "Three repeated characters hash"]
    :set res [$RunTestCase $res "aaaa" "ad98e545" "Four repeated characters hash"]
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaa" "cfd668d5" "Sixteen repeated characters hash"]
    :set res [$RunTestCase $res "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "cab11777" "Thirty-two repeated characters hash"]

    # Length boundary tests
    :local chars31 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    :local chars32 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    :local chars33 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

    :set res [$RunTestCase $res $chars31 "04bf8db6" "Thirty-one byte input boundary hash"]
    :set res [$RunTestCase $res $chars32 "cab11777" "Thirty-two byte input boundary hash"]
    :set res [$RunTestCase $res $chars33 "261cebcb" "Thirty-three byte input boundary hash"]

    # 255/256/257 byte boundaries
    :local chars255 ""
    :local chars256 ""
    :local chars257 ""

    :for i from=1 to=255 do={
        :set chars255 ($chars255 . "a")
    }

    :for i from=1 to=256 do={
        :set chars256 ($chars256 . "a")
    }

    :for i from=1 to=257 do={
        :set chars257 ($chars257 . "a")
    }

    :set res [$RunTestCase $res $chars255 "a2c40b3d" "Two-hundred-fifty-five byte input boundary hash"]
    :set res [$RunTestCase $res $chars256 "b07d3659" "Two-hundred-fifty-six byte input boundary hash"]
    :set res [$RunTestCase $res $chars257 "fab02a25" "Two-hundred-fifty-seven byte input boundary hash"]

    # Long numeric sequence
    :local longNumeric "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"

    :set res [$RunTestCase $res $longNumeric "b1fc4bbc" "One-hundred-byte numeric sequence hash"]

    # Byte-oriented test vectors
    :local lowBytes ""
    :local highBytes ""

    :for i from=0 to=15 do={
        :set lowBytes ($lowBytes . [$DecToChar $i])
    }

    :for i from=240 to=255 do={
        :set highBytes ($highBytes . [$DecToChar $i])
    }

    :set res [$RunTestCase $res $lowBytes "cecee288" "Low control byte sequence hash"]
    :set res [$RunTestCase $res $highBytes "61e8443c" "High byte sequence hash"]

    # Alternating byte patterns
    :local alternating01 ""
    :local alternatingAA55 ""

    :for i from=1 to=16 do={
        :set alternating01 ($alternating01 . "\00\01")
        :set alternatingAA55 ($alternatingAA55 . "\AA\55")
    }

    :set res [$RunTestCase $res $alternating01 "b44a7c0d" "Alternating zero and one byte pattern hash"]
    :set res [$RunTestCase $res $alternatingAA55 "6dc14610" "Alternating AA and 55 byte pattern hash"]

    :put "Testing completed."
    :return $res
}
