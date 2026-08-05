:global RunAllArrayStrTests2
:global CompareStrTest
:global ReverseStrTest
:global IsPrintableStrTest
:global ExtractFileNameTest
:global ContainsStrTest
:global StartsWithStrTest
:global EndsWithStrTest
:global CleanStrTest

:set RunAllArrayStrTests2 do={
    :global CompareStrTest
    :global ReverseStrTest
    :global IsPrintableStrTest
    :global ExtractFileNameTest
    :global ContainsStrTest
    :global StartsWithStrTest
    :global EndsWithStrTest
    :global CleanStrTest

    :put "\1B[35m=== STARTING ALL ARRAY AND STRING TESTS 2 ===\1B[0m"

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    # Execute all test suites sequentially, passing and updating the same accumulator array
    :set res [$CompareStrTest $res]
    :set res [$ReverseStrTest $res]
    :set res [$IsPrintableStrTest $res]
    :set res [$ExtractFileNameTest $res]
    :set res [$ContainsStrTest $res]
    :set res [$StartsWithStrTest $res]
    :set res [$EndsWithStrTest $res]
    :set res [$CleanStrTest $res]

    :put "\1B[35m=== ALL ARRAY AND STRING TESTS 2 COMPLETED ===\1B[0m"

    :return $res
}

:set CompareStrTest do={
    :global CompareStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        :global CompareStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local str1 [:tostr $2]
        :local str2 [:tostr $3]
        :local expected [:tonum $4]
        :local name [:tostr $5]

        :local actual [$CompareStr $str1 $str2]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $str1 . "' vs '" . $str2 . "' -> " . $actual)
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $str1 . "' vs '" . $str2 . "' | Expected: " . $expected . ", Got: " . $actual)
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting CompareStr tests..."

    # --- Edge Cases & Basics ---
    :set res [$RunTestCase $res "" "" 0 "Both empty"]
    :set res [$RunTestCase $res "a" "" 1 "First non-empty, second empty"]
    :set res [$RunTestCase $res "" "a" -1 "First empty, second non-empty"]
    :set res [$RunTestCase $res "identical" "identical" 0 "Identical long strings"]

    # --- Case Sensitivity (ASCII orders uppercase before lowercase) ---
    :set res [$RunTestCase $res "Apple" "apple" -1 "Uppercase vs Lowercase start"]
    :set res [$RunTestCase $res "apple" "Apple" 1 "Lowercase vs Uppercase start"]
    :set res [$RunTestCase $res "aPple" "apple" -1 "Difference in middle (caps first)"]
    :set res [$RunTestCase $res "apple" "aPple" 1 "Difference in middle (lowercase first)"]
    :set res [$RunTestCase $res "A" "a" -1 "Single char Uppercase vs Lowercase"]
    :set res [$RunTestCase $res "a" "A" 1 "Single char Lowercase vs Uppercase"]
    :set res [$RunTestCase $res "WORD" "word" -1 "All caps vs all lowercase"]

    # --- Length & Prefixes ---
    :set res [$RunTestCase $res "test" "testing" -1 "Short prefix vs long string"]
    :set res [$RunTestCase $res "testing" "test" 1 "Long string vs short prefix"]
    :set res [$RunTestCase $res "abc" "abcdefgh" -1 "Very short vs very long prefix"]
    :set res [$RunTestCase $res "abcdefgh" "abc" 1 "Very long vs very short prefix"]

    # --- Standard Alphabetical ---
    :set res [$RunTestCase $res "abc" "abd" -1 "Last char smaller"]
    :set res [$RunTestCase $res "abd" "abc" 1 "Last char larger"]
    :set res [$RunTestCase $res "absolute" "abstract" -1 "Divergence in middle (o vs r)"]

    # --- Numbers & Numeric Strings (ASCII order: '0'-'9') ---
    :set res [$RunTestCase $res "123" "123" 0 "Identical numbers"]
    :set res [$RunTestCase $res "123" "124" -1 "Numbers standard order"]
    :set res [$RunTestCase $res "2" "10" 1 "ASCII comparison vs numeric value (2 > 1)"]
    :set res [$RunTestCase $res "01" "1" -1 "Leading zero comparison"]

    # --- Special Characters & Spaces (ASCII order: space=32, symbols vary) ---
    :set res [$RunTestCase $res " " "" 1 "Space vs empty"]
    :set res [$RunTestCase $res "a b" "ab" -1 "Space vs no space (space is smaller than 'b')"]
    :set res [$RunTestCase $res "abc" "abc " -1 "String vs string with trailing space"]
    :set res [$RunTestCase $res "abc!" "abc?" -1 "Special chars (! is 33, ? is 63)"]
    :set res [$RunTestCase $res "abc" "abc_def" -1 "String vs string with underscore"]

    :put "Testing completed."
    :return $res
}

