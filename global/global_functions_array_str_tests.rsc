:global RunAllArrayStrTests
:global ParseKeyValueStoreTest
:global JoinArrayTest
:global SplitStrTest
:global TrimStrTest
:global ReplaceStrTest
:global RecursiveMergeSortTest
:global RecursiveMergeSortStrTest
:global ToUpperCaseTest
:global ToLowerCaseTest
:global HexToCharTest
:global DecToCharTest
:global CompareStrTest

:set RunAllArrayStrTests do={
    :global ParseKeyValueStoreTest
    :global JoinArrayTest
    :global SplitStrTest
    :global TrimStrTest
    :global ReplaceStrTest
    :global RecursiveMergeSortTest
    :global RecursiveMergeSortStrTest
    :global ToUpperCaseTest
    :global ToLowerCaseTest
    :global HexToCharTest
    :global DecToCharTest
    :global CompareStrTest

    :put "\1B[35m=== STARTING ALL SYSTEM TESTS ===\1B[0m"

    # Execute string manipulation tests
    $TrimStrTest
    $SplitStrTest
    $JoinArrayTest
    $ReplaceStrTest
    
    # Execute case conversion tests
    $ToUpperCaseTest
    $ToLowerCaseTest
    
    # Execute character conversion tests
    $HexToCharTest
    $DecToCharTest
    
    # Execute sorting and comparison tests
    $CompareStrTest
    $RecursiveMergeSortTest
    $RecursiveMergeSortStrTest
    
    # Execute storage parser tests
    $ParseKeyValueStoreTest

    :put "\1B[35m=== ALL TESTS EXECUTED ===\1B[0m"
}

:set ParseKeyValueStoreTest do={
    :global ParseKeyValueStore

    # Helper function to run a single test case for key-value parsing
    :local RunTestCase do={
        :global ParseKeyValueStore
        :local src $1;        # Can be a string or a real array
        :local delim $2;      # Can be nothing or a string delimiter
        :local expectedStr [:tostr $3]
        :local name [:tostr $4]

        :local actual
        :if ($delim = "nothing") do={
            :set actual [$ParseKeyValueStore $src]
        } else={
            :set actual [$ParseKeyValueStore $src $delim]
        }

        :local actualStr [:tostr $actual]

        :if ($actualStr = $expectedStr) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> [" . $actualStr . "]")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: [" . $expectedStr . "], Got: [" . $actualStr . "]")
        }
    }

    :put "Starting ParseKeyValueStore tests..."

    # --- Basic String Parsing (Space Delimiter) ---
    [$RunTestCase "a=1 b=2 c=3" nothing "a=1;b=2;c=3" "Standard space-separated string"]
    [$RunTestCase "status=up active=true" nothing "active=true;status=up" "Booleans and text mixing"]

    # --- Custom Delimiters ---
    [$RunTestCase "x=10,y=20,z=30" "," "x=10;y=20;z=30" "Comma delimiter"]
    [$RunTestCase "proto=tcp;port=80" ";" "port=80;proto=tcp" "Semicolon delimiter"]

    # --- Boolean Type Casting ---
    [$RunTestCase "flag1=true flag2=false" nothing "flag1=true;flag2=false" "True and False strings cast to boolean types"]

    # --- Keys Without Values (Flags) ---
    [$RunTestCase "disabled force debug=true" nothing "debug=true;disabled=true;force=true" "Implicit true for valueless keys"]

    # --- Parsing Pre-split Arrays ---
    :local inputArr {"foo=bar"; "baz=qux"}
    [$RunTestCase $inputArr nothing "baz=qux;foo=bar" "Input as a ready-made array of strings"]

    # --- Edge Cases with Trimming ---
    [$RunTestCase "  key1=val1   key2=val2  " nothing "key1=val1;key2=val2" "Spaces around elements (handled by TrimStr)"]
    [$RunTestCase "" nothing "" "Empty input string"]

    # --- Special Characters inside Values ---
    [$RunTestCase ("url=http://host/path?a=1&b=2") nothing "url=http://host/path?a=1&b=2" "Values containing internal equal signs"]

    # --- Duplicate Keys (Last one should win) ---
    [$RunTestCase "user=ivan user=bobro" nothing "user=bobro" "Duplicate keys overwrite previous values"]

    # --- Mixed Delimiters & Empty Elements ---
    [$RunTestCase "  a=1    b=2  " nothing "a=1;b=2" "Multiple sequential spaces between pairs"]
    [$RunTestCase "x=1,,y=2" "," "x=1;y=2" "Consecutive custom delimiters (empty elements)"]

    # --- No Equals Sign at All (All Keys become Flags) ---
    [$RunTestCase "force disabled debug" nothing "debug=true;disabled=true;force=true" "Multiple flags without values"]

    # --- Empty Values (Key with Equals but nothing after) ---
    [$RunTestCase "key1= key2=val2" nothing "key1=;key2=val2" "Empty value after equals sign"]

    # --- Complex Strings inside Pre-split Array ---
    :local complexArray {"interface=ether1"; "mac-address=00:11:22:33:44:55"; "comment=LAN port"}
    [$RunTestCase $complexArray nothing "comment=LAN port;interface=ether1;mac-address=00:11:22:33:44:55" "Pre-split array with MAC and comments"]

    # --- Delimiter that looks like part of the data ---
    [$RunTestCase "foo==bar baz==qux" nothing "baz==qux;foo==bar" "Double equals sign (first split wins)"]

    # --- Arguments Emulation Filtering (Fixes empty trailing variables) ---
    :local simulatedArgs {"ether1=1Gbps"; "ether2=1Gbps"; "ether3=1Gbps"; "ether4=1Gbps"; "ether5=1Gbps"; ""; ""}
    [$RunTestCase $simulatedArgs nothing "ether1=1Gbps;ether2=1Gbps;ether3=1Gbps;ether4=1Gbps;ether5=1Gbps" "Five valid interfaces with two empty trailing arguments"]

    :local emptyMiddleArgs {""; "status=up"; ""; "debug"; ""}
    [$RunTestCase $emptyMiddleArgs nothing "debug=true;status=up" "Empty elements at start, middle, and end of the array"]

    :local onlyEmptyArgs {""; ""; ""}
    [$RunTestCase $onlyEmptyArgs nothing "" "Array containing only empty strings"]

    :put "Testing completed."
}

