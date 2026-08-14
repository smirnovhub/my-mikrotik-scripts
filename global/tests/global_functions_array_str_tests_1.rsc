:global RunAllArrayStrTests1
:global ParseKeyValueStoreTest
:global RandomTest
:global HexToNumTest
:global MapArrayTest
:global JoinArrayTest
:global SplitStrTest
:global TrimStrTest
:global ReplaceStrTest
:global RecursiveMergeSortTest
:global RecursiveMergeSortStrTest

:set RunAllArrayStrTests1 do={
    :global InitTestCaseState
    :global ParseKeyValueStoreTest
    :global RandomTest
    :global HexToNumTest
    :global MapArrayTest
    :global JoinArrayTest
    :global SplitStrTest
    :global TrimStrTest
    :global ReplaceStrTest
    :global RecursiveMergeSortTest
    :global RecursiveMergeSortStrTest

    :put "\1B[35m=== STARTING ALL ARRAY AND STRING TESTS 1 ===\1B[0m"

    :local res [$InitTestCaseState ]

    # Execute all test suites sequentially, passing and updating the same accumulator array
    :set res [$TrimStrTest $res]
    :set res [$SplitStrTest $res]
    :set res [$HexToNumTest $res]
    :set res [$MapArrayTest $res]
    :set res [$JoinArrayTest $res]
    :set res [$ReplaceStrTest $res]
    :set res [$RecursiveMergeSortTest $res]
    :set res [$RecursiveMergeSortStrTest $res]

    :set res [$ParseKeyValueStoreTest $res]
    :set res [$RandomTest $res]

    :put "\1B[35m=== ALL ARRAY AND STRING TESTS 1 COMPLETED ===\1B[0m"

    :return $res
}

:set ParseKeyValueStoreTest do={
    :global InitTestCaseState
    :global ParseKeyValueStore
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting ParseKeyValueStore tests..."

    # Basic String Parsing (Space Delimiter)
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "a=1 b=2 c=3" "nothing" "nothing" "a=1;b=2;c=3" "Standard space-separated string"]
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "status=up active=true" "nothing" "nothing" "active=true;status=up" "Booleans and text mixing"]

    # Custom Delimiters
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "x=10,y=20,z=30" (",") "nothing" "x=10;y=20;z=30" "Comma delimiter"]
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "proto=tcp;port=80" (";") "nothing" "port=80;proto=tcp" "Semicolon delimiter"]

    # Boolean Type Casting
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "flag1=true flag2=false" "nothing" "nothing" "flag1=true;flag2=false" "True and False strings cast to boolean types"]

    # Keys Without Values (Flags)
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "disabled force debug=true" "nothing" "nothing" "debug=true;disabled=true;force=true" "Implicit true for valueless keys"]

    # Parsing Pre-split Arrays
    :local inputArr {"foo=bar"; "baz=qux"}
    :set res [$RunGenericTestCase $res $ParseKeyValueStore $inputArr "nothing" "nothing" "baz=qux;foo=bar" "Input as a ready-made array of strings"]

    # Edge Cases with Trimming
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "  key1=val1   key2=val2  " "nothing" "nothing" "key1=val1;key2=val2" "Spaces around elements (handled by TrimStr)"]
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "" "nothing" "nothing" "" "Empty input string"]

    # Special Characters inside Values
    :set res [$RunGenericTestCase $res $ParseKeyValueStore ("url=http://host/path?a=1&b=2") "nothing" "nothing" "url=http://host/path?a=1&b=2" "Values containing internal equal signs"]

    # Duplicate Keys (Last one should win)
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "user=ivan user=bobro" "nothing" "nothing" "user=bobro" "Duplicate keys overwrite previous values"]

    # Mixed Delimiters & Empty Elements
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "  a=1    b=2  " "nothing" "nothing" "a=1;b=2" "Multiple sequential spaces between pairs"]
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "x=1,,y=2" (",") "nothing" "x=1;y=2" "Consecutive custom delimiters (empty elements)"]

    # No Equals Sign at All (All Keys become Flags)
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "force disabled debug" "nothing" "nothing" "debug=true;disabled=true;force=true" "Multiple flags without values"]

    # Empty Values (Key with Equals but nothing after)
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "key1= key2=val2" "nothing" "nothing" "key1=;key2=val2" "Empty value after equals sign"]

    # Complex Strings inside Pre-split Array
    :local complexArray {"interface=ether1"; "mac-address=00:11:22:33:44:55"; "comment=LAN port"}
    :set res [$RunGenericTestCase $res $ParseKeyValueStore $complexArray "nothing" "nothing" "comment=LAN port;interface=ether1;mac-address=00:11:22:33:44:55" "Pre-split array with MAC and comments"]

    # Delimiter that looks like part of the data
    :set res [$RunGenericTestCase $res $ParseKeyValueStore "foo==bar baz==qux" "nothing" "nothing" "baz==qux;foo==bar" "Double equals sign (first split wins)"]

    # Arguments Emulation Filtering (Fixes empty trailing variables)
    :local simulatedArgs {"ether1=1Gbps"; "ether2=1Gbps"; "ether3=1Gbps"; "ether4=1Gbps"; "ether5=1Gbps"; ""; ""}
    :set res [$RunGenericTestCase $res $ParseKeyValueStore $simulatedArgs "nothing" "nothing" "ether1=1Gbps;ether2=1Gbps;ether3=1Gbps;ether4=1Gbps;ether5=1Gbps" "Five valid interfaces with two empty trailing arguments"]

    :local emptyMiddleArgs {""; "status=up"; ""; "debug"; ""}
    :set res [$RunGenericTestCase $res $ParseKeyValueStore $emptyMiddleArgs "nothing" "nothing" "debug=true;status=up" "Empty elements at start, middle, and end of the array"]

    :local onlyEmptyArgs {""; ""; ""}
    :set res [$RunGenericTestCase $res $ParseKeyValueStore $onlyEmptyArgs "nothing" "nothing" "" "Array containing only empty strings"]

    :put "Testing completed."
    :return $res
}