:set ReverseStrTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local actual $2
        :local expected $3
        :local name [:tostr $4]

        # Convert both to string to avoid RouterOS type mismatch bugs
        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . [:tostr $actual] . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "', Got: '" . [:tostr $actual] . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting ReverseStr tests..."
    :global ReverseStr

    # --- Base & Standard Cases ---

    # Test Case 1: Standard word reversal
    :local r1 [$ReverseStr "hello"]
    :set res [$RunTestCase $res $r1 "olleh" "Standard word reversal"]

    # Test Case 2: Multi-word string reversal
    :local r2 [$ReverseStr "hello world"]
    :set res [$RunTestCase $res $r2 "dlrow olleh" "Multi-word string reversal"]

    # Test Case 3: Palindrome reversal
    :local r3 [$ReverseStr "radar"]
    :set res [$RunTestCase $res $r3 "radar" "Palindrome reversal"]

    # --- Edge Cases & Boundaries ---

    # Test Case 4: Empty string
    :local r4 [$ReverseStr ""]
    :set res [$RunTestCase $res $r4 "" "Empty string"]

    # Test Case 5: Single character string
    :local r5 [$ReverseStr "a"]
    :set res [$RunTestCase $res $r5 "a" "Single character string"]

    # Test Case 6: Two character string
    :local r6 [$ReverseStr "ab"]
    :set res [$RunTestCase $res $r6 "ba" "Two character string"]

    # --- Formatting & Special Characters ---

    # Test Case 7: Mixed case string
    :local r7 [$ReverseStr "RouterOS"]
    :set res [$RunTestCase $res $r7 "SOretuoR" "Mixed case string"]

    # Test Case 8: File path reversal
    :local r8 [$ReverseStr "flash/backups/cfg.rsc"]
    :set res [$RunTestCase $res $r8 "csr.gfc/spukcab/hsalf" "File path reversal"]

    # Test Case 9: String with spaces and tabs
    :local r9 [$ReverseStr ("a b\tc")]
    :set res [$RunTestCase $res $r9 ("c\tb a") "String with spaces and tabs"]

    # Test Case 10: Punctuation and symbols
    :local r10 [$ReverseStr "192.168.88.1/24"]
    :set res [$RunTestCase $res $r10 "42/1.88.861.291" "Punctuation and symbols"]

    # --- Non-string Parameters ---

    # Test Case 11: Non-string parameters (Numeric types)
    :local r11 [$ReverseStr 12345]
    :set res [$RunTestCase $res $r11 "54321" "Non-string parameters (Numeric types)"]

    # Test Case 12: Boolean parameter
    :local r12 [$ReverseStr true]
    :set res [$RunTestCase $res $r12 "eurt" "Boolean parameter"]

    # Test Case 13: IP address type parameter
    :local r13 [$ReverseStr 10.0.0.1]
    :set res [$RunTestCase $res $r13 "1.0.0.01" "IP address type parameter"]

    :put "Testing completed."
    :return $res
}

