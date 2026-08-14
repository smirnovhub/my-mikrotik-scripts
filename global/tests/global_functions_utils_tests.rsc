:global RunAllUtilsTests
:global GetArgOrDefaultTest
:global GetArgOrExitTest
:global SilentPingTest
:global RunScriptTest
:global ExportConfigurationTest
:global GetRouterOSVersionTest

:set RunAllUtilsTests do={
    :global GetArgOrDefaultTest
    :global GetArgOrExitTest
    :global SilentPingTest
    :global RunScriptTest
    :global ExportConfigurationTest
    :global GetRouterOSVersionTest

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "\1B[35m=== STARTING ALL UTILS TESTS ===\1B[0m"

    :set res [$GetArgOrDefaultTest $res]
    :set res [$GetArgOrExitTest $res]
    :set res [$SilentPingTest $res]
    :set res [$RunScriptTest $res]
    :set res [$ExportConfigurationTest $res]
    :set res [$GetRouterOSVersionTest $res]

    :put "\1B[35m=== ALL UTILS TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set GetArgOrDefaultTest do={
    :global GetArgOrDefault
    :global RunGenericTestCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting GetArgOrDefault tests..."

    # Prepare fixtures using associative array structures
    :local sampleMap {
        "ip"="192.168.1.10";
        "emptyVal"="";
        "strTrue"="true";
        "strFalse"="false";
        "boolTrue"=true;
        "boolFalse"=false;
        "numVal"=100;
        "zeroVal"=0;
        "strZero"="0";
        "upperTrue"="TRUE";
        "mixedFalse"="False";
        "trueSpaces"=" true ";
        "arrayVal"={1;2;3};
        "mapVal"={
            "a"=1;
            "b"=2
        };
        "trueHost"="true.local";
        ""="emptyKeyValue"
    }

    # Baseline asset recovery
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "ip" "10.0.0.1" "192.168.1.10" "Retrieve existing string argument value"]

    # Missing arguments and empty values falling back to defaults
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "nonexistent" "10.0.0.1" "10.0.0.1" "Fallback to default value when key is missing"]
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "emptyVal" "fallback_str" "fallback_str" "Fallback to default value when key exists but is empty"]

    # Boolean transformation logic (String to Boolean)
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "strTrue" false true "Convert string true to explicit boolean true"]
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "strFalse" true false "Convert string false to explicit boolean false"]

    # Native Boolean preservation validation
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "boolTrue" false true "Preserve native boolean true configuration type"]
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "boolFalse" true false "Preserve native boolean false configuration type"]

    # Integer preservation
    # Need to use variable to preserve numeric type
    :local expectedNum 100
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "numVal" 1 $expectedNum "Preserve native integer value types without mutations"]

    # Zero value preservation
    :local expectedZero 0
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "zeroVal" 1 $expectedZero "Preserve numeric zero value"]

    # Existing zero must override default value
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "zeroVal" 999 $expectedZero "Existing numeric zero overrides default value"]

    # String zero must remain a string
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "strZero" "1" "0" "Preserve string zero value"]

    # Existing false must override default value
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "boolFalse" true false "Existing boolean false overrides default value"]

    # Case-sensitive boolean conversion
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "upperTrue" false "TRUE" "Do not convert uppercase TRUE"]
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "mixedFalse" true "False" "Do not convert mixed-case False"]

    # Strings containing whitespace must not be converted
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "trueSpaces" false " true " "Do not convert boolean-like string with surrounding spaces"]

    # Partial boolean strings must not be converted
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "trueHost" "default" "true.local" "Do not convert partial boolean string"]

    # Empty key lookup
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "" "fallback" "emptyKeyValue" "Retrieve value using empty string key"]

    # Empty map handling
    :local emptyMap [:toarray ""]
    :set res [$RunGenericTestCase $res $GetArgOrDefault $emptyMap "ip" "fallback" "fallback" "Fallback when argument map is empty"]

    # Negative validation: Missing defaultValue checks (triggers LogAndExit code block)
    :set res [$RunGenericTestCase $res $GetArgOrDefault $sampleMap "ip" "" "error" "Assert exception when defaultValue is an empty string"]

    :local modified false

    :if (($sampleMap->"boolTrue") != true) do={ :set modified true }
    :if (($sampleMap->"boolFalse") != false) do={ :set modified true }
    :if (($sampleMap->"numVal") != 100) do={ :set modified true }
    :if (($sampleMap->"zeroVal") != 0) do={ :set modified true }
    :if (($sampleMap->"strTrue") != "true") do={ :set modified true }
    :if (($sampleMap->"strFalse") != "false") do={ :set modified true }

    :if ($modified = true) do={
        :set ($res->"failed") (($res->"failed") + 1)
        :put "  \1B[31m[FAIL]\1B[0m Source argument map was modified"
    } else={
        :set ($res->"passed") (($res->"passed") + 1)
        :put "  \1B[32m[PASS]\1B[0m Source argument map remains unchanged"
    }

    :put "Testing completed."
    :return $res
}

