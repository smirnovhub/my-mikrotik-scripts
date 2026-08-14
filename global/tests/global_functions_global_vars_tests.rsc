:global RunAllGlobalVarTests
:global GlobalVarTest

:set RunAllGlobalVarTests do={
    :global GlobalVarTest

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "\1B[35m=== STARTING ALL GLOBAL VAR TESTS ===\1B[0m"

    :set res [$GlobalVarTest $res]

    :put "\1B[35m=== ALL GLOBAL VAR TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set GlobalVarTest do={
    :global GetGlobalVar
    :global GetGlobalVarOrDefault
    :global SetGlobalVar
    :global RemoveGlobalVar
    :global DecToChar
    :global RunGenericTestCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting GlobalVarUtils tests..."

    # SetGlobalVar & GetGlobalVar (String)
    $SetGlobalVar "testVarStr" "helloMikrotik"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarStr" "nothing" "nothing" "helloMikrotik" "Set and get string value"]

    # SetGlobalVar & GetGlobalVar (String with Double Quotes)
    $SetGlobalVar "testVarQuotes" ("text \"with\" quotes")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarQuotes" "nothing" "nothing" ("text \"with\" quotes") "Set and get string with internal double quotes"]

    # SetGlobalVar & GetGlobalVar (Integer)
    $SetGlobalVar "testVarInt" 12345
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarInt" "nothing" "nothing" 12345 "Set and get integer value"]

    # SetGlobalVar & GetGlobalVar (Boolean)
    $SetGlobalVar "testVarBool" true
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarBool" "nothing" "nothing" true "Set and get boolean value"]

    # GetGlobalVarOrDefault (Variable Exists)
    $SetGlobalVar "testVarExist" "activeValue"
    :set res [$RunGenericTestCase $res $GetGlobalVarOrDefault "testVarExist" "defaultFallback" "nothing" "activeValue" "Get existing variable value with default fallback"]

    # GetGlobalVarOrDefault (Variable Is Nothing/Unset)
    :set res [$RunGenericTestCase $res $GetGlobalVarOrDefault "testVarNonExistent" "fallbackStr" "nothing" "fallbackStr" "Get non-existent variable returns default string"]
    :set res [$RunGenericTestCase $res $GetGlobalVarOrDefault "testVarNonExistent" 999 "nothing" 999 "Get non-existent variable returns default integer"]

    # RemoveGlobalVar
    $SetGlobalVar "testVarToRemove" "temporaryData"
    $RemoveGlobalVar "testVarToRemove"
    :set res [$RunGenericTestCase $res $GetGlobalVarOrDefault "testVarToRemove" "removedSuccessfully" "nothing" "removedSuccessfully" "Remove global variable and verify deletion"]

    # SetGlobalVar & GetGlobalVar (Float / Num)
    $SetGlobalVar "testVarFloat" 15.65
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarFloat" "nothing" "nothing" 15.65 "Set and get float number value"]

    # SetGlobalVar & GetGlobalVar (IP Address)
    $SetGlobalVar "testVarIp" 192.168.88.1
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarIp" "nothing" "nothing" 192.168.88.1 "Set and get IP address value"]

    # SetGlobalVar & GetGlobalVar (IP Prefix / Subnet)
    $SetGlobalVar "testVarPrefix" 10.0.0.0/24
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarPrefix" "nothing" "nothing" 10.0.0.0/24 "Set and get IP prefix value"]

    # SetGlobalVar & GetGlobalVar (Time)
    $SetGlobalVar "testVarTime" 01:15:30
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarTime" "nothing" "nothing" 01:15:30 "Set and get time value"]

    # SetGlobalVar & GetGlobalVar (Array)
    $SetGlobalVar "testVarArray" [:toarray "a,b,c"]
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarArray" "nothing" "nothing" "a;b;c" "Set and get simple array structure"]

    # GetGlobalVarOrDefault (With Float and IP Fallbacks)
    :set res [$RunGenericTestCase $res $GetGlobalVarOrDefault "testVarNonExistent" 25.45 "nothing" 25.45 "Get non-existent variable returns default float"]
    :set res [$RunGenericTestCase $res $GetGlobalVarOrDefault "testVarNonExistent" 10.0.0.1 "nothing" 10.0.0.1 "Get non-existent variable returns default IP address"]

    # SetGlobalVar & GetGlobalVar (Associative Array)
    :local assocKeyVal [:toarray ""]
    :set ($assocKeyVal->"host") "192.168.88.1"
    :set ($assocKeyVal->"port") 8080
    $SetGlobalVar "testVarAssocArray" $assocKeyVal
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarAssocArray" "nothing" "nothing" "host=192.168.88.1;port=8080" "Set and get associative array"]

    # GetGlobalVarOrDefault (Associative Array Fallback)
    :local defaultAssoc [:toarray ""]
    :set ($defaultAssoc->"status") "down"
    :set res [$RunGenericTestCase $res $GetGlobalVarOrDefault "testVarNonExistent" $defaultAssoc "nothing" "status=down" "Get non-existent variable returns default associative array"]

    # Empty String
    $SetGlobalVar "testVarEmpty" ""
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarEmpty" "nothing" "nothing" "" "Set and get empty string"]

    # Overwrite Existing Value
    $SetGlobalVar "testVarOverwrite" "first"
    $SetGlobalVar "testVarOverwrite" "second"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarOverwrite" "nothing" "nothing" "second" "Overwrite existing global variable"]

    # Change Value Type
    $SetGlobalVar "testVarType" "text"
    $SetGlobalVar "testVarType" 555
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarType" "nothing" "nothing" 555 "Overwrite string with integer"]

    # Boolean False
    $SetGlobalVar "testVarFalse" false
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarFalse" "nothing" "nothing" false "Set and get boolean false"]

    # Integer Zero
    $SetGlobalVar "testVarZero" 0
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarZero" "nothing" "nothing" 0 "Set and get zero"]

    # Negative Integer
    $SetGlobalVar "testVarNegative" -123
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarNegative" "nothing" "nothing" -123 "Set and get negative integer"]

    # Long String
    :local longString ""
    :for i from=1 to=500 do={
        :set longString ($longString . "A")
    }
    $SetGlobalVar "testVarLong" $longString
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarLong" "nothing" "nothing" $longString "Set and get long string"]

    # Special Characters
    $SetGlobalVar "testVarSpecial" ("\\/\$[]{}();,:|")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarSpecial" "nothing" "nothing" ("\\/\$[]{}();,:|") "Set and get special characters"]

    # Multiple Updates
    :for i from=1 to=100 do={
        $SetGlobalVar "testVarLoop" $i
    }
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarLoop" "nothing" "nothing" 100 "Multiple sequential updates"]

    # Remove Twice
    $SetGlobalVar "testVarRemoveTwice" "x"
    $RemoveGlobalVar "testVarRemoveTwice"
    $RemoveGlobalVar "testVarRemoveTwice"
    :set res [$RunGenericTestCase $res $GetGlobalVarOrDefault "testVarRemoveTwice" "ok" "nothing" "ok" "Remove already removed variable"]

    # Default Does Not Create Variable
    [$GetGlobalVarOrDefault "testVarDefault" "fallback"]
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarDefault" "nothing" "nothing" "" "GetGlobalVarOrDefault does not create variable"]

    # Variable Isolation
    $SetGlobalVar "testVarA" "AAA"
    $SetGlobalVar "testVarB" "BBB"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarA" "nothing" "nothing" "AAA" "Variables are independent (A)"]
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarB" "nothing" "nothing" "BBB" "Variables are independent (B)"]

    # Space
    $SetGlobalVar "testVarSpace" "Hello World"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarSpace" "nothing" "nothing" "Hello World" "String with spaces"]

    # Leading and trailing spaces
    $SetGlobalVar "testVarSpaces" "  Hello World  "
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarSpaces" "nothing" "nothing" "  Hello World  " "Leading and trailing spaces"]

    # Tabs
    $SetGlobalVar "testVarTabs" ("A\tB\tC")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarTabs" "nothing" "nothing" ("A\tB\tC") "String with tabs"]

    # New lines
    $SetGlobalVar "testVarNewLines" ("Line1\nLine2\nLine3")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarNewLines" "nothing" "nothing" ("Line1\nLine2\nLine3") "String with new lines"]

    # Carriage return
    $SetGlobalVar "testVarCR" ("Line1\rLine2")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarCR" "nothing" "nothing" ("Line1\rLine2") "String with carriage return"]

    # Quotes
    $SetGlobalVar "testVarQuotes2" ("\"Hello\"")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarQuotes2" "nothing" "nothing" ("\"Hello\"") "Double quotes"]

    # Single quotes
    $SetGlobalVar "testVarSingleQuotes" "'Hello'"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarSingleQuotes" "nothing" "nothing" "'Hello'" "Single quotes"]

    # Backslashes
    $SetGlobalVar "testVarBackslash" ("\\server\\share\\dir")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarBackslash" "nothing" "nothing" ("\\server\\share\\dir") "Backslashes"]

    # Dollar sign
    $SetGlobalVar "testVarDollar" ("\$abc$123")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarDollar" "nothing" "nothing" ("\$abc$123") "Dollar sign"]

    # Percent signs
    $SetGlobalVar "testVarPercent" "100% complete"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarPercent" "nothing" "nothing" "100% complete" "Percent signs"]

    # URL characters
    $SetGlobalVar "testVarUrl" "https://example.com/test?a=1&b=2#fragment"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarUrl" "nothing" "nothing" "https://example.com/test?a=1&b=2#fragment" "URL"]

    # File path
    $SetGlobalVar "testVarPath" ("C:\\Program Files\\RouterOS\\test.txt")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarPath" "nothing" "nothing" ("C:\\Program Files\\RouterOS\\test.txt") "Windows path"]

    # Shell characters
    $SetGlobalVar "testVarShell" "&|;<>`(){}[]"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarShell" "nothing" "nothing" "&|;<>`(){}[]" "Shell metacharacters"]

    # Math symbols
    $SetGlobalVar "testVarMath" "+-*/=%^"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarMath" "nothing" "nothing" "+-*/=%^" "Math symbols"]

    # Punctuation
    $SetGlobalVar "testVarPunctuation" ".,:!?@#~"
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarPunctuation" "nothing" "nothing" ".,:!?@#~" "Punctuation"]

    # Mixed special characters
    $SetGlobalVar "testVarMixed" ("\"%\\\$&;=+?<>[]{}()\n\r\t")
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarMixed" "nothing" "nothing" ("\"%\\\$&;=+?<>[]{}()\n\r\t") "Mixed special characters"]

    # Empty string
    $SetGlobalVar "testVarEmpty2" ""
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarEmpty2" "nothing" "nothing" "" "Empty string"]

    # All 256 Byte Values
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    $SetGlobalVar "testVarAllChars" $allChars
    :set res [$RunGenericTestCase $res $GetGlobalVar "testVarAllChars" "nothing" "nothing" $allChars "String containing all byte values (0-255)"]

    # Cleanup environment
    $RemoveGlobalVar "testVarUnset"
    $RemoveGlobalVar "testVarStr"
    $RemoveGlobalVar "testVarQuotes"
    $RemoveGlobalVar "testVarInt"
    $RemoveGlobalVar "testVarBool"
    $RemoveGlobalVar "testVarExist"
    $RemoveGlobalVar "testVarFloat"
    $RemoveGlobalVar "testVarIp"
    $RemoveGlobalVar "testVarPrefix"
    $RemoveGlobalVar "testVarTime"
    $RemoveGlobalVar "testVarArray"
    $RemoveGlobalVar "testVarAssocArray"
    $RemoveGlobalVar "testVarEmpty"
    $RemoveGlobalVar "testVarOverwrite"
    $RemoveGlobalVar "testVarType"
    $RemoveGlobalVar "testVarFalse"
    $RemoveGlobalVar "testVarZero"
    $RemoveGlobalVar "testVarNegative"
    $RemoveGlobalVar "testVarLong"
    $RemoveGlobalVar "testVarSpecial"
    $RemoveGlobalVar "testVarLoop"
    $RemoveGlobalVar "testVarRemoveTwice"
    $RemoveGlobalVar "testVarDeclare"
    $RemoveGlobalVar "testVarDefault"
    $RemoveGlobalVar "testVarA"
    $RemoveGlobalVar "testVarB"
    $RemoveGlobalVar "testVarSpace"
    $RemoveGlobalVar "testVarSpaces"
    $RemoveGlobalVar "testVarTabs"
    $RemoveGlobalVar "testVarNewLines"
    $RemoveGlobalVar "testVarCR"
    $RemoveGlobalVar "testVarQuotes2"
    $RemoveGlobalVar "testVarSingleQuotes"
    $RemoveGlobalVar "testVarBackslash"
    $RemoveGlobalVar "testVarDollar"
    $RemoveGlobalVar "testVarPercent"
    $RemoveGlobalVar "testVarUrl"
    $RemoveGlobalVar "testVarPath"
    $RemoveGlobalVar "testVarShell"
    $RemoveGlobalVar "testVarMath"
    $RemoveGlobalVar "testVarPunctuation"
    $RemoveGlobalVar "testVarMixed"
    $RemoveGlobalVar "testVarEmpty2"
    $RemoveGlobalVar "testVarAllChars"

    :put "Testing completed."
    :return $res
}