:set IsPrintableStrTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        :global IsPrintableStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local input [:tostr $2]
        :local expected $3
        :local name [:tostr $4]

        :local actual [$IsPrintableStr $input]

        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> " . [:tostr $actual])
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: " . [:tostr $expected] . ", Got: " . [:tostr $actual])
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting IsPrintableStr tests..."
    :global DecToChar

    # --- Standard Printable Strings ---
    :set res [$RunTestCase $res ("Hello World") true "Standard text with space"]
    :set res [$RunTestCase $res ("RouterOS-123!") true "Alphanumeric and standard punctuation"]
    :set res [$RunTestCase $res ("~`@#\$%^&*()_+{}|:<>?-=[]\\;',./") true "All standard keyboard symbols"]

    # --- Edge Cases (Empty and Short) ---
    :set res [$RunTestCase $res ("") true "Empty string is technically free of control characters"]
    :set res [$RunTestCase $res ("A") true "Single printable character"]

    # --- Low Control Characters (0x00 - 0x1F) ---
    :set res [$RunTestCase $res ("Line1" . [$DecToChar 10] . "Line2") false "String containing Line Feed (LF, 0x0A)"]
    :set res [$RunTestCase $res ("Data" . [$DecToChar 13]) false "String ending with Carriage Return (CR, 0x0D)"]
    :set res [$RunTestCase $res ("Text" . [$DecToChar 9] . "Aligned") false "String containing Tab character (0x09)"]
    :set res [$RunTestCase $res ([$DecToChar 0] . "NullStart") false "String starting with Null character (0x00)"]
    :set res [$RunTestCase $res ([$DecToChar 31]) false "Boundary low control character (0x1F)"]

    # --- High Control and Extended Characters (0x7F - 0xFF) ---
    :set res [$RunTestCase $res ("CleanText" . [$DecToChar 127]) false "String containing Delete character (DEL, 0x7F)"]
    :set res [$RunTestCase $res ([$DecToChar 128] . "Extended") false "Boundary extended ASCII character (0x80)"]
    :set res [$RunTestCase $res ("BadChar_" . [$DecToChar 255]) false "Max ASCII range character (0xFF)"]

    :put "Testing completed."
    :return $res
}

