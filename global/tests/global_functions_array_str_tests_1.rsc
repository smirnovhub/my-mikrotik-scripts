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

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

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
    :global ParseKeyValueStore

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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

:set RandomTest do={
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

        # Convert both to string to avoid RouterOS boolean/numeric type comparison issues
        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> " . [:tostr $actual])
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: " . [:tostr $expected] . ", Got: " . [:tostr $actual])
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting Randomness & Generation tests..."
    :global GetRandom20CharHex
    :global GetRandomNumber
    :global IsPrintableStr

    # --- Part 1: GetRandom20CharHex Tests ---
    :local hexStr [$GetRandom20CharHex]
    :local hexStrLen [:len $hexStr]

    # Test 1: Verify exact string length
    :set res [$RunTestCase $res $hexStrLen 20 "Verify random hex string length is exactly 20 chars"]

    :local lenOk true

    :for i from=1 to=100 do={
        :local s [$GetRandom20CharHex]

        :if ([:len $s] != 20) do={
            :set lenOk false
        }
    }

    :set res [$RunTestCase $res $lenOk true "Verify 100 generated hex strings have correct length"]

    # Test 2: Verify it contains only printable characters
    :local isPrintable [$IsPrintableStr $hexStr]
    :set res [$RunTestCase $res $isPrintable true "Verify random hex string consists only of printable characters"]

    # Test 3: Uniqueness check (two consecutive calls must not yield the exact same string)
    :local hexStr2 [$GetRandom20CharHex]
    :local isUnique ($hexStr != $hexStr2)
    :set res [$RunTestCase $res $isUnique true "Verify consecutive SCEP OTP calls produce unique tokens"]

    :local generated [:toarray ""]
    :local unique true

    :for i from=1 to=100 do={
        :local s [$GetRandom20CharHex]

        :if ([:typeof ($generated->$s)] != "nothing") do={
            :set unique false
        }

        :set ($generated->$s) true
    }

    :set res [$RunTestCase $res $unique true "Verify no duplicate hex strings in 100 generations"]

    # Test 4: Hexadecimal character validation
    :local validHex "0123456789abcdefABCDEF"
    :local isStrictHex true
    :for i from=0 to=($hexStrLen - 1) do={
        :local char [:pick $hexStr $i]
        :if ([:find $validHex $char] < 0) do={
            :set isStrictHex false
        }
    }
    :set res [$RunTestCase $res $isStrictHex true "Verify random string contains only valid hexadecimal characters"]

    # --- Part 2: GetRandomNumber Bounds Tests ---

    # Test 4: Default behavior (no arguments passed)
    :local numDefault [$GetRandomNumber]
    :local withinDefaultRange ($numDefault >= 0 && $numDefault <= 4294967295)
    :set res [$RunTestCase $res $withinDefaultRange true "Verify default random number is within 32-bit unsigned range"]

    # Test 5: Custom maximum boundary (range 0 to 9)
    :local maxTen 10
    :local numTen [$GetRandomNumber ($maxTen - 1)]
    :local withinTenRange ($numTen >= 0 && $numTen < $maxTen)
    :set res [$RunTestCase $res $withinTenRange true "Verify random number is within custom range [0, 9]"]

    # Test 6: Extremely narrow boundary (range 0 to 1)
    :local maxTwo 2
    :local numTwo [$GetRandomNumber ($maxTwo - 1)]
    :local withinTwoRange ($numTwo >= 0 && $numTwo < $maxTwo)
    :set res [$RunTestCase $res $withinTwoRange true "Verify binary random boundary [0, 1]"]
    :set res [$RunTestCase $res ([$GetRandomNumber 0]) 0 "Verify max=0 always returns 0"]

    # --- Part 3: Distribution & Multi-run Validation ---
    # Running a loop to ensure dynamic changes and boundaries hold over multiple iterations
    :local distributionPass true
    :for i from=1 to=50 do={
        :local val [$GetRandomNumber 99]
        :if ($val < 0 || $val > 99) do={
            :set distributionPass false
        }
    }
    :set res [$RunTestCase $res $distributionPass true "Verify 50 consecutive iterations respect bounds [0, 99]"]

    # Test: Verify approximate uniform distribution for range [0,9]
    :local buckets [:toarray ""]
    :for i from=0 to=9 do={
        :set ($buckets->$i) 0
    }

    :local samples 1000

    :for i from=1 to=$samples do={
        :local value [$GetRandomNumber 9]
        :set ($buckets->$value) (($buckets->$value) + 1)
    }

    :local distributionOk true

    :for i from=0 to=9 do={
        :local count ($buckets->$i)

        :if (($count < 60) || ($count > 140)) do={
            :set distributionOk false
        }
    }

    :set res [$RunTestCase $res $distributionOk true "Verify approximate uniform distribution over range [0,9]"]

    # Optional: print histogram
    :put "Distribution:"
    :for i from=0 to=9 do={
        :put ("  " . $i . ": " . ($buckets->$i))
    }

    :put "Testing completed."
    :return $res
}