:set RandomTest do={
    :global InitTestCaseState
    :global RunGenericTestCase
    :global GetRandom20CharHex
    :global GetRandomNumber
    :global IsPrintableStr

    :local res [$InitTestCaseState ]

    :put "Starting Randomness & Generation tests..."

    # Helper anonymous closures for dynamic evaluations
    :local EvalHexLen do={ :global GetRandom20CharHex; :return [:len [$GetRandom20CharHex]] }
    :local EvalHexPrintable do={ :global GetRandom20CharHex; :global IsPrintableStr; :return [$IsPrintableStr [$GetRandom20CharHex]] }

    # GetRandom20CharHex Tests

    # Verify exact string length
    :set res [$RunGenericTestCase $res $EvalHexLen "nothing" "nothing" "nothing" 20 "Verify random hex string length is exactly 20 chars"]

    :local lenOk true
    :for i from=1 to=100 do={
        :local s [$GetRandom20CharHex]
        :if ([:len $s] != 20) do={ :set lenOk false }
    }
    :local EvalLen100 do={ :return $1 }
    :set res [$RunGenericTestCase $res $EvalLen100 $lenOk "nothing" "nothing" true "Verify 100 generated hex strings have correct length"]

    # Verify it contains only printable characters
    :set res [$RunGenericTestCase $res $EvalHexPrintable "nothing" "nothing" "nothing" true "Verify random hex string consists only of printable characters"]

    # Uniqueness check (two consecutive calls must not yield the exact same string)
    :local hexStr1 [$GetRandom20CharHex]
    :local hexStr2 [$GetRandom20CharHex]
    :local EvalUnique do={ :return ($1 != $2) }
    :set res [$RunGenericTestCase $res $EvalUnique $hexStr1 $hexStr2 "nothing" true "Verify consecutive SCEP OTP calls produce unique tokens"]

    :local generated [:toarray ""]
    :local unique true
    :for i from=1 to=100 do={
        :local s [$GetRandom20CharHex]
        :if ([:typeof ($generated->$s)] != "nothing") do={ :set unique false }
        :set ($generated->$s) true
    }
    :set res [$RunGenericTestCase $res $EvalLen100 $unique "nothing" "nothing" true "Verify no duplicate hex strings in 100 generations"]

    # Hexadecimal character validation
    :local validHex "0123456789abcdefABCDEF"
    :local isStrictHex true
    :local testHex [$GetRandom20CharHex]
    :for i from=0 to=19 do={
        :local char [:pick $testHex $i]
        :if ([:find $validHex $char] < 0) do={ :set isStrictHex false }
    }
    :set res [$RunGenericTestCase $res $EvalLen100 $isStrictHex "nothing" "nothing" true "Verify random string contains only valid hexadecimal characters"]

    # GetRandomNumber Bounds Tests

    # Default behavior (no arguments passed)
    :local numDefault [$GetRandomNumber]
    :local withinDefaultRange ($numDefault >= 0 && $numDefault <= 4294967295)
    :set res [$RunGenericTestCase $res $EvalLen100 $withinDefaultRange "nothing" "nothing" true "Verify default random number is within 32-bit unsigned range"]

    # Custom maximum boundary (range 0 to 9)
    :local maxTen 10
    :local numTen [$GetRandomNumber ($maxTen - 1)]
    :local withinTenRange ($numTen >= 0 && $numTen < $maxTen)
    :set res [$RunGenericTestCase $res $EvalLen100 $withinTenRange "nothing" "nothing" true "Verify random number is within custom range [0, 9]"]

    # Extremely narrow boundary (range 0 to 1)
    :local maxTwo 2
    :local numTwo [$GetRandomNumber ($maxTwo - 1)]
    :local withinTwoRange ($numTwo >= 0 && $numTwo < $maxTwo)
    :set res [$RunGenericTestCase $res $EvalLen100 $withinTwoRange "nothing" "nothing" true "Verify binary random boundary [0, 1]"]
    :set res [$RunGenericTestCase $res $GetRandomNumber 0 "nothing" "nothing" 0 "Verify max=0 always returns 0"]

    # Distribution & Multi-run Validation

    # Running a loop to ensure dynamic changes and boundaries hold over multiple iterations
    :local distributionPass true
    :for i from=1 to=50 do={
        :local val [$GetRandomNumber 99]
        :if ($val < 0 || $val > 99) do={ :set distributionPass false }
    }
    :set res [$RunGenericTestCase $res $EvalLen100 $distributionPass "nothing" "nothing" true "Verify 50 consecutive iterations respect bounds [0, 99]"]

    # Verify approximate uniform distribution for range [0,9]
    :local buckets [:toarray ""]
    :for i from=0 to=9 do={ :set ($buckets->$i) 0 }
    :for i from=1 to=1000 do={
        :local value [$GetRandomNumber 9]
        :set ($buckets->$value) (($buckets->$value) + 1)
    }

    :local distributionOk true
    :for i from=0 to=9 do={
        :local count ($buckets->$i)
        :if (($count < 60) || ($count > 140)) do={ :set distributionOk false }
    }
    :set res [$RunGenericTestCase $res $EvalLen100 $distributionOk "nothing" "nothing" true "Verify approximate uniform distribution over range [0,9]"]

    # Optional: print histogram
    :put "Distribution:"
    :for i from=0 to=9 do={ :put ("  " . $i . ": " . ($buckets->$i)) }

    :put "Testing completed."
    :return $res
}

