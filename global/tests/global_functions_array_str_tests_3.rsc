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
    :global RunGenericTestCase
    :global QuickSort

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting QuickSort (numeric) tests..."

    # Edge Cases & Basics
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray ""]) "nothing" "nothing" ([:toarray ""]) "Empty array"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "42"]) "nothing" "nothing" ([:toarray "42"]) "Single element array"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "7,7,7,7"]) "nothing" "nothing" ([:toarray "7,7,7,7"]) "Array with identical elements"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "5,5,1,1,5,1"]) "nothing" "nothing" ([:toarray "1,1,1,5,5,5"]) "Duplicates mixed up"]

    # Standard Numeric Sorting
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "20,10"]) "nothing" "nothing" ([:toarray "10,20"]) "Two unsorted numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "1,2,3,4,5"]) "nothing" "nothing" ([:toarray "1,2,3,4,5"]) "Already sorted numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "5,4,3,2,1"]) "nothing" "nothing" ([:toarray "1,2,3,4,5"]) "Reverse sorted numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "10,2,1"]) "nothing" "nothing" ([:toarray "1,2,10"]) "True mathematical sort (1 < 2 < 10)"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "100,5,20,3,50"]) "nothing" "nothing" ([:toarray "3,5,20,50,100"]) "Unsorted varying digits"]

    # Boundaries and Zero
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "0,5,0,2"]) "nothing" "nothing" ([:toarray "0,0,2,5"]) "Sorting with zeros"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "0,0,0"]) "nothing" "nothing" ([:toarray "0,0,0"]) "All zeros"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "9999,1,99,9"]) "nothing" "nothing" ([:toarray "1,9,99,9999"]) "Large gaps between scales"]

    # Shuffled Multi-element Arrays
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "15,2,48,12,36,4,22"]) "nothing" "nothing" ([:toarray "2,4,12,15,22,36,48"]) "Seven shuffled numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "8,1,6,3,7,2,5,4"]) "nothing" "nothing" ([:toarray "1,2,3,4,5,6,7,8"]) "Eight completely reversed/shuffled numbers"]

    # Negative Numbers & Zero Crossing Advanced
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "-1"]) "nothing" "nothing" ([:toarray "-1"]) "Single negative element"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "-10,-20,-30,-40"]) "nothing" "nothing" ([:toarray "-40,-30,-20,-10"]) "Strictly descending negative numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "-40,-30,-20,-10"]) "nothing" "nothing" ([:toarray "-40,-30,-20,-10"]) "Already sorted negative numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "-5,0,5,-10,10"]) "nothing" "nothing" ([:toarray "-10,-5,0,5,10"]) "Symmetric around zero"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "0,-100,0,100,0"]) "nothing" "nothing" ([:toarray "-100,0,0,0,100"]) "Multiple zeros with mixed signs"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "-999999,999999,-1,1,0"]) "nothing" "nothing" ([:toarray "-999999,-1,0,1,999999"]) "Extreme signed values span"]

    # Permutations & Structural Edge Cases
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "2,1"]) "nothing" "nothing" ([:toarray "1,2"]) "Two reversed numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "1,2"]) "nothing" "nothing" ([:toarray "1,2"]) "Two sorted numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "2,2"]) "nothing" "nothing" ([:toarray "2,2"]) "Two identical numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "1,3,2"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements (last two swapped)"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "2,1,3"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements (first two swapped)"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "3,2,1"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements strictly reversed"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "2,3,1"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements shift right"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "3,1,2"]) "nothing" "nothing" ([:toarray "1,2,3"]) "Three elements shift left"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "1,2,3,5,4"]) "nothing" "nothing" ([:toarray "1,2,3,4,5"]) "Five elements, only last pair swapped"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "2,1,3,4,5"]) "nothing" "nothing" ([:toarray "1,2,3,4,5"]) "Five elements, only first pair swapped"]

    # Duplicates & Pivot Traps
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "4,2,4,2,4,2,4"]) "nothing" "nothing" ([:toarray "2,2,2,4,4,4,4"]) "Interleaved dual values"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "1,1,1,1,1,1,1,1,1,1"]) "nothing" "nothing" ([:toarray "1,1,1,1,1,1,1,1,1,1"]) "Ten identical elements"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "5,1,5,1,5,1,5,1,5,1"]) "nothing" "nothing" ([:toarray "1,1,1,1,1,5,5,5,5,5"]) "Equal frequency binary array"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "9,9,9,9,1"]) "nothing" "nothing" ([:toarray "1,9,9,9,9"]) "Heavy tail duplicates with single min"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "1,9,9,9,9"]) "nothing" "nothing" ([:toarray "1,9,9,9,9"]) "Single min with heavy tail duplicates"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "9,1,1,1,1"]) "nothing" "nothing" ([:toarray "1,1,1,1,9"]) "Heavy head duplicates with single max"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "10,20,30,20,10,20,30,10"]) "nothing" "nothing" ([:toarray "10,10,10,20,20,20,30,30"]) "Three repeated distinct values"]

    # Mathematical Sequences & Multiples
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "100,10,1000,1,10000"]) "nothing" "nothing" ([:toarray "1,10,100,1000,10000"]) "Powers of ten"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "2,4,8,16,32,64,128,256"]) "nothing" "nothing" ([:toarray "2,4,8,16,32,64,128,256"]) "Powers of two sorted"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "256,128,64,32,16,8,4,2"]) "nothing" "nothing" ([:toarray "2,4,8,16,32,64,128,256"]) "Powers of two reversed"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "1,3,2,6,5,15,14"]) "nothing" "nothing" ([:toarray "1,2,3,5,6,14,15"]) "Zig-zag sequence"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "1,1,2,3,5,8,13,21"]) "nothing" "nothing" ([:toarray "1,1,2,3,5,8,13,21"]) "Sorted Fibonacci"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "21,13,8,5,3,2,1,1"]) "nothing" "nothing" ([:toarray "1,1,2,3,5,8,13,21"]) "Reversed Fibonacci"]

    # Array Length Shapes (Odd / Even / Power of 2)
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "7,6,5,4,3,2,1"]) "nothing" "nothing" ([:toarray "1,2,3,4,5,6,7"]) "Odd length (7 items) reversed"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "8,7,6,5,4,3,2,1"]) "nothing" "nothing" ([:toarray "1,2,3,4,5,6,7,8"]) "Even length (8 items) reversed"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "9,8,7,6,5,4,3,2,1"]) "nothing" "nothing" ([:toarray "1,2,3,4,5,6,7,8,9"]) "Odd length (9 items) reversed"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "31,15,7,3,1,0,2,4,8,16,32"]) "nothing" "nothing" ([:toarray "0,1,2,3,4,7,8,15,16,31,32"]) "V-shape array (descending then ascending)"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "0,1,3,7,15,31,16,8,4,2"]) "nothing" "nothing" ([:toarray "0,1,2,3,4,7,8,15,16,31"]) "A-shape array (ascending then descending)"]

    # Medium Size Unsorted Collections
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "44,12,89,3,71,25,98,1,56,30"]) "nothing" "nothing" ([:toarray "1,3,12,25,30,44,56,71,89,98"]) "10 random numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "17,83,41,95,2,68,54,29,91,10,36,74,61,5,88"]) "nothing" "nothing" ([:toarray "2,5,10,17,29,36,41,54,61,68,74,83,88,91,95"]) "15 random numbers"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "50,49,51,48,52,47,53,46,54,45,55,44,56,43,57"]) "nothing" "nothing" ([:toarray "43,44,45,46,47,48,49,50,51,52,53,54,55,56,57"]) "Oscillating outward from median"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "1,100,2,99,3,98,4,97,5,96,6,95"]) "nothing" "nothing" ([:toarray "1,2,3,4,5,6,95,96,97,98,99,100"]) "Interleaved min and max pairs"]

    # Stress Large Datasets
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0"]) "nothing" "nothing" ([:toarray "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30"]) "31 elements strictly descending"]
    :set res [$RunGenericTestCase $res $QuickSort ([:toarray "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30"]) "nothing" "nothing" ([:toarray "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30"]) "31 elements already sorted"]

    :put "Testing completed."
    :return $res
}

