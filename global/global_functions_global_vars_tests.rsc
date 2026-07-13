:global RunAllGlobalVarTests
:global GlobalVarTest

:set RunAllGlobalVarTests do={
    :global GlobalVarTest

    :put "\1B[35m=== STARTING ALL GLOBAL VAR TESTS ===\1B[0m"

    $GlobalVarTest

    :put "\1B[35m=== ALL GLOBAL VAR TESTS EXECUTED ===\1B[0m"
}

:set GlobalVarTest do={
    :global DeclareGlobalVar
    :global GetGlobalVar
    :global GetGlobalVarOrDefault
    :global SetGlobalVar
    :global RemoveGlobalVar

    :global testsPassedCount
    :global testsFailedCount

    # Helper function to validate results and update counters
    :local RunTestCase do={
        :global testsPassedCount
        :global testsFailedCount

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return ""
        }

        :local actual [:tostr $1]
        :local expected [:tostr $2]
        :local name [:tostr $3]

        if ($actual = $expected) do={
            :set testsPassedCount ($testsPassedCount + 1)
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . $actual . "'")
        } else={
            :set testsFailedCount ($testsFailedCount + 1)
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . $expected . "', Got: '" . $actual . "'")
        }
    }

    :put "Starting GlobalVarUtils tests..."

    # --- Test 1: DeclareGlobalVar & GetGlobalVar (Uninitialized) ---
    $DeclareGlobalVar "testVarUnset"
    [$RunTestCase [$GetGlobalVar "testVarUnset"] "" "Declare and get uninitialized variable"]

    # --- Test 2: SetGlobalVar & GetGlobalVar (String) ---
    $SetGlobalVar "testVarStr" "helloMikrotik"
    [$RunTestCase [$GetGlobalVar "testVarStr"] "helloMikrotik" "Set and get string value"]

    # --- Test 3: SetGlobalVar & GetGlobalVar (String with Double Quotes) ---
    $SetGlobalVar "testVarQuotes" ("text \"with\" quotes")
    [$RunTestCase [$GetGlobalVar "testVarQuotes"] ("text \"with\" quotes") "Set and get string with internal double quotes"]

    # --- Test 4: SetGlobalVar & GetGlobalVar (Integer) ---
    $SetGlobalVar "testVarInt" 12345
    [$RunTestCase [$GetGlobalVar "testVarInt"] "12345" "Set and get integer value"]

    # --- Test 5: SetGlobalVar & GetGlobalVar (Boolean) ---
    $SetGlobalVar "testVarBool" true
    [$RunTestCase [$GetGlobalVar "testVarBool"] "true" "Set and get boolean value"]

    # --- Test 6: GetGlobalVarOrDefault (Variable Exists) ---
    $SetGlobalVar "testVarExist" "activeValue"
    [$RunTestCase [$GetGlobalVarOrDefault "testVarExist" "defaultFallback"] "activeValue" "Get existing variable value with default fallback"]

    # --- Test 7: GetGlobalVarOrDefault (Variable Is Nothing/Unset) ---
    [$RunTestCase [$GetGlobalVarOrDefault "testVarNonExistent" "fallbackStr"] "fallbackStr" "Get non-existent variable returns default string"]
    [$RunTestCase [$GetGlobalVarOrDefault "testVarNonExistent" 999] "999" "Get non-existent variable returns default integer"]

    # --- Test 8: RemoveGlobalVar ---
    $SetGlobalVar "testVarToRemove" "temporaryData"
    $RemoveGlobalVar "testVarToRemove"
    [$RunTestCase [$GetGlobalVarOrDefault "testVarToRemove" "removedSuccessfully"] "removedSuccessfully" "Remove global variable and verify deletion"]

    # --- Test 9: SetGlobalVar & GetGlobalVar (Float / Num) ---
    $SetGlobalVar "testVarFloat" 15.65
    [$RunTestCase [$GetGlobalVar "testVarFloat"] "15.65" "Set and get float number value"]

    # --- Test 10: SetGlobalVar & GetGlobalVar (IP Address) ---
    $SetGlobalVar "testVarIp" 192.168.88.1
    [$RunTestCase [$GetGlobalVar "testVarIp"] "192.168.88.1" "Set and get IP address value"]

    # --- Test 11: SetGlobalVar & GetGlobalVar (IP Prefix / Subnet) ---
    $SetGlobalVar "testVarPrefix" 10.0.0.0/24
    [$RunTestCase [$GetGlobalVar "testVarPrefix"] "10.0.0.0/24" "Set and get IP prefix value"]

    # --- Test 12: SetGlobalVar & GetGlobalVar (Time) ---
    $SetGlobalVar "testVarTime" 01:15:30
    [$RunTestCase [$GetGlobalVar "testVarTime"] "01:15:30" "Set and get time value"]

    # --- Test 13: SetGlobalVar & GetGlobalVar (Array) ---
    $SetGlobalVar "testVarArray" [:toarray "a,b,c"]
    [$RunTestCase [$GetGlobalVar "testVarArray"] "a;b;c" "Set and get simple array structure"]

    # --- Test 14: GetGlobalVarOrDefault (With Float and IP Fallbacks) ---
    [$RunTestCase [$GetGlobalVarOrDefault "testVarNonExistent" 25.45] "25.45" "Get non-existent variable returns default float"]
    [$RunTestCase [$GetGlobalVarOrDefault "testVarNonExistent" 10.0.0.1] "10.0.0.1" "Get non-existent variable returns default IP address"]

    # --- Test 15: SetGlobalVar & GetGlobalVar (Associative Array) ---
    :local assocKeyVal [:toarray ""]
    :set ($assocKeyVal->"host") "192.168.88.1"
    :set ($assocKeyVal->"port") 8080
    $SetGlobalVar "testVarAssocArray" $assocKeyVal
    [$RunTestCase [$GetGlobalVar "testVarAssocArray"] "host=192.168.88.1;port=8080" "Set and get associative array"]

    # --- Test 16: GetGlobalVarOrDefault (Associative Array Fallback) ---
    :local defaultAssoc [:toarray ""]
    :set ($defaultAssoc->"status") "down"
    [$RunTestCase [$GetGlobalVarOrDefault "testVarNonExistent" $defaultAssoc] "status=down" "Get non-existent variable returns default associative array"]

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

    :put "Testing completed."
}