:set HexToNumTest do={
    :global InitTestCaseState
    :global HexToNum
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting HexToNum tests..."

    # Basic Single Digit Tests
    :set res [$RunGenericTestCase $res $HexToNum "0" "nothing" "nothing" 0 "Zero case"]
    :set res [$RunGenericTestCase $res $HexToNum "5" "nothing" "nothing" 5 "Single low digit"]
    :set res [$RunGenericTestCase $res $HexToNum "9" "nothing" "nothing" 9 "Single high digit"]

    # Letter Digits (Case Sensitivity)
    :set res [$RunGenericTestCase $res $HexToNum "a" "nothing" "nothing" 10 "Lowercase A"]
    :set res [$RunGenericTestCase $res $HexToNum "A" "nothing" "nothing" 10 "Uppercase A"]
    :set res [$RunGenericTestCase $res $HexToNum "f" "nothing" "nothing" 15 "Lowercase F"]
    :set res [$RunGenericTestCase $res $HexToNum "F" "nothing" "nothing" 15 "Uppercase F"]

    # Multi-digit Numbers
    :set res [$RunGenericTestCase $res $HexToNum "10" "nothing" "nothing" 16 "Hex sixteen"]
    :set res [$RunGenericTestCase $res $HexToNum "1A" "nothing" "nothing" 26 "Mixed digits and uppercase"]
    :set res [$RunGenericTestCase $res $HexToNum "ff" "nothing" "nothing" 255 "Max byte lowercase"]
    :set res [$RunGenericTestCase $res $HexToNum "FF" "nothing" "nothing" 255 "Max byte uppercase"]

    # Complex Mixed Case & Large Values
    :set res [$RunGenericTestCase $res $HexToNum "7aB4" "nothing" "nothing" 31412 "Mixed case complex string"]
    :set res [$RunGenericTestCase $res $HexToNum "1000" "nothing" "nothing" 4096 "Power of sixteen"]
    :set res [$RunGenericTestCase $res $HexToNum "FFFF" "nothing" "nothing" 65535 "Two byte max value"]

    # Edge Cases
    :set res [$RunGenericTestCase $res $HexToNum "" "nothing" "nothing" nil "Empty input string"]

    # Leading Zeros
    :set res [$RunGenericTestCase $res $HexToNum "000" "nothing" "nothing" 0 "Multiple zeros"]
    :set res [$RunGenericTestCase $res $HexToNum "00FF" "nothing" "nothing" 255 "Leading zeros with value"]
    :set res [$RunGenericTestCase $res $HexToNum "01" "nothing" "nothing" 1 "Single leading zero"]

    # Large Values (32-bit & 64-bit Boundaries)
    :set res [$RunGenericTestCase $res $HexToNum "7FFFFFFF" "nothing" "nothing" 2147483647 "Max signed 32-bit integer"]
    :set res [$RunGenericTestCase $res $HexToNum "80000000" "nothing" "nothing" 2147483648 "Boundary above 32-bit signed"]
    :set res [$RunGenericTestCase $res $HexToNum "FFFFFFFF" "nothing" "nothing" 4294967295 "Max unsigned 32-bit integer"]
    :set res [$RunGenericTestCase $res $HexToNum "100000000" "nothing" "nothing" 4294967296 "Value requiring 64-bit storage"]

    # Alternative Input Formats (Type Conversion)
    # Prefix handling check (Note: if function does not strip 0x, actual value will be wrong)
    :set res [$RunGenericTestCase $res $HexToNum "0x1A" "nothing" "nothing" nil "Prefix handling check"]

    # Invalid Hex Characters (Robustness Check)
    # Note: Depending on the HexToNum logic, invalid characters like 'G' or 'Z'
    # might cause fallback behavior, negative values, or return 0.
    :set res [$RunGenericTestCase $res $HexToNum "G" "nothing" "nothing" nil "Invalid single letter"]
    :set res [$RunGenericTestCase $res $HexToNum "1Z" "nothing" "nothing" nil "Invalid trailing character"]

    :put "Testing completed."
    :return $res
}

