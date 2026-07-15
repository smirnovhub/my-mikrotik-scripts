:global RunAllArrayStrTests
:global ParseKeyValueStoreTest
:global JoinArrayTest
:global SplitStrTest
:global TrimStrTest
:global ReplaceStrTest
:global RecursiveMergeSortTest
:global RecursiveMergeSortStrTest
:global DivideIntAndRoundTest
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
    :global DivideIntAndRoundTest
    :global ToUpperCaseTest
    :global ToLowerCaseTest
    :global HexToCharTest
    :global DecToCharTest
    :global CompareStrTest

    :put "\1B[35m=== STARTING ALL ARRAY AND STRING TESTS ===\1B[0m"

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    # Execute all test suites sequentially, passing and updating the same accumulator array
    :set res [$TrimStrTest $res]
    :set res [$SplitStrTest $res]
    :set res [$JoinArrayTest $res]
    :set res [$ReplaceStrTest $res]
    :set res [$ToUpperCaseTest $res]
    :set res [$ToLowerCaseTest $res]
    :set res [$HexToCharTest $res]
    :set res [$DecToCharTest $res]
    :set res [$CompareStrTest $res]
    :set res [$RecursiveMergeSortTest $res]
    :set res [$RecursiveMergeSortStrTest $res]
    :set res [$DivideIntAndRoundTest $res]
    :set res [$ParseKeyValueStoreTest $res]

    :put "\1B[35m=== ALL ARRAY AND STRING TESTS COMPLETED ===\1B[0m"
    
    :return $res
}

:set ParseKeyValueStoreTest do={
    :global ParseKeyValueStore

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global ParseKeyValueStore

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local src $2;        # Can be a string or a real array
        :local delim $3;      # Can be nothing or a string delimiter
        :local expectedStr [:tostr $4]
        :local name [:tostr $5]

        :local actual
        :if ($delim = "nothing") do={
            :set actual [$ParseKeyValueStore $src]
        } else={
            :set actual [$ParseKeyValueStore $src $delim]
        }

        :local actualStr [:tostr $actual]

        :if ($actualStr = $expectedStr) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> [" . $actualStr . "]")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: [" . $expectedStr . "], Got: [" . $actualStr . "]")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting ParseKeyValueStore tests..."

    # --- Basic String Parsing (Space Delimiter) ---
    :set res [$RunTestCase $res "a=1 b=2 c=3" nothing "a=1;b=2;c=3" "Standard space-separated string"]
    :set res [$RunTestCase $res "status=up active=true" nothing "active=true;status=up" "Booleans and text mixing"]

    # --- Custom Delimiters ---
    :set res [$RunTestCase $res "x=10,y=20,z=30" "," "x=10;y=20;z=30" "Comma delimiter"]
    :set res [$RunTestCase $res "proto=tcp;port=80" ";" "port=80;proto=tcp" "Semicolon delimiter"]

    # --- Boolean Type Casting ---
    :set res [$RunTestCase $res "flag1=true flag2=false" nothing "flag1=true;flag2=false" "True and False strings cast to boolean types"]

    # --- Keys Without Values (Flags) ---
    :set res [$RunTestCase $res "disabled force debug=true" nothing "debug=true;disabled=true;force=true" "Implicit true for valueless keys"]

    # --- Parsing Pre-split Arrays ---
    :local inputArr {"foo=bar"; "baz=qux"}
    :set res [$RunTestCase $res $inputArr nothing "baz=qux;foo=bar" "Input as a ready-made array of strings"]

    # --- Edge Cases with Trimming ---
    :set res [$RunTestCase $res "  key1=val1   key2=val2  " nothing "key1=val1;key2=val2" "Spaces around elements (handled by TrimStr)"]
    :set res [$RunTestCase $res "" nothing "" "Empty input string"]

    # --- Special Characters inside Values ---
    :set res [$RunTestCase $res ("url=http://host/path?a=1&b=2") nothing "url=http://host/path?a=1&b=2" "Values containing internal equal signs"]

    # --- Duplicate Keys (Last one should win) ---
    :set res [$RunTestCase $res "user=ivan user=bobro" nothing "user=bobro" "Duplicate keys overwrite previous values"]

    # --- Mixed Delimiters & Empty Elements ---
    :set res [$RunTestCase $res "  a=1    b=2  " nothing "a=1;b=2" "Multiple sequential spaces between pairs"]
    :set res [$RunTestCase $res "x=1,,y=2" "," "x=1;y=2" "Consecutive custom delimiters (empty elements)"]

    # --- No Equals Sign at All (All Keys become Flags) ---
    :set res [$RunTestCase $res "force disabled debug" nothing "debug=true;disabled=true;force=true" "Multiple flags without values"]

    # --- Empty Values (Key with Equals but nothing after) ---
    :set res [$RunTestCase $res "key1= key2=val2" nothing "key1=;key2=val2" "Empty value after equals sign"]

    # --- Complex Strings inside Pre-split Array ---
    :local complexArray {"interface=ether1"; "mac-address=00:11:22:33:44:55"; "comment=LAN port"}
    :set res [$RunTestCase $res $complexArray nothing "comment=LAN port;interface=ether1;mac-address=00:11:22:33:44:55" "Pre-split array with MAC and comments"]

    # --- Delimiter that looks like part of the data ---
    :set res [$RunTestCase $res "foo==bar baz==qux" nothing "baz==qux;foo==bar" "Double equals sign (first split wins)"]

    # --- Arguments Emulation Filtering (Fixes empty trailing variables) ---
    :local simulatedArgs {"ether1=1Gbps"; "ether2=1Gbps"; "ether3=1Gbps"; "ether4=1Gbps"; "ether5=1Gbps"; ""; ""}
    :set res [$RunTestCase $res $simulatedArgs nothing "ether1=1Gbps;ether2=1Gbps;ether3=1Gbps;ether4=1Gbps;ether5=1Gbps" "Five valid interfaces with two empty trailing arguments"]

    :local emptyMiddleArgs {""; "status=up"; ""; "debug"; ""}
    :set res [$RunTestCase $res $emptyMiddleArgs nothing "debug=true;status=up" "Empty elements at start, middle, and end of the array"]

    :local onlyEmptyArgs {""; ""; ""}
    :set res [$RunTestCase $res $onlyEmptyArgs nothing "" "Array containing only empty strings"]

    :put "Testing completed."
    :return $res
}