:set ExtractFileNameTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local actual $2
        :local expected $3
        :local name [:tostr $4]

        # Convert both to string to avoid RouterOS type mismatch bugs
        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . [:tostr $actual] . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "', Got: '" . [:tostr $actual] . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting ExtractFileName tests..."
    :global ExtractFileName

    # --- Test Case 1: Standard path with extension (Strip extension) ---
    :local r1 [$ExtractFileName "flash/backups/router-config.rsc"]
    :set res [$RunTestCase $res $r1 "router-config" "Standard path with extension (Strip extension)"]

    # --- Test Case 2: Standard path with extension (Keep extension) ---
    :local r2 [$ExtractFileName "flash/backups/router-config.rsc" true]
    :set res [$RunTestCase $res $r2 "router-config.rsc" "Standard path with extension (Keep extension)"]

    # --- Test Case 3: File in root directory (Strip extension) ---
    :local r3 [$ExtractFileName "system.backup"]
    :set res [$RunTestCase $res $r3 "system" "File in root (Strip extension)"]

    # --- Test Case 4: File in root directory (Keep extension) ---
    :local r4 [$ExtractFileName "system.backup" true]
    :set res [$RunTestCase $res $r4 "system.backup" "File in root (Keep extension)"]

    # --- Test Case 5: Path with no extension ---
    :local r5 [$ExtractFileName "flash/backups/my-file"]
    :set res [$RunTestCase $res $r5 "my-file" "Path with no extension"]

    # --- Test Case 6: Dot inside directory name, but no extension in file ---
    # The dot is in the folder name, the actual file 'script' has no extension.
    :local r6 [$ExtractFileName "flash.backups/my-folder/script"]
    :set res [$RunTestCase $res $r6 "script" "Dot in directory name, file has no extension"]

    # --- Test Case 7: Dot inside directory name, and file has extension ---
    :local r7 [$ExtractFileName "flash.backups/my-folder/script.txt"]
    :set res [$RunTestCase $res $r7 "script" "Dot in directory name, file has extension (Strip)"]

    # --- Test Case 8: File starting with dot (Hidden style) ---
    :local r8 [$ExtractFileName "flash/configs/.env"]
    :set res [$RunTestCase $res $r8 "" "Hidden style file starting with dot (Strip extension)"]

    # --- Test Case 9: File starting with dot (Hidden style, Keep extension) ---
    :local r9 [$ExtractFileName "flash/configs/.env" true]
    :set res [$RunTestCase $res $r9 ".env" "Hidden style file starting with dot (Keep extension)"]

    # --- File with multiple dots (Strip extension) ---
    :local r10 [$ExtractFileName "flash/archive/router.config.backup"]
    :set res [$RunTestCase $res $r10 "router.config" "Multiple dots in file name (Strip extension)"]

    # --- File with multiple dots (Keep extension) ---
    :local r11 [$ExtractFileName "flash/archive/router.config.backup" true]
    :set res [$RunTestCase $res $r11 "router.config.backup" "Multiple dots in file name (Keep extension)"]

    # --- File ending with a dot ---
    :local r12 [$ExtractFileName "flash/test/file."]
    :set res [$RunTestCase $res $r12 "file" "File ending with dot"]

    # --- File consisting only of an extension separator ---
    :local r13 [$ExtractFileName "."]
    :set res [$RunTestCase $res $r13 "" "Single dot as file name"]

    # --- File consisting of two dots ---
    :local r14 [$ExtractFileName ".."]
    :set res [$RunTestCase $res $r14 "" "Double dot as file name"]

    # --- Empty path ---
    :local r15 [$ExtractFileName ""]
    :set res [$RunTestCase $res $r15 "" "Empty path"]

    # --- Path ending with slash ---
    :local r16 [$ExtractFileName "flash/backups/"]
    :set res [$RunTestCase $res $r16 "" "Path ending with slash"]

    # --- Root slash only ---
    :local r17 [$ExtractFileName "/"]
    :set res [$RunTestCase $res $r17 "" "Root slash only"]

    # --- Multiple consecutive slashes ---
    :local r18 [$ExtractFileName "flash//configs///script.rsc"]
    :set res [$RunTestCase $res $r18 "script" "Multiple consecutive slashes"]

    # --- Hidden file with multiple dots ---
    :local r19 [$ExtractFileName ".config.json"]
    :set res [$RunTestCase $res $r19 ".config" "Hidden file with multiple dots"]

    # --- Directory names containing many dots ---
    :local r20 [$ExtractFileName "dir.v1/archive.v2/file.txt"]
    :set res [$RunTestCase $res $r20 "file" "Directories containing dots"]

    # --- File without path and without extension ---
    :local r21 [$ExtractFileName "README"]
    :set res [$RunTestCase $res $r21 "README" "Root file without extension"]

    # --- File with trailing spaces ---
    :local r22 [$ExtractFileName "flash/file.txt "]
    :set res [$RunTestCase $res $r22 "file" "Trailing spaces in file name"]

    :put "Testing completed."
    :return $res
}

:set ContainsStrTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local actual $2
        :local expected $3
        :local name [:tostr $4]

        # Convert both to string to avoid RouterOS type mismatch bugs
        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . [:tostr $actual] . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "', Got: '" . [:tostr $actual] . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting ContainsStr tests..."
    :global ContainsStr

    # --- Test Case 1: Substring exists in the middle ---
    :local r1 [$ContainsStr "hello world" "lo wo"]
    :set res [$RunTestCase $res $r1 true "Substring exists in the middle"]

    # --- Test Case 2: Substring does not exist ---
    :local r2 [$ContainsStr "hello world" "abc"]
    :set res [$RunTestCase $res $r2 false "Substring does not exist"]

    # --- Test Case 3: Empty search string ---
    :local r3 [$ContainsStr "hello world" ""]
    :set res [$RunTestCase $res $r3 true "Empty search string"]

    # --- Test Case 4: Search string matches target string completely ---
    :local r4 [$ContainsStr "exact" "exact"]
    :set res [$RunTestCase $res $r4 true "Search string matches target string completely"]

    # --- Test Case 5: Substring at the very beginning ---
    :local r5 [$ContainsStr "start of text" "start"]
    :set res [$RunTestCase $res $r5 true "Substring at the very beginning"]

    # --- Test Case 6: Substring at the very end ---
    :local r6 [$ContainsStr "end of text" "text"]
    :set res [$RunTestCase $res $r6 true "Substring at the very end"]

    # --- Test Case 7: Both parameters are empty strings ---
    :local r7 [$ContainsStr "" ""]
    :set res [$RunTestCase $res $r7 true "Both parameters are empty strings"]

    # --- Test Case 8: Target string is empty, search string is not ---
    :local r8 [$ContainsStr "" "abc"]
    :set res [$RunTestCase $res $r8 false "Target string is empty, search string is not"]

    # --- Test Case 9: Case sensitivity check ---
    :local r9 [$ContainsStr "Hello World" "hello"]
    :set res [$RunTestCase $res $r9 false "Case sensitivity check"]

    # --- Test Case 10: Non-string parameters (Numeric types) ---
    :local r10 [$ContainsStr 12345 "23"]
    :set res [$RunTestCase $res $r10 true "Non-string parameters (Numeric types)"]

    # --- Test Case 11: Special characters in string ---
    :local r11 [$ContainsStr "flash/backups/file.rsc" "/backups/"]
    :set res [$RunTestCase $res $r11 true "Special characters in string"]

    :put "Testing completed."
    :return $res
}