:set GetArgOrExitTest do={
    :global GetArgOrExit
    :global RunGenericTestCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting GetArgOrExit tests..."

    # Prepare fixtures using associative array structures
    :local sampleMap {
        "ip"="192.168.1.10";
        "emptyVal"="";
        "strTrue"="true";
        "strFalse"="false";
        "boolTrue"=true;
        "boolFalse"=false;
        "numVal"=100;
        "zeroVal"=0;
        "strZero"="0";
        "upperTrue"="TRUE";
        "mixedFalse"="False";
        "trueSpaces"=" true ";
        "arrayVal"={1;2;3};
        "mapVal"={
            "a"=1;
            "b"=2
        };
        "trueHost"="true.local";
        ""="emptyKeyValue"
    }

    # Baseline asset recovery
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "ip" "Test context" "192.168.1.10" "Retrieve existing string argument value"]

    # Mandatory parameter absence checks (triggers LogAndExit code block)
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "nonexistent" "Test context" "error" "Assert exception when key is missing"]
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "emptyVal" "Test context" "error" "Assert exception when key exists but is empty"]

    # Optional description omitted (should handle internal default description fallback)
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "nonexistent" "" "error" "Assert exception when key is missing and context description is empty"]

    # Boolean transformation logic (String to Boolean)
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "strTrue" "Test context" true "Convert string true to explicit boolean true"]
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "strFalse" "Test context" false "Convert string false to explicit boolean false"]

    # Native Boolean preservation validation
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "boolTrue" "Test context" true "Preserve native boolean true configuration type"]
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "boolFalse" "Test context" false "Preserve native boolean false configuration type"]

    # Integer preservation
    :local expectedNum 100
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "numVal" "Test context" $expectedNum "Preserve native integer value types without mutations"]

    # Zero value preservation (Should pass through since len(0) is not 0 in newer RouterOS versions)
    :local expectedZero 0
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "zeroVal" "Test context" $expectedZero "Preserve numeric zero value"]

    # String zero must remain a string
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "strZero" "Test context" "0" "Preserve string zero value"]

    # Case-sensitive boolean conversion
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "upperTrue" "Test context" "TRUE" "Do not convert uppercase TRUE"]
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "mixedFalse" "Test context" "False" "Do not convert mixed-case False"]

    # Strings containing whitespace must not be converted
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "trueSpaces" "Test context" " true " "Do not convert boolean-like string with surrounding spaces"]

    # Partial boolean strings must not be converted
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "trueHost" "Test context" "true.local" "Do not convert partial boolean string"]

    # Empty key lookup
    :set res [$RunGenericTestCase $res $GetArgOrExit $sampleMap "" "Test context" "emptyKeyValue" "Retrieve value using empty string key"]

    # Empty map handling (triggers LogAndExit code block)
    :local emptyMap [:toarray ""]
    :set res [$RunGenericTestCase $res $GetArgOrExit $emptyMap "ip" "Test context" "error" "Assert exception when argument map is empty"]

    # Side-effect validation: ensuring structure stability
    :local modified false

    :if (($sampleMap->"boolTrue") != true) do={ :set modified true }
    :if (($sampleMap->"boolFalse") != false) do={ :set modified true }
    :if (($sampleMap->"numVal") != 100) do={ :set modified true }
    :if (($sampleMap->"zeroVal") != 0) do={ :set modified true }
    :if (($sampleMap->"strTrue") != "true") do={ :set modified true }
    :if (($sampleMap->"strFalse") != "false") do={ :set modified true }

    :if ($modified = true) do={
        :set ($res->"failed") (($res->"failed") + 1)
        :put "  \1B[31m[FAIL]\1B[0m Source argument map was modified"
    } else={
        :set ($res->"passed") (($res->"passed") + 1)
        :put "  \1B[32m[PASS]\1B[0m Source argument map remains unchanged"
    }

    :put "Testing completed."
    :return $res
}