:set JoinArrayTest do={
    :global JoinArray

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global JoinArray

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        # ROS [:toarray] natively splits strings by comma
        :local arr [:toarray $2]
        :local delim [:tostr $3]
        :local expectedStr [:tostr $4]
        :local name [:tostr $5]

        :local actual [$JoinArray $arr $delim]
        :local actualStr [:tostr $actual]

        :if ($actualStr = $expectedStr) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . $actualStr . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . $expectedStr . "', Got: '" . $actualStr . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting JoinArray tests..."

    # --- Basic Joining ---
    :set res [$RunTestCase $res "1,3,4,2,7,5" "+" "1+3+4+2+7+5" "Example case from description (numbers)"]
    :set res [$RunTestCase $res "apple,banana,cherry" "," "apple,banana,cherry" "Comma separator with strings"]
    :set res [$RunTestCase $res "one,two,three" " / " "one / two / three" "Separator with spaces"]

    # --- Multi-character Separators ---
    :set res [$RunTestCase $res "a,b,c" "::" "a::b::c" "Two-colon separator"]
    :set res [$RunTestCase $res "hello,world" "AND" "helloANDworld" "Word separator"]

    # --- Edge Cases ---
    :set res [$RunTestCase $res "single" "," "single" "Array with a single element"]
    :set res [$RunTestCase $res "" "," "" "Empty array"]
    :set res [$RunTestCase $res "a,b,c" "" "abc" "Empty separator string"]

    # --- Special Characters & Escapes ---
    :set res [$RunTestCase $res "price,100,200" ("\$") ("price\$100\$200") "Join by dollar sign"]
    :set res [$RunTestCase $res "path,to,file" ("\\") ("path\\to\\file") "Join by backslash"]
    :set res [$RunTestCase $res "line1,line2,line3" ("\n") ("line1\nline2\nline3") "Join by newline"]
    :set res [$RunTestCase $res "a,b,c" " " "a b c" "Join by space"]

    :put "Testing completed."
    :return $res
}