:set DivideIntAndRoundTest do={
    :global RunGenericTestCase
    :global DivideIntAndRound

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting DivideIntAndRound decimal precision tests..."

    # Zero decimal places (fallback to rounded integer string)
    :set res [$RunGenericTestCase $res $DivideIntAndRound 10 3 0 "3" "Round down to integer standard case"]
    :set res [$RunGenericTestCase $res $DivideIntAndRound 11 3 0 "4" "Round up to integer standard case"]
    :set res [$RunGenericTestCase $res $DivideIntAndRound 5 2 0 "3" "Round half up boundary to integer"]

    # Division by zero error handling
    :set res [$RunGenericTestCase $res $DivideIntAndRound 10 0 2 "Division by zero error" "Division by zero guard clause validation"]

    # Exact division with formatting padding validation
    :set res [$RunGenericTestCase $res $DivideIntAndRound 4 2 3 "2.000" "Exact division with trailing zeros padding"]
    :set res [$RunGenericTestCase $res $DivideIntAndRound 0 5 2 "0.00" "Zero numerator with decimal places format"]

    # Standard rounding operations (down, up, half-up)
    :set res [$RunGenericTestCase $res $DivideIntAndRound 10 7 7 "1.4285714" "Example target step documentation case"]
    :set res [$RunGenericTestCase $res $DivideIntAndRound 2 3 3 "0.667" "Repeating decimal rounding up case"]
    :set res [$RunGenericTestCase $res $DivideIntAndRound 1 3 3 "0.333" "Repeating decimal rounding down case"]

    # Results strictly smaller than one (leading zero verification)
    :set res [$RunGenericTestCase $res $DivideIntAndRound 1 8 3 "0.125" "Fraction result with leading zero and exact decimals"]
    :set res [$RunGenericTestCase $res $DivideIntAndRound 1 200 4 "0.0050" "Small fraction requiring single leading zero inside decimal part"]
    :set res [$RunGenericTestCase $res $DivideIntAndRound 1 2000 5 "0.00050" "Very small fraction requiring multiple padding zeros"]

    :put "Testing completed."
    :return $res
}