:set MapArrayTest do={
    :global InitTestCaseState
    :global MapArray
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting MapArray tests..."

    # Helper Transformation Functions for Testing
    :local square do={ :return ($v * $v) }
    :local identity do={ :return $v }
    :local useKeyOnly do={ :return ("key_" . $n) }
    :local concatString do={ :return ($v . "_suffix") }
    :local stringifyAll do={ :return [:tostr $v] }
    :local invertBool do={ :return (!$v) }
    :local decrementOffset do={ :return ($v - 1) }
    :local doubleValue do={ :return ($v * 2) }
    :local clearValue do={ :return 0 }
    :local combine do={ :return ($n . "=" . $v) }

    # Basic Indexed Array Tests
    :set res [$RunGenericTestCase $res $MapArray ({7; 5; 10}) $square "nothing" ({49; 25; 100}) "Square numbers in indexed array"]
    :set res [$RunGenericTestCase $res $MapArray ({"apple"; "banana"}) $concatString "nothing" ({"apple_suffix"; "banana_suffix"}) "Concatenate strings in indexed array"]

    # Associative Array (Map) Tests
    :set res [$RunGenericTestCase $res $MapArray ({a=4; b=7; c=15}) $square "nothing" ({a=16; b=49; c=225}) "Square values in associative map"]
    :set res [$RunGenericTestCase $res $MapArray ({host="mikrotik"; ip="10.0.0.1"}) $concatString "nothing" ({host="mikrotik_suffix"; ip="10.0.0.1_suffix"}) "Modify string values in associative map"]

    # Tests Using Key Parameter ($n) & Edge Cases
    :set res [$RunGenericTestCase $res $MapArray ({first=""; second=""}) $useKeyOnly "nothing" ({first="key_first"; second="key_second"}) "Transform values using their array keys"]
    :set res [$RunGenericTestCase $res $MapArray ({}) $square "nothing" ({}) "Empty array input"]
    :set res [$RunGenericTestCase $res $MapArray ({x=10}) $identity "nothing" ({x=10}) "Single element array with identity function"]

    # Mixed Types in Array
    # Testing how the function handles an array containing different types simultaneously
    :set res [$RunGenericTestCase $res $MapArray ({num=42; text="status"; logic=true}) $stringifyAll "nothing" ({num="42"; text="status"; logic="true"}) "Convert mixed data types to strings"]

    # Boolean Inversion
    # Testing logical inversion of boolean values within a map
    :set res [$RunGenericTestCase $res $MapArray ({up=true; down=false; active=true}) $invertBool "nothing" ({up=false; down=true; active=false}) "Invert boolean states"]

    # Numeric Offset Modification
    # Testing mathematical adjustments (subtraction/addition) on metrics
    :set res [$RunGenericTestCase $res $MapArray ({port1=81; port2=82; port3=444}) $decrementOffset "nothing" ({port1=80; port2=81; port3=443}) "Apply negative offset to port numbers"]

    # Numeric Keys Handling
    # Testing that keys explicitly defined as numbers are processed correctly without being converted or lost
    :set res [$RunGenericTestCase $res $MapArray ({10=5; 20=15}) $doubleValue "nothing" ({10=10; 20=30}) "Process map with explicitly numeric keys"]

    # Extreme Values Handling
    # Testing map execution with huge numbers and special string formats
    :set res [$RunGenericTestCase $res $MapArray ({"maxInt"=2147483647; "hexStr"="7"}) $clearValue "nothing" ({"maxInt"=0; "hexStr"=0}) "Reset complex or large value formats to zero"]

    # Simultaneous Key and Value Usage
    # Testing that the transformation function can correctly access and combine
    # both the current key ($n) and its corresponding value ($v) during mapping
    :set res [$RunGenericTestCase $res $MapArray ({a=10; b=20}) $combine "nothing" ({a="a=10"; b="b=20"}) "Use both key and value"]

    :put "Testing completed."
    :return $res
}

:set JoinArrayTest do={
    :global InitTestCaseState
    :global JoinArray
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting JoinArray tests..."

    # Basic Joining
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "1,3,4,2,7,5"] "+" "nothing" "1+3+4+2+7+5" "Example case from description (numbers)"]
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "apple,banana,cherry"] (",") "nothing" "apple,banana,cherry" "Comma separator with strings"]
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "one,two,three"] " / " "nothing" "one / two / three" "Separator with spaces"]

    # Multi-character Separators
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "a,b,c"] "::" "nothing" "a::b::c" "Two-colon separator"]
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "hello,world"] "AND" "nothing" "helloANDworld" "Word separator"]

    # Edge Cases
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "single"] (",") "nothing" "single" "Array with a single element"]
    :set res [$RunGenericTestCase $res $JoinArray [:toarray ""] (",") "nothing" "" "Empty array"]
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "a,b,c"] "" "nothing" "abc" "Empty separator string"]

    # Special Characters & Escapes
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "price,100,200"] ("\$") "nothing" ("price\$100\$200") "Join by dollar sign"]
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "path,to,file"] ("\\") "nothing" ("path\\to\\file") "Join by backslash"]
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "line1,line2,line3"] ("\n") "nothing" ("line1\nline2\nline3") "Join by newline"]
    :set res [$RunGenericTestCase $res $JoinArray [:toarray "a,b,c"] " " "nothing" "a b c" "Join by space"]

    :put "Testing completed."
    :return $res
}