:set SplitStrTest do={
    :global SplitStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global SplitStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local str [:tostr $2]
        :local delim [:tostr $3]
        :local limit $4; # Can be nothing or a number
        :local expected [:toarray $5]
        :local name [:tostr $6]

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
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $str . "' del: '" . $delim . "' | Expected: [" . $expectedStr . "], Got: [" . $actualStr . "]")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting SplitStr tests..."

    # --- Basic Splitting ---
    :set res [$RunTestCase $res "1+3+4+2+7+5" "+" nothing "1,3,4,2,7,5" "Example case from description"]
    :set res [$RunTestCase $res "apple,banana,cherry" "," nothing "apple,banana,cherry" "Comma delimiter"]
    :set res [$RunTestCase $res "one/two/three" "/" nothing "one,two,three" "Slash delimiter"]

    # --- Multi-character Delimiters ---
    :set res [$RunTestCase $res "a::b::c" "::" nothing "a,b,c" "Two-colon delimiter"]
    :set res [$RunTestCase $res "helloANDworldANDagain" "AND" nothing "hello,world,again" "Word delimiter"]

    # --- Edge Cases with Delimiters ---
    :set res [$RunTestCase $res "abc" "," nothing "abc" "Delimiter not found (returns original string in array)"]
    :set res [$RunTestCase $res ",abc," "," nothing ",abc," "Leading and trailing delimiters"]
    :set res [$RunTestCase $res "abc,,def" "," nothing "abc,,def" "Consecutive delimiters (creates empty elements)"]
    :set res [$RunTestCase $res "" "," nothing "" "Empty input string"]

    # --- Limit Parameter ($4) Tests ---
    :set res [$RunTestCase $res "a+b+c+d" "+" 2 "a;b+c+d" "Limit to 2 parts (first element and the rest)"]
    :set res [$RunTestCase $res "1.2.3.4.5" "." 3 "1,2,3.4.5" "Limit to 3 parts with dot delimiter"]
    :set res [$RunTestCase $res "one,two" "," 5 "one,two" "Limit greater than total parts available"]
    :set res [$RunTestCase $res "a,b,c" "," 1 "a,b,c" "Limit is 1 (returns original string in array)"]

    # --- Special Characters & Escapes ---
    :set res [$RunTestCase $res ("price " . ("\$") . " 100 " . ("\$") . " 200") ("\$") nothing "price ; 100 ; 200" "Split by dollar sign"]
    :set res [$RunTestCase $res ("path\\to\\file") ("\\") nothing "path,to,file" "Split by backslash"]
    :set res [$RunTestCase $res ("line1\nline2\nline3") ("\n") nothing "line1,line2,line3" "Split by newline"]
    :set res [$RunTestCase $res "a b c" " " nothing "a,b,c" "Split by space"]

    :put "Testing completed."
    :return $res
}