:set StartsWithStrTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local actual $2
        :local expected $3
        :local name [:tostr $4]

        # Convert both to string to avoid RouterOS type mismatch bugs
        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . [:tostr $actual] . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "', Got: '" . [:tostr $actual] . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting StartsWithStr tests..."
    :global StartsWithStr

    # --- Test Case 1: Standard matching prefix ---
    :local r1 [$StartsWithStr "hello world" "hello"]
    :set res [$RunTestCase $res $r1 true "Standard matching prefix"]

    # --- Test Case 2: Non-matching prefix ---
    :local r2 [$StartsWithStr "hello world" "world"]
    :set res [$RunTestCase $res $r2 false "Non-matching prefix"]

    # --- Test Case 3: Empty prefix ---
    :local r3 [$StartsWithStr "hello world" ""]
    :set res [$RunTestCase $res $r3 true "Empty prefix"]

    # --- Test Case 4: Prefix equals target string ---
    :local r4 [$StartsWithStr "exact" "exact"]
    :set res [$RunTestCase $res $r4 true "Prefix equals target string"]

    # --- Test Case 5: Prefix longer than target string ---
    :local r5 [$StartsWithStr "short" "shorter"]
    :set res [$RunTestCase $res $r5 false "Prefix longer than target string"]

    # --- Test Case 6: Both parameters are empty strings ---
    :local r6 [$StartsWithStr "" ""]
    :set res [$RunTestCase $res $r6 true "Both parameters are empty strings"]

    # --- Test Case 7: Target string is empty, prefix is not ---
    :local r7 [$StartsWithStr "" "prefix"]
    :set res [$RunTestCase $res $r7 false "Target string is empty, prefix is not"]

    # --- Test Case 8: Case sensitivity check ---
    :local r8 [$StartsWithStr "Hello world" "hello"]
    :set res [$RunTestCase $res $r8 false "Case sensitivity check"]

    # --- Test Case 9: Non-string parameters (Numeric types) ---
    :local r9 [$StartsWithStr 12345 12]
    :set res [$RunTestCase $res $r9 true "Non-string parameters (Numeric types)"]

    # --- Test Case 10: Special characters in path prefix ---
    :local r10 [$StartsWithStr "flash/backups/file.rsc" "flash/"]
    :set res [$RunTestCase $res $r10 true "Special characters in path prefix"]

    # --- Test Case 11: Single character match ---
    :local r11 [$StartsWithStr "router" "r"]
    :set res [$RunTestCase $res $r11 true "Single character match"]

    :put "Testing completed."
    :return $res
}