:set JoinArrayTest do={
    :global JoinArray

    # Helper function to run a single test case for array joining
    :local RunTestCase do={
        :global JoinArray
        # ROS [:toarray] natively splits strings by comma
        :local arr [:toarray $1]
        :local delim [:tostr $2]
        :local expectedStr [:tostr $3]
        :local name [:tostr $4]

        :local actual [$JoinArray $arr $delim]
        :local actualStr [:tostr $actual]

        :if ($actualStr = $expectedStr) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . $actualStr . "'")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . $expectedStr . "', Got: '" . $actualStr . "'")
        }
    }

    :put "Starting JoinArray tests..."

    # --- Basic Joining ---
    [$RunTestCase ("1,3,4,2,7,5") "+" "1+3+4+2+7+5" "Example case from description (numbers)"]
    [$RunTestCase ("apple,banana,cherry") "," "apple,banana,cherry" "Comma separator with strings"]
    [$RunTestCase ("one,two,three") " / " "one / two / three" "Separator with spaces"]

    # --- Multi-character Separators ---
    [$RunTestCase ("a,b,c") "::" "a::b::c" "Two-colon separator"]
    [$RunTestCase ("hello,world") "AND" "helloANDworld" "Word separator"]

    # --- Edge Cases ---
    [$RunTestCase "single" "," "single" "Array with a single element"]
    [$RunTestCase "" "," "" "Empty array"]
    [$RunTestCase ("a,b,c") "" "abc" "Empty separator string"]

    # --- Special Characters & Escapes ---
    [$RunTestCase ("price,100,200") ("\$") ("price\$100\$200") "Join by dollar sign"]
    [$RunTestCase ("path,to,file") ("\\") ("path\\to\\file") "Join by backslash"]
    [$RunTestCase ("line1,line2,line3") ("\n") ("line1\nline2\nline3") "Join by newline"]
    [$RunTestCase ("a,b,c") " " "a b c" "Join by space"]

    :put "Testing completed."
}