:set TrimStrTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global TrimStrLeft
        :global TrimStrRight
        :global TrimStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local targetFunc [:tostr $2]
        :local str [:tostr $3]
        :local chars [:tostr $4]
        :local expected [:tostr $5]
        :local name [:tostr $6]

        :if ([:len $targetFunc] > 0) do={
            :local actual ""
            :if ($targetFunc = "left")  do={ :set actual [$TrimStrLeft $str $chars] }
            :if ($targetFunc = "right") do={ :set actual [$TrimStrRight $str $chars] }
            :if ($targetFunc = "both")  do={ :set actual [$TrimStr $str $chars] }

            :if ($actual = $expected) do={
                :put ("\1B[32m  [PASS]\1B[0m [" . $targetFunc . "] " . $name . ": '" . $str . "' -> '" . $actual . "'")
                :set ($state->"passed") (($state->"passed") + 1)
            } else={
                :put ("\1B[31m  [FAIL]\1B[0m [" . $targetFunc . "] " . $name . ": '" . $str . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
                :set ($state->"failed") (($state->"failed") + 1)
            }
        }
        :return $state
    }

    :put "Starting TrimStr tests..."

    # --- Part 1: TrimStrLeft Tests ---
    :set res [$RunTestCase $res "left" "TrimmedString" "Trng" "immedString" "Example case from description"]
    :set res [$RunTestCase $res "left" "   hello" " " "hello" "Leading spaces"]
    :set res [$RunTestCase $res "left" "hello" "xyz" "hello" "No matching trim characters"]
    :set res [$RunTestCase $res "left" "aaaaab" "a" "b" "Multiple identical characters"]
    :set res [$RunTestCase $res "left" "abcba" "ab" "cba" "Stop at non-matching character"]
    :set res [$RunTestCase $res "left" "" "abc" "" "Empty input string"]
    :set res [$RunTestCase $res "left" "abc" "" "abc" "Empty trim character set"]
    :set res [$RunTestCase $res "left" "abc" "abc" "" "Trim entire string"]
    :set res [$RunTestCase $res "left" ("\$" . "\$" . "100") ("\$") "100" "Trim leading dollar signs"]

    # --- Part 2: TrimStrRight Tests ---
    :set res [$RunTestCase $res "right" "TrimmedString" "Trng" "TrimmedStri" "Example case from description"]
    :set res [$RunTestCase $res "right" "hello   " " " "hello" "Trailing spaces"]
    :set res [$RunTestCase $res "right" "hello" "xyz" "hello" "No matching trim characters"]
    :set res [$RunTestCase $res "right" "baaaaa" "a" "b" "Multiple identical characters"]
    :set res [$RunTestCase $res "right" "abcba" "ba" "abc" "Stop at non-matching character"]
    :set res [$RunTestCase $res "right" "" "abc" "" "Empty input string"]
    :set res [$RunTestCase $res "right" "abc" "" "abc" "Empty trim character set"]
    :set res [$RunTestCase $res "right" "abc" "abc" "" "Trim entire string"]
    :set res [$RunTestCase $res "right" ("100" . "\$" . "\$") ("\$") "100" "Trim trailing dollar signs"]

    # --- Part 3: TrimStr (Both Ends) Tests ---
    :set res [$RunTestCase $res "both" "TrimmedString" "Trng" "immedStri" "Example case from description"]
    :set res [$RunTestCase $res "both" "   hello   " " " "hello" "Spaces on both sides"]
    :set res [$RunTestCase $res "both" "abc" "xyz" "abc" "No matching trim characters"]
    :set res [$RunTestCase $res "both" "aaa" "a" "" "Trim entire string consisting of trim chars"]
    :set res [$RunTestCase $res "both" "abccba" "ab" "cc" "Trim both ends until mismatch"]
    :set res [$RunTestCase $res "both" ("\$" . "50" . "\$") ("\$") "50" "Trim dollars from both ends"]
    :set res [$RunTestCase $res "both" ("\\path\\to\\file\\") ("\\") ("path\\to\\file") "Trim leading/trailing backslashes"]
    :set res [$RunTestCase $res "both" "/path/to/file/" "/" "path/to/file" "Trim leading/trailing slashes"]

    :put "Testing completed."
    :return $res
}