:set HexToNumTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        :global HexToNum

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local input [:tostr $2]
        :local expected [:tonum $3]
        :local name [:tostr $4]

        :local actual [$HexToNum $input]

        :if ($actual = $expected) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $input . "' -> " . $actual)
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: " . $expected . ", Got: " . $actual)
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting HexToNum tests..."

    # --- Basic Single Digit Tests ---
    :set res [$RunTestCase $res "0" 0 "Zero case"]
    :set res [$RunTestCase $res "5" 5 "Single low digit"]
    :set res [$RunTestCase $res "9" 9 "Single high digit"]

    # --- Letter Digits (Case Sensitivity) ---
    :set res [$RunTestCase $res "a" 10 "Lowercase A"]
    :set res [$RunTestCase $res "A" 10 "Uppercase A"]
    :set res [$RunTestCase $res "f" 15 "Lowercase F"]
    :set res [$RunTestCase $res "F" 15 "Uppercase F"]

    # --- Multi-digit Numbers ---
    :set res [$RunTestCase $res "10" 16 "Hex sixteen"]
    :set res [$RunTestCase $res "1A" 26 "Mixed digits and uppercase"]
    :set res [$RunTestCase $res "ff" 255 "Max byte lowercase"]
    :set res [$RunTestCase $res "FF" 255 "Max byte uppercase"]

    # --- Complex Mixed Case & Large Values ---
    :set res [$RunTestCase $res "7aB4" 31412 "Mixed case complex string"]
    :set res [$RunTestCase $res "1000" 4096 "Power of sixteen"]
    :set res [$RunTestCase $res "FFFF" 65535 "Two byte max value"]

    # --- Edge Cases ---
    :set res [$RunTestCase $res "" nil "Empty input string"]

    # --- Leading Zeros ---
    :set res [$RunTestCase $res "000" 0 "Multiple zeros"]
    :set res [$RunTestCase $res "00FF" 255 "Leading zeros with value"]
    :set res [$RunTestCase $res "01" 1 "Single leading zero"]

    # --- Large Values (32-bit & 64-bit Boundaries) ---
    :set res [$RunTestCase $res "7FFFFFFF" 2147483647 "Max signed 32-bit integer"]
    :set res [$RunTestCase $res "80000000" 2147483648 "Boundary above 32-bit signed"]
    :set res [$RunTestCase $res "FFFFFFFF" 4294967295 "Max unsigned 32-bit integer"]
    :set res [$RunTestCase $res "100000000" 4294967296 "Value requiring 64-bit storage"]

    # --- Alternative Input Formats (Type Conversion) ---
    :set res [$RunTestCase $res "0x1A" nil "Prefix handling check (Note: if function does not strip 0x, actual value will be wrong)"]

    # --- Invalid Hex Characters (Robustness Check) ---
    # Note: Depending on the HexToNum logic, invalid characters like 'G' or 'Z' 
    # might cause fallback behavior, negative values, or return 0.
    :set res [$RunTestCase $res "G" nil "Invalid single letter"]
    :set res [$RunTestCase $res "1Z" nil "Invalid trailing character"]

    :put "Testing completed."
    :return $res
}

