:global RunAllHashesTests
:global GetCrc32SumTest
:global GetMd5SumTest
:global GetSha1SumTest
:global GetSha256SumTest

:set RunAllHashesTests do={
    :global InitTestCaseState
    :global GetCrc32SumTest
    :global GetMd5SumTest
    :global GetSha1SumTest
    :global GetSha256SumTest

    :local res [$InitTestCaseState ]

    :put "\1B[35m=== STARTING ALL HASHES TESTS ===\1B[0m"

    :set res [$GetCrc32SumTest $res]
    :set res [$GetMd5SumTest $res]
    :set res [$GetSha1SumTest $res]
    :set res [$GetSha256SumTest $res]

    :put "\1B[35m=== ALL HASHES TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set GetCrc32SumTest do={
    :global InitTestCaseState
    :global GetCrc32Sum
    :global DecToChar
    :global IsPrintableStr
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting GetCrc32Sum tests..."

    # Empty string validation (Standard Crc32 for empty input)
    :set res [$RunGenericTestCase $res $GetCrc32Sum "" "nothing" "nothing" "00000000" "Empty string boundary hash verification"]

    # Short basic strings
    :set res [$RunGenericTestCase $res $GetCrc32Sum "a" "nothing" "nothing" "e8b7be43" "Single lowercase character string hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "abc" "nothing" "nothing" "352441c2" "Short lowercase alphabetical sequence hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "message digest" "nothing" "nothing" "20159d7f" "Standard spaced alphabetical phrase hash"]

    # Numeric and special character sequences
    :set res [$RunGenericTestCase $res $GetCrc32Sum "1234567890" "nothing" "nothing" "261daee5" "Numeric sequence data hash validation"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "admin" "nothing" "nothing" "880e0d76" "Common administrative identifier string hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "RouterOS" "nothing" "nothing" "866c2528" "Mixed case application specific string hash"]

    # Single character inputs
    :set res [$RunGenericTestCase $res $GetCrc32Sum "A" "nothing" "nothing" "d3d99e8b" "Single uppercase character string hash"]

    # Standard RFC 1321 test vectors
    :set res [$RunGenericTestCase $res $GetCrc32Sum "abcdefghijklmnopqrstuvwxyz" "nothing" "nothing" "4c2750bd" "Complete lowercase alphabet hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" "nothing" "nothing" "1fc2e6d2" "Uppercase lowercase and digit sequence hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "12345678901234567890123456789012345678901234567890123456789012345678901234567890" "nothing" "nothing" "7ca94a72" "Long numeric sequence RFC validation hash"]

    # Common strings
    :set res [$RunGenericTestCase $res $GetCrc32Sum "password" "nothing" "nothing" "35c246d5" "Common password string hash"]

    # Case sensitivity
    :set res [$RunGenericTestCase $res $GetCrc32Sum "hello" "nothing" "nothing" "3610a686" "Lowercase word hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "Hello" "nothing" "nothing" "f7d18982" "Capitalized word hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "HELLO" "nothing" "nothing" "c1446436" "Uppercase word hash"]

    # Whitespace handling
    :set res [$RunGenericTestCase $res $GetCrc32Sum " " "nothing" "nothing" "e96ccf45" "Single space character hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "  " "nothing" "nothing" "ef331695" "Two consecutive space characters hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "abc " "nothing" "nothing" "9c334898" "Trailing space preservation hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum " abc" "nothing" "nothing" "4b13e8f2" "Leading space preservation hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "abc 123" "nothing" "nothing" "fc382e1d" "Embedded space preservation hash"]

    # Repeated character sequences
    :set res [$RunGenericTestCase $res $GetCrc32Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "cab11777" "Repeated lowercase character block hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" "nothing" "nothing" "47fd49d4" "Repeated lowercase character block hash"]

    # Special characters
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("!@#\$%^&*()") "nothing" "nothing" "aea29b98" "Common punctuation character sequence hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("~`[]{}|\\:;") "nothing" "nothing" "ad6d1dcf" "Mixed punctuation character sequence hash"]

    # --- Test: All 256 byte values ---
    :local allChars ""
    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }
    :set res [$RunGenericTestCase $res $GetCrc32Sum $allChars "nothing" "nothing" "29058c73" "All 256 byte values hash"]

    # Standard CRC32 test vector
    :set res [$RunGenericTestCase $res $GetCrc32Sum "123456789" "nothing" "nothing" "cbf43926" "Canonical CRC32 standard test vector"]

    # Common text
    :set res [$RunGenericTestCase $res $GetCrc32Sum "The quick brown fox jumps over the lazy dog" "nothing" "nothing" "414fa339" "Common pangram CRC32 validation"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "The quick brown fox jumps over the lazy dog." "nothing" "nothing" "519025e9" "Common pangram with trailing punctuation hash"]

    # Numeric boundary values
    :set res [$RunGenericTestCase $res $GetCrc32Sum "0" "nothing" "nothing" "f4dbdf21" "Single zero digit hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "00" "nothing" "nothing" "b84614a0" "Repeated zero digits hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "00000000" "nothing" "nothing" "c0088d03" "Eight zero digits hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "-1" "nothing" "nothing" "302d482a" "Negative numeric string hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "+1" "nothing" "nothing" "6677efac" "Signed positive numeric string hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "1.0" "nothing" "nothing" "f7366f35" "Decimal numeric string hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "0xFF" "nothing" "nothing" "b2111273" "Hexadecimal notation string hash"]

    # Case sensitivity
    :set res [$RunGenericTestCase $res $GetCrc32Sum "aA" "nothing" "nothing" "3ce4391f" "Adjacent lowercase and uppercase character hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "Aa" "nothing" "nothing" "920e3d75" "Reversed case ordering hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "abcABC" "nothing" "nothing" "e4c9dbc6" "Lowercase followed by uppercase hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "ABCabc" "nothing" "nothing" "14311c40" "Uppercase followed by lowercase hash"]

    # Character ordering
    :set res [$RunGenericTestCase $res $GetCrc32Sum "abc" "nothing" "nothing" "352441c2" "Ascending lowercase sequence hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "cba" "nothing" "nothing" "d8aef480" "Reversed lowercase sequence hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "123456789" "nothing" "nothing" "cbf43926" "Ascending numeric sequence hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "987654321" "nothing" "nothing" "015f0201" "Reversed numeric sequence hash"]

    # Whitespace and control characters
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("\t") "nothing" "nothing" "abde5729" "Single tab character hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("\r") "nothing" "nothing" "acb39330" "Single carriage return hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("\n") "nothing" "nothing" "32d70693" "Single line feed hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("\r\n") "nothing" "nothing" "14a285ac" "CRLF sequence hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("abc\n") "nothing" "nothing" "4788814e" "Trailing line feed preservation hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("abc\r\n") "nothing" "nothing" "ecb57442" "Trailing CRLF preservation hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("abc\tdef") "nothing" "nothing" "a58e4c1a" "Embedded tab preservation hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("a\nb") "nothing" "nothing" "ef0790fb" "Embedded line feed preservation hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("a\rb") "nothing" "nothing" "a046063c" "Embedded carriage return preservation hash"]

    # Null byte handling
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("a\00b") "nothing" "nothing" "15e87871" "Embedded null byte hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum ("\00") "nothing" "nothing" "d202ef8d" "Single null byte hash"]

    # Mixed character classes
    :set res [$RunGenericTestCase $res $GetCrc32Sum "abcABC123" "nothing" "nothing" "9d1eef04" "Mixed lowercase uppercase and numeric hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "ABC123!@#" "nothing" "nothing" "ac73d39f" "Mixed alphanumeric and punctuation hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "A1b2C3d4" "nothing" "nothing" "9f750047" "Alternating case and numeric hash"]

    # Repeated character boundary lengths
    :set res [$RunGenericTestCase $res $GetCrc32Sum "a" "nothing" "nothing" "e8b7be43" "One repeated character hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "aa" "nothing" "nothing" "078a19d7" "Two repeated characters hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "aaa" "nothing" "nothing" "f007732d" "Three repeated characters hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "aaaa" "nothing" "nothing" "ad98e545" "Four repeated characters hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "aaaaaaaaaaaaaaaa" "nothing" "nothing" "cfd668d5" "Sixteen repeated characters hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "cab11777" "Thirty-two repeated characters hash"]

    # Length boundary tests
    :local chars31 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    :local chars32 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    :local chars33 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

    :set res [$RunGenericTestCase $res $GetCrc32Sum $chars31 "nothing" "nothing" "04bf8db6" "Thirty-one byte input boundary hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum $chars32 "nothing" "nothing" "cab11777" "Thirty-two byte input boundary hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum $chars33 "nothing" "nothing" "261cebcb" "Thirty-three byte input boundary hash"]

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

    :set res [$RunGenericTestCase $res $GetCrc32Sum $chars255 "nothing" "nothing" "a2c40b3d" "Two-hundred-fifty-five byte input boundary hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum $chars256 "nothing" "nothing" "b07d3659" "Two-hundred-fifty-six byte input boundary hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum $chars257 "nothing" "nothing" "fab02a25" "Two-hundred-fifty-seven byte input boundary hash"]

    # Long numeric sequence
    :local longNumeric "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
    :set res [$RunGenericTestCase $res $GetCrc32Sum $longNumeric "nothing" "nothing" "b1fc4bbc" "One-hundred-byte numeric sequence hash"]

    # Byte-oriented test vectors
    :local lowBytes ""
    :local highBytes ""

    :for i from=0 to=15 do={
        :set lowBytes ($lowBytes . [$DecToChar $i])
    }

    :for i from=240 to=255 do={
        :set highBytes ($highBytes . [$DecToChar $i])
    }

    :set res [$RunGenericTestCase $res $GetCrc32Sum $lowBytes "nothing" "nothing" "cecee288" "Low control byte sequence hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum $highBytes "nothing" "nothing" "61e8443c" "High byte sequence hash"]

    # Alternating byte patterns
    :local alternating01 ""
    :local alternatingAA55 ""

    :for i from=1 to=16 do={
        :set alternating01 ($alternating01 . "\00\01")
        :set alternatingAA55 ($alternatingAA55 . "\AA\55")
    }

    :set res [$RunGenericTestCase $res $GetCrc32Sum $alternating01 "nothing" "nothing" "b44a7c0d" "Alternating zero and one byte pattern hash"]
    :set res [$RunGenericTestCase $res $GetCrc32Sum $alternatingAA55 "nothing" "nothing" "6dc14610" "Alternating AA and 55 byte pattern hash"]

    :put "Testing completed."
    :return $res
}

:set GetMd5SumTest do={
    :global InitTestCaseState
    :global GetMd5Sum
    :global DecToChar
    :global IsPrintableStr
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting GetMd5Sum tests..."

    # Empty string validation (Standard MD5 for empty input)
    :set res [$RunGenericTestCase $res $GetMd5Sum "" "nothing" "nothing" "d41d8cd98f00b204e9800998ecf8427e" "Empty string boundary hash verification"]

    # Short basic strings
    :set res [$RunGenericTestCase $res $GetMd5Sum "a" "nothing" "nothing" "0cc175b9c0f1b6a831c399e269772661" "Single lowercase character string hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "abc" "nothing" "nothing" "900150983cd24fb0d6963f7d28e17f72" "Short lowercase alphabetical sequence hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "message digest" "nothing" "nothing" "f96b697d7cb7938d525a2f31aaf161d0" "Standard spaced alphabetical phrase hash"]

    # Numeric and special character sequences
    :set res [$RunGenericTestCase $res $GetMd5Sum "1234567890" "nothing" "nothing" "e807f1fcf82d132f9bb018ca6738a19f" "Numeric sequence data hash validation"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "admin" "nothing" "nothing" "21232f297a57a5a743894a0e4a801fc3" "Common administrative identifier string hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "RouterOS" "nothing" "nothing" "7e08a36aac8e952ec66f3f28bd384bc0" "Mixed case application specific string hash"]

    # Single character inputs
    :set res [$RunGenericTestCase $res $GetMd5Sum "A" "nothing" "nothing" "7fc56270e7a70fa81a5935b72eacbe29" "Single uppercase character string hash"]

    # Standard RFC 1321 test vectors
    :set res [$RunGenericTestCase $res $GetMd5Sum "abcdefghijklmnopqrstuvwxyz" "nothing" "nothing" "c3fcd3d76192e4007dfb496cca67e13b" "Complete lowercase alphabet hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" "nothing" "nothing" "d174ab98d277d9f5a5611c2c9f419d9f" "Uppercase lowercase and digit sequence hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "12345678901234567890123456789012345678901234567890123456789012345678901234567890" "nothing" "nothing" "57edf4a22be3c955ac49da2e2107b67a" "Long numeric sequence RFC validation hash"]

    # Common strings
    :set res [$RunGenericTestCase $res $GetMd5Sum "password" "nothing" "nothing" "5f4dcc3b5aa765d61d8327deb882cf99" "Common password string hash"]

    # Case sensitivity
    :set res [$RunGenericTestCase $res $GetMd5Sum "hello" "nothing" "nothing" "5d41402abc4b2a76b9719d911017c592" "Lowercase word hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "Hello" "nothing" "nothing" "8b1a9953c4611296a827abf8c47804d7" "Capitalized word hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "HELLO" "nothing" "nothing" "eb61eead90e3b899c6bcbe27ac581660" "Uppercase word hash"]

    # Whitespace handling
    :set res [$RunGenericTestCase $res $GetMd5Sum " " "nothing" "nothing" "7215ee9c7d9dc229d2921a40e899ec5f" "Single space character hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "  " "nothing" "nothing" "23b58def11b45727d3351702515f86af" "Two consecutive space characters hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "abc " "nothing" "nothing" "28a53e303da9f5742476fd6b62434540" "Trailing space preservation hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum " abc" "nothing" "nothing" "12cfaf7fd98f33be8038b3d56c18f061" "Leading space preservation hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "abc 123" "nothing" "nothing" "c89cfdb5dd9f56836f59fba6c062dda4" "Embedded space preservation hash"]

    # Repeated character sequences
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "5eca9bd3eb07c006cd43ae48dfde7fd3" "Repeated lowercase character block hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" "nothing" "nothing" "8b4f9ea16de4bcf5bbfc0ff1ea237934" "Repeated lowercase character block hash"]

    # Special characters
    :set res [$RunGenericTestCase $res $GetMd5Sum ("!@#\$%^&*()") "nothing" "nothing" "05b28d17a7b6e7024b6e5d8cc43a8bf7" "Common punctuation character sequence hash"]
    :set res [$RunGenericTestCase $res $GetMd5Sum ("~`[]{}|\\:;") "nothing" "nothing" "a5264c255ab316bcff01963a084ec8a0" "Mixed punctuation character sequence hash"]

    # 55-byte message (Last message length fitting before length field)
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "ef1772b6dff9a122358552954ad0df65" "55-byte message block boundary hash"]

    # 56-byte message (First message requiring an additional block)
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "3b0c8ac703f828b04c6c197006d17218" "56-byte message block boundary hash"]

    # 57-byte message
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "652b906d60af96844ebd21b674f35e93" "57-byte message block boundary hash"]

    # 63-byte message
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "b06521f39153d618550606be297466d5" "63-byte message block boundary hash"]

    # 64-byte message (Exactly one complete MD5 block)
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "014842d480b571495a4a0363793f7367" "64-byte message exact block hash"]

    # 65-byte message (One full block plus one byte)
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "c743a45e0d2e6a95cb859adae0248435" "65-byte message block overflow hash"]

    # 127-byte message
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "020406e1d05cdc2aa287641f7ae2cc39" "127-byte message double block boundary hash"]

    # 128-byte message (Exactly two complete MD5 blocks)
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "e510683b3f5ffe4093d021808bc6ff70" "128-byte message exact double block hash"]

    # 129-byte message
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "nothing" "nothing" "b325dc1c6f5e7a2b7cf465b9feab7948" "129-byte message double block overflow hash"]

    # --- Test: All 256 byte values ---
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    :set res [$RunGenericTestCase $res $GetMd5Sum $allChars "nothing" "nothing" "e2c865db4162bed963bfaa9ef6ac18f0" "All 256 byte values hash"]

    # Short remaining-byte packing tests
    :set res [$RunGenericTestCase $res $GetMd5Sum "aa" "nothing" "nothing" "4124bc0a9335c27f086f24ba207a4912" "Two-byte message packing validation"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaa" "nothing" "nothing" "47bce5c74f589f4867dbd57e9ca9f808" "Three-byte message packing validation"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaa" "nothing" "nothing" "74b87337454200d4d33f80c4663dc5e5" "Four-byte message word boundary validation"]
    :set res [$RunGenericTestCase $res $GetMd5Sum "aaaaa" "nothing" "nothing" "594f803b380a41396ed63dca39503542" "Five-byte message packing validation"]

    # 119/120/121-byte padding boundary
    :local testStr ""

    :for i from=1 to=119 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "8a7bd0732ed6a28ce75f6dabc90e1613" "119-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "5f61c0ccad4cac44c75ff505e1f1e537" "120-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "f6acfca2d47c87f2b14ca038234d3614" "121-byte message padding boundary hash"]

    # 191/192/193-byte multi-block boundary
    :set testStr ""

    :for i from=1 to=191 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "16e2824f7a3f00ef0028994182071953" "191-byte message multi-block boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "234c07907df5019d5f40f03936939bce" "192-byte message exact three-block hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "8ea3af1d9476fa0b6c04ce4f3a336c03" "193-byte message multi-block overflow hash"]

    # 255/256/257-byte boundary
    :set testStr ""

    :for i from=1 to=255 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "46bc249a5a8fc5d622cf12c42c463ae0" "255-byte message boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "81109eec5aa1a284fb5327b10e9c16b9" "256-byte message exact boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "b7958df91b9413477491e9b6e27f1bac" "257-byte message boundary overflow hash"]

    # Long multi-block messages
    :set testStr ""

    :for i from=1 to=512 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "56907396339ca2b099bd12245f936ddc" "512-byte multi-block message hash"]

    :set testStr ""

    :for i from=1 to=1024 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "c9a34cfc85d982698c6ac89f76071abd" "1024-byte multi-block message hash"]

    # Zero-byte handling
    :set testStr ""

    :for i from=1 to=64 do={
        :set testStr ($testStr . [$DecToChar 0])
    }
    :set res [$RunGenericTestCase $res $GetMd5Sum $testStr "nothing" "nothing" "3b5d3c7d207e37dceeedd301e35e2e58" "64 zero-byte message hash"]

    :put "Testing completed."
    :return $res
}

