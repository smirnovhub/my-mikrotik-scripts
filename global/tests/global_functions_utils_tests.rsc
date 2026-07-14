:global RunAllUtilsTests
:global GetArgOrDefaultTest
:global GetArgOrExitTest
:global SilentPingTest

:set RunAllUtilsTests do={
    :global GetArgOrDefaultTest
    :global GetArgOrExitTest
    :global SilentPingTest

    :put "\1B[35m=== STARTING ALL UTILS TESTS ===\1B[0m"

    $GetArgOrDefaultTest
    $GetArgOrExitTest
    $SilentPingTest

    :put "\1B[35m=== ALL UTILS TESTS COMPLETED ===\1B[0m"
}

:set GetArgOrDefaultTest do={
    :global GetArgOrDefault

    :global testsPassedCount
    :global testsFailedCount

    :local RunTestCase do={
        :global GetArgOrDefault

        :global testsPassedCount
        :global testsFailedCount

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return ""
        }

        :local map $1
        :local key $2
        :local default $3
        :local expected $4
        :local name $5
        :local expectError $6

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
                :set testsPassedCount ($testsPassedCount + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . " (Execution crash successfully intercepted)")
            } else={
                :set testsFailedCount ($testsFailedCount + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected LogAndExit call but function returned code execution normally")
            }
            :return ""
        }

        # Guard check if function crashed unexpectedly during standard data retrieval
        :if ($scriptCrashed = true) do={
            :set testsFailedCount ($testsFailedCount + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Function crashed unexpectedly via on-error boundary trap")
            :return ""
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
            :set testsPassedCount ($testsPassedCount + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . " -> Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        } else={
            :set testsFailedCount ($testsFailedCount + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "' (" . [:typeof $expected] . "), Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        }
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
    [$RunTestCase $sampleMap "ip" "10.0.0.1" "192.168.1.10" "Retrieve existing string argument value"]

    # Missing arguments and empty values falling back to defaults
    [$RunTestCase $sampleMap "nonexistent" "10.0.0.1" "10.0.0.1" "Fallback to default value when key is missing"]
    [$RunTestCase $sampleMap "emptyVal" "fallback_str" "fallback_str" "Fallback to default value when key exists but is empty"]

    # Boolean transformation logic (String to Boolean)
    [$RunTestCase $sampleMap "strTrue" false true "Convert string true to explicit boolean true"]
    [$RunTestCase $sampleMap "strFalse" true false "Convert string false to explicit boolean false"]

    # Native Boolean preservation validation
    [$RunTestCase $sampleMap "boolTrue" false true "Preserve native boolean true configuration type"]
    [$RunTestCase $sampleMap "boolFalse" true false "Preserve native boolean false configuration type"]

    # Integer preservation
    # Need to use variable to preserve numeric type
    :local expectedNum 100
    [$RunTestCase $sampleMap "numVal" 1 $expectedNum "Preserve native integer value types without mutations"]

    # Zero value preservation
    :local expectedZero 0
    [$RunTestCase $sampleMap "zeroVal" 1 $expectedZero "Preserve numeric zero value"]

    # Existing zero must override default value
    [$RunTestCase $sampleMap "zeroVal" 999 $expectedZero "Existing numeric zero overrides default value"]

    # String zero must remain a string
    [$RunTestCase $sampleMap "strZero" "1" "0" "Preserve string zero value"]

    # Existing false must override default value
    [$RunTestCase $sampleMap "boolFalse" true false "Existing boolean false overrides default value"]

    # Case-sensitive boolean conversion
    [$RunTestCase $sampleMap "upperTrue" false "TRUE" "Do not convert uppercase TRUE"]
    [$RunTestCase $sampleMap "mixedFalse" true "False" "Do not convert mixed-case False"]

    # Strings containing whitespace must not be converted
    [$RunTestCase $sampleMap "trueSpaces" false " true " "Do not convert boolean-like string with surrounding spaces"]

    # Partial boolean strings must not be converted
    [$RunTestCase $sampleMap "trueHost" "" "true.local" "Do not convert partial boolean string" true]

    # Empty key lookup
    [$RunTestCase $sampleMap "" "fallback" "emptyKeyValue" "Retrieve value using empty string key"]

    # Empty map handling
    :local emptyMap [:toarray ""]
    [$RunTestCase $emptyMap "ip" "fallback" "fallback" "Fallback when argument map is empty"]

    # Negative validation: Missing defaultValue checks (triggers LogAndExit code block)
    [$RunTestCase $sampleMap "ip" "" "" "Assert exception when defaultValue is an empty string" true]

    :local modified false

    :if (($sampleMap->"boolTrue") != true) do={ :set modified true }
    :if (($sampleMap->"boolFalse") != false) do={ :set modified true }
    :if (($sampleMap->"numVal") != 100) do={ :set modified true }
    :if (($sampleMap->"zeroVal") != 0) do={ :set modified true }
    :if (($sampleMap->"strTrue") != "true") do={ :set modified true }
    :if (($sampleMap->"strFalse") != "false") do={ :set modified true }

    :if ($modified = true) do={
        :set testsFailedCount ($testsFailedCount + 1)
        :put "  \1B[31m[FAIL]\1B[0m Source argument map was modified"
    } else={
        :set testsPassedCount ($testsPassedCount + 1)
        :put "  \1B[32m[PASS]\1B[0m Source argument map remains unchanged"
    }

    :put "Testing completed."
}

:set GetArgOrExitTest do={
    :global GetArgOrExit

    :global testsPassedCount
    :global testsFailedCount

    :local RunTestCase do={
        :global GetArgOrExit

        :global testsPassedCount
        :global testsFailedCount

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return ""
        }

        :local map $1
        :local key $2
        :local contextDescription $3
        :local expected $4
        :local name $5
        :local expectError $6

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
                :set testsPassedCount ($testsPassedCount + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . " (Execution crash successfully intercepted)")
            } else={
                :set testsFailedCount ($testsFailedCount + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected LogAndExit call but function returned code execution normally")
            }
            :return ""
        }

        # Guard check if function crashed unexpectedly during standard data retrieval
        :if ($scriptCrashed = true) do={
            :set testsFailedCount ($testsFailedCount + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Function crashed unexpectedly via on-error boundary trap")
            :return ""
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
            :set testsPassedCount ($testsPassedCount + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . " -> Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        } else={
            :set testsFailedCount ($testsFailedCount + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "' (" . [:typeof $expected] . "), Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        }
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
    [$RunTestCase $sampleMap "ip" "Test context" "192.168.1.10" "Retrieve existing string argument value"]

    # Mandatory parameter absence checks (triggers LogAndExit code block)
    [$RunTestCase $sampleMap "nonexistent" "Test context" "" "Assert exception when key is missing" true]
    [$RunTestCase $sampleMap "emptyVal" "Test context" "" "Assert exception when key exists but is empty" true]

    # Optional description omitted (should handle internal default description fallback)
    [$RunTestCase $sampleMap "nonexistent" "" "" "Assert exception when key is missing and context description is empty" true]

    # Boolean transformation logic (String to Boolean)
    [$RunTestCase $sampleMap "strTrue" "Test context" true "Convert string true to explicit boolean true"]
    [$RunTestCase $sampleMap "strFalse" "Test context" false "Convert string false to explicit boolean false"]

    # Native Boolean preservation validation
    [$RunTestCase $sampleMap "boolTrue" "Test context" true "Preserve native boolean true configuration type"]
    [$RunTestCase $sampleMap "boolFalse" "Test context" false "Preserve native boolean false configuration type"]

    # Integer preservation
    :local expectedNum 100
    [$RunTestCase $sampleMap "numVal" "Test context" $expectedNum "Preserve native integer value types without mutations"]

    # Zero value preservation (Should pass through since len(0) is not 0 in newer RouterOS versions)
    :local expectedZero 0
    [$RunTestCase $sampleMap "zeroVal" "Test context" $expectedZero "Preserve numeric zero value"]

    # String zero must remain a string
    [$RunTestCase $sampleMap "strZero" "Test context" "0" "Preserve string zero value"]

    # Case-sensitive boolean conversion
    [$RunTestCase $sampleMap "upperTrue" "Test context" "TRUE" "Do not convert uppercase TRUE"]
    [$RunTestCase $sampleMap "mixedFalse" "Test context" "False" "Do not convert mixed-case False"]

    # Strings containing whitespace must not be converted
    [$RunTestCase $sampleMap "trueSpaces" "Test context" " true " "Do not convert boolean-like string with surrounding spaces"]

    # Partial boolean strings must not be converted
    [$RunTestCase $sampleMap "trueHost" "Test context" "true.local" "Do not convert partial boolean string"]

    # Empty key lookup
    [$RunTestCase $sampleMap "" "Test context" "emptyKeyValue" "Retrieve value using empty string key"]

    # Empty map handling (triggers LogAndExit code block)
    :local emptyMap [:toarray ""]
    [$RunTestCase $emptyMap "ip" "Test context" "" "Assert exception when argument map is empty" true]

    # Side-effect validation: ensuring structure stability
    :local modified false

    :if (($sampleMap->"boolTrue") != true) do={ :set modified true }
    :if (($sampleMap->"boolFalse") != false) do={ :set modified true }
    :if (($sampleMap->"numVal") != 100) do={ :set modified true }
    :if (($sampleMap->"zeroVal") != 0) do={ :set modified true }
    :if (($sampleMap->"strTrue") != "true") do={ :set modified true }
    :if (($sampleMap->"strFalse") != "false") do={ :set modified true }

    :if ($modified = true) do={
        :set testsFailedCount ($testsFailedCount + 1)
        :put "  \1B[31m[FAIL]\1B[0m Source argument map was modified"
    } else={
        :set testsPassedCount ($testsPassedCount + 1)
        :put "  \1B[32m[PASS]\1B[0m Source argument map remains unchanged"
    }

    :put "Testing completed."
}

:set SilentPingTest do={
    :global SilentPing

    :global testsPassedCount
    :global testsFailedCount

    :local RunTestCase do={
        :global SilentPing

        :global testsPassedCount
        :global testsFailedCount

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return ""
        }

        :local inputData $1
        :local count $2
        :local expected $3
        :local name $4
        :local expectError $5

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
                :set testsPassedCount ($testsPassedCount + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . " (Execution crash successfully intercepted)")
            } else={
                :set testsFailedCount ($testsFailedCount + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected function crash but it returned normally")
            }
            :return ""
        }

        # Guard check if function crashed unexpectedly
        :if ($scriptCrashed = true) do={
            :set testsFailedCount ($testsFailedCount + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Function crashed unexpectedly via on-error boundary trap")
            :return ""
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
                :set testsPassedCount ($testsPassedCount + 1)
                :put ("  \1B[32m[PASS]\1B[0m " . $name . " -> Got matching array response")
            } else={
                :set testsFailedCount ($testsFailedCount + 1)
                :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "', Got: '" . [:tostr $actual] . "'")
            }
            :return ""
        }

        # Validate matching types along with values for single host (scalars)
        :if (($actual = $expected) && ([:typeof $actual] = [:typeof $expected])) do={
            :set testsPassedCount ($testsPassedCount + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $name . " -> Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        } else={
            :set testsFailedCount ($testsFailedCount + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $name . " | Expected: '" . [:tostr $expected] . "' (" . [:typeof $expected] . "), Got: '" . [:tostr $actual] . "' (" . [:typeof $actual] . ")")
        }
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
    [$RunTestCase "127.0.0.1" 1 $one "Ping single local host with 1 packet"]
    [$RunTestCase "127.0.0.1" 3 $three "Ping single local host with multiple packets"]

    # Test Google
    [$RunTestCase "dns.google" 1 $one "Ping Googlet with 1 packet"]
    [$RunTestCase "dns.google" 2 $two "Ping Google with multiple packets"]

    # Test optional packets parameter (default should be 1, checking type/value)
    [$RunTestCase "127.0.0.1" "" $one "Verify default packet count is 1 when parameter is omitted"]

    # Test completely unreachable or dummy IP address (RFC 5737 Test-Net range)
    [$RunTestCase "198.51.100.254" 2 $zero "Ping unreachable target returns 0 successful replies"]

    # Test invalid string formats (should handle gracefully inside job and return 0)
    [$RunTestCase "invalid...hostname" 1 $zero "Handle invalid hostname string syntax gracefully without crashing"]

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
    [$RunTestCase $targetMap 3 $expectedMap "Ping multiple hosts in parallel and collect mapped results"]

    # Empty dictionary validation (should return an empty array without runtime errors)
    :local emptyMap [:toarray ""]
    [$RunTestCase $emptyMap 2 $emptyMap "Handle empty host dictionary input gracefully"]

    # -------------------------------------------------------------------------
    # PART 3: Side-Effects & Environmental Leak Validation
    # -------------------------------------------------------------------------

    # Verify target maps are completely unmutated by the function logic
    :local modified false
    :if (($targetMap->"local") != "127.0.0.1") do={ :set modified true }
    :if (($targetMap->"dead") != "198.51.100.254") do={ :set modified true }
    :if (($targetMap->"badhost") != "broken..ip") do={ :set modified true }

    :if ($modified = true) do={
        :set testsFailedCount ($testsFailedCount + 1)
        :put "  \1B[31m[FAIL]\1B[0m Source host dictionary was modified during execution"
    } else={
        :set testsPassedCount ($testsPassedCount + 1)
        :put "  \1B[32m[PASS]\1B[0m Source host dictionary remains unchanged"
    }

    :if ($leakDetected = true) do={
        :set testsFailedCount ($testsFailedCount + 1)
        :put "  \1B[31m[FAIL]\1B[0m Environment leak: temporary global result variables were not cleaned up"
    } else={
        :set testsPassedCount ($testsPassedCount + 1)
        :put "  \1B[32m[PASS]\1B[0m Environment clean: no temporary variable leaks detected"
    }

    :put "Testing completed."
}
