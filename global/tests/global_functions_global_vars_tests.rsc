:global RunAllGlobalVarTests
:global GlobalVarTest

:set RunAllGlobalVarTests do={
    :global GlobalVarTest

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :put "\1B[35m=== STARTING ALL GLOBAL VAR TESTS ===\1B[0m"

    :set res [$GlobalVarTest $res]

    :put "\1B[35m=== ALL GLOBAL VAR TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set GlobalVarTest do={
    :global DeclareGlobalVar
    :global GetGlobalVar
    :global GetGlobalVarOrDefault
    :global SetGlobalVar
    :global RemoveGlobalVar
    :global DecToChar
    :global IsPrintableStr

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    # Helper function to validate results and update counters
    :local RunTestCase do={
        :global IsPrintableStr

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local actual [:tostr $2]
        :local expected [:tostr $3]
        :local name [:tostr $4]
        :local input $5

        :local inputDisplay $input
        :if (![$IsPrintableStr $inputDisplay]) do={
            :set inputDisplay "<binary string>"
        }

        :local actualDisplay $actual
        :if (![$IsPrintableStr $actualDisplay]) do={
            :set actualDisplay "<binary string>"
        }

        :local expectedDisplay $expected
        :if (![$IsPrintableStr $expectedDisplay]) do={
            :set expectedDisplay "<binary string>"
        }

        :if ($actual = $expected) do={
            :put ("  \1B[32m[PASS]\1B[0m " . $name . ": '" . $inputDisplay . "' -> '" . $actualDisplay . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . ": '" . $inputDisplay . "' | Expected: '" . $expectedDisplay . "', Got: '" . $actualDisplay . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }
        :return $state
    }

    :put "Starting GlobalVarUtils tests..."

    # --- Test 1: DeclareGlobalVar & GetGlobalVar (Uninitialized) ---
    $DeclareGlobalVar "testVarUnset"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarUnset"] "" "Declare and get uninitialized variable"]

    # --- Test 2: SetGlobalVar & GetGlobalVar (String) ---
    $SetGlobalVar "testVarStr" "helloMikrotik"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarStr"] "helloMikrotik" "Set and get string value"]

    # --- Test 3: SetGlobalVar & GetGlobalVar (String with Double Quotes) ---
    $SetGlobalVar "testVarQuotes" ("text \"with\" quotes")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarQuotes"] ("text \"with\" quotes") "Set and get string with internal double quotes"]

    # --- Test 4: SetGlobalVar & GetGlobalVar (Integer) ---
    $SetGlobalVar "testVarInt" 12345
    :set res [$RunTestCase $res [$GetGlobalVar "testVarInt"] "12345" "Set and get integer value"]

    # --- Test 5: SetGlobalVar & GetGlobalVar (Boolean) ---
    $SetGlobalVar "testVarBool" true
    :set res [$RunTestCase $res [$GetGlobalVar "testVarBool"] "true" "Set and get boolean value"]

    # --- Test 6: GetGlobalVarOrDefault (Variable Exists) ---
    $SetGlobalVar "testVarExist" "activeValue"
    :set res [$RunTestCase $res [$GetGlobalVarOrDefault "testVarExist" "defaultFallback"] "activeValue" "Get existing variable value with default fallback"]

    # --- Test 7: GetGlobalVarOrDefault (Variable Is Nothing/Unset) ---
    :set res [$RunTestCase $res [$GetGlobalVarOrDefault "testVarNonExistent" "fallbackStr"] "fallbackStr" "Get non-existent variable returns default string"]
    :set res [$RunTestCase $res [$GetGlobalVarOrDefault "testVarNonExistent" 999] "999" "Get non-existent variable returns default integer"]

    # --- Test 8: RemoveGlobalVar ---
    $SetGlobalVar "testVarToRemove" "temporaryData"
    $RemoveGlobalVar "testVarToRemove"
    :set res [$RunTestCase $res [$GetGlobalVarOrDefault "testVarToRemove" "removedSuccessfully"] "removedSuccessfully" "Remove global variable and verify deletion"]

    # --- Test 9: SetGlobalVar & GetGlobalVar (Float / Num) ---
    $SetGlobalVar "testVarFloat" 15.65
    :set res [$RunTestCase $res [$GetGlobalVar "testVarFloat"] "15.65" "Set and get float number value"]

    # --- Test 10: SetGlobalVar & GetGlobalVar (IP Address) ---
    $SetGlobalVar "testVarIp" 192.168.88.1
    :set res [$RunTestCase $res [$GetGlobalVar "testVarIp"] "192.168.88.1" "Set and get IP address value"]

    # --- Test 11: SetGlobalVar & GetGlobalVar (IP Prefix / Subnet) ---
    $SetGlobalVar "testVarPrefix" 10.0.0.0/24
    :set res [$RunTestCase $res [$GetGlobalVar "testVarPrefix"] "10.0.0.0/24" "Set and get IP prefix value"]

    # --- Test 12: SetGlobalVar & GetGlobalVar (Time) ---
    $SetGlobalVar "testVarTime" 01:15:30
    :set res [$RunTestCase $res [$GetGlobalVar "testVarTime"] "01:15:30" "Set and get time value"]

    # --- Test 13: SetGlobalVar & GetGlobalVar (Array) ---
    $SetGlobalVar "testVarArray" [:toarray "a,b,c"]
    :set res [$RunTestCase $res [$GetGlobalVar "testVarArray"] "a;b;c" "Set and get simple array structure"]

    # --- Test 14: GetGlobalVarOrDefault (With Float and IP Fallbacks) ---
    :set res [$RunTestCase $res [$GetGlobalVarOrDefault "testVarNonExistent" 25.45] "25.45" "Get non-existent variable returns default float"]
    :set res [$RunTestCase $res [$GetGlobalVarOrDefault "testVarNonExistent" 10.0.0.1] "10.0.0.1" "Get non-existent variable returns default IP address"]

    # --- Test 15: SetGlobalVar & GetGlobalVar (Associative Array) ---
    :local assocKeyVal [:toarray ""]
    :set ($assocKeyVal->"host") "192.168.88.1"
    :set ($assocKeyVal->"port") 8080
    $SetGlobalVar "testVarAssocArray" $assocKeyVal
    :set res [$RunTestCase $res [$GetGlobalVar "testVarAssocArray"] "host=192.168.88.1;port=8080" "Set and get associative array"]

    # --- Test 16: GetGlobalVarOrDefault (Associative Array Fallback) ---
    :local defaultAssoc [:toarray ""]
    :set ($defaultAssoc->"status") "down"
    :set res [$RunTestCase $res [$GetGlobalVarOrDefault "testVarNonExistent" $defaultAssoc] "status=down" "Get non-existent variable returns default associative array"]

    # --- Test 17: Empty String ---
    $SetGlobalVar "testVarEmpty" ""
    :set res [$RunTestCase $res [$GetGlobalVar "testVarEmpty"] "" "Set and get empty string"]

    # --- Test 18: Overwrite Existing Value ---
    $SetGlobalVar "testVarOverwrite" "first"
    $SetGlobalVar "testVarOverwrite" "second"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarOverwrite"] "second" "Overwrite existing global variable"]

    # --- Test 19: Change Value Type ---
    $SetGlobalVar "testVarType" "text"
    $SetGlobalVar "testVarType" 555
    :set res [$RunTestCase $res [$GetGlobalVar "testVarType"] "555" "Overwrite string with integer"]

    # --- Test 20: Boolean False ---
    $SetGlobalVar "testVarFalse" false
    :set res [$RunTestCase $res [$GetGlobalVar "testVarFalse"] "false" "Set and get boolean false"]

    # --- Test 21: Integer Zero ---
    $SetGlobalVar "testVarZero" 0
    :set res [$RunTestCase $res [$GetGlobalVar "testVarZero"] "0" "Set and get zero"]

    # --- Test 22: Negative Integer ---
    $SetGlobalVar "testVarNegative" -123
    :set res [$RunTestCase $res [$GetGlobalVar "testVarNegative"] "-123" "Set and get negative integer"]

    # --- Test 23: Long String ---
    :local longString ""
    :for i from=1 to=500 do={
        :set longString ($longString . "A")
    }
    $SetGlobalVar "testVarLong" $longString
    :set res [$RunTestCase $res [$GetGlobalVar "testVarLong"] $longString "Set and get long string"]

    # --- Test 25: Special Characters ---
    $SetGlobalVar "testVarSpecial" ("\\/\$[]{}();,:|")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarSpecial"] ("\\/\$[]{}();,:|") "Set and get special characters"]

    # --- Test 26: Multiple Updates ---
    :for i from=1 to=100 do={
        $SetGlobalVar "testVarLoop" $i
    }
    :set res [$RunTestCase $res [$GetGlobalVar "testVarLoop"] "100" "Multiple sequential updates"]

    # --- Test 27: Remove Twice ---
    $SetGlobalVar "testVarRemoveTwice" "x"
    $RemoveGlobalVar "testVarRemoveTwice"
    $RemoveGlobalVar "testVarRemoveTwice"
    :set res [$RunTestCase $res [$GetGlobalVarOrDefault "testVarRemoveTwice" "ok"] "ok" "Remove already removed variable"]

    # --- Test 28: Declare Existing Variable ---
    $SetGlobalVar "testVarDeclare" "value"
    $DeclareGlobalVar "testVarDeclare"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarDeclare"] "value" "Declare existing variable preserves value"]

    # --- Test 29: Default Does Not Create Variable ---
    [$GetGlobalVarOrDefault "testVarDefault" "fallback"]
    :set res [$RunTestCase $res [$GetGlobalVar "testVarDefault"] "" "GetGlobalVarOrDefault does not create variable"]

    # --- Test 30: Variable Isolation ---
    $SetGlobalVar "testVarA" "AAA"
    $SetGlobalVar "testVarB" "BBB"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarA"] "AAA" "Variables are independent (A)"]
    :set res [$RunTestCase $res [$GetGlobalVar "testVarB"] "BBB" "Variables are independent (B)"]

    # --- Test: Space ---
    $SetGlobalVar "testVarSpace" "Hello World"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarSpace"] "Hello World" "String with spaces"]

    # --- Test: Leading and trailing spaces ---
    $SetGlobalVar "testVarSpaces" "  Hello World  "
    :set res [$RunTestCase $res [$GetGlobalVar "testVarSpaces"] "  Hello World  " "Leading and trailing spaces"]

    # --- Test: Tabs ---
    $SetGlobalVar "testVarTabs" ("A\tB\tC")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarTabs"] ("A\tB\tC") "String with tabs"]

    # --- Test: New lines ---
    $SetGlobalVar "testVarNewLines" ("Line1\nLine2\nLine3")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarNewLines"] ("Line1\nLine2\nLine3") "String with new lines"]

    # --- Test: Carriage return ---
    $SetGlobalVar "testVarCR" ("Line1\rLine2")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarCR"] ("Line1\rLine2") "String with carriage return"]

    # --- Test: Quotes ---
    $SetGlobalVar "testVarQuotes2" ("\"Hello\"")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarQuotes2"] ("\"Hello\"") "Double quotes"]

    # --- Test: Single quotes ---
    $SetGlobalVar "testVarSingleQuotes" "'Hello'"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarSingleQuotes"] "'Hello'" "Single quotes"]

    # --- Test: Backslashes ---
    $SetGlobalVar "testVarBackslash" ("\\server\\share\\dir")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarBackslash"] ("\\server\\share\\dir") "Backslashes"]

    # --- Test: Dollar sign ---
    $SetGlobalVar "testVarDollar" ("\$abc$123")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarDollar"] ("\$abc$123") "Dollar sign"]

    # --- Test: Percent signs ---
    $SetGlobalVar "testVarPercent" "100% complete"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarPercent"] "100% complete" "Percent signs"]

    # --- Test: URL characters ---
    $SetGlobalVar "testVarUrl" "https://example.com/test?a=1&b=2#fragment"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarUrl"] "https://example.com/test?a=1&b=2#fragment" "URL"]

    # --- Test: File path ---
    $SetGlobalVar "testVarPath" ("C:\\Program Files\\RouterOS\\test.txt")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarPath"] ("C:\\Program Files\\RouterOS\\test.txt") "Windows path"]

    # --- Test: Shell characters ---
    $SetGlobalVar "testVarShell" "&|;<>`(){}[]"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarShell"] "&|;<>`(){}[]" "Shell metacharacters"]

    # --- Test: Math symbols ---
    $SetGlobalVar "testVarMath" "+-*/=%^"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarMath"] "+-*/=%^" "Math symbols"]

    # --- Test: Punctuation ---
    $SetGlobalVar "testVarPunctuation" ".,:!?@#~"
    :set res [$RunTestCase $res [$GetGlobalVar "testVarPunctuation"] ".,:!?@#~" "Punctuation"]

    # --- Test: Mixed special characters ---
    $SetGlobalVar "testVarMixed" ("\"%\\\$&;=+?<>[]{}()\n\r\t")
    :set res [$RunTestCase $res [$GetGlobalVar "testVarMixed"] ("\"%\\\$&;=+?<>[]{}()\n\r\t") "Mixed special characters"]

    # --- Test: Empty string ---
    $SetGlobalVar "testVarEmpty2" ""
    :set res [$RunTestCase $res [$GetGlobalVar "testVarEmpty2"] "" "Empty string"]

    # --- Test: All 256 Byte Values ---
    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    $SetGlobalVar "testVarAllChars" $allChars
    :set res [$RunTestCase $res [$GetGlobalVar "testVarAllChars"] $allChars "String containing all byte values (0-255)"]

    # --- Cleanup environment ---
    # Removing environmental pollution from tests
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
