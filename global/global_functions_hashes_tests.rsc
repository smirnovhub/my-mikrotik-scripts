:global RunAllHashesTests
:global GetMd5SumTest

:set RunAllHashesTests do={
    :global GetMd5SumTest

    :put "\1B[35m=== STARTING ALL HASHES TESTS ===\1B[0m"

    $GetMd5SumTest

    :put "\1B[35m=== ALL HASHES TESTS EXECUTED ===\1B[0m"
}

:set GetMd5SumTest do={
    :global GetMd5Sum

    :local RunTestCase do={
        :global GetMd5Sum

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return ""
        }

        :local inputStr [:tostr $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        # Use an explicit check for the test execution block to handle empty strings safely
        :local actual [$GetMd5Sum $inputStr]
        :if ($actual = $expected) do={
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputStr . "' -> '" . $actual . "'")
        } else={
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputStr . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting GetMd5Sum tests..."

    # Empty string validation (Standard MD5 for empty input)
    [$RunTestCase "" "d41d8cd98f00b204e9800998ecf8427e" "Empty string boundary hash verification"]

    # Short basic strings
    [$RunTestCase "a" "0cc175b9c0f1b6a831c399e269772661" "Single lowercase character string hash"]
    [$RunTestCase "abc" "900150983cd24fb0d6963f7d28e17f72" "Short lowercase alphabetical sequence hash"]
    [$RunTestCase "message digest" "f96b697d7cb7938d525a2f31aaf161d0" "Standard spaced alphabetical phrase hash"]

    # Numeric and special character sequences
    [$RunTestCase "1234567890" "e807f1fcf82d132f9bb018ca6738a19f" "Numeric sequence data hash validation"]
    [$RunTestCase "admin" "21232f297a57a5a743894a0e4a801fc3" "Common administrative identifier string hash"]
    [$RunTestCase "RouterOS" "7e08a36aac8e952ec66f3f28bd384bc0" "Mixed case application specific string hash"]

    # Empty string validation (Standard MD5 for empty input)
    [$RunTestCase "" "d41d8cd98f00b204e9800998ecf8427e" "Empty string boundary hash verification"]
    
    # Single character inputs
    [$RunTestCase "A" "7fc56270e7a70fa81a5935b72eacbe29" "Single uppercase character string hash"]
    
    # Standard RFC 1321 test vectors
    [$RunTestCase "abcdefghijklmnopqrstuvwxyz" "c3fcd3d76192e4007dfb496cca67e13b" "Complete lowercase alphabet hash"]
    [$RunTestCase "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" "d174ab98d277d9f5a5611c2c9f419d9f" "Uppercase lowercase and digit sequence hash"]
    [$RunTestCase "12345678901234567890123456789012345678901234567890123456789012345678901234567890" "57edf4a22be3c955ac49da2e2107b67a" "Long numeric sequence RFC validation hash"]
    
    # Common strings
    [$RunTestCase "password" "5f4dcc3b5aa765d61d8327deb882cf99" "Common password string hash"]
    
    # Case sensitivity
    [$RunTestCase "hello" "5d41402abc4b2a76b9719d911017c592" "Lowercase word hash"]
    [$RunTestCase "Hello" "8b1a9953c4611296a827abf8c47804d7" "Capitalized word hash"]
    [$RunTestCase "HELLO" "eb61eead90e3b899c6bcbe27ac581660" "Uppercase word hash"]
    
    # Whitespace handling
    [$RunTestCase " " "7215ee9c7d9dc229d2921a40e899ec5f" "Single space character hash"]
    [$RunTestCase "  " "23b58def11b45727d3351702515f86af" "Two consecutive space characters hash"]
    [$RunTestCase "abc " "28a53e303da9f5742476fd6b62434540" "Trailing space preservation hash"]
    [$RunTestCase " abc" "12cfaf7fd98f33be8038b3d56c18f061" "Leading space preservation hash"]
    [$RunTestCase "abc 123" "c89cfdb5dd9f56836f59fba6c062dda4" "Embedded space preservation hash"]
    
    # Repeated character sequences
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "5eca9bd3eb07c006cd43ae48dfde7fd3" "Repeated lowercase character block hash"]
    [$RunTestCase "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" "8b4f9ea16de4bcf5bbfc0ff1ea237934" "Repeated lowercase character block hash"]
    
    # Special characters
    [$RunTestCase ("!@#\$%^&*()") "05b28d17a7b6e7024b6e5d8cc43a8bf7" "Common punctuation character sequence hash"]
    [$RunTestCase ("~`[]{}|\\:;") "a5264c255ab316bcff01963a084ec8a0" "Mixed punctuation character sequence hash"]

    # 55-byte message (Last message length fitting before length field)
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "ef1772b6dff9a122358552954ad0df65" "55-byte message block boundary hash"]
    
    # 56-byte message (First message requiring an additional block)
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "3b0c8ac703f828b04c6c197006d17218" "56-byte message block boundary hash"]
    
    # 57-byte message
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "652b906d60af96844ebd21b674f35e93" "57-byte message block boundary hash"]
    
    # 63-byte message
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "b06521f39153d618550606be297466d5" "63-byte message block boundary hash"]
    
    # 64-byte message (Exactly one complete MD5 block)
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "014842d480b571495a4a0363793f7367" "64-byte message exact block hash"]
    
    # 65-byte message (One full block plus one byte)
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "c743a45e0d2e6a95cb859adae0248435" "65-byte message block overflow hash"]
    
    # 127-byte message
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "020406e1d05cdc2aa287641f7ae2cc39" "127-byte message double block boundary hash"]
    
    # 128-byte message (Exactly two complete MD5 blocks)
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "e510683b3f5ffe4093d021808bc6ff70" "128-byte message exact double block hash"]
    
    # 129-byte message
    [$RunTestCase "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "b325dc1c6f5e7a2b7cf465b9feab7948" "129-byte message double block overflow hash"]

    :put "Testing completed."
}