:set SilentPingTest do={
    :global SilentPing
    :global RunGenericTestCase

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :put "Starting SilentPing tests..."

    # -------------------------------------------------------------------------
    # PART 1: Single Host Pings (Scalar string inputs)
    # -------------------------------------------------------------------------

    :local zero 0
    :local one 1
    :local two 2
    :local three 3

    # Test localhost (should always answer if network stack is alive)
    :set res [$RunGenericTestCase $res $SilentPing "127.0.0.1" 1 "nothing" $one "Ping single local host with 1 packet"]
    :set res [$RunGenericTestCase $res $SilentPing "127.0.0.1" 3 "nothing" $three "Ping single local host with multiple packets"]

    # Test Google
    :set res [$RunGenericTestCase $res $SilentPing "dns.google" 1 "nothing" $one "Ping Googlet with 1 packet"]
    :set res [$RunGenericTestCase $res $SilentPing "dns.google" 2 "nothing" $two "Ping Google with multiple packets"]

    # Test optional packets parameter (default should be 1, checking type/value)
    :set res [$RunGenericTestCase $res $SilentPing "127.0.0.1" "" "nothing" $one "Verify default packet count is 1 when parameter is omitted"]

    # Test completely unreachable or dummy IP address (RFC 5737 Test-Net range)
    :set res [$RunGenericTestCase $res $SilentPing "198.51.100.254" 2 "nothing" $zero "Ping unreachable target returns 0 successful replies"]

    # Test invalid string formats (should handle gracefully inside job and return 0)
    :set res [$RunGenericTestCase $res $SilentPing "invalid...hostname" 1 "nothing" $zero "Handle invalid hostname string syntax gracefully without crashing"]

    # -------------------------------------------------------------------------
    # PART 2: Multiple Hosts Pings (Associative array / Dictionary inputs)
    # -------------------------------------------------------------------------

    :local targetMap {
        "local"="127.0.0.1";
        "google"="dns.google";
        "dead"="198.51.100.254";
        "badhost"="broken..ip"
    }

    :local expectedMap {
        "local"=3;
        "google"=3;
        "dead"=0;
        "badhost"=0
    }

    # Parallel processing validation
    :set res [$RunGenericTestCase $res $SilentPing $targetMap 3 "nothing" $expectedMap "Ping multiple hosts in parallel and collect mapped results"]

    # Empty dictionary validation (should return an empty array without runtime errors)
    :local emptyMap [:toarray ""]
    :set res [$RunGenericTestCase $res $SilentPing $emptyMap 2 "nothing" $emptyMap "Handle empty host dictionary input gracefully"]

    # -------------------------------------------------------------------------
    # PART 3: Side-Effects & Environmental Leak Validation
    # -------------------------------------------------------------------------

    # Verify target maps are completely unmutated by the function logic
    :local modified false
    :if (($targetMap->"local") != "127.0.0.1") do={ :set modified true }
    :if (($targetMap->"dead") != "198.51.100.254") do={ :set modified true }
    :if (($targetMap->"badhost") != "broken..ip") do={ :set modified true }

    :if ($modified = true) do={
        :set ($res->"failed") (($res->"failed") + 1)
        :put "  \1B[31m[FAIL]\1B[0m Source host dictionary was modified during execution"
    } else={
        :set ($res->"passed") (($res->"passed") + 1)
        :put "  \1B[32m[PASS]\1B[0m Source host dictionary remains unchanged"
    }

    :put "Testing completed."
    :return $res
}

:set RunScriptTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :global RunScript
    :global RunGenericTestCase

    :put "Starting RunScript tests..."

    # Setup: Define names for temporary test scripts
    :local tempScriptName "tmp_test_runscript_target"

    # Ensure no leftover scripts exist before starting
    /system script remove [find name=$tempScriptName]

    # Parameter Passing Verification
    # We create a script that writes its arguments to a global variable so we can verify them
    :global runScriptTestResult [:toarray ""]
    /system script add name=$tempScriptName source=":global runScriptTestResult; :set runScriptTestResult {\"arg1\"=\$1; \"arg2\"=\$2; \"arg3\"=\$3; \"arg4\"=\$4; \"arg5\"=\$5; \"arg6\"=\$6}"

    # Execute with 6 parameters
    [$RunScript $tempScriptName "val1" "val2" "val3" "val4" "val5" "val6"]

    # Verify that the arguments reached the script correctly
    :local paramMatch true
    :if (($runScriptTestResult->"arg1") != "val1") do={ :set paramMatch false }
    :if (($runScriptTestResult->"arg2") != "val2") do={ :set paramMatch false }
    :if (($runScriptTestResult->"arg3") != "val3") do={ :set paramMatch false }
    :if (($runScriptTestResult->"arg4") != "val4") do={ :set paramMatch false }
    :if (($runScriptTestResult->"arg5") != "val5") do={ :set paramMatch false }
    :if (($runScriptTestResult->"arg6") != "val6") do={ :set paramMatch false }

    :local dummyFunc do={ :return $1 }
    :set res [$RunGenericTestCase $res $dummyFunc $paramMatch "nothing" "nothing" true "Verify all 6 parameters are correctly passed to target script"]

    # Partial Parameters Handling
    # Reset test variable and test with only 2 parameters
    :set runScriptTestResult [:toarray ""]
    [$RunScript $tempScriptName "only_one" "only_two"]

    :local partialMatch true
    :if (($runScriptTestResult->"arg1") != "only_one") do={ :set partialMatch false }
    :if (($runScriptTestResult->"arg2") != "only_two") do={ :set partialMatch false }
    # Unpassed arguments should resolve to empty/nil (represented as empty string in tostr)
    :if ([:len ($runScriptTestResult->"arg3")] > 0) do={ :set partialMatch false }

    :set res [$RunGenericTestCase $res $dummyFunc $partialMatch "nothing" "nothing" true "Verify partial parameters are handled and rest are empty"]

    # Clean up the script used for positive tests
    /system script remove [find name=$tempScriptName]

    :local nonExistentWrapper do={
        :global RunScript
        :local res "error"
        :do {
            [$RunScript "non_existent_script_name_xyz"]
            :set res "success"
        } on-error={
            :set res "error"
        }
        :return $res
    }

    :set res [$RunGenericTestCase $res $nonExistentWrapper "nothing" "nothing" "nothing" "success" "Verify calling a non-existent script does not crash the environment"]

    # Syntax Error inside Target Script
    # Create a script with broken syntax that will fail compilation during :parse
    /system script add name=$tempScriptName source="[:global runScriptTestResult; :set runScriptTestResult"
    :local syntaxErrorWrapper do={
        :global RunScript
        :local res "error"
        :do {
            [$RunScript "tmp_test_runscript_target"]
            :set res "success"
        } on-error={
            :set res "error"
        }
        :return $res
    }
    :set res [$RunGenericTestCase $res $syntaxErrorWrapper "nothing" "nothing" "nothing" "success" "Verify target script compilation failure is intercepted gracefully"]

    # Final Cleanup
    /system script remove [find name=$tempScriptName]
    :set runScriptTestResult

    :put "Testing completed."
    :return $res
}