:set SplitStrTest do={
    :global SplitStr

    # Helper function to run a single test case for array splitting
    :local RunTestCase do={
        :global SplitStr
        :local str [:tostr $1]
        :local delim [:tostr $2]
        :local limit $3; # Can be nothing or a number
        :local expected [:toarray $4]
        :local name [:tostr $5]

        :local actual
        :if ([:typeof $limit] = "nothing") do={
            :set actual [$SplitStr $str $delim]
        } else={
            :set actual [$SplitStr $str $delim $limit]
        }

        # Convert arrays to string representation for safe comparison in ROS 6.49
        :local actualStr [:tostr $actual]
        :local expectedStr [:tostr $expected]

        :if ($actualStr = $expectedStr) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $str . "' del: '" . $delim . "' -> [" . $actualStr . "]")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $str . "' del: '" . $delim . "' | Expected: [" . $expectedStr . "], Got: [" . $actualStr . "]")
        }
    }

    :put "Starting SplitStr tests..."

    # --- Basic Splitting ---
    [$RunTestCase "1+3+4+2+7+5" "+" nothing "1,3,4,2,7,5" "Example case from description"]
    [$RunTestCase "apple,banana,cherry" "," nothing "apple,banana,cherry" "Comma delimiter"]
    [$RunTestCase "one/two/three" "/" nothing "one,two,three" "Slash delimiter"]

    # --- Multi-character Delimiters ---
    [$RunTestCase "a::b::c" "::" nothing "a,b,c" "Two-colon delimiter"]
    [$RunTestCase "helloANDworldANDagain" "AND" nothing "hello,world,again" "Word delimiter"]

    # --- Edge Cases with Delimiters ---
    [$RunTestCase "abc" "," nothing "abc" "Delimiter not found (returns original string in array)"]
    [$RunTestCase ",abc," "," nothing ",abc," "Leading and trailing delimiters"]
    [$RunTestCase "abc,,def" "," nothing "abc,,def" "Consecutive delimiters (creates empty elements)"]
    [$RunTestCase "" "," nothing "" "Empty input string"]

    # --- Limit Parameter ($3) Tests ---
    [$RunTestCase "a+b+c+d" "+" 2 "a;b+c+d" "Limit to 2 parts (first element and the rest)"]
    [$RunTestCase "1.2.3.4.5" "." 3 "1,2,3.4.5" "Limit to 3 parts with dot delimiter"]
    [$RunTestCase "one,two" "," 5 "one,two" "Limit greater than total parts available"]
    [$RunTestCase "a,b,c" "," 1 "a,b,c" "Limit is 1 (returns original string in array)"]

    # --- Special Characters & Escapes ---
    [$RunTestCase ("price " . ("\$") . " 100 " . ("\$") . " 200") ("\$") nothing "price ; 100 ; 200" "Split by dollar sign"]
    [$RunTestCase ("path\\to\\file") ("\\") nothing "path,to,file" "Split by backslash"]
    [$RunTestCase ("line1\nline2\nline3") ("\n") nothing "line1,line2,line3" "Split by newline"]
    [$RunTestCase "a b c" " " nothing "a,b,c" "Split by space"]

    :put "Testing completed."
}