:set SplitStrTest do={
    :global InitTestCaseState
    :global SplitStr
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting SplitStr tests..."

    # Basic Splitting
    :set res [$RunGenericTestCase $res $SplitStr "1+3+4+2+7+5" "+" "nothing" "1;3;4;2;7;5" "Example case from description"]
    :set res [$RunGenericTestCase $res $SplitStr "apple,banana,cherry" (",") "nothing" "apple;banana;cherry" "Comma delimiter"]
    :set res [$RunGenericTestCase $res $SplitStr "one/two/three" "/" "nothing" "one;two;three" "Slash delimiter"]

    # Multi-character Delimiters
    :set res [$RunGenericTestCase $res $SplitStr "a::b::c" "::" "nothing" "a;b;c" "Two-colon delimiter"]
    :set res [$RunGenericTestCase $res $SplitStr "helloANDworldANDagain" "AND" "nothing" "hello;world;again" "Word delimiter"]

    # Edge Cases with Delimiters
    :set res [$RunGenericTestCase $res $SplitStr "abc" (",") "nothing" "abc" "Delimiter not found (returns original string in array)"]
    :set res [$RunGenericTestCase $res $SplitStr ",abc," (",") "nothing" "abc" "Leading and trailing delimiters"]
    :set res [$RunGenericTestCase $res $SplitStr "abc,,def" (",") "nothing" "abc;def" "Consecutive delimiters (creates empty elements)"]
    :set res [$RunGenericTestCase $res $SplitStr "" (",") "nothing" "" "Empty input string"]

    # Limit Parameter ($3) Tests
    :set res [$RunGenericTestCase $res $SplitStr "a+b+c+d" "+" 2 "a;b+c+d" "Limit to 2 parts (first element and the rest)"]
    :set res [$RunGenericTestCase $res $SplitStr "1.2.3.4.5" "." 3 "1;2;3.4.5" "Limit to 3 parts with dot delimiter"]
    :set res [$RunGenericTestCase $res $SplitStr "one,two" (",") 5 "one;two" "Limit greater than total parts available"]
    :set res [$RunGenericTestCase $res $SplitStr "a,b,c" (",") 1 "a,b,c" "Limit is 1 (returns original string in array)"]

    # Special Characters & Escapes
    :set res [$RunGenericTestCase $res $SplitStr ("price " . ("\$") . " 100 " . ("\$") . " 200") ("\$") "nothing" "price ; 100 ; 200" "Split by dollar sign"]
    :set res [$RunGenericTestCase $res $SplitStr ("path\\to\\file") ("\\") "nothing" "path;to;file" "Split by backslash"]
    :set res [$RunGenericTestCase $res $SplitStr ("line1\nline2\nline3") ("\n") "nothing" "line1;line2;line3" "Split by newline"]
    :set res [$RunGenericTestCase $res $SplitStr "a b c" " " "nothing" "a;b;c" "Split by space"]

    :put "Testing completed."
    :return $res
}

:set TrimStrTest do={
    :global InitTestCaseState
    :global TrimStrLeft
    :global TrimStrRight
    :global TrimStr
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting TrimStr tests..."

    # TrimStrLeft Tests
    :set res [$RunGenericTestCase $res $TrimStrLeft "TrimmedString" "Trng" "nothing" "immedString" "Example case from description"]
    :set res [$RunGenericTestCase $res $TrimStrLeft ("\r\n\t TrStr\r\n\t ") "" "nothing" ("TrStr\r\n\t ") "Trim without parameters"]
    :set res [$RunGenericTestCase $res $TrimStrLeft "   hello" " " "nothing" "hello" "Leading spaces"]
    :set res [$RunGenericTestCase $res $TrimStrLeft "hello" "xyz" "nothing" "hello" "No matching trim characters"]
    :set res [$RunGenericTestCase $res $TrimStrLeft "aaaaab" "a" "nothing" "b" "Multiple identical characters"]
    :set res [$RunGenericTestCase $res $TrimStrLeft "abcba" "ab" "nothing" "cba" "Stop at non-matching character"]
    :set res [$RunGenericTestCase $res $TrimStrLeft "" "abc" "nothing" "" "Empty input string"]
    :set res [$RunGenericTestCase $res $TrimStrLeft "abc" "" "nothing" "abc" "Empty trim character set"]
    :set res [$RunGenericTestCase $res $TrimStrLeft "abc" "abc" "nothing" "" "Trim entire string"]
    :set res [$RunGenericTestCase $res $TrimStrLeft ("\$" . "\$" . "100") ("\$") "nothing" "100" "Trim leading dollar signs"]

    # TrimStrRight Tests
    :set res [$RunGenericTestCase $res $TrimStrRight "TrimmedString" "Trng" "nothing" "TrimmedStri" "Example case from description"]
    :set res [$RunGenericTestCase $res $TrimStrRight ("\r\n\t TrStr\r\n\t ") "" "nothing" ("\r\n\t TrStr") "Trim without parameters"]
    :set res [$RunGenericTestCase $res $TrimStrRight "hello   " " " "nothing" "hello" "Trailing spaces"]
    :set res [$RunGenericTestCase $res $TrimStrRight "hello" "xyz" "nothing" "hello" "No matching trim characters"]
    :set res [$RunGenericTestCase $res $TrimStrRight "baaaaa" "a" "nothing" "b" "Multiple identical characters"]
    :set res [$RunGenericTestCase $res $TrimStrRight "abcba" "ba" "nothing" "abc" "Stop at non-matching character"]
    :set res [$RunGenericTestCase $res $TrimStrRight "" "abc" "nothing" "" "Empty input string"]
    :set res [$RunGenericTestCase $res $TrimStrRight "abc" "" "nothing" "abc" "Empty trim character set"]
    :set res [$RunGenericTestCase $res $TrimStrRight "abc" "abc" "nothing" "" "Trim entire string"]
    :set res [$RunGenericTestCase $res $TrimStrRight ("100" . "\$" . "\$") ("\$") "nothing" "100" "Trim trailing dollar signs"]

    # TrimStr (Both Ends) Tests
    :set res [$RunGenericTestCase $res $TrimStr "TrimmedString" "Trng" "nothing" "immedStri" "Example case from description"]
    :set res [$RunGenericTestCase $res $TrimStr ("\r\n\t TrStr\r\n\t ") "" "nothing" "TrStr" "Trim without parameters"]
    :set res [$RunGenericTestCase $res $TrimStr "   hello   " " " "nothing" "hello" "Spaces on both sides"]
    :set res [$RunGenericTestCase $res $TrimStr "abc" "xyz" "nothing" "abc" "No matching trim characters"]
    :set res [$RunGenericTestCase $res $TrimStr "aaa" "a" "nothing" "" "Trim entire string consisting of trim chars"]
    :set res [$RunGenericTestCase $res $TrimStr "abccba" "ab" "nothing" "cc" "Trim both ends until mismatch"]
    :set res [$RunGenericTestCase $res $TrimStr ("\$" . "50" . "\$") ("\$") "nothing" "50" "Trim dollars from both ends"]
    :set res [$RunGenericTestCase $res $TrimStr ("\\path\\to\\file\\") ("\\") "nothing" ("path\\to\\file") "Trim leading/trailing backslashes"]
    :set res [$RunGenericTestCase $res $TrimStr "/path/to/file/" "/" "nothing" "path/to/file" "Trim leading/trailing slashes"]

    :put "Testing completed."
    :return $res
}