:set ToUpperCaseTest do={
    :global RunGenericTestCase
    :global ToUpperCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting ToUpperCase tests..."

    # Basic conversion
    :set res [$RunGenericTestCase $res $ToUpperCase "hello" "nothing" "nothing" "HELLO" "All lowercase"]
    :set res [$RunGenericTestCase $res $ToUpperCase "WORLD" "nothing" "nothing" "WORLD" "All uppercase"]
    :set res [$RunGenericTestCase $res $ToUpperCase "MikroTik" "nothing" "nothing" "MIKROTIK" "Mixed case"]

    # Edge cases
    :set res [$RunGenericTestCase $res $ToUpperCase "" "nothing" "nothing" "" "Empty string"]
    :set res [$RunGenericTestCase $res $ToUpperCase "a" "nothing" "nothing" "A" "Single lowercase letter"]
    :set res [$RunGenericTestCase $res $ToUpperCase "Z" "nothing" "nothing" "Z" "Single uppercase letter"]

    # Numbers and special characters (should remain unchanged)
    :set res [$RunGenericTestCase $res $ToUpperCase "12345" "nothing" "nothing" "12345" "Digits only"]
    :set res [$RunGenericTestCase $res $ToUpperCase "hello 123!" "nothing" "nothing" "HELLO 123!" "Lowercase with digits and spaces"]
    :set res [$RunGenericTestCase $res $ToUpperCase "abc-def_ghi" "nothing" "nothing" "ABC-DEF_GHI" "Lowercase with symbols"]
    :set res [$RunGenericTestCase $res $ToUpperCase "ABC-DEF_GHI" "nothing" "nothing" "ABC-DEF_GHI" "Uppercase with symbols"]

    :put "Testing completed."
    :return $res
}