:set TrimStrTest do={
    # Helper function to run a single test case
    :local RunTestCase do={
        :global TrimStrLeft
        :global TrimStrRight
        :global TrimStr

        :local targetFunc [:tostr $1]
        :local str [:tostr $2]
        :local chars [:tostr $3]
        :local expected [:tostr $4]
        :local name [:tostr $5]

        :if ([:len $targetFunc] > 0) do={
            :local actual ""
            :if ($targetFunc = "left")  do={ :set actual [$TrimStrLeft $str $chars] }
            :if ($targetFunc = "right") do={ :set actual [$TrimStrRight $str $chars] }
            :if ($targetFunc = "both")  do={ :set actual [$TrimStr $str $chars] }

            :if ($actual = $expected) do={
                :put ("\1B[32m  [PASS]\1B[0m [" . $targetFunc . "] " . $name . ": '" . $str . "' -> '" . $actual . "'")
            } else={
                :put ("\1B[31m  [FAIL]\1B[0m [" . $targetFunc . "] " . $name . ": '" . $str . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
            }
        }
    }

    :put "Starting TrimStr tests..."

    # ==========================================
    # --- Part 1: TrimStrLeft Tests ---
    # ==========================================
    [$RunTestCase "left" "TrimmedString" "Trng" "immedString" "Example case from description"]
    [$RunTestCase "left" "   hello" " " "hello" "Leading spaces"]
    [$RunTestCase "left" "hello" "xyz" "hello" "No matching trim characters"]
    [$RunTestCase "left" "aaaaab" "a" "b" "Multiple identical characters"]
    [$RunTestCase "left" "abcba" "ab" "cba" "Stop at non-matching character"]
    [$RunTestCase "left" "" "abc" "" "Empty input string"]
    [$RunTestCase "left" "abc" "" "abc" "Empty trim character set"]
    [$RunTestCase "left" "abc" "abc" "" "Trim entire string"]
    [$RunTestCase "left" ("\$" . "\$" . "100") ("\$") "100" "Trim leading dollar signs"]

    # ==========================================
    # --- Part 2: TrimStrRight Tests ---
    # ==========================================
    [$RunTestCase "right" "TrimmedString" "Trng" "TrimmedStri" "Example case from description"]
    [$RunTestCase "right" "hello   " " " "hello" "Trailing spaces"]
    [$RunTestCase "right" "hello" "xyz" "hello" "No matching trim characters"]
    [$RunTestCase "right" "baaaaa" "a" "b" "Multiple identical characters"]
    [$RunTestCase "right" "abcba" "ba" "abc" "Stop at non-matching character"]
    [$RunTestCase "right" "" "abc" "" "Empty input string"]
    [$RunTestCase "right" "abc" "" "abc" "Empty trim character set"]
    [$RunTestCase "right" "abc" "abc" "" "Trim entire string"]
    [$RunTestCase "right" ("100" . "\$" . "\$") ("\$") "100" "Trim trailing dollar signs"]

    # ==========================================
    # --- Part 3: TrimStr (Both Ends) Tests ---
    # ==========================================
    [$RunTestCase "both" "TrimmedString" "Trng" "immedStri" "Example case from description"]
    [$RunTestCase "both" "   hello   " " " "hello" "Spaces on both sides"]
    [$RunTestCase "both" "abc" "xyz" "abc" "No matching trim characters"]
    [$RunTestCase "both" "aaa" "a" "" "Trim entire string consisting of trim chars"]
    [$RunTestCase "both" "abccba" "ab" "cc" "Trim both ends until mismatch"]
    [$RunTestCase "both" ("\$" . "50" . "\$") ("\$") "50" "Trim dollars from both ends"]
    [$RunTestCase "both" ("\\path\\to\\file\\") ("\\") ("path\\to\\file") "Trim leading/trailing backslashes"]
    [$RunTestCase "both" "/path/to/file/" "/" "path/to/file" "Trim leading/trailing slashes"]

    :put "Testing completed."
}

:set ReplaceStrTest do={
    :global ReplaceStr

    # Helper function to run a single test case
    :local RunTestCase do={
        :global ReplaceStr
        :local str [:tostr $1]
        :local from [:tostr $2]
        :local to [:tostr $3]
        :local expected [:tostr $4]
        :local name [:tostr $5]

        :local actual [$ReplaceStr $str $from $to]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $str . "' -> '" . $actual . "'")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $str . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting ReplaceStr tests..."

    # --- Basic Replacements ---
    [$RunTestCase "StringToReplace" "e" "777" "StringToR777plac777" "Example case from description"]
    [$RunTestCase "hello world" "world" "everyone" "hello everyone" "Single full word match"]
    [$RunTestCase "banana" "a" "o" "bonono" "Multiple single-char matches"]

    # --- Edge Cases with Empty Strings ---
    [$RunTestCase "apple" "" "orange" "apple" "Empty 'find' substring (should return original)"]
    [$RunTestCase "apple" "apple" "" "" "Replace entire string with empty string"]
    [$RunTestCase "banana" "a" "" "bnn" "Remove substring (replace with empty string)"]
    [$RunTestCase "" "a" "b" "" "Empty source string"]

    # --- No Match Cases ---
    [$RunTestCase "hello" "x" "y" "hello" "Substring not found"]
    [$RunTestCase "hello" "HELLO" "hi" "hello" "Case sensitive check (no match)"]

    # --- Overlapping & Repeating Patterns ---
    [$RunTestCase "aaaa" "aa" "b" "bb" "Overlapping substrings (aa -> b)"]
    [$RunTestCase "ababaf" "aba" "x" "xbaf" "Partial overlapping match"]
    [$RunTestCase "11111" "1" "1" "11111" "Replacing character with itself"]

    # --- Special Characters & Escapes ---
    [$RunTestCase ("price is " . ("\$") . "100") ("\$") "EUR " "price is EUR 100" "Replace dollar sign"]
    [$RunTestCase ("path\\to\\file") ("\\") "/" "path/to/file" "Replace backslashes to slashes"]
    [$RunTestCase "text with spaces" " " "_" "text_with_spaces" "Replace spaces with underscores"]
    [$RunTestCase "line1,line2,line3" "," ("\n") "line1
line2
line3" "Replace comma with newline"]

    :put "Testing completed."
}

:set RecursiveMergeSortTest do={
    :global RecursiveMergeSort

    # Helper function to run a single test case for numeric array sorting
    :local RunTestCase do={
        :global RecursiveMergeSort
        :local input [:toarray $1]
        :local expected [:toarray $2]
        :local name [:tostr $3]

        # Ensure all elements in the input are treated as numbers
        :local numInput [:toarray ""]
        :foreach item in=$input do={
            :set numInput ($numInput, [:tonum $item])
        }

        :local actual [$RecursiveMergeSort $numInput]

        # Convert arrays to string representation for safe comparison in ROS 6.49
        :local actualStr [:tostr $actual]
        :local expectedStr [:tostr $expected]

        :if ($actualStr = $expectedStr) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": [" . [:tostr $numInput] . "] -> [" . $actualStr . "]")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": [" . [:tostr $numInput] . "] | Expected: [" . $expectedStr . "], Got: [" . $actualStr . "]")
        }
    }

    :put "Starting RecursiveMergeSort (numeric) tests..."

    # --- Edge Cases & Basics ---
    [$RunTestCase "" "" "Empty array"]
    [$RunTestCase "42" "42" "Single element array"]
    [$RunTestCase "7,7,7,7" "7,7,7,7" "Array with identical elements"]
    [$RunTestCase "5,5,1,1,5,1" "1,1,1,5,5,5" "Duplicates mixed up"]

    # --- Standard Numeric Sorting ---
    [$RunTestCase "20,10" "10,20" "Two unsorted numbers"]
    [$RunTestCase "1,2,3,4,5" "1,2,3,4,5" "Already sorted numbers"]
    [$RunTestCase "5,4,3,2,1" "1,2,3,4,5" "Reverse sorted numbers"]
    [$RunTestCase "10,2,1" "1,2,10" "True mathematical sort (1 < 2 < 10)"]
    [$RunTestCase "100,5,20,3,50" "3,5,20,50,100" "Unsorted varying digits"]

    # --- Boundaries and Zero ---
    [$RunTestCase "0,5,0,2" "0,0,2,5" "Sorting with zeros"]
    [$RunTestCase "0,0,0" "0,0,0" "All zeros"]
    [$RunTestCase "9999,1,99,9" "1,9,99,9999" "Large gaps between scales"]

    # --- Shuffled Multi-element Arrays ---
    [$RunTestCase "15,2,48,12,36,4,22" "2,4,12,15,22,36,48" "Seven shuffled numbers"]
    [$RunTestCase "8,1,6,3,7,2,5,4" "1,2,3,4,5,6,7,8" "Eight completely reversed/shuffled numbers"]

    :put "Testing completed."
}