:set EndsWithStrTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local actual $2
        :local expected $3
        :local name [:tostr $4]

        # Convert both to string to avoid RouterOS type mismatch bugs
        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . [:tostr $actual] . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "', Got: '" . [:tostr $actual] . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting EndsWithStr tests..."
    :global EndsWithStr

    # --- Base & Standard Cases ---

    # Test Case 1: Standard matching suffix
    :local r1 [$EndsWithStr "Hello World" "World"]
    :set res [$RunTestCase $res $r1 true "Standard matching suffix"]

    # Test Case 2: Non-matching suffix
    :local r2 [$EndsWithStr "Hello World" "Hello"]
    :set res [$RunTestCase $res $r2 false "Non-matching suffix"]

    # Test Case 3: Empty suffix
    :local r3 [$EndsWithStr "Hello World" ""]
    :set res [$RunTestCase $res $r3 true "Empty suffix"]

    # Test Case 4: Suffix equals target string
    :local r4 [$EndsWithStr "exact" "exact"]
    :set res [$RunTestCase $res $r4 true "Suffix equals target string"]

    # Test Case 5: Suffix longer than target string
    :local r5 [$EndsWithStr "short" "longer_suffix"]
    :set res [$RunTestCase $res $r5 false "Suffix longer than target string"]

    # --- Edge Cases & Boundaries ---

    # Test Case 6: Both parameters are empty strings
    :local r6 [$EndsWithStr "" ""]
    :set res [$RunTestCase $res $r6 true "Both parameters are empty strings"]

    # Test Case 7: Target string is empty, suffix is not
    :local r7 [$EndsWithStr "" "suffix"]
    :set res [$RunTestCase $res $r7 false "Target string is empty, suffix is not"]

    # Test Case 8: Single character match at the end
    :local r8 [$EndsWithStr "router" "r"]
    :set res [$RunTestCase $res $r8 true "Single character match at the end"]

    # Test Case 9: Case sensitivity check
    :local r9 [$EndsWithStr "Hello World" "world"]
    :set res [$RunTestCase $res $r9 false "Case sensitivity check"]

    # --- Formatting & Path Cases ---

    # Test Case 10: File extension matching
    :local r10 [$EndsWithStr "flash/backups/script.rsc" ".rsc"]
    :set res [$RunTestCase $res $r10 true "File extension matching"]

    # Test Case 11: Matching trailing slash
    :local r11 [$EndsWithStr "flash/backups/" "/"]
    :set res [$RunTestCase $res $r11 true "Matching trailing slash"]

    # Test Case 12: Matching trailing space
    :local r12 [$EndsWithStr "hello " " "]
    :set res [$RunTestCase $res $r12 true "Matching trailing space"]

    # Test Case 13: Partial match before end (should fail)
    :local r13 [$EndsWithStr "config.rsc.backup" ".rsc"]
    :set res [$RunTestCase $res $r13 false "Partial match before end"]

    # --- Non-string Parameters ---

    # Test Case 14: Non-string parameters (Numeric types)
    :local r14 [$EndsWithStr 12345 45]
    :set res [$RunTestCase $res $r14 true "Non-string parameters (Numeric types)"]

    # Test Case 15: IP address object type passed as input
    :local r15 [$EndsWithStr 192.168.88.1 ".88.1"]
    :set res [$RunTestCase $res $r15 true "IP address type input parameter"]

    :put "Testing completed."
    :return $res
}