:set ReplaceStrTest do={
    :global InitTestCaseState
    :global ReplaceStr
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting ReplaceStr tests..."

    # Basic Replacements
    :set res [$RunGenericTestCase $res $ReplaceStr "StringToReplace" "e" "777" "StringToR777plac777" "Example case from description"]
    :set res [$RunGenericTestCase $res $ReplaceStr "hello world" "world" "everyone" "hello everyone" "Single full word match"]
    :set res [$RunGenericTestCase $res $ReplaceStr "banana" "a" "o" "bonono" "Multiple single-char matches"]

    # Edge Cases with Empty Strings
    :set res [$RunGenericTestCase $res $ReplaceStr "apple" "" "orange" "apple" "Empty 'find' substring (should return original)"]
    :set res [$RunGenericTestCase $res $ReplaceStr "apple" "apple" "" "" "Replace entire string with empty string"]
    :set res [$RunGenericTestCase $res $ReplaceStr "banana" "a" "" "bnn" "Remove substring (replace with empty string)"]
    :set res [$RunGenericTestCase $res $ReplaceStr "" "a" "b" "" "Empty source string"]

    # No Match Cases & Overlapping Patterns
    :set res [$RunGenericTestCase $res $ReplaceStr "hello" "x" "y" "hello" "Substring not found"]
    :set res [$RunGenericTestCase $res $ReplaceStr "hello" "HELLO" "hi" "hello" "Case sensitive check (no match)"]
    :set res [$RunGenericTestCase $res $ReplaceStr "aaaa" "aa" "b" "bb" "Overlapping substrings (aa -> b)"]
    :set res [$RunGenericTestCase $res $ReplaceStr "ababaf" "aba" "x" "xbaf" "Partial overlapping match"]
    :set res [$RunGenericTestCase $res $ReplaceStr "11111" "1" "1" "11111" "Replacing character with itself"]

    # Special Characters & Escapes
    :set res [$RunGenericTestCase $res $ReplaceStr ("price is " . ("\$") . "100") ("\$") "EUR " "price is EUR 100" "Replace dollar sign"]
    :set res [$RunGenericTestCase $res $ReplaceStr ("path\\to\\file") ("\\") "/" "path/to/file" "Replace backslashes to slashes"]
    :set res [$RunGenericTestCase $res $ReplaceStr "text with spaces" " " "_" "text_with_spaces" "Replace spaces with underscores"]
    :set res [$RunGenericTestCase $res $ReplaceStr "line1,line2,line3" (",") ("\n") ("line1\nline2\nline3") "Replace comma with newline"]

    # Boundary Matches & Expanding/Shrinking
    :set res [$RunGenericTestCase $res $ReplaceStr "apple" "app" "7" "7le" "Match strictly at the beginning of string"]
    :set res [$RunGenericTestCase $res $ReplaceStr "apple" "ple" "7" "ap7" "Match strictly at the end of string"]
    :set res [$RunGenericTestCase $res $ReplaceStr "appapp" "app" "X" "XX" "Adjacent matches covering the entire string"]
    :set res [$RunGenericTestCase $res $ReplaceStr "a" "a" "abc" "abc" "Replacing single char with longer string (expansion)"]
    :set res [$RunGenericTestCase $res $ReplaceStr "abcde" "bcd" "x" "axe" "Replacing long sequence with shorter string (shrinking)"]

    # Recursion & Special Formatting
    :set res [$RunGenericTestCase $res $ReplaceStr "foo" "o" "oo" "foooo" "Replacement target contains search pattern (infinite loop check)"]
    :set res [$RunGenericTestCase $res $ReplaceStr "abc" "b" "bab" "ababc" "Replacement creates pattern sandwich"]
    :set res [$RunGenericTestCase $res $ReplaceStr ("col1\tcol2\tcol3") ("\t") " " "col1 col2 col3" "Replace tabs with spaces"]
    :set res [$RunGenericTestCase $res $ReplaceStr ("line1\r\nline2") ("\r\n") ("\n") ("line1\nline2") "Normalize Windows CRLF to Unix LF"]
    :set res [$RunGenericTestCase $res $ReplaceStr "foo::bar::baz" "::" ":" "foo:bar:baz" "Double colon delimiter reduction"]
    :set res [$RunGenericTestCase $res $ReplaceStr "123456" "34" "99" "129956" "Replace numbers represented as string"]
    :set res [$RunGenericTestCase $res $ReplaceStr "x.y.z" "." "-" "x-y-z" "Replace dots in IP or version-like strings"]

    :put "Testing completed."
    :return $res
}