:set ExportConfigurationTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :global ExportConfiguration
    :global RunGenericTestCase

    :put "Starting ExportConfiguration tests..."

    # Verify Physical File Creation
    # Export to root to ensure it succeeds
    :local actualFilename [$ExportConfiguration ""]
    :delay 1s

    :local fileExists false
    :if ([:len $actualFilename] > 0) do={
        :local checkFile [/file find name=$actualFilename]
        :if ([:len $checkFile] > 0) do={
            :set fileExists true
        }
    }

    :local dummyFunc do={ :return $1 }
    :set res [$RunGenericTestCase $res $dummyFunc $fileExists "nothing" "nothing" true "Verify configuration file physically exists on the storage"]

    # Error Handling (Non-existent Directory)
    # Attempt to write to an invalid path and check that it returns an empty string
    :local invalidPath "non_existent_directory_xyz"
    :local errorResult [$ExportConfiguration $invalidPath]
    :set res [$RunGenericTestCase $res $dummyFunc $errorResult "nothing" "nothing" "" "Verify function returns empty string on invalid path error"]

    # Cleanup
    # Remove the created backup file if it exists
    :if ([:len $actualFilename] > 0) do={
        /file remove [find name=$actualFilename]
    }

    :put "Testing completed."
    :return $res
}

:set GetRouterOSVersionTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    } else={
        :set ($res->"passed") 0
        :set ($res->"failed") 0
    }

    :global GetRouterOSVersion
    :global RunGenericTestCase

    :put "Starting GetRouterOSVersion tests..."

    # Get the system raw version directly to compare with the function output
    :local rawSystemVersion [/system resource get version]
    :local parsedVersion [$GetRouterOSVersion]

    # Verify version is not empty
    :local isNotEmpty false
    :if ([:len $parsedVersion] > 0) do={
        :set isNotEmpty true
    }

    :local dummyFunc do={ :return $1 }
    :set res [$RunGenericTestCase $res $dummyFunc $isNotEmpty "nothing" "nothing" true "Verify returned version string is not empty"]

    # Verify no spaces in parsed version
    # The output must be stripped of any channel/build information (like "7.15 (stable)")
    :local hasSpace ([:find $parsedVersion " "] >= 0)
    :set res [$RunGenericTestCase $res $dummyFunc $hasSpace "nothing" "nothing" false "Verify there are no spaces in the extracted version"]

    # Verify correct parsing behavior based on raw system string
    # We replicate the extraction logic directly on the raw value to verify the function's internal path
    :local expectedParsed $rawSystemVersion
    :local spacePos [:find $rawSystemVersion " "]
    :if ($spacePos >= 0) do={
        :set expectedParsed [:pick $rawSystemVersion 0 $spacePos]
    }

    :set res [$RunGenericTestCase $res $dummyFunc $parsedVersion "nothing" "nothing" $expectedParsed "Verify function output matches expected slice of raw system version"]

    :put "Testing completed."
    :return $res
}