:set RecursiveMergeSortStrTest do={
    :global RecursiveMergeSortStr

    # Helper function to run a single test case for array sorting
    :local RunTestCase do={
        :global RecursiveMergeSortStr
        :local input [:toarray $1]
        :local expected [:toarray $2]
        :local name [:tostr $3]

        :local actual [$RecursiveMergeSortStr $input]

        # Convert arrays to string representation for safe comparison in ROS 6.49
        :local actualStr [:tostr $actual]
        :local expectedStr [:tostr $expected]

        :if ($actualStr = $expectedStr) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": [" . [:tostr $input] . "] -> [" . $actualStr . "]")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": [" . [:tostr $input] . "] | Expected: [" . $expectedStr . "], Got: [" . $actualStr . "]")
        }
    }

    :put "Starting extended RecursiveMergeSortStr tests..."

    # --- Edge Cases & Basics ---
    [$RunTestCase "" "" "Empty array"]
    [$RunTestCase "apple" "apple" "Single element array"]
    [$RunTestCase "apple,apple,apple" "apple,apple,apple" "Array with identical elements"]
    [$RunTestCase "b,b,a,a,b,a" "a,a,a,b,b,b" "Duplicates mixed up"]

    # --- Standard Alphabetical Sorting ---
    [$RunTestCase "banana,apple" "apple,banana" "Two unsorted elements"]
    [$RunTestCase "apple,banana,cherry" "apple,banana,cherry" "Already sorted array"]
    [$RunTestCase "cherry,banana,apple" "apple,banana,cherry" "Reverse sorted array"]
    [$RunTestCase "d,a,c,b" "a,b,c,d" "Four unsorted characters"]
    [$RunTestCase "fox,dog,cat,bird" "bird,cat,dog,fox" "Unsorted words"]

    # --- Prefix & Length Variations ---
    [$RunTestCase "testing,test" "test,testing" "Prefix after long string"]
    [$RunTestCase "test,testing" "test,testing" "Prefix before long string"]
    [$RunTestCase "asdfghjk,asdf,as" "as,asdf,asdfghjk" "Multiple varying lengths of same prefix"]
    [$RunTestCase "abc,ab,a" "a,ab,abc" "Strict reverse prefix order"]

    # --- Case Sensitivity (ASCII: uppercase before lowercase) ---
    [$RunTestCase "banana,Apple,cherry" "Apple,banana,cherry" "One capitalized word"]
    [$RunTestCase "apple,Apple,a" "Apple,a,apple" "Same characters different case"]
    [$RunTestCase "Z,a,A,z" "A,Z,a,z" "Caps vs lowercase boundaries"]
    [$RunTestCase "WORD,word,Word" "WORD,Word,word" "Identical words with different casing"]

    # --- Numbers & Numeric Strings (ASCII character sorting) ---
    [$RunTestCase "10,2,1" "1,10,2" "Numeric strings (1 < 10 < 2)"]
    [$RunTestCase "01,1,00" "00,01,1" "Leading zeros"]
    [$RunTestCase "200,199,3" "199,200,3" "Three digit vs one digit ASCII logic"]

    # --- Special Characters & Spaces (ASCII order criteria) ---
    [$RunTestCase "a b,ab" "a b,ab" "Space vs no space (space is smaller than 'b')"]
    [$RunTestCase "abc,abc " "abc,abc " "Trailing space comparison"]
    [$RunTestCase "abc?,abc!" "abc!,abc?" "Punctuation (! is 33, ? is 63)"]
    [$RunTestCase "under_score,underscore" "under_score,underscore" "Underscore vs regular character"]

    :put "Testing completed."
}