:set ReplaceStrTest do={
    :global ReplaceStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global ReplaceStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local str [:tostr $2]
        :local from [:tostr $3]
        :local to [:tostr $4]
        :local expected [:tostr $5]
        :local name [:tostr $6]

        :local actual [$ReplaceStr $str $from $to]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $str . "' -> '" . $actual . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $str . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting ReplaceStr tests..."

    # --- Basic Replacements ---
    :set res [$RunTestCase $res "StringToReplace" "e" "777" "StringToR777plac777" "Example case from description"]
    :set res [$RunTestCase $res "hello world" "world" "everyone" "hello everyone" "Single full word match"]
    :set res [$RunTestCase $res "banana" "a" "o" "bonono" "Multiple single-char matches"]

    # --- Edge Cases with Empty Strings ---
    :set res [$RunTestCase $res "apple" "" "orange" "apple" "Empty 'find' substring (should return original)"]
    :set res [$RunTestCase $res "apple" "apple" "" "" "Replace entire string with empty string"]
    :set res [$RunTestCase $res "banana" "a" "" "bnn" "Remove substring (replace with empty string)"]
    :set res [$RunTestCase $res "" "a" "b" "" "Empty source string"]

    # --- No Match Cases ---
    :set res [$RunTestCase $res "hello" "x" "y" "hello" "Substring not found"]
    :set res [$RunTestCase $res "hello" "HELLO" "hi" "hello" "Case sensitive check (no match)"]

    # --- Overlapping & Repeating Patterns ---
    :set res [$RunTestCase $res "aaaa" "aa" "b" "bb" "Overlapping substrings (aa -> b)"]
    :set res [$RunTestCase $res "ababaf" "aba" "x" "xbaf" "Partial overlapping match"]
    :set res [$RunTestCase $res "11111" "1" "1" "11111" "Replacing character with itself"]

    # --- Special Characters & Escapes ---
    :set res [$RunTestCase $res ("price is " . ("\$") . "100") ("\$") "EUR " "price is EUR 100" "Replace dollar sign"]
    :set res [$RunTestCase $res ("path\\to\\file") ("\\") "/" "path/to/file" "Replace backslashes to slashes"]
    :set res [$RunTestCase $res "text with spaces" " " "_" "text_with_spaces" "Replace spaces with underscores"]
    :set res [$RunTestCase $res "line1,line2,line3" "," ("\n") ("line1\nline2\nline3") "Replace comma with newline"]

    :put "Testing completed."
    :return $res
}

:set RecursiveMergeSortTest do={
    :global RecursiveMergeSort

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global RecursiveMergeSort

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local input [:toarray $2]
        :local expected [:toarray $3]
        :local name [:tostr $4]

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
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": [" . [:tostr $numInput] . "] | Expected: [" . $expectedStr . "], Got: [" . $actualStr . "]")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting RecursiveMergeSort (numeric) tests..."

    # --- Edge Cases & Basics ---
    :set res [$RunTestCase $res "" "" "Empty array"]
    :set res [$RunTestCase $res "42" "42" "Single element array"]
    :set res [$RunTestCase $res "7,7,7,7" "7,7,7,7" "Array with identical elements"]
    :set res [$RunTestCase $res "5,5,1,1,5,1" "1,1,1,5,5,5" "Duplicates mixed up"]

    # --- Standard Numeric Sorting ---
    :set res [$RunTestCase $res "20,10" "10,20" "Two unsorted numbers"]
    :set res [$RunTestCase $res "1,2,3,4,5" "1,2,3,4,5" "Already sorted numbers"]
    :set res [$RunTestCase $res "5,4,3,2,1" "1,2,3,4,5" "Reverse sorted numbers"]
    :set res [$RunTestCase $res "10,2,1" "1,2,10" "True mathematical sort (1 < 2 < 10)"]
    :set res [$RunTestCase $res "100,5,20,3,50" "3,5,20,50,100" "Unsorted varying digits"]

    # --- Boundaries and Zero ---
    :set res [$RunTestCase $res "0,5,0,2" "0,0,2,5" "Sorting with zeros"]
    :set res [$RunTestCase $res "0,0,0" "0,0,0" "All zeros"]
    :set res [$RunTestCase $res "9999,1,99,9" "1,9,99,9999" "Large gaps between scales"]

    # --- Shuffled Multi-element Arrays ---
    :set res [$RunTestCase $res "15,2,48,12,36,4,22" "2,4,12,15,22,36,48" "Seven shuffled numbers"]
    :set res [$RunTestCase $res "8,1,6,3,7,2,5,4" "1,2,3,4,5,6,7,8" "Eight completely reversed/shuffled numbers"]

    :put "Testing completed."
    :return $res
}

