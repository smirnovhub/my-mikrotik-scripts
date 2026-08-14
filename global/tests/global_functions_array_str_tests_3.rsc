:global RunAllArrayStrTests3
:global QuickSortTest
:global DivideIntAndRoundTest
:global ToUpperCaseTest
:global ToLowerCaseTest
:global HexToCharTest
:global DecToCharTest

:set RunAllArrayStrTests3 do={
    :global QuickSortTest
    :global DivideIntAndRoundTest
    :global ToUpperCaseTest
    :global ToLowerCaseTest
    :global HexToCharTest
    :global DecToCharTest

    :put "\1B[35m=== STARTING ALL ARRAY AND STRING TESTS 3 ===\1B[0m"

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    # Execute all test suites sequentially, passing and updating the same accumulator array
    :set res [$QuickSortTest $res]
    :set res [$DivideIntAndRoundTest $res]
    :set res [$ToUpperCaseTest $res]
    :set res [$ToLowerCaseTest $res]
    :set res [$HexToCharTest $res]
    :set res [$DecToCharTest $res]

    :put "\1B[35m=== ALL ARRAY AND STRING TESTS 3 COMPLETED ===\1B[0m"

    :return $res
}

:set QuickSortTest do={
    :global QuickSort

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :local RunTestCase do={
        :global QuickSort

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

        :local actual [$QuickSort $numInput]

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

    :put "Starting QuickSort (numeric) tests..."

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

:set DivideIntAndRoundTest do={
    :global DivideIntAndRound

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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

        :local actualType [:typeof $actual]

        :if ($actualType != "str") do={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": Type error! Expected 'str', Got '" . $actualType . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        } else={
            :if ($actual = $expected) do={
                :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
                :set ($state->"passed") (($state->"passed") + 1)
            } else={
                :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
                :set ($state->"failed") (($state->"failed") + 1)
            }
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
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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

        :local actualType [:typeof $actual]

        :if ($actualType != "str") do={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": Type error! Expected 'str', Got '" . $actualType . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        } else={
            :if ($actual = $expected) do={
                :put ("\1B[32m  [PASS]\1B[0m " . $name . ": '" . $input . "' -> '" . $actual . "'")
                :set ($state->"passed") (($state->"passed") + 1)
            } else={
                :put ("\1B[31m  [FAIL]\1B[0m " . $name . ": '" . $input . "' | Expected: '" . $expected . "', Got: '" . $actual . "'")
                :set ($state->"failed") (($state->"failed") + 1)
            }
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
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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

    # --- Special Characters & Spaces (lowercase hex) ---
    :set res [$RunTestCase $res "2b" "+" "Plus sign (lowercase hex)"]
    :set res [$RunTestCase $res "2c" "," "Comma (lowercase hex)"]
    :set res [$RunTestCase $res "2f" "/" "Forward slash (lowercase hex)"]
    :set res [$RunTestCase $res "3a" ":" "Colon (lowercase hex)"]
    :set res [$RunTestCase $res "3b" ";" "Semicolon (lowercase hex)"]
    :set res [$RunTestCase $res "3d" "=" "Equals sign (lowercase hex)"]
    :set res [$RunTestCase $res "3f" "?" "Question mark (lowercase hex)"]
    :set res [$RunTestCase $res "40" "@" "At symbol"]
    :set res [$RunTestCase $res "5b" "[" "Left square bracket (lowercase hex)"]
    :set res [$RunTestCase $res "5c" ("\\") "Backslash (lowercase hex)"]
    :set res [$RunTestCase $res "5d" "]" "Right square bracket (lowercase hex)"]
    :set res [$RunTestCase $res "5f" "_" "Underscore (lowercase hex)"]

    # --- Control Characters (Whitespace/Escapes) ---
    :set res [$RunTestCase $res "0a" ("\n") "Line feed / Newline (lowercase hex)"]
    :set res [$RunTestCase $res "0d" ("\r") "Carriage return (lowercase hex)"]

    # --- Boundaries of 8-bit ASCII / Extended ---
    :set res [$RunTestCase $res "7e" "~" "Tilde (lowercase hex)"]
    :set res [$RunTestCase $res "7f" ("\7F") "Delete control char (lowercase hex)"]
    :set res [$RunTestCase $res "ff" ("\FF") "Extended ASCII upper boundary (lowercase hex)"]

    :put "Testing completed."
    :return $res
}

:set DecToCharTest do={
    :global DecToChar

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
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