:set CleanStrTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local actual $2
        :local expected $3
        :local name [:tostr $4]

        # Convert both to string to avoid RouterOS type mismatch bugs
        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . [:tostr $actual] . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "', Got: '" . [:tostr $actual] . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting CleanStr expanded tests..."
    :global CleanStr

    # --- Base Cases ---

    # Test Case 1: Standard alphanumeric filtering
    :local r1 [$CleanStr "my-var@name!#123" "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"]
    :set res [$RunTestCase $res $r1 "myvarname123" "Standard alphanumeric filtering"]

    # Test Case 2: Only digits allowed (IP/MAC extraction style)
    :local r2 [$CleanStr "ip: 192.168.88.1" "0123456789"]
    :set res [$RunTestCase $res $r2 "192168881" "Only digits allowed"]

    # Test Case 3: Empty allowed characters string
    :local r3 [$CleanStr "some text" ""]
    :set res [$RunTestCase $res $r3 "" "Empty allowed characters string"]

    # Test Case 4: Empty input string
    :local r4 [$CleanStr "" "abc123"]
    :set res [$RunTestCase $res $r4 "" "Empty input string"]

    # Test Case 5: Both parameters empty
    :local r5 [$CleanStr "" ""]
    :set res [$RunTestCase $res $r5 "" "Both parameters empty"]

    # --- Edge Cases & Boundaries ---

    # Test Case 6: Single character input (Allowed)
    :local r6 [$CleanStr "a" "abc"]
    :set res [$RunTestCase $res $r6 "a" "Single character input (Allowed)"]

    # Test Case 7: Single character input (Not allowed)
    :local r7 [$CleanStr "z" "abc"]
    :set res [$RunTestCase $res $r7 "" "Single character input (Not allowed)"]

    # Test Case 8: Repeating allowed characters
    :local r8 [$CleanStr "aaaaabbbbb" "ab"]
    :set res [$RunTestCase $res $r8 "aaaaabbbbb" "Repeating allowed characters"]

    # Test Case 9: Allowed set contains duplicate characters
    :local r9 [$CleanStr "hello-123" "l11l"]
    :set res [$RunTestCase $res $r9 "ll1" "Allowed set contains duplicate characters"]

    # Test Case 10: All characters in input are allowed
    :local r10 [$CleanStr "cleanText" "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
    :set res [$RunTestCase $res $r10 "cleanText" "All characters allowed"]

    # Test Case 11: No characters in input are allowed
    :local r11 [$CleanStr "123456" "abcdef"]
    :set res [$RunTestCase $res $r11 "" "No characters allowed"]

    # --- Whitespaces & Formatting ---

    # Test Case 12: Preserve spaces when space is in allowed characters
    :local r12 [$CleanStr "hello world 123" "abcdefghijklmnopqrstuvwxyz "]
    :set res [$RunTestCase $res $r12 "hello world " "Preserve spaces when space is allowed"]

    # Test Case 13: Strip spaces when space is not in allowed characters
    :local r13 [$CleanStr "h e l l o" "helo"]
    :set res [$RunTestCase $res $r13 "hello" "Strip spaces when space is not allowed"]

    # Test Case 14: Tabs and newlines stripped if not allowed
    :local r14 [$CleanStr ("line1\nline2\tval") "line12val"]
    :set res [$RunTestCase $res $r14 "line1line2val" "Control characters stripped"]

    # --- Special Characters & Escaping ---

    # Test Case 15: Double quotes handling in string and allowed set
    :local r15 [$CleanStr ("text \"with\" quotes") ("abcdefghijklmnopqrstuvwxyz\"")]
    :set res [$RunTestCase $res $r15 ("text\"with\"quotes") "Double quotes handling"]

    # Test Case 16: Backslashes filtering
    :local r16 [$CleanStr ("path\\to\\file") ("abcdefghijklmnopqrstuvwxyz\\")]
    :set res [$RunTestCase $res $r16 ("path\\to\\file") "Backslashes filtering"]

    # Test Case 17: Punctuation and network symbols filtering
    :local r17 [$CleanStr "192.168.88.1/24:80" "0123456789./"]
    :set res [$RunTestCase $res $r17 "192.168.88.1/2480" "Punctuation and network symbols"]

    # Test Case 18: File system path cleaning
    :local r18 [$CleanStr "flash/backups/cfg!.rsc" "abcdefghijklmnopqrstuvwxyz/."]
    :set res [$RunTestCase $res $r18 "flash/backups/cfg.rsc" "File system path cleaning"]

    # --- Case Sensitivity & Types ---

    # Test Case 19: Strict upper/lower case sensitivity
    :local r19 [$CleanStr "ABCdef" "abc"]
    :set res [$RunTestCase $res $r19 "" "Case sensitivity in allowed list"]

    # Test Case 20: Non-string input parameter (Integer type)
    :local r20 [$CleanStr 123456 "135"]
    :set res [$RunTestCase $res $r20 "135" "Non-string input parameter (Integer type)"]

    # Test Case 21: Non-string allowed parameter (Integer type)
    :local r21 [$CleanStr "abc123def456" 234]
    :set res [$RunTestCase $res $r21 "234" "Non-string allowed parameter (Integer type)"]

    # Test Case 22: Boolean type parameters passed as input
    :local r22 [$CleanStr true "tru"]
    :set res [$RunTestCase $res $r22 "tru" "Boolean type input parameter"]

    # Test Case 23: IP address object type passed as input
    :local r23 [$CleanStr 192.168.88.1 "0123456789"]
    :set res [$RunTestCase $res $r23 "192168881" "IP address type input parameter"]

    :put "Testing completed."
    :return $res
}