:set RecursiveMergeSortStrTest do={
    :global RecursiveMergeSortStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global RecursiveMergeSortStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local input [:toarray $2]
        :local expected [:toarray $3]
        :local name [:tostr $4]

        :local actual [$RecursiveMergeSortStr $input]

        # Convert arrays to string representation for safe comparison in ROS 6.49
        :local actualStr [:tostr $actual]
        :local expectedStr [:tostr $expected]

        :if ($actualStr = $expectedStr) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": [" . [:tostr $input] . "] -> [" . $actualStr . "]")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": [" . [:tostr $input] . "] | Expected: [" . $expectedStr . "], Got: [" . $actualStr . "]")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting extended RecursiveMergeSortStr tests..."

    # --- Edge Cases & Basics ---
    :set res [$RunTestCase $res "" "" "Empty array"]
    :set res [$RunTestCase $res "apple" "apple" "Single element array"]
    :set res [$RunTestCase $res "apple,apple,apple" "apple,apple,apple" "Array with identical elements"]
    :set res [$RunTestCase $res "b,b,a,a,b,a" "a,a,a,b,b,b" "Duplicates mixed up"]

    # --- Standard Alphabetical Sorting ---
    :set res [$RunTestCase $res "banana,apple" "apple,banana" "Two unsorted elements"]
    :set res [$RunTestCase $res "apple,banana,cherry" "apple,banana,cherry" "Already sorted array"]
    :set res [$RunTestCase $res "cherry,banana,apple" "apple,banana,cherry" "Reverse sorted array"]
    :set res [$RunTestCase $res "d,a,c,b" "a,b,c,d" "Four unsorted characters"]
    :set res [$RunTestCase $res "fox,dog,cat,bird" "bird,cat,dog,fox" "Unsorted words"]

    # --- Prefix & Length Variations ---
    :set res [$RunTestCase $res "testing,test" "test,testing" "Prefix after long string"]
    :set res [$RunTestCase $res "test,testing" "test,testing" "Prefix before long string"]
    :set res [$RunTestCase $res "asdfghjk,asdf,as" "as,asdf,asdfghjk" "Multiple varying lengths of same prefix"]
    :set res [$RunTestCase $res "abc,ab,a" "a,ab,abc" "Strict reverse prefix order"]

    # --- Case Sensitivity (ASCII: uppercase before lowercase) ---
    :set res [$RunTestCase $res "banana,Apple,cherry" "Apple,banana,cherry" "One capitalized word"]
    :set res [$RunTestCase $res "apple,Apple,a" "Apple,a,apple" "Same characters different case"]
    :set res [$RunTestCase $res "Z,a,A,z" "A,Z,a,z" "Caps vs lowercase boundaries"]
    :set res [$RunTestCase $res "WORD,word,Word" "WORD,Word,word" "Identical words with different casing"]

    # --- Numbers & Numeric Strings (ASCII character sorting) ---
    :set res [$RunTestCase $res "10,2,1" "1,10,2" "Numeric strings (1 < 10 < 2)"]
    :set res [$RunTestCase $res "01,1,00" "00,01,1" "Leading zeros"]
    :set res [$RunTestCase $res "200,199,3" "199,200,3" "Three digit vs one digit ASCII logic"]

    # --- Special Characters & Spaces (ASCII order criteria) ---
    :set res [$RunTestCase $res "a b,ab" "a b,ab" "Space vs no space (space is smaller than 'b')"]
    :set res [$RunTestCase $res "abc,abc " "abc,abc " "Trailing space comparison"]
    :set res [$RunTestCase $res "abc?,abc!" "abc!,abc?" "Punctuation (! is 33, ? is 63)"]
    :set res [$RunTestCase $res "under_score,underscore" "under_score,underscore" "Underscore vs regular character"]

    :put "Testing completed."
    :return $res
}