:set MapArrayTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        :global MapArray

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state [:toarray $1]
        :local input [:toarray $2]
        :local transformFunc $3
        :local expected [:toarray $4]
        :local name [:tostr $5]

        :local actual [$MapArray $input $transformFunc]

        # Array comparison logic since RouterOS does not support direct array1 = array2
        :local isMatch true

        # Verify sizes match first
        :if ([:len $actual] != [:len $expected]) do={
            :set isMatch false
        } else={
            # Check every key and value from expected array inside actual array
            :foreach k,expectedVal in=$expected do={
                :local actualVal ($actual->$k)
                :if ($actualVal != $expectedVal) do={
                    :set isMatch false
                }
            }
            # Double check for extra keys in actual array
            :foreach k,actualVal in=$actual do={
                :local expectedVal ($expected->$k)
                :if ($expectedVal != $actualVal) do={
                    :set isMatch false
                }
            }
        }

        :if ($isMatch = true) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . ": Input size " . [:len $input] . " processed successfully")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: " . [:tostr $expected] . ", Got: " . [:tostr $actual])
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting MapArray tests..."

    # --- Helper Transformation Functions for Testing ---
    :local square do={ :return ($v * $v) }
    :local identity do={ :return $v }
    :local useKeyOnly do={ :return ("key_" . $n) }
    :local concatString do={ :return ($v . "_suffix") }

    # --- Basic Indexed Array Tests ---
    :set res [$RunTestCase $res ({7; 5; 10}) $square ({49; 25; 100}) "Square numbers in indexed array"]
    :set res [$RunTestCase $res ({"apple"; "banana"}) $concatString ({"apple_suffix"; "banana_suffix"}) "Concatenate strings in indexed array"]

    # --- Associative Array (Map) Tests ---
    :set res [$RunTestCase $res ({a=4; b=7; c=15}) $square ({a=16; b=49; c=225}) "Square values in associative map"]
    :set res [$RunTestCase $res ({host="mikrotik"; ip="10.0.0.1"}) $concatString ({host="mikrotik_suffix"; ip="10.0.0.1_suffix"}) "Modify string values in associative map"]

    # --- Tests Using the Key Parameter ($n) ---
    :set res [$RunTestCase $res ({first=""; second=""}) $useKeyOnly ({first="key_first"; second="key_second"}) "Transform values using their array keys"]

    # --- Edge Cases ---
    :set res [$RunTestCase $res ({}) $square ({}) "Empty array input"]
    :set res [$RunTestCase $res ({x=10}) $identity ({x=10}) "Single element array with identity function"]

    # --- Mixed Types in Array ---
    # Testing how the function handles an array containing different types simultaneously
    :local stringifyAll do={ :return [:tostr $v] }
    :set res [$RunTestCase $res ({num=42; text="status"; logic=true}) $stringifyAll ({num="42"; text="status"; logic="true"}) "Convert mixed data types to strings"]

    # --- Boolean Inversion ---
    # Testing logical inversion of boolean values within a map
    :local invertBool do={ :return (!$v) }
    :set res [$RunTestCase $res ({up=true; down=false; active=true}) $invertBool ({up=false; down=true; active=false}) "Invert boolean states"]

    # --- Numeric Offset Modification ---
    # Testing mathematical adjustments (subtraction/addition) on metrics
    :local decrementOffset do={ :return ($v - 1) }
    :set res [$RunTestCase $res ({port1=81; port2=82; port3=444}) $decrementOffset ({port1=80; port2=81; port3=443}) "Apply negative offset to port numbers"]

    # --- Numeric Keys Handling ---
    # Testing that keys explicitly defined as numbers are processed correctly without being converted or lost
    :local doubleValue do={ :return ($v * 2) }
    :set res [$RunTestCase $res ({10=5; 20=15}) $doubleValue ({10=10; 20=30}) "Process map with explicitly numeric keys"]

    # --- Extreme Values Handling ---
    # Testing map execution with huge numbers and special string formats
    :local clearValue do={ :return 0 }
    :set res [$RunTestCase $res ({"maxInt"=2147483647; "hexStr"="7"}) $clearValue ({"maxInt"=0; "hexStr"=0}) "Reset complex or large value formats to zero"]

    # --- Simultaneous Key and Value Usage ---
    # Testing that the transformation function can correctly access and combine
    # both the current key ($n) and its corresponding value ($v) during mapping
    :local combine do={
        :return ($n . "=" . $v)
    }

    :set res [$RunTestCase $res ({a=10; b=20}) $combine ({a="a=10"; b="b=20"}) "Use both key and value"]

    :put "Testing completed."
    :return $res
}

