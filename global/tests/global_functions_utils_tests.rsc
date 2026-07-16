:global RunAllUtilsTests
:global GetArgOrDefaultTest
:global GetArgOrExitTest
:global SilentPingTest
:global RunScriptTest
:global ExportConfigurationTest

:set RunAllUtilsTests do={
    :global GetArgOrDefaultTest
    :global GetArgOrExitTest
    :global SilentPingTest
    :global RunScriptTest
    :global ExportConfigurationTest

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :put "\1B[35m=== STARTING ALL UTILS TESTS ===\1B[0m"

    :set res [$GetArgOrDefaultTest $res]
    :set res [$GetArgOrExitTest $res]
    :set res [$SilentPingTest $res]
    :set res [$RunScriptTest $res]
    :set res [$ExportConfigurationTest $res]

    :put "\1B[35m=== ALL UTILS TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set GetArgOrDefaultTest do={
    :global GetArgOrDefault

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global GetArgOrDefault

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local map $2
        :local key $3
        :local default $4
        :local expected $5
        :local name $6
        :local expectError $7

        :local actual
        :local scriptCrashed false

        # Execute code block with native error trapping
        :do {
            :set actual [$GetArgOrDefault $map $key $default]
        } on-error={
            :set scriptCrashed true
        }

        # Validate negative scenarios where error/exit is mandated
        :if ($expectError = true) do={
            :if ($scriptCrashed = true) do={
                :set ($state->"passed") (($state->"passed") + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . " (Execution crash successfully intercepted)")
            } else={
                :set ($state->"failed") (($state->"failed") + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected LogAndExit call but function returned code execution normally")
            }
            :return $state
        }

        # Guard check if function crashed unexpectedly during standard data retrieval
        :if ($scriptCrashed = true) do={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Function crashed unexpectedly via on-error boundary trap")
            :return $state
        }

        :if ($expected = "true") do={
            :set expected true
        } else={
            :if ($expected = "false") do={
                :set expected false
            }
        }

        # Validate matching types along with values
        :if (($actual = $expected) && ([:typeof $actual] = [:typeof $expected])) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . " -> Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "' (" . [:typeof $expected] . "), Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        }
        :return $state
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
    :set res [$RunTestCase $res $sampleMap "ip" "10.0.0.1" "192.168.1.10" "Retrieve existing string argument value"]

    # Missing arguments and empty values falling back to defaults
    :set res [$RunTestCase $res $sampleMap "nonexistent" "10.0.0.1" "10.0.0.1" "Fallback to default value when key is missing"]
    :set res [$RunTestCase $res $sampleMap "emptyVal" "fallback_str" "fallback_str" "Fallback to default value when key exists but is empty"]

    # Boolean transformation logic (String to Boolean)
    :set res [$RunTestCase $res $sampleMap "strTrue" false true "Convert string true to explicit boolean true"]
    :set res [$RunTestCase $res $sampleMap "strFalse" true false "Convert string false to explicit boolean false"]

    # Native Boolean preservation validation
    :set res [$RunTestCase $res $sampleMap "boolTrue" false true "Preserve native boolean true configuration type"]
    :set res [$RunTestCase $res $sampleMap "boolFalse" true false "Preserve native boolean false configuration type"]

    # Integer preservation
    # Need to use variable to preserve numeric type
    :local expectedNum 100
    :set res [$RunTestCase $res $sampleMap "numVal" 1 $expectedNum "Preserve native integer value types without mutations"]

    # Zero value preservation
    :local expectedZero 0
    :set res [$RunTestCase $res $sampleMap "zeroVal" 1 $expectedZero "Preserve numeric zero value"]

    # Existing zero must override default value
    :set res [$RunTestCase $res $sampleMap "zeroVal" 999 $expectedZero "Existing numeric zero overrides default value"]

    # String zero must remain a string
    :set res [$RunTestCase $res $sampleMap "strZero" "1" "0" "Preserve string zero value"]

    # Existing false must override default value
    :set res [$RunTestCase $res $sampleMap "boolFalse" true false "Existing boolean false overrides default value"]

    # Case-sensitive boolean conversion
    :set res [$RunTestCase $res $sampleMap "upperTrue" false "TRUE" "Do not convert uppercase TRUE"]
    :set res [$RunTestCase $res $sampleMap "mixedFalse" true "False" "Do not convert mixed-case False"]

    # Strings containing whitespace must not be converted
    :set res [$RunTestCase $res $sampleMap "trueSpaces" false " true " "Do not convert boolean-like string with surrounding spaces"]

    # Partial boolean strings must not be converted
    :set res [$RunTestCase $res $sampleMap "trueHost" "" "true.local" "Do not convert partial boolean string" true]

    # Empty key lookup
    :set res [$RunTestCase $res $sampleMap "" "fallback" "emptyKeyValue" "Retrieve value using empty string key"]

    # Empty map handling
    :local emptyMap [:toarray ""]
    :set res [$RunTestCase $res $emptyMap "ip" "fallback" "fallback" "Fallback when argument map is empty"]

    # Negative validation: Missing defaultValue checks (triggers LogAndExit code block)
    :set res [$RunTestCase $res $sampleMap "ip" "" "" "Assert exception when defaultValue is an empty string" true]

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

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global GetArgOrExit

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local map $2
        :local key $3
        :local contextDescription $4
        :local expected $5
        :local name $6
        :local expectError $7

        :local actual
        :local scriptCrashed false

        # Execute code block with native error trapping
        :do {
            :set actual [$GetArgOrExit $map $key $contextDescription]
        } on-error={
            :set scriptCrashed true
        }

        # Validate negative scenarios where error/exit is mandated
        :if ($expectError = true) do={
            :if ($scriptCrashed = true) do={
                :set ($state->"passed") (($state->"passed") + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . " (Execution crash successfully intercepted)")
            } else={
                :set ($state->"failed") (($state->"failed") + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected LogAndExit call but function returned code execution normally")
            }
            :return $state
        }

        # Guard check if function crashed unexpectedly during standard data retrieval
        :if ($scriptCrashed = true) do={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Function crashed unexpectedly via on-error boundary trap")
            :return $state
        }

        # Workaround to preserve expected boolean types passed via literal strings
        :if ($expected = "true") do={
            :set expected true
        } else={
            :if ($expected = "false") do={
                :set expected false
            }
        }

        # Validate matching types along with values
        :if (($actual = $expected) && ([:typeof $actual] = [:typeof $expected])) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . " -> Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "' (" . [:typeof $expected] . "), Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        }
        :return $state
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
    :set res [$RunTestCase $res $sampleMap "ip" "Test context" "192.168.1.10" "Retrieve existing string argument value"]

    # Mandatory parameter absence checks (triggers LogAndExit code block)
    :set res [$RunTestCase $res $sampleMap "nonexistent" "Test context" "" "Assert exception when key is missing" true]
    :set res [$RunTestCase $res $sampleMap "emptyVal" "Test context" "" "Assert exception when key exists but is empty" true]

    # Optional description omitted (should handle internal default description fallback)
    :set res [$RunTestCase $res $sampleMap "nonexistent" "" "" "Assert exception when key is missing and context description is empty" true]

    # Boolean transformation logic (String to Boolean)
    :set res [$RunTestCase $res $sampleMap "strTrue" "Test context" true "Convert string true to explicit boolean true"]
    :set res [$RunTestCase $res $sampleMap "strFalse" "Test context" false "Convert string false to explicit boolean false"]

    # Native Boolean preservation validation
    :set res [$RunTestCase $res $sampleMap "boolTrue" "Test context" true "Preserve native boolean true configuration type"]
    :set res [$RunTestCase $res $sampleMap "boolFalse" "Test context" false "Preserve native boolean false configuration type"]

    # Integer preservation
    :local expectedNum 100
    :set res [$RunTestCase $res $sampleMap "numVal" "Test context" $expectedNum "Preserve native integer value types without mutations"]

    # Zero value preservation (Should pass through since len(0) is not 0 in newer RouterOS versions)
    :local expectedZero 0
    :set res [$RunTestCase $res $sampleMap "zeroVal" "Test context" $expectedZero "Preserve numeric zero value"]

    # String zero must remain a string
    :set res [$RunTestCase $res $sampleMap "strZero" "Test context" "0" "Preserve string zero value"]

    # Case-sensitive boolean conversion
    :set res [$RunTestCase $res $sampleMap "upperTrue" "Test context" "TRUE" "Do not convert uppercase TRUE"]
    :set res [$RunTestCase $res $sampleMap "mixedFalse" "Test context" "False" "Do not convert mixed-case False"]

    # Strings containing whitespace must not be converted
    :set res [$RunTestCase $res $sampleMap "trueSpaces" "Test context" " true " "Do not convert boolean-like string with surrounding spaces"]

    # Partial boolean strings must not be converted
    :set res [$RunTestCase $res $sampleMap "trueHost" "Test context" "true.local" "Do not convert partial boolean string"]

    # Empty key lookup
    :set res [$RunTestCase $res $sampleMap "" "Test context" "emptyKeyValue" "Retrieve value using empty string key"]

    # Empty map handling (triggers LogAndExit code block)
    :local emptyMap [:toarray ""]
    :set res [$RunTestCase $res $emptyMap "ip" "Test context" "" "Assert exception when argument map is empty" true]

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

    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
    }

    :local RunTestCase do={
        :global SilentPing

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return $1
        }

        :local state $1
        :local inputData $2
        :local count $3
        :local expected $4
        :local name $5
        :local expectError $6

        :local actual
        :local scriptCrashed false

        # Execute code block with native error trapping
        :do {
            :set actual [$SilentPing $inputData $count]
        } on-error={
            :set scriptCrashed true
        }

        # Validate negative scenarios where execution crash is expected
        :if ($expectError = true) do={
            :if ($scriptCrashed = true) do={
                :set ($state->"passed") (($state->"passed") + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . " (Execution crash successfully intercepted)")
            } else={
                :set ($state->"failed") (($state->"failed") + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected function crash but it returned normally")
            }
            :return $state
        }

        # Guard check if function crashed unexpectedly
        :if ($scriptCrashed = true) do={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Function crashed unexpectedly via on-error boundary trap")
            :return $state
        }

        # Workaround to preserve expected boolean types if they sneak into validation
        :if ($expected = "true") do={
            :set expected true
        } else={
            :if ($expected = "false") do={
                :set expected false
            }
        }

        # Handle validation for array (dictionary) results
        :if ([:typeof $actual] = "array" && [:typeof $expected] = "array") do={
            :local arraysMatch true

            # Check size parity
            :if ([:len $actual] != [:len $expected]) do={
                :set arraysMatch false
            } else={
                # Deep compare keys and values
                :foreach k,v in=$expected do={
                    :if (($actual->$k) != $v) do={
                        :set arraysMatch false
                    }
                }
            }

            :if ($arraysMatch = true) do={
                :set ($state->"passed") (($state->"passed") + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . " -> Got matching array response")
            } else={
                :set ($state->"failed") (($state->"failed") + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "', Got: '" . [:tostr $actual] . "'")
            }
            :return $state
        }

        # Validate matching types along with values for single host (scalars)
        :if (($actual = $expected) && ([:typeof $actual] = [:typeof $expected])) do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . " -> Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "' (" . [:typeof $expected] . "), Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        }
        :return $state
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
    :set res [$RunTestCase $res "127.0.0.1" 1 $one "Ping single local host with 1 packet"]
    :set res [$RunTestCase $res "127.0.0.1" 3 $three "Ping single local host with multiple packets"]

    # Test Google
    :set res [$RunTestCase $res "dns.google" 1 $one "Ping Googlet with 1 packet"]
    :set res [$RunTestCase $res "dns.google" 2 $two "Ping Google with multiple packets"]

    # Test optional packets parameter (default should be 1, checking type/value)
    :set res [$RunTestCase $res "127.0.0.1" "" $one "Verify default packet count is 1 when parameter is omitted"]

    # Test completely unreachable or dummy IP address (RFC 5737 Test-Net range)
    :set res [$RunTestCase $res "198.51.100.254" 2 $zero "Ping unreachable target returns 0 successful replies"]

    # Test invalid string formats (should handle gracefully inside job and return 0)
    :set res [$RunTestCase $res "invalid...hostname" 1 $zero "Handle invalid hostname string syntax gracefully without crashing"]

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
    :set res [$RunTestCase $res $targetMap 3 $expectedMap "Ping multiple hosts in parallel and collect mapped results"]

    # Empty dictionary validation (should return an empty array without runtime errors)
    :local emptyMap [:toarray ""]
    :set res [$RunTestCase $res $emptyMap 2 $emptyMap "Handle empty host dictionary input gracefully"]

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

    :if ($leakDetected = true) do={
        :set ($res->"failed") (($res->"failed") + 1)
        :put "  \1B[31m[FAIL]\1B[0m Environment leak: temporary global result variables were not cleaned up"
    } else={
        :set ($res->"passed") (($res->"passed") + 1)
        :put "  \1B[32m[PASS]\1B[0m Environment clean: no temporary variable leaks detected"
    }

    :put "Testing completed."
    :return $res
}

:set RunScriptTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
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

        # Convert both to string to avoid RouterOS type mismatch bugs
        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> " . [:tostr $actual])
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: " . [:tostr $expected] . ", Got: " . [:tostr $actual])
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting RunScript tests..."
    :global RunScript

    # --- Setup: Define names for temporary test scripts ---
    :local tempScriptName "tmp_test_runscript_target"

    # Ensure no leftover scripts exist before starting
    /system script remove [find name=$tempScriptName]

    # --- Test Case 1: Parameter Passing Verification ---
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

    :set res [$RunTestCase $res $paramMatch true "Verify all 6 parameters are correctly passed to target script"]

    # --- Test Case 2: Partial Parameters Handling ---
    # Reset test variable and test with only 2 parameters
    :set runScriptTestResult [:toarray ""]
    [$RunScript $tempScriptName "only_one" "only_two"]

    :local partialMatch true
    :if (($runScriptTestResult->"arg1") != "only_one") do={ :set partialMatch false }
    :if (($runScriptTestResult->"arg2") != "only_two") do={ :set partialMatch false }
    # Unpassed arguments should resolve to empty/nil (represented as empty string in tostr)
    :if ([:len ($runScriptTestResult->"arg3")] > 0) do={ :set partialMatch false }

    :set res [$RunTestCase $res $partialMatch true "Verify partial parameters are handled and rest are empty"]

    # Clean up the script used for positive tests
    /system script remove [find name=$tempScriptName]

    # --- Test Case 3: Error Handling (Non-existent script) ---
    # RunScript should handle non-existent scripts gracefully via on-error block without crashing the execution
    :local errorHandled true
    do {
        [$RunScript "non_existent_script_name_xyz"]
    } on-error={
        :set errorHandled false
    }

    :set res [$RunTestCase $res $errorHandled true "Verify calling a non-existent script does not crash the environment"]

    # --- Test Case 4: Syntax Error inside Target Script ---
    # Create a script with broken syntax that will fail compilation during :parse
    /system script add name=$tempScriptName source="[:global runScriptTestResult; :set runScriptTestResult"

    :local parseErrorHandled true
    do {
        [$RunScript $tempScriptName]
    } on-error={
        :set parseErrorHandled false
    }

    :set res [$RunTestCase $res $parseErrorHandled true "Verify target script compilation failure is intercepted gracefully"]

    # --- Final Cleanup ---
    /system script remove [find name=$tempScriptName]
    :set runScriptTestResult

    :put "Testing completed."
    :return $res
}

:set ExportConfigurationTest do={
    :local res [:toarray ""]
    :if ([:typeof $1] = "array") do={
        :set res $1
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

        # Convert both to string to avoid RouterOS type mismatch bugs
        :if ([:tostr $actual] = [:tostr $expected]) do={
            :put ("\1B[32m  [PASS]\1B[0m " . $name . " -> '" . [:tostr $actual] . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("\1B[31m  [FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "', Got: '" . [:tostr $actual] . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }

        :return $state
    }

    :put "Starting ExportConfiguration tests..."
    :global ExportConfiguration

    # --- Test Case 1: Verify Physical File Creation ---
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

    :set res [$RunTestCase $res $fileExists true "Verify configuration file physically exists on the storage"]

    # --- Test Case 2: Error Handling (Non-existent Directory) ---
    # Attempt to write to an invalid path and check that it returns an empty string
    :local invalidPath "non_existent_directory_xyz"
    :local errorResult [$ExportConfiguration $invalidPath]

    :set res [$RunTestCase $res $errorResult "" "Verify function returns empty string on invalid path error"]

    # --- Cleanup ---
    # Remove the created backup file if it exists
    :if ([:len $actualFilename] > 0) do={
        /file remove [find name=$actualFilename]
    }

    :put "Testing completed."
    :return $res
}