:set ToLowerCaseTest do={
    :global RunGenericTestCase
    :global ToLowerCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting ToLowerCase tests..."

    # Basic conversion
    :set res [$RunGenericTestCase $res $ToLowerCase "HELLO" "nothing" "nothing" "hello" "All uppercase"]
    :set res [$RunGenericTestCase $res $ToLowerCase "world" "nothing" "nothing" "world" "All lowercase"]
    :set res [$RunGenericTestCase $res $ToLowerCase "MikroTik" "nothing" "nothing" "mikrotik" "Mixed case"]

    # Edge cases
    :set res [$RunGenericTestCase $res $ToLowerCase "" "nothing" "nothing" "" "Empty string"]
    :set res [$RunGenericTestCase $res $ToLowerCase "A" "nothing" "nothing" "a" "Single uppercase letter"]
    :set res [$RunGenericTestCase $res $ToLowerCase "z" "nothing" "nothing" "z" "Single lowercase letter"]

    # Numbers and special characters (should remain unchanged)
    :set res [$RunGenericTestCase $res $ToLowerCase "12345" "nothing" "nothing" "12345" "Digits only"]
    :set res [$RunGenericTestCase $res $ToLowerCase "HELLO 123!" "nothing" "nothing" "hello 123!" "Uppercase with digits and spaces"]
    :set res [$RunGenericTestCase $res $ToLowerCase "abc-def_ghi" "nothing" "nothing" "abc-def_ghi" "Lowercase with symbols"]
    :set res [$RunGenericTestCase $res $ToLowerCase "ABC-DEF_GHI" "nothing" "nothing" "abc-def_ghi" "Uppercase with symbols"]

    :put "Testing completed."
    :return $res
}