:set ToUpperCaseTest do={
    :global ToUpperCase

    # Helper function to run a single test case
    :local RunTestCase do={
        :global ToUpperCase
        :local input [:tostr $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        :local actual [$ToUpperCase $input]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting ToUpperCase tests..."

    # Basic conversion
    [$RunTestCase "hello" "HELLO" "All lowercase"]
    [$RunTestCase "WORLD" "WORLD" "All uppercase"]
    [$RunTestCase "MikroTik" "MIKROTIK" "Mixed case"]

    # Edge cases
    [$RunTestCase "" "" "Empty string"]
    [$RunTestCase "a" "A" "Single lowercase letter"]
    [$RunTestCase "Z" "Z" "Single uppercase letter"]

    # Numbers and special characters (should remain unchanged)
    [$RunTestCase "12345" "12345" "Digits only"]
    [$RunTestCase "hello 123!" "HELLO 123!" "Lowercase with digits and spaces"]
    [$RunTestCase "abc-def_ghi" "ABC-DEF_GHI" "Lowercase with symbols"]
    [$RunTestCase "ABC-DEF_GHI" "ABC-DEF_GHI" "Uppercase with symbols"]

    :put "Testing completed."
}

:set ToLowerCaseTest do={
    :global ToLowerCase

    # Helper function to run a single test case
    :local RunTestCase do={
        :global ToLowerCase
        :local input [:tostr $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        :local actual [$ToLowerCase $input]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting ToLowerCase tests..."

    # Basic conversion
    [$RunTestCase "HELLO" "hello" "All uppercase"]
    [$RunTestCase "world" "world" "All lowercase"]
    [$RunTestCase "MikroTik" "mikrotik" "Mixed case"]

    # Edge cases
    [$RunTestCase "" "" "Empty string"]
    [$RunTestCase "A" "a" "Single uppercase letter"]
    [$RunTestCase "z" "z" "Single lowercase letter"]

    # Numbers and special characters (should remain unchanged)
    [$RunTestCase "12345" "12345" "Digits only"]
    [$RunTestCase "HELLO 123!" "hello 123!" "Uppercase with digits and spaces"]
    [$RunTestCase "abc-def_ghi" "abc-def_ghi" "Lowercase with symbols"]
    [$RunTestCase "ABC-DEF_GHI" "abc-def_ghi" "Uppercase with symbols"]

    :put "Testing completed."
}

:set HexToCharTest do={
    :global HexToChar

    # Helper function to run a single test case
    :local RunTestCase do={
        :global HexToChar
        :local hexCode [:tostr $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        :local actual [$HexToChar $hexCode]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": Hex " . $hexCode . " -> '" . $actual . "'")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": Hex " . $hexCode . " | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting HexToChar tests..."

    # --- Printable Characters (Standard Ranges) ---
    # Numbers
    [$RunTestCase "30" "0" "Digit 0"]
    [$RunTestCase "39" "9" "Digit 9"]

    # Uppercase letters
    [$RunTestCase "41" "A" "Capital A"]
    [$RunTestCase "5A" "Z" "Capital Z"]

    # Lowercase letters
    [$RunTestCase "61" "a" "Lowercase a"]
    [$RunTestCase "7A" "z" "Lowercase z"]

    # --- Special Characters & Spaces ---
    [$RunTestCase "20" " " "Space character"]
    [$RunTestCase "21" "!" "Exclamation mark"]
    [$RunTestCase "24" ("\$") "Dollar sign"]
    [$RunTestCase "2B" "+" "Plus sign"]
    [$RunTestCase "3D" "=" "Equals sign"]
    [$RunTestCase "40" "@" "At symbol"]
    [$RunTestCase "5F" "_" "Underscore"]

    # --- Control Characters (Whitespace/Escapes) ---
    [$RunTestCase "09" ("\t") "Tab character"]
    [$RunTestCase "0A" ("\n") "Line feed / Newline"]
    [$RunTestCase "0D" ("\r") "Carriage return"]

    # --- Boundaries of 8-bit ASCII / Extended ---
    [$RunTestCase "00" ("\00") "Null byte boundary"]
    [$RunTestCase "7E" "~" "Tilde (Last standard printable)"]
    [$RunTestCase "7F" ("\7F") "Delete control char"]

    :put "Testing completed."
}

:set DecToCharTest do={
    :global DecToChar

    # Helper function to run a single test case with explicit ANSI escape strings
    :local RunTestCase do={
        :global DecToChar
        :local asciiCode [:tonum $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        :local actual [$DecToChar $asciiCode]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": Code " . $asciiCode . " -> '" . $actual . "'")
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": Code " . $asciiCode . " | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting DecToChar tests..."

    # --- Printable Characters (Standard Ranges) ---
    # Numbers
    [$RunTestCase 48 "0" "Digit 0"]
    [$RunTestCase 57 "9" "Digit 9"]

    # Uppercase letters
    [$RunTestCase 65 "A" "Capital A"]
    [$RunTestCase 90 "Z" "Capital Z"]

    # Lowercase letters
    [$RunTestCase 97 "a" "Lowercase a"]
    [$RunTestCase 122 "z" "Lowercase z"]

    # --- Special Characters & Spaces ---
    [$RunTestCase 32 " " "Space character"]
    [$RunTestCase 33 "!" "Exclamation mark"]
    [$RunTestCase 36 ("\$") "Dollar sign"]
    [$RunTestCase 43 "+" "Plus sign"]
    [$RunTestCase 61 "=" "Equals sign"]
    [$RunTestCase 64 "@" "At symbol"]
    [$RunTestCase 95 "_" "Underscore"]

    # --- Control Characters (Whitespace/Escapes) ---
    # Note: ROS 6.49 correctly evaluates standard escape sequences in constants
    [$RunTestCase 9 ("\t") "Tab character"]
    [$RunTestCase 10 ("\n") "Line feed / Newline"]
    [$RunTestCase 13 ("\r") "Carriage return"]

    # --- Boundaries of 8-bit ASCII / Extended ---
    [$RunTestCase 0 ("\00") "Null byte boundary"]
    [$RunTestCase 126 "~" "Tilde (Last standard printable)"]
    [$RunTestCase 127 ("\7F") "Delete control char"]

    :put "Testing completed."
}

:set CompareStrTest do={
    :global CompareStr

    # Helper function to run a single test case with explicit ANSI escape strings
    :local RunTestCase do={
        :global CompareStr
        :local str1 [:tostr $1]
        :local str2 [:tostr $2]
        :local expected [:tonum $3]
        :local name [:tostr $4]

        :local actual [$CompareStr $str1 $str2]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $str1 . "' vs '" . $str2 . "' -> " . $actual)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $str1 . "' vs '" . $str2 . "' | Expected: " . $expected . ", Got: " . $actual)
        }
    }

    :put "Starting CompareStr tests..."

    # --- Edge Cases & Basics ---
    [$RunTestCase "" "" 0 "Both empty"]
    [$RunTestCase "a" "" 1 "First non-empty, second empty"]
    [$RunTestCase "" "a" -1 "First empty, second non-empty"]
    [$RunTestCase "identical" "identical" 0 "Identical long strings"]

    # --- Case Sensitivity (ASCII orders uppercase before lowercase) ---
    [$RunTestCase "Apple" "apple" -1 "Uppercase vs Lowercase start"]
    [$RunTestCase "apple" "Apple" 1 "Lowercase vs Uppercase start"]
    [$RunTestCase "aPple" "apple" -1 "Difference in middle (caps first)"]
    [$RunTestCase "apple" "aPple" 1 "Difference in middle (lowercase first)"]
    [$RunTestCase "A" "a" -1 "Single char Uppercase vs Lowercase"]
    [$RunTestCase "a" "A" 1 "Single char Lowercase vs Uppercase"]
    [$RunTestCase "WORD" "word" -1 "All caps vs all lowercase"]

    # --- Length & Prefixes ---
    [$RunTestCase "test" "testing" -1 "Short prefix vs long string"]
    [$RunTestCase "testing" "test" 1 "Long string vs short prefix"]
    [$RunTestCase "abc" "abcdefgh" -1 "Very short vs very long prefix"]
    [$RunTestCase "abcdefgh" "abc" 1 "Very long vs very short prefix"]

    # --- Standard Alphabetical ---
    [$RunTestCase "abc" "abd" -1 "Last char smaller"]
    [$RunTestCase "abd" "abc" 1 "Last char larger"]
    [$RunTestCase "absolute" "abstract" -1 "Divergence in middle (o vs r)"]

    # --- Numbers & Numeric Strings (ASCII order: '0'-'9') ---
    [$RunTestCase "123" "123" 0 "Identical numbers"]
    [$RunTestCase "123" "124" -1 "Numbers standard order"]
    [$RunTestCase "2" "10" 1 "ASCII comparison vs numeric value (2 > 1)"]
    [$RunTestCase "01" "1" -1 "Leading zero comparison"]

    # --- Special Characters & Spaces (ASCII order: space=32, symbols vary) ---
    [$RunTestCase " " "" 1 "Space vs empty"]
    [$RunTestCase "a b" "ab" -1 "Space vs no space (space is smaller than 'b')"]
    [$RunTestCase "abc" "abc " -1 "String vs string with trailing space"]
    [$RunTestCase "abc!" "abc?" -1 "Special chars (! is 33, ? is 63)"]
    [$RunTestCase "abc" "abc_def" -1 "String vs string with underscore"]

    :put "Testing completed."
}