:set JoinArrayTest do={
    :global JoinArray

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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

        :local actualType [:typeof $actual]

        :if ($actualType != "str") do={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": Type error! Expected 'str', Got '" . $actualType . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        } else={
            :if ($actualStr = $expectedStr) do={
                :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . $actualStr . "'")
                :set ($state->"passed") (($state->"passed") + 1)
            } else={
                :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . $expectedStr . "', Got: '" . $actualStr . "'")
                :set ($state->"failed") (($state->"failed") + 1)
            }
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
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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

            :local actualType [:typeof $actual]

            :if ($actualType != "str") do={
                :put ("\1B[31m  [FAIL]\1B[0m [" . $targetFunc . "] " . $name . ": Type error! Expected 'str', Got '" . $actualType . "'")
                :set ($state->"failed") (($state->"failed") + 1)
            } else={
                :if ($actual = $expected) do={
                    :put ("\1B[32m  [PASS]\1B[0m [" . $targetFunc . "] " . $name . ": '" . $str . "' -> '" . $actual . "'")
                    :set ($state->"passed") (($state->"passed") + 1)
                } else={
                    :put ("\1B[31m  [FAIL]\1B[0m [" . $targetFunc . "] " . $name . ": '" . $str . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
                    :set ($state->"failed") (($state->"failed") + 1)
                }
            }
        }
        :return $state
    }

    :put "Starting TrimStr tests..."

    # --- Part 1: TrimStrLeft Tests ---
    :set res [$RunTestCase $res "left" "TrimmedString" "Trng" "immedString" "Example case from description"]
	:set res [$RunTestCase $res "left" ("\r\n\t TrStr\r\n\t ") "" ("TrStr\r\n\t ") "Trim without parameters"]
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
    :set res [$RunTestCase $res "right" ("\r\n\t TrStr\r\n\t ") "" ("\r\n\t TrStr") "Trim without parameters"]
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
    :set res [$RunTestCase $res "both" ("\r\n\t TrStr\r\n\t ") "" "TrStr" "Trim without parameters"]
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
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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

        :local actualType [:typeof $actual]

        :if ($actualType != "str") do={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": Type error! Expected 'str', Got '" . $actualType . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        } else={
            :if ($actual = $expected) do={
                :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $str . "' -> '" . $actual . "'")
                :set ($state->"passed") (($state->"passed") + 1)
            } else={
                :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $str . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
                :set ($state->"failed") (($state->"failed") + 1)
            }
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

    # --- Boundary Matches (Start & End of String) ---
    :set res [$RunTestCase $res "apple" "app" "7" "7le" "Match strictly at the beginning of string"]
    :set res [$RunTestCase $res "apple" "ple" "7" "ap7" "Match strictly at the end of string"]
    :set res [$RunTestCase $res "appapp" "app" "X" "XX" "Adjacent matches covering the entire string"]

    # --- Expanding & Shrinking Replacements ---
    :set res [$RunTestCase $res "a" "a" "abc" "abc" "Replacing single char with longer string (expansion)"]
    :set res [$RunTestCase $res "abcde" "bcd" "x" "axe" "Replacing long sequence with shorter string (shrinking)"]

    # --- Recursion & Self-Containment Risk ---
    :set res [$RunTestCase $res "foo" "o" "oo" "foooo" "Replacement target contains search pattern (infinite loop check)"]
    :set res [$RunTestCase $res "abc" "b" "bab" "ababc" "Replacement creates pattern sandwich"]

    # --- Special Characters & Tabulation ---
    :set res [$RunTestCase $res ("col1\tcol2\tcol3") ("\t") " " "col1 col2 col3" "Replace tabs with spaces"]
    :set res [$RunTestCase $res ("line1\r\nline2") ("\r\n") ("\n") ("line1\nline2") "Normalize Windows CRLF to Unix LF"]
    :set res [$RunTestCase $res "foo::bar::baz" "::" ":" "foo:bar:baz" "Double colon delimiter reduction"]

    # --- Type Coercion & Numbers ---
    :set res [$RunTestCase $res "123456" "34" "99" "129956" "Replace numbers represented as string"]
    :set res [$RunTestCase $res "x.y.z" "." "-" "x-y-z" "Replace dots in IP or version-like strings"]

    :put "Testing completed."
    :return $res
}