:set RecursiveMergeSortTest do={
    :global InitTestCaseState
    :global RecursiveMergeSort
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting RecursiveMergeSort (numeric) tests..."

    # Edge Cases & Basics
    :set res [$RunGenericTestCase $res $RecursiveMergeSort [:toarray ""] "nothing" "nothing" "" "Empty array"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({42}) "nothing" "nothing" "42" "Single element array"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({7;7;7;7}) "nothing" "nothing" "7;7;7;7" "Array with identical elements"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({5;5;1;1;5;1}) "nothing" "nothing" "1;1;1;5;5;5" "Duplicates mixed up"]

    # Standard Numeric Sorting
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({20;10}) "nothing" "nothing" "10;20" "Two unsorted numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({1;2;3;4;5}) "nothing" "nothing" "1;2;3;4;5" "Already sorted numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({5;4;3;2;1}) "nothing" "nothing" "1;2;3;4;5" "Reverse sorted numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({10;2;1}) "nothing" "nothing" "1;2;10" "True mathematical sort (1 < 2 < 10)"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({100;5;20;3;50}) "nothing" "nothing" "3;5;20;50;100" "Unsorted varying digits"]

    # Boundaries and Zero
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({0;5;0;2}) "nothing" "nothing" "0;0;2;5" "Sorting with zeros"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({0;0;0}) "nothing" "nothing" "0;0;0" "All zeros"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({9999;1;99;9}) "nothing" "nothing" "1;9;99;9999" "Large gaps between scales"]

    # Shuffled Multi-element Arrays
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({15;2;48;12;36;4;22}) "nothing" "nothing" "2;4;12;15;22;36;48" "Seven shuffled numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({8;1;6;3;7;2;5;4}) "nothing" "nothing" "1;2;3;4;5;6;7;8" "Eight completely reversed/shuffled numbers"]

    # Negative Numbers & Zero Crossing
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({-1}) "nothing" "nothing" "-1" "Single negative element"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({-10;-20;-30;-40}) "nothing" "nothing" "-40;-30;-20;-10" "Strictly descending negative numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({-40;-30;-20;-10}) "nothing" "nothing" "-40;-30;-20;-10" "Already sorted negative numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({-5;0;5;-10;10}) "nothing" "nothing" "-10;-5;0;5;10" "Symmetric around zero"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({0;-100;0;100;0}) "nothing" "nothing" "-100;0;0;0;100" "Multiple zeros with mixed signs"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({-999999;999999;-1;1;0}) "nothing" "nothing" "-999999;-1;0;1;999999" "Extreme signed values span"]

    # Structural Edge Cases & Medium Datasets
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({2;1}) "nothing" "nothing" "1;2" "Two reversed numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ({44;12;89;3;71;25;98;1;56;30}) "nothing" "nothing" "1;3;12;25;30;44;56;71;89;98" "10 random numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "1,2"]) "nothing" "nothing" ([:toarray "1,2"]) "Two sorted numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "2,2"]) "nothing" "nothing" ([:toarray "2,2"]) "Two identical numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "1,3,2"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements (last two swapped)"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "2,1,3"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements (first two swapped)"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "3,2,1"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements strictly reversed"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "2,3,1"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements shift right"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "3,1,2"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements shift left"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "1,2,3,5,4"]) "nothing" "nothing" ([:toarray "1,2,3,4,5"]) "Five elements, only last pair swapped"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "2,1,3,4,5"]) "nothing" "nothing" ([:toarray "1,2,3,4,5"]) "Five elements, only first pair swapped"]

    # Duplicates & Pivot Traps
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "4,2,4,2,4,2,4"]) "nothing" "nothing" ([:toarray "2,2,2,4,4,4,4"]) "Interleaved dual values"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "1,1,1,1,1,1,1,1,1,1"]) "nothing" "nothing" ([:toarray "1,1,1,1,1,1,1,1,1,1"]) "Ten identical elements"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "5,1,5,1,5,1,5,1,5,1"]) "nothing" "nothing" ([:toarray "1,1,1,1,1,5,5,5,5,5"]) "Equal frequency binary array"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "9,9,9,9,1"]) "nothing" "nothing" ([:toarray "1,9,9,9,9"]) "Heavy tail duplicates with single min"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "1,9,9,9,9"]) "nothing" "nothing" ([:toarray "1,9,9,9,9"]) "Single min with heavy tail duplicates"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "9,1,1,1,1"]) "nothing" "nothing" ([:toarray "1,1,1,1,9"]) "Heavy head duplicates with single max"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "10,20,30,20,10,20,30,10"]) "nothing" "nothing" ([:toarray "10,10,10,20,20,20,30,30"]) "Three repeated distinct values"]

    # Mathematical Sequences & Multiples
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "100,10,1000,1,10000"]) "nothing" "nothing" ([:toarray "1,10,100,1000,10000"]) "Powers of ten"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "2,4,8,16,32,64,128,256"]) "nothing" "nothing" ([:toarray "2,4,8,16,32,64,128,256"]) "Powers of two sorted"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "256,128,64,32,16,8,4,2"]) "nothing" "nothing" ([:toarray "2,4,8,16,32,64,128,256"]) "Powers of two reversed"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "1,3,2,6,5,15,14"]) "nothing" "nothing" ([:toarray "1,2,3,5,6,14,15"]) "Zig-zag sequence"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "1,1,2,3,5,8,13,21"]) "nothing" "nothing" ([:toarray "1,1,2,3,5,8,13,21"]) "Sorted Fibonacci"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "21,13,8,5,3,2,1,1"]) "nothing" "nothing" ([:toarray "1,1,2,3,5,8,13,21"]) "Reversed Fibonacci"]

    # Array Length Shapes (Odd / Even / Power of )
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "7,6,5,4,3,2,1"]) "nothing" "nothing" ([:toarray "1,2,3,4,5,6,7"]) "Odd length (7 items) reversed"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "8,7,6,5,4,3,2,1"]) "nothing" "nothing" ([:toarray "1,2,3,4,5,6,7,8"]) "Even length (8 items) reversed"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "9,8,7,6,5,4,3,2,1"]) "nothing" "nothing" ([:toarray "1,2,3,4,5,6,7,8,9"]) "Odd length (9 items) reversed"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "31,15,7,3,1,0,2,4,8,16,32"]) "nothing" "nothing" ([:toarray "0,1,2,3,4,7,8,15,16,31,32"]) "V-shape array (descending then ascending)"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "0,1,3,7,15,31,16,8,4,2"]) "nothing" "nothing" ([:toarray "0,1,2,3,4,7,8,15,16,31"]) "A-shape array (ascending then descending)"]

    # Medium Size Unsorted Collections
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "17,83,41,95,2,68,54,29,91,10,36,74,61,5,88"]) "nothing" "nothing" ([:toarray "2,5,10,17,29,36,41,54,61,68,74,83,88,91,95"]) "15 random numbers"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "50,49,51,48,52,47,53,46,54,45,55,44,56,43,57"]) "nothing" "nothing" ([:toarray "43,44,45,46,47,48,49,50,51,52,53,54,55,56,57"]) "Oscillating outward from median"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "1,100,2,99,3,98,4,97,5,96,6,95"]) "nothing" "nothing" ([:toarray "1,2,3,4,5,6,95,96,97,98,99,100"]) "Interleaved min and max pairs"]

    # Stress Large Datasets
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0"]) "nothing" "nothing" ([:toarray "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30"]) "31 elements strictly descending"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSort ([:toarray "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30"]) "nothing" "nothing" ([:toarray "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30"]) "31 elements already sorted"]

    :put "Testing completed."
    :return $res
}