:set DivideIntAndRoundTest do={
    :global DivideIntAndRound

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global DivideIntAndRound

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local num [:tonum $2]
        :local den [:tonum $3]
        :local places [:tonum $4]
        :local expected [:tostr $5]
        :local name [:tostr $6]

        :local actual [$DivideIntAndRound $num $den $places]
        :if ($actual = $expected) do={
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": " . $num . "/" . $den . " (" . $places . " places) -> '" . $actual . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": " . $num . "/" . $den . " (" . $places . " places) | Expected: '" . $expected . "', Got: '" . $actual . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting DivideIntAndRound decimal precision tests..."

    # Zero decimal places (fallback to rounded integer string)
    :set res [$RunTestCase $res "10" "3" "0" "3" "Round down to integer standard case"]
    :set res [$RunTestCase $res "11" "3" "0" "4" "Round up to integer standard case"]
    :set res [$RunTestCase $res "5" "2" "0" "3" "Round half up boundary to integer"]

    # Division by zero error handling
    :set res [$RunTestCase $res "10" "0" "2" "Division by zero error" "Division by zero guard clause validation"]

    # Exact division with formatting padding validation
    :set res [$RunTestCase $res "4" "2" "3" "2.000" "Exact division with trailing zeros padding"]
    :set res [$RunTestCase $res "0" "5" "2" "0.00" "Zero numerator with decimal places format"]

    # Standard rounding operations (down, up, half-up)
    :set res [$RunTestCase $res "10" "7" "7" "1.4285714" "Example target step documentation case"]
    :set res [$RunTestCase $res "2" "3" "3" "0.667" "Repeating decimal rounding up case"]
    :set res [$RunTestCase $res "1" "3" "3" "0.333" "Repeating decimal rounding down case"]

    # Results strictly smaller than one (leading zero verification)
    :set res [$RunTestCase $res "1" "8" "3" "0.125" "Fraction result with leading zero and exact decimals"]
    :set res [$RunTestCase $res "1" "200" "4" "0.0050" "Small fraction requiring single leading zero inside decimal part"]
    :set res [$RunTestCase $res "1" "2000" "5" "0.00050" "Very small fraction requiring multiple padding zeros"]

    :put "Testing completed."
    :return $res
}

:set ToUpperCaseTest do={
    :global ToUpperCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global ToUpperCase

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local input [:tostr $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local actual [$ToUpperCase $input]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting ToUpperCase tests..."

    # Basic conversion
    :set res [$RunTestCase $res "hello" "HELLO" "All lowercase"]
    :set res [$RunTestCase $res "WORLD" "WORLD" "All uppercase"]
    :set res [$RunTestCase $res "MikroTik" "MIKROTIK" "Mixed case"]

    # Edge cases
    :set res [$RunTestCase $res "" "" "Empty string"]
    :set res [$RunTestCase $res "a" "A" "Single lowercase letter"]
    :set res [$RunTestCase $res "Z" "Z" "Single uppercase letter"]

    # Numbers and special characters (should remain unchanged)
    :set res [$RunTestCase $res "12345" "12345" "Digits only"]
    :set res [$RunTestCase $res "hello 123!" "HELLO 123!" "Lowercase with digits and spaces"]
    :set res [$RunTestCase $res "abc-def_ghi" "ABC-DEF_GHI" "Lowercase with symbols"]
    :set res [$RunTestCase $res "ABC-DEF_GHI" "ABC-DEF_GHI" "Uppercase with symbols"]

    :put "Testing completed."
    :return $res
}

:set ToLowerCaseTest do={
    :global ToLowerCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global ToLowerCase

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local input [:tostr $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local actual [$ToLowerCase $input]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting ToLowerCase tests..."

    # Basic conversion
    :set res [$RunTestCase $res "HELLO" "hello" "All uppercase"]
    :set res [$RunTestCase $res "world" "world" "All lowercase"]
    :set res [$RunTestCase $res "MikroTik" "mikrotik" "Mixed case"]

    # Edge cases
    :set res [$RunTestCase $res "" "" "Empty string"]
    :set res [$RunTestCase $res "A" "a" "Single uppercase letter"]
    :set res [$RunTestCase $res "z" "z" "Single lowercase letter"]

    # Numbers and special characters (should remain unchanged)
    :set res [$RunTestCase $res "12345" "12345" "Digits only"]
    :set res [$RunTestCase $res "HELLO 123!" "hello 123!" "Uppercase with digits and spaces"]
    :set res [$RunTestCase $res "abc-def_ghi" "abc-def_ghi" "Lowercase with symbols"]
    :set res [$RunTestCase $res "ABC-DEF_GHI" "abc-def_ghi" "Uppercase with symbols"]

    :put "Testing completed."
    :return $res
}

:set HexToCharTest do={
    :global HexToChar

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global HexToChar

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local hexCode [:tostr $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local actual [$HexToChar $hexCode]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": Hex " . $hexCode . " -> '" . $actual . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": Hex " . $hexCode . " | Expected: '" . $expected . "', Got: '" . $actual . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting HexToChar tests..."

    # --- Printable Characters (Standard Ranges) ---
    :set res [$RunTestCase $res "30" "0" "Digit 0"]
    :set res [$RunTestCase $res "39" "9" "Digit 9"]
    :set res [$RunTestCase $res "41" "A" "Capital A"]
    :set res [$RunTestCase $res "5A" "Z" "Capital Z"]
    :set res [$RunTestCase $res "61" "a" "Lowercase a"]
    :set res [$RunTestCase $res "7A" "z" "Lowercase z"]

    # --- Special Characters & Spaces ---
    :set res [$RunTestCase $res "20" " " "Space character"]
    :set res [$RunTestCase $res "21" "!" "Exclamation mark"]
    :set res [$RunTestCase $res "24" ("\$") "Dollar sign"]
    :set res [$RunTestCase $res "2B" "+" "Plus sign"]
    :set res [$RunTestCase $res "3D" "=" "Equals sign"]
    :set res [$RunTestCase $res "40" "@" "At symbol"]
    :set res [$RunTestCase $res "5F" "_" "Underscore"]

    # --- Control Characters (Whitespace/Escapes) ---
    :set res [$RunTestCase $res "09" ("\t") "Tab character"]
    :set res [$RunTestCase $res "0A" ("\n") "Line feed / Newline"]
    :set res [$RunTestCase $res "0D" ("\r") "Carriage return"]

    # --- Boundaries of 8-bit ASCII / Extended ---
    :set res [$RunTestCase $res "00" ("\00") "Null byte boundary"]
    :set res [$RunTestCase $res "7E" "~" "Tilde (Last standard printable)"]
    :set res [$RunTestCase $res "7F" ("\7F") "Delete control char"]

    :put "Testing completed."
    :return $res
}

:set DecToCharTest do={
    :global DecToChar

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global DecToChar

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local asciiCode [:tonum $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]

        :local actual [$DecToChar $asciiCode]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": Code " . $asciiCode . " -> '" . $actual . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": Code " . $asciiCode . " | Expected: '" . $expected . "', Got: '" . $actual . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting DecToChar tests..."

    # --- Printable Characters (Standard Ranges) ---
    :set res [$RunTestCase $res 48 "0" "Digit 0"]
    :set res [$RunTestCase $res 57 "9" "Digit 9"]
    :set res [$RunTestCase $res 65 "A" "Capital A"]
    :set res [$RunTestCase $res 90 "Z" "Capital Z"]
    :set res [$RunTestCase $res 97 "a" "Lowercase a"]
    :set res [$RunTestCase $res 122 "z" "Lowercase z"]

    # --- Special Characters & Spaces ---
    :set res [$RunTestCase $res 32 " " "Space character"]
    :set res [$RunTestCase $res 33 "!" "Exclamation mark"]
    :set res [$RunTestCase $res 36 ("\$") "Dollar sign"]
    :set res [$RunTestCase $res 43 "+" "Plus sign"]
    :set res [$RunTestCase $res 61 "=" "Equals sign"]
    :set res [$RunTestCase $res 64 "@" "At symbol"]
    :set res [$RunTestCase $res 95 "_" "Underscore"]

    # --- Control Characters (Whitespace/Escapes) ---
    :set res [$RunTestCase $res 9 ("\t") "Tab character"]
    :set res [$RunTestCase $res 10 ("\n") "Line feed / Newline"]
    :set res [$RunTestCase $res 13 ("\r") "Carriage return"]

    # --- Boundaries of 8-bit ASCII / Extended ---
    :set res [$RunTestCase $res 0 ("\00") "Null byte boundary"]
    :set res [$RunTestCase $res 126 "~" "Tilde (Last standard printable)"]
    :set res [$RunTestCase $res 127 ("\7F") "Delete control char"]

    :put "Testing completed."
    :return $res
}

:set CompareStrTest do={
    :global CompareStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
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