:set RecursiveMergeSortTest do={
    :global RecursiveMergeSort

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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

    # --- Negative Numbers & Zero Crossing Advanced ---
    :set res [$RunTestCase $res "-1" "-1" "Single negative element"]
    :set res [$RunTestCase $res "-10,-20,-30,-40" "-40,-30,-20,-10" "Strictly descending negative numbers"]
    :set res [$RunTestCase $res "-40,-30,-20,-10" "-40,-30,-20,-10" "Already sorted negative numbers"]
    :set res [$RunTestCase $res "-5,0,5,-10,10" "-10,-5,0,5,10" "Symmetric around zero"]
    :set res [$RunTestCase $res "0,-100,0,100,0" "-100,0,0,0,100" "Multiple zeros with mixed signs"]
    :set res [$RunTestCase $res "-999999,999999,-1,1,0" "-999999,-1,0,1,999999" "Extreme signed values span"]

    # --- Permutations & Structural Edge Cases ---
    :set res [$RunTestCase $res "2,1" "1,2" "Two reversed numbers"]
    :set res [$RunTestCase $res "1,2" "1,2" "Two sorted numbers"]
    :set res [$RunTestCase $res "2,2" "2,2" "Two identical numbers"]
    :set res [$RunTestCase $res "1,3,2" "1,2,3" "Three elements (last two swapped)"]
    :set res [$RunTestCase $res "2,1,3" "1,2,3" "Three elements (first two swapped)"]
    :set res [$RunTestCase $res "3,2,1" "1,2,3" "Three elements strictly reversed"]
    :set res [$RunTestCase $res "2,3,1" "1,2,3" "Three elements shift right"]
    :set res [$RunTestCase $res "3,1,2" "1,2,3" "Three elements shift left"]
    :set res [$RunTestCase $res "1,2,3,5,4" "1,2,3,4,5" "Five elements, only last pair swapped"]
    :set res [$RunTestCase $res "2,1,3,4,5" "1,2,3,4,5" "Five elements, only first pair swapped"]

    # --- Duplicates & Pivot Traps ---
    :set res [$RunTestCase $res "4,2,4,2,4,2,4" "2,2,2,4,4,4,4" "Interleaved dual values"]
    :set res [$RunTestCase $res "1,1,1,1,1,1,1,1,1,1" "1,1,1,1,1,1,1,1,1,1" "Ten identical elements"]
    :set res [$RunTestCase $res "5,1,5,1,5,1,5,1,5,1" "1,1,1,1,1,5,5,5,5,5" "Equal frequency binary array"]
    :set res [$RunTestCase $res "9,9,9,9,1" "1,9,9,9,9" "Heavy tail duplicates with single min"]
    :set res [$RunTestCase $res "1,9,9,9,9" "1,9,9,9,9" "Single min with heavy tail duplicates"]
    :set res [$RunTestCase $res "9,1,1,1,1" "1,1,1,1,9" "Heavy head duplicates with single max"]
    :set res [$RunTestCase $res "10,20,30,20,10,20,30,10" "10,10,10,20,20,20,30,30" "Three repeated distinct values"]

    # --- Mathematical Sequences & Multiples ---
    :set res [$RunTestCase $res "100,10,1000,1,10000" "1,10,100,1000,10000" "Powers of ten"]
    :set res [$RunTestCase $res "2,4,8,16,32,64,128,256" "2,4,8,16,32,64,128,256" "Powers of two sorted"]
    :set res [$RunTestCase $res "256,128,64,32,16,8,4,2" "2,4,8,16,32,64,128,256" "Powers of two reversed"]
    :set res [$RunTestCase $res "1,3,2,6,5,15,14" "1,2,3,5,6,14,15" "Zig-zag sequence"]
    :set res [$RunTestCase $res "1,1,2,3,5,8,13,21" "1,1,2,3,5,8,13,21" "Sorted Fibonacci"]
    :set res [$RunTestCase $res "21,13,8,5,3,2,1,1" "1,1,2,3,5,8,13,21" "Reversed Fibonacci"]

    # --- Array Length Shapes (Odd / Even / Power of 2) ---
    :set res [$RunTestCase $res "7,6,5,4,3,2,1" "1,2,3,4,5,6,7" "Odd length (7 items) reversed"]
    :set res [$RunTestCase $res "8,7,6,5,4,3,2,1" "1,2,3,4,5,6,7,8" "Even length (8 items) reversed"]
    :set res [$RunTestCase $res "9,8,7,6,5,4,3,2,1" "1,2,3,4,5,6,7,8,9" "Odd length (9 items) reversed"]
    :set res [$RunTestCase $res "31,15,7,3,1,0,2,4,8,16,32" "0,1,2,3,4,7,8,15,16,31,32" "V-shape array (descending then ascending)"]
    :set res [$RunTestCase $res "0,1,3,7,15,31,16,8,4,2" "0,1,2,3,4,7,8,15,16,31" "A-shape array (ascending then descending)"]

    # --- Medium Size Unsorted Collections ---
    :set res [$RunTestCase $res "44,12,89,3,71,25,98,1,56,30" "1,3,12,25,30,44,56,71,89,98" "10 random numbers"]
    :set res [$RunTestCase $res "17,83,41,95,2,68,54,29,91,10,36,74,61,5,88" "2,5,10,17,29,36,41,54,61,68,74,83,88,91,95" "15 random numbers"]
    :set res [$RunTestCase $res "50,49,51,48,52,47,53,46,54,45,55,44,56,43,57" "43,44,45,46,47,48,49,50,51,52,53,54,55,56,57" "Oscillating outward from median"]
    :set res [$RunTestCase $res "1,100,2,99,3,98,4,97,5,96,6,95" "1,2,3,4,5,6,95,96,97,98,99,100" "Interleaved min and max pairs"]

    # --- Stress Large Datasets ---
    :set res [$RunTestCase $res "30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0" "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30" "31 elements strictly descending"]
    :set res [$RunTestCase $res "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30" "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30" "31 elements already sorted"]

    :put "Testing completed."
    :return $res
}

:set RecursiveMergeSortStrTest do={
    :global RecursiveMergeSortStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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