:set HexToCharTest do={
    :global RunGenericTestCase
    :global HexToChar

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting HexToChar tests..."

    # Printable Characters (Standard Ranges)
    :set res [$RunGenericTestCase $res $HexToChar "30" "nothing" "nothing" "0" "Digit 0"]
    :set res [$RunGenericTestCase $res $HexToChar "39" "nothing" "nothing" "9" "Digit 9"]
    :set res [$RunGenericTestCase $res $HexToChar "41" "nothing" "nothing" "A" "Capital A"]
    :set res [$RunGenericTestCase $res $HexToChar "5A" "nothing" "nothing" "Z" "Capital Z"]
    :set res [$RunGenericTestCase $res $HexToChar "61" "nothing" "nothing" "a" "Lowercase a"]
    :set res [$RunGenericTestCase $res $HexToChar "7A" "nothing" "nothing" "z" "Lowercase z"]

    # Special Characters & Spaces
    :set res [$RunGenericTestCase $res $HexToChar "20" "nothing" "nothing" " " "Space character"]
    :set res [$RunGenericTestCase $res $HexToChar "21" "nothing" "nothing" "!" "Exclamation mark"]
    :set res [$RunGenericTestCase $res $HexToChar "24" "nothing" "nothing" ("\$") "Dollar sign"]
    :set res [$RunGenericTestCase $res $HexToChar "2B" "nothing" "nothing" "+" "Plus sign"]
    :set res [$RunGenericTestCase $res $HexToChar "3D" "nothing" "nothing" "=" "Equals sign"]
    :set res [$RunGenericTestCase $res $HexToChar "40" "nothing" "nothing" "@" "At symbol"]
    :set res [$RunGenericTestCase $res $HexToChar "5F" "nothing" "nothing" "_" "Underscore"]

    # Control Characters (Whitespace/Escapes)
    :set res [$RunGenericTestCase $res $HexToChar "09" "nothing" "nothing" ("\t") "Tab character"]
    :set res [$RunGenericTestCase $res $HexToChar "0A" "nothing" "nothing" ("\n") "Line feed / Newline"]
    :set res [$RunGenericTestCase $res $HexToChar "0D" "nothing" "nothing" ("\r") "Carriage return"]

    # Boundaries of 8-bit ASCII / Extended
    :set res [$RunGenericTestCase $res $HexToChar "00" "nothing" "nothing" ("\00") "Null byte boundary"]
    :set res [$RunGenericTestCase $res $HexToChar "7E" "nothing" "nothing" "~" "Tilde (Last standard printable)"]
    :set res [$RunGenericTestCase $res $HexToChar "7F" "nothing" "nothing" ("\7F") "Delete control char"]

    # Special Characters & Spaces (lowercase hex)
    :set res [$RunGenericTestCase $res $HexToChar "2b" "nothing" "nothing" "+" "Plus sign (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "2c" "nothing" "nothing" "," "Comma (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "2f" "nothing" "nothing" "/" "Forward slash (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "3a" "nothing" "nothing" ":" "Colon (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "3b" "nothing" "nothing" ";" "Semicolon (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "3d" "nothing" "nothing" "=" "Equals sign (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "3f" "nothing" "nothing" "?" "Question mark (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "40" "nothing" "nothing" "@" "At symbol"]
    :set res [$RunGenericTestCase $res $HexToChar "5b" "nothing" "nothing" "[" "Left square bracket (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "5c" "nothing" "nothing" ("\\") "Backslash (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "5d" "nothing" "nothing" "]" "Right square bracket (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "5f" "nothing" "nothing" "_" "Underscore (lowercase hex)"]

    # Control Characters (Whitespace/Escapes)
    :set res [$RunGenericTestCase $res $HexToChar "0a" "nothing" "nothing" ("\n") "Line feed / Newline (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "0d" "nothing" "nothing" ("\r") "Carriage return (lowercase hex)"]

    # Boundaries of 8-bit ASCII / Extended
    :set res [$RunGenericTestCase $res $HexToChar "7e" "nothing" "nothing" "~" "Tilde (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "7f" "nothing" "nothing" ("\7F") "Delete control char (lowercase hex)"]
    :set res [$RunGenericTestCase $res $HexToChar "ff" "nothing" "nothing" ("\FF") "Extended ASCII upper boundary (lowercase hex)"]

    :put "Testing completed."
    :return $res
}

:set DecToCharTest do={
    :global RunGenericTestCase
    :global DecToChar

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting DecToChar tests..."

    # Printable Characters (Standard Ranges)
    :set res [$RunGenericTestCase $res $DecToChar 48 "nothing" "nothing" "0" "Digit 0"]
    :set res [$RunGenericTestCase $res $DecToChar 57 "nothing" "nothing" "9" "Digit 9"]
    :set res [$RunGenericTestCase $res $DecToChar 65 "nothing" "nothing" "A" "Capital A"]
    :set res [$RunGenericTestCase $res $DecToChar 90 "nothing" "nothing" "Z" "Capital Z"]
    :set res [$RunGenericTestCase $res $DecToChar 97 "nothing" "nothing" "a" "Lowercase a"]
    :set res [$RunGenericTestCase $res $DecToChar 122 "nothing" "nothing" "z" "Lowercase z"]

    # Special Characters & Spaces
    :set res [$RunGenericTestCase $res $DecToChar 32 "nothing" "nothing" " " "Space character"]
    :set res [$RunGenericTestCase $res $DecToChar 33 "nothing" "nothing" "!" "Exclamation mark"]
    :set res [$RunGenericTestCase $res $DecToChar 36 "nothing" "nothing" ("\$") "Dollar sign"]
    :set res [$RunGenericTestCase $res $DecToChar 43 "nothing" "nothing" "+" "Plus sign"]
    :set res [$RunGenericTestCase $res $DecToChar 61 "nothing" "nothing" "=" "Equals sign"]
    :set res [$RunGenericTestCase $res $DecToChar 64 "nothing" "nothing" "@" "At symbol"]
    :set res [$RunGenericTestCase $res $DecToChar 95 "nothing" "nothing" "_" "Underscore"]

    # Control Characters (Whitespace/Escapes)
    :set res [$RunGenericTestCase $res $DecToChar 9 "nothing" "nothing" ("\t") "Tab character"]
    :set res [$RunGenericTestCase $res $DecToChar 10 "nothing" "nothing" ("\n") "Line feed / Newline"]
    :set res [$RunGenericTestCase $res $DecToChar 13 "nothing" "nothing" ("\r") "Carriage return"]

    # Boundaries of 8-bit ASCII / Extended
    :set res [$RunGenericTestCase $res $DecToChar 0 "nothing" "nothing" ("\00") "Null byte boundary"]
    :set res [$RunGenericTestCase $res $DecToChar 126 "nothing" "nothing" "~" "Tilde (Last standard printable)"]
    :set res [$RunGenericTestCase $res $DecToChar 127 "nothing" "nothing" ("\7F") "Delete control char"]

    :put "Testing completed."
    :return $res
}