:set GetSha1SumTest do={
    :global InitTestCaseState
    :global GetSha1Sum
    :global DecToChar
    :global IsPrintableStr
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting GetSha1Sum tests..."

    # Short basic strings
    :set res [$RunGenericTestCase $res $GetSha1Sum "" "nothing" "nothing" \
        "da39a3ee5e6b4b0d3255bfef95601890afd80709" \
        "Empty string boundary hash verification"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "a" "nothing" "nothing" \
        "86f7e437faa5a7fce15d1ddcb9eaeaea377667b8" \
        "Single lowercase character string hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "abc" "nothing" "nothing" \
        "a9993e364706816aba3e25717850c26c9cd0d89d" \
        "Short lowercase alphabetical sequence hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "message digest" "nothing" "nothing" \
        "c12252ceda8be8994d5fa0290a47231c1d16aae3" \
        "Standard spaced alphabetical phrase hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "1234567890" "nothing" "nothing" \
        "01b307acba4f54f55aafc33bb06bbbf6ca803e9a" \
        "Numeric sequence data hash validation"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "admin" "nothing" "nothing" \
        "d033e22ae348aeb5660fc2140aec35850c4da997" \
        "Common administrative identifier string hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "RouterOS" "nothing" "nothing" \
        "87894613e2157470a89a9ddb05817e3fe3afb1f2" \
        "Mixed case application specific string hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "A" "nothing" "nothing" \
        "6dcd4ce23d88e2ee9568ba546c007c63d9131c1b" \
        "Single uppercase character string hash"]

    # Standard SHA-1 test vectors
    :set res [$RunGenericTestCase $res $GetSha1Sum "abcdefghijklmnopqrstuvwxyz" "nothing" "nothing" \
        "32d10c7b8cf96570ca04ce37f2a19d84240d3a89" \
        "Complete lowercase alphabet hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" "nothing" "nothing" \
        "761c457bf73b14d27e9e9265c46f4b4dda11f940" \
        "Uppercase lowercase and digit sequence hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "12345678901234567890123456789012345678901234567890123456789012345678901234567890" "nothing" "nothing" \
        "50abf5706a150990a08b2c5ea40fa0e585554732" \
        "Long numeric sequence SHA-1 validation hash"]

    # Case sensitivity
    :set res [$RunGenericTestCase $res $GetSha1Sum "hello" "nothing" "nothing" \
        "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d" \
        "Lowercase word hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "Hello" "nothing" "nothing" \
        "f7ff9e8b7bb2e09b70935a5d785e0cc5d9d0abf0" \
        "Capitalized word hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "HELLO" "nothing" "nothing" \
        "c65f99f8c5376adadddc46d5cbcf5762f9e55eb7" \
        "Uppercase word hash"]

    # Whitespace handling
    :set res [$RunGenericTestCase $res $GetSha1Sum " " "nothing" "nothing" \
        "b858cb282617fb0956d960215c8e84d1ccf909c6" \
        "Single space character hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "  " "nothing" "nothing" \
        "099600a10a944114aac406d136b625fb416dd779" \
        "Two consecutive spaces hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "abc " "nothing" "nothing" \
        "eeca658f56ce50a4f36605aaf93e29e87c12009a" \
        "Trailing space preservation hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum " abc" "nothing" "nothing" \
        "3a2d0af63d31343a13054b9758c00398c772c5fd" \
        "Leading space preservation hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum "abc 123" "nothing" "nothing" \
        "e2d0a343442ba7bd2c0537659a05e61668575f2b" \
        "Embedded space preservation hash"]

    # Repeated character sequences
    :local testStr ""

    :set testStr ""
    :for i from=1 to=32 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "68f84a59a3ca2d0e5cb1646fbb164da409b5d8f2" \
        "32 repeated lowercase character hash"]

    :set testStr ""
    :for i from=1 to=32 do={
        :set testStr ($testStr . "b")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "142e27ca6d179970507f4076e2ac96fec5834f82" \
        "32 repeated b character hash"]

    # Special characters
    :set res [$RunGenericTestCase $res $GetSha1Sum ("!@#\$%^&*()") "nothing" "nothing" \
        "bf24d65c9bb05b9b814a966940bcfa50767c8a8d" \
        "Common punctuation character sequence hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum ("~`[]{}|\\:;") "nothing" "nothing" \
        "bc90a8aa5f875213befae0246ffef89697651b75" \
        "Mixed punctuation character sequence hash"]

    # Short message packing boundaries
    :set testStr ""

    :for i from=1 to=2 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "e0c9035898dd52fc65c41454cec9c4d2611bfb37" \
        "Two-byte message packing validation"]

    :set testStr ""

    :for i from=1 to=3 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "7e240de74fb1ed08fa08d38063f6a6a91462a815" \
        "Three-byte message packing validation"]

    :set testStr ""

    :for i from=1 to=4 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "70c881d4a26984ddce795f6f71817c9cf4480e79" \
        "Four-byte message word boundary validation"]

    :set testStr ""

    :for i from=1 to=5 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "df51e37c269aa94d38f93e537bf6e2020b21406c" \
        "Five-byte message packing validation"]

    # SHA-1 512-bit block boundaries
    :set testStr ""

    :for i from=1 to=55 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "c1c8bbdc22796e28c0e15163d20899b65621d65a" \
        "55-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "c2db330f6083854c99d4b5bfb6e8f29f201be699" \
        "56-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "f08f24908d682555111be7ff6f004e78283d989a" \
        "57-byte message padding overflow hash"]

    # 63 / 64 / 65 bytes
    :set testStr ""

    :for i from=1 to=63 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "03f09f5b158a7a8cdad920bddc29b81c18a551f5" \
        "63-byte message boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "0098ba824b5c16427bd7a1122a5a442a25ec644d" \
        "64-byte message exact block hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "11655326c708d70319be2610e8a57d9a5b959d3b" \
        "65-byte message block overflow hash"]

    # 119 / 120 / 121 bytes
    :set testStr ""

    :for i from=1 to=119 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "ee971065aaa017e0632a8ca6c77bb3bf8b1dfc56" \
        "119-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "f34c1488385346a55709ba056ddd08280dd4c6d6" \
        "120-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "fa6b5a6f8ac27182f838fe7841ec6d2aef3ade29" \
        "121-byte message padding boundary hash"]

    # 127 / 128 / 129 bytes
    :set testStr ""

    :for i from=1 to=127 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "89d95fa32ed44a7c610b7ee38517ddf57e0bb975" \
        "127-byte message double block boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "ad5b3fdbcb526778c2839d2f151ea753995e26a0" \
        "128-byte message exact double block hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "d96debf1bdcbc896e6c134ea76e8141f40d78536" \
        "129-byte message double block overflow hash"]

    # 191 / 192 / 193 bytes
    :set testStr ""

    :for i from=1 to=191 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "f0d0429532d8c279879349ef6d15ec39a1f337c7" \
        "191-byte message multi-block boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "9b1a580cb91c62712ce65498ebad252a1d83051d" \
        "192-byte message exact three-block hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "8a3a12a43de5d50c9b65809e21f11912fd66a237" \
        "193-byte message multi-block overflow hash"]

    # 255 / 256 / 257 bytes
    :set testStr ""

    :for i from=1 to=255 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "5afd9729928ad946eee5610434e66b5f95accbaf" \
        "255-byte message boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "9c78512ad150c8b5d8918395ad0e5169397d2b62" \
        "256-byte message exact boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "0c1038883670f8a0203e053eaf67dc2dec280b42" \
        "257-byte message boundary overflow hash"]

    # Long multi-block messages
    :set testStr ""

    :for i from=1 to=512 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "164557facb73929875168c1e92caf09bb6064564" \
        "512-byte multi-block message hash"]

    :set testStr ""

    :for i from=1 to=1024 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "8eca554631df9ead14510e1a70ae48c70f9b9384" \
        "1024-byte multi-block message hash"]

    # All 256 possible byte values
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    :set res [$RunGenericTestCase $res $GetSha1Sum $allChars "nothing" "nothing" \
        "4916d6bdb7f78e6803698cab32d1586ea457dfc8" \
        "All 256 byte values hash"]

    # 64 zero bytes
    :set testStr ""

    :for i from=1 to=64 do={
        :set testStr ($testStr . [$DecToChar 0])
    }

    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "c8d7d0ef0eedfa82d2ea1aa592845b9a6d4b02b7" \
        "64 zero-byte message hash"]

    # Escape and control characters (RouterOS safe syntax)
    :set res [$RunGenericTestCase $res $GetSha1Sum ("hello\nworld") "nothing" "nothing" \
        "7db827c10afc1719863502cf95397731b23b8bae" \
        "Newline Unix control character hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum ("hello\r\nworld") "nothing" "nothing" \
        "d07cff009c449bfdf131d865e1dc4413256e5f52" \
        "CRLF Windows control sequence hash"]

    :set res [$RunGenericTestCase $res $GetSha1Sum ("\"\\\$") "nothing" "nothing" \
        "17ef2c5fff42a2ff7d1675d60bbadf87ef4180be" \
        "Escaped characters quote backslash dollar hash"]

    # Embedded null byte inside non-empty string
    :set testStr ("abc" . [$DecToChar 0] . "def")
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "487b1975d97215516d7267dff3557c0676956056" \
        "Embedded null byte string truncation check"]

    # 4096 bytes long string (counter overflow validation)
    :set testStr ""
    :for i from=1 to=4096 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha1Sum $testStr "nothing" "nothing" \
        "8c51fb6a0b587ec95ca74acfa43df7539b486297" \
        "4096-byte large buffer length counter hash"]

    :put "Testing completed."

    :return $res
}

:set GetSha256SumTest do={
    :global InitTestCaseState
    :global GetSha256Sum
    :global DecToChar
    :global IsPrintableStr
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting GetSha256Sum tests..."

    # Short basic strings
    :set res [$RunGenericTestCase $res $GetSha256Sum "" "nothing" "nothing" \
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" \
        "Empty string boundary hash verification"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "a" "nothing" "nothing" \
        "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb" \
        "Single lowercase character string hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "abc" "nothing" "nothing" \
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad" \
        "Short lowercase alphabetical sequence hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "message digest" "nothing" "nothing" \
        "f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650" \
        "Standard spaced alphabetical phrase hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "1234567890" "nothing" "nothing" \
        "c775e7b757ede630cd0aa1113bd102661ab38829ca52a6422ab782862f268646" \
        "Numeric sequence data hash validation"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "admin" "nothing" "nothing" \
        "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918" \
        "Common administrative identifier string hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "RouterOS" "nothing" "nothing" \
        "a90c8469ca077a14dc19b0b414054ad03c39e9bd94146454ab9c4f12b40ff4f3" \
        "Mixed case application specific string hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "A" "nothing" "nothing" \
        "559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd" \
        "Single uppercase character string hash"]

    # Standard SHA-256 test vectors
    :set res [$RunGenericTestCase $res $GetSha256Sum "abcdefghijklmnopqrstuvwxyz" "nothing" "nothing" \
        "71c480df93d6ae2f1efad1447c66c9525e316218cf51fc8d9ed832f2daf18b73" \
        "Complete lowercase alphabet hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" "nothing" "nothing" \
        "db4bfcbd4da0cd85a60c3c37d3fbd8805c77f15fc6b1fdfe614ee0a7c8fdb4c0" \
        "Uppercase lowercase and digit sequence hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "12345678901234567890123456789012345678901234567890123456789012345678901234567890" "nothing" "nothing" \
        "f371bc4a311f2b009eef952dd83ca80e2b60026c8e935592d0f9c308453c813e" \
        "Long numeric sequence validation hash"]

    # Case sensitivity
    :set res [$RunGenericTestCase $res $GetSha256Sum "hello" "nothing" "nothing" \
        "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824" \
        "Lowercase word hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "Hello" "nothing" "nothing" \
        "185f8db32271fe25f561a6fc938b2e264306ec304eda518007d1764826381969" \
        "Capitalized word hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "HELLO" "nothing" "nothing" \
        "3733cd977ff8eb18b987357e22ced99f46097f31ecb239e878ae63760e83e4d5" \
        "Uppercase word hash"]

    # Whitespace handling
    :set res [$RunGenericTestCase $res $GetSha256Sum " " "nothing" "nothing" \
        "36a9e7f1c95b82ffb99743e0c5c4ce95d83c9a430aac59f84ef3cbfab6145068" \
        "Single space character hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "  " "nothing" "nothing" \
        "6c179f21e6f62b629055d8ab40f454ed02e48b68563913473b857d3638e23b28" \
        "Two consecutive spaces hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "abc " "nothing" "nothing" \
        "5488613c42b0d34d60f7aa9e94be317a3ee102a2bbd91ccc73cc79fbc2269955" \
        "Trailing space preservation hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum " abc" "nothing" "nothing" \
        "d92b1cb3a32147b86a4db0647e4bf6eda6cf160fd3b2da264c5b088c9f9ccbfa" \
        "Leading space preservation hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "abc 123" "nothing" "nothing" \
        "58384e9216293c79c817a333c0098482f2d59f826cac1e3dae7a8b904c1ea3a4" \
        "Embedded space preservation hash"]

    # Repeated character sequences
    :local testStr ""

    :set testStr ""
    :for i from=1 to=32 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "3ba3f5f43b92602683c19aee62a20342b084dd5971ddd33808d81a328879a547" \
        "32 repeated lowercase character hash"]

    :set testStr ""
    :for i from=1 to=32 do={
        :set testStr ($testStr . "b")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "bdb339768bc5e4fecbe55a442056919b2b325907d49bcbf3bf8de13781996a83" \
        "32 repeated b character hash"]

    # Special characters
    :set res [$RunGenericTestCase $res $GetSha256Sum ("!@#\$%^&*()") "nothing" "nothing" \
        "95ce789c5c9d18490972709838ca3a9719094bca3ac16332cfec0652b0236141" \
        "Common punctuation character sequence hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum ("~`[]{}|\\:;") "nothing" "nothing" \
        "4976bbfc1f68ff4d585f4e457811c6446f56798f19bf49b4f368357fdfce8d14" \
        "Mixed punctuation character sequence hash"]

    # Short message packing boundaries
    :set testStr ""

    :for i from=1 to=2 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "961b6dd3ede3cb8ecbaacbd68de040cd78eb2ed5889130cceb4c49268ea4d506" \
        "Two-byte message packing validation"]

    :set testStr ""

    :for i from=1 to=3 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "9834876dcfb05cb167a5c24953eba58c4ac89b1adf57f28f2f9d09af107ee8f0" \
        "Three-byte message packing validation"]

    :set testStr ""

    :for i from=1 to=4 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "61be55a8e2f6b4e172338bddf184d6dbee29c98853e0a0485ecee7f27b9af0b4" \
        "Four-byte message word boundary validation"]

    :set testStr ""

    :for i from=1 to=5 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "ed968e840d10d2d313a870bc131a4e2c311d7ad09bdf32b3418147221f51a6e2" \
        "Five-byte message packing validation"]

    # SHA-256 512-bit block boundaries
    :set testStr ""

    :for i from=1 to=55 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "9f4390f8d30c2dd92ec9f095b65e2b9ae9b0a925a5258e241c9f1e910f734318" \
        "55-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "b35439a4ac6f0948b6d6f9e3c6af0f5f590ce20f1bde7090ef7970686ec6738a" \
        "56-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "f13b2d724659eb3bf47f2dd6af1accc87b81f09f59f2b75e5c0bed6589dfe8c6" \
        "57-byte message padding overflow hash"]

    # 63 / 64 / 65 bytes
    :set testStr ""

    :for i from=1 to=63 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "7d3e74a05d7db15bce4ad9ec0658ea98e3f06eeecf16b4c6fff2da457ddc2f34" \
        "63-byte message boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb" \
        "64-byte message exact block hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "635361c48bb9eab14198e76ea8ab7f1a41685d6ad62aa9146d301d4f17eb0ae0" \
        "65-byte message block overflow hash"]

    # 119 / 120 / 121 bytes
    :set testStr ""

    :for i from=1 to=119 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "31eba51c313a5c08226adf18d4a359cfdfd8d2e816b13f4af952f7ea6584dcfb" \
        "119-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "2f3d335432c70b580af0e8e1b3674a7c020d683aa5f73aaaedfdc55af904c21c" \
        "120-byte message padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "e9615320128cc7a3d6078e9af05603188e5ccbf0d07d8b735d3df5e8e0c1281f" \
        "121-byte message padding boundary hash"]

    # 127 / 128 / 129 bytes
    :set testStr ""

    :for i from=1 to=127 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "c57e9278af78fa3cab38667bef4ce29d783787a2f731d4e12200270f0c32320a" \
        "127-byte message double block boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "6836cf13bac400e9105071cd6af47084dfacad4e5e302c94bfed24e013afb73e" \
        "128-byte message exact double block hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "c12cb024a2e5551cca0e08fce8f1c5e314555cc3fef6329ee994a3db752166ae" \
        "129-byte message double block overflow hash"]

    # 191 / 192 / 193 bytes
    :set testStr ""

    :for i from=1 to=191 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "311834ddbafe20677dddbf9f4beb2b5b0b9e6ee97dddb70fce4e8f62c1b7518d" \
        "191-byte message multi-block boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "7cee24628d290c16183532716cc5a8a889bc951b4b0a1507c32b8e29cee01052" \
        "192-byte message exact three-block hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "33f93a9879ef18f9779150b2dbace6f8cc17b29e1af6be4e1048fc647489f1c2" \
        "193-byte message multi-block overflow hash"]

    # 255 / 256 / 257 bytes
    :set testStr ""

    :for i from=1 to=255 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "b0f3323e7a3cad8ae6778340cc2a17ae0cb31c818df3767cda7c3dd423725e90" \
        "255-byte message boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "02d7160d77e18c6447be80c2e355c7ed4388545271702c50253b0914c65ce5fe" \
        "256-byte message exact boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "e8d95cc2b4bc198c54b40bd214df958afb65f5e73d2c2eafe0593cf5c635c1f0" \
        "257-byte message boundary overflow hash"]

    # Long multi-block messages
    :set testStr ""

    :for i from=1 to=512 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "471be6558b665e4f6dd49f1184814d1491b0315d466beea768c153cc5500c836" \
        "512-byte multi-block message hash"]

    :set testStr ""

    :for i from=1 to=1024 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "2edc986847e209b4016e141a6dc8716d3207350f416969382d431539bf292e4a" \
        "1024-byte multi-block message hash"]

    # All 256 possible byte values
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    :set res [$RunGenericTestCase $res $GetSha256Sum $allChars "nothing" "nothing" \
        "40aff2e9d2d8922e47afd4648e6967497158785fbd1da870e7110266bf944880" \
        "All 256 byte values hash"]

    # 64 zero bytes
    :set testStr ""

    :for i from=1 to=64 do={
        :set testStr ($testStr . [$DecToChar 0])
    }

    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "f5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b" \
        "64 zero-byte message hash"]

    # Escape and control characters (RouterOS safe syntax)
    :set res [$RunGenericTestCase $res $GetSha256Sum ("hello\nworld") "nothing" "nothing" \
        "26c60a61d01db5836ca70fefd44a6a016620413c8ef5f259a6c5612d4f79d3b8" \
        "Newline Unix control character hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum ("hello\r\nworld") "nothing" "nothing" \
        "4739e65e5ea45fcd394e1ca6dc39e603f59fb6cf3f4f31fc7b6a1f6c4715be8e" \
        "CRLF Windows control sequence hash"]

    :set res [$RunGenericTestCase $res $GetSha256Sum ("\"\r\n\\\$") "nothing" "nothing" \
        "2868105d4ccbe0563f1f201a854b2fa0fcf87af1e54ad93a24bed3d44136e1e8" \
        "Escaped characters quote backslash dollar hash"]

    # Embedded null byte inside non-empty string
    :set testStr ("abc" . [$DecToChar 0] . "def")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "516a5e926ce20c5f4d80f00e1a01abdf14986def6588d6abeed9fce090bc660c" \
        "Embedded null byte string truncation check"]

    # 4096 bytes long string (counter overflow validation)
    :set testStr ""
    :for i from=1 to=4096 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "c93eee2d0db02f10acc7460d9576e122dcf8cd53c4bf8dfcae1b3e74ebcfff5a" \
        "4096-byte large buffer length counter hash"]

    # SHA-256 official NIST / FIPS test vectors
    :set res [$RunGenericTestCase $res $GetSha256Sum "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" "nothing" "nothing" \
        "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1" \
        "NIST 56-byte SHA-256 test vector"]

    :set res [$RunGenericTestCase $res $GetSha256Sum "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmno" "nothing" "nothing" \
        "2ff100b36c386c65a1afc462ad53e25479bec9498ed00aa5a04de584bc25301b" \
        "NIST 64-byte SHA-256 test vector"]

    # 447 / 448 / 449 bytes
    :set testStr ""
    :for i from=1 to=447 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "e34a202bd60bf20ec2d35716169251ed99d2c2cc57df0dc85dcb024ff0b797c8" \
        "447-byte message boundary hash"]

    # Test length-field boundary at 448 bytes
    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "8984f047b9332de349e82f5f855bf0d224bcec9b3c7f59f9ae022cad44119f65" \
        "448-byte message length-field boundary hash"]

    # Test padding overflow at 449 bytes
    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "f0873d67765d732a3b57565e9567cb4ac9a893e66474cf76b85b399234283195" \
        "449-byte message padding overflow hash"]

    # 511 / 512 / 513 bytes
    :set testStr ""
    :for i from=1 to=511 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "058fc5084b6355a06099bfef3de8e360344046dc5a47026de47470b9aabb5bfd" \
        "511-byte multi-block boundary hash"]

    # Test exact eight-block boundary at 512 bytes
    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "471be6558b665e4f6dd49f1184814d1491b0315d466beea768c153cc5500c836" \
        "512-byte exact eight-block hash"]

    # Test multi-block overflow at 513 bytes
    :set testStr ($testStr . "a")
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "02425c0f5b0dabf3d2b9115f3f7723a02ad8bcfb1534a0d231614fd42b8188f6" \
        "513-byte multi-block overflow hash"]

    # Different byte distributions across multiple blocks
    :set testStr ""
    :for i from=0 to=255 do={
        :set testStr ($testStr . [$DecToChar $i])
    }
    :set testStr ($testStr . $testStr)
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "110009dcee21620b166f3abfecb5eff7a873be729d1c2d53822e7acc5f34eb9b" \
        "512-byte repeated all-byte-values hash"]

    # High-bit bytes across multiple blocks
    :set testStr ""
    :for i from=128 to=255 do={
        :set testStr ($testStr . [$DecToChar $i])
    }
    :for i from=128 to=255 do={
        :set testStr ($testStr . [$DecToChar $i])
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "4735f13c30847f0efd0b3cf9139c6f27242640219e6464b9cb12c21ba390b902" \
        "256-byte high-bit byte sequence hash"]

    # Alternating byte patterns
    :set testStr ""
    :for i from=1 to=256 do={
        :if (($i & 1) = 0) do={
            :set testStr ($testStr . [$DecToChar 0xAA])
        } else={
            :set testStr ($testStr . [$DecToChar 0x55])
        }
    }
    :set res [$RunGenericTestCase $res $GetSha256Sum $testStr "nothing" "nothing" \
        "f27a3a59770a5641860de605db1cca7212f7132cda71d0217901c4c347ba15ab" \
        "Alternating AA55 byte pattern hash"]

    :put "Testing completed."

    :return $res
}