:set RecursiveMergeSortStrTest do={
    :global InitTestCaseState
    :global RecursiveMergeSortStr
    :global RunGenericTestCase

    :local res [$InitTestCaseState ]

    :put "Starting extended RecursiveMergeSortStr tests..."

    # Edge Cases & Basics
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr [:toarray ""] "nothing" "nothing" "" "Empty array"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"apple"}) "nothing" "nothing" "apple" "Single element array"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"apple";"apple";"apple"}) "nothing" "nothing" "apple;apple;apple" "Array with identical elements"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"b";"b";"a";"a";"b";"a"}) "nothing" "nothing" "a;a;a;b;b;b" "Duplicates mixed up"]

    # Standard Alphabetical Sorting
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"banana";"apple"}) "nothing" "nothing" "apple;banana" "Two unsorted elements"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"apple";"banana";"cherry"}) "nothing" "nothing" "apple;banana;cherry" "Already sorted array"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"cherry";"banana";"apple"}) "nothing" "nothing" "apple;banana;cherry" "Reverse sorted array"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"d";"a";"c";"b"}) "nothing" "nothing" "a;b;c;d" "Four unsorted characters"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"fox";"dog";"cat";"bird"}) "nothing" "nothing" "bird;cat;dog;fox" "Unsorted words"]

    # Prefix & Length Variations
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"testing";"test"}) "nothing" "nothing" "test;testing" "Prefix after long string"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"test";"testing"}) "nothing" "nothing" "test;testing" "Prefix before long string"]

    # Case Sensitivity (ASCII) & Special Chars
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"banana";"Apple";"cherry"}) "nothing" "nothing" "Apple;banana;cherry" "One capitalized word"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"Z";"a";"A";"z"}) "nothing" "nothing" "A;Z;a;z" "Caps vs lowercase boundaries"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"10";"2";"1"}) "nothing" "nothing" "1;10;2" "Numeric strings (1 < 10 < 2)"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ({"a b";"ab"}) "nothing" "nothing" "a b;ab" "Space vs no space"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "asdfghjk,asdf,as"]) "nothing" "nothing" ([:toarray "as,asdf,asdfghjk"]) "Multiple varying lengths of same prefix"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "abc,ab,a"]) "nothing" "nothing" ([:toarray "a,ab,abc"]) "Strict reverse prefix order"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "apple,Apple,a"]) "nothing" "nothing" ([:toarray "Apple,a,apple"]) "Same characters different case"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "Z,a,A,z"]) "nothing" "nothing" ([:toarray "A,Z,a,z"]) "Caps vs lowercase boundaries"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "WORD,word,Word"]) "nothing" "nothing" ([:toarray "WORD,Word,word"]) "Identical words with different casing"]

    # Numbers & Numeric Strings (ASCII character sorting)
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "10,2,1"]) "nothing" "nothing" ([:toarray "1,10,2"]) "Numeric strings (1 < 10 < 2)"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "01,1,00"]) "nothing" "nothing" ([:toarray "00,01,1"]) "Leading zeros"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "200,199,3"]) "nothing" "nothing" ([:toarray "199,200,3"]) "Three digit vs one digit ASCII logic"]

    # Special Characters & Spaces (ASCII order criteria)
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "a b,ab"]) "nothing" "nothing" ([:toarray "a b,ab"]) "Space vs no space (space is smaller than 'b')"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "abc,abc "]) "nothing" "nothing" ([:toarray "abc,abc "]) "Trailing space comparison"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "abc?,abc!"]) "nothing" "nothing" ([:toarray "abc!,abc?"]) "Punctuation (! is 33, ? is 63)"]
    :set res [$RunGenericTestCase $res $RecursiveMergeSortStr ([:toarray "under_score,underscore"]) "nothing" "nothing" ([:toarray "under_score,underscore"]) "Underscore vs regular character"]

    :put "Testing completed."
    :return $res
}
