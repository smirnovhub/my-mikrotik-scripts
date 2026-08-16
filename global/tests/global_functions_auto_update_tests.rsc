:global RunAllAutoUpdateTests
:global FetchWithRedirectTest

:set RunAllAutoUpdateTests do={
    :global InitTestCaseState
    :global FetchWithRedirectTest

    :put "\1B[35m=== STARTING ALL AUTO UPDATE TESTS ===\1B[0m"

    :local res [$InitTestCaseState $1]

    # Execute all test suites sequentially, passing and updating the same accumulator array
    :set res [$FetchWithRedirectTest $res]

    :put "\1B[35m=== ALL AUTO UPDATE TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set FetchWithRedirectTest do={
    :global InitTestCaseState
    :global RunTestCase
    :global RemoveGlobalVar
    :global GetGlobalVar
    :global SetGlobalVar
    :global FetchWithRedirect
    :global ParseScriptsListFromUrl
    :global DownloadAndImportScriptsFromList

    :local res [$InitTestCaseState $1]

    :put "Starting FetchWithRedirect tests..."

    :set res [$RunTestCase $res $FetchWithRedirect \
        "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string1.txt" \
        "nothing" "nothing" "This is a first test string. Do not change" "File fetching"]

    :local crc32TestResults { \
        "test_string1"={ \
            "hash"="1f1cf737"; \
            "hashtype"="crc32"; \
            "listname"="test_data/test_list_crc32.txt"; \
            "scriptname"="test_string1"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string1.txt" \
        }; \
        "test_string2"={ \
            "hash"="0b156af8"; \
            "hashtype"="crc32"; \
            "listname"="test_data/test_list_crc32.txt"; \
            "scriptname"="test_string2"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string2.txt" \
        }; \
        "test_string3"={ \
            "hash"="400473f5"; \
            "hashtype"="crc32"; \
            "listname"="test_data/test_list_crc32.txt"; \
            "scriptname"="test_string3"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string3.txt" \
        } \
    }

    :set res [$RunTestCase $res $ParseScriptsListFromUrl \
        "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_list_crc32.txt" \
        "nothing" "nothing" \
        $crc32TestResults \
        "List with CRC32 hashes"]

    :local md5TestResults { \
        "test_string1"={ \
            "hash"="bf9e4f9eb4deaef4aa9ce189cedb83e8"; \
            "hashtype"="md5"; \
            "listname"="test_data/test_list_md5.txt"; \
            "scriptname"="test_string1"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string1.txt" \
        }; \
        "test_string2"={ \
            "hash"="9e64c3492e931c30c16550dd80c7138b"; \
            "hashtype"="md5"; \
            "listname"="test_data/test_list_md5.txt"; \
            "scriptname"="test_string2"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string2.txt" \
        }; \
        "test_string3"={ \
            "hash"="399bf7667ad80fe89ba99be3ed39de36"; \
            "hashtype"="md5"; \
            "listname"="test_data/test_list_md5.txt"; \
            "scriptname"="test_string3"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string3.txt" \
        } \
    }

    :set res [$RunTestCase $res $ParseScriptsListFromUrl \
        "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_list_md5.txt" \
        "nothing" "nothing" \
        $md5TestResults \
        "List with MD5 hashes"]

    :local sha1TestResults { \
        "test_string1"={ \
            "hash"="a0fb841ed773151daf1bf8996048c2345767f9e5"; \
            "hashtype"="sha1"; \
            "listname"="test_data/test_list_sha1.txt"; \
            "scriptname"="test_string1"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string1.txt" \
        }; \
        "test_string2"={ \
            "hash"="aae727b8b24204f98147017360f4fe078a0cf4a7"; \
            "hashtype"="sha1"; \
            "listname"="test_data/test_list_sha1.txt"; \
            "scriptname"="test_string2"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string2.txt" \
        }; \
        "test_string3"={ \
            "hash"="f950856eb995c9de01cf11340c5ee7a616f23ab8"; \
            "hashtype"="sha1"; \
            "listname"="test_data/test_list_sha1.txt"; \
            "scriptname"="test_string3"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string3.txt" \
        } \
    }

    :set res [$RunTestCase $res $ParseScriptsListFromUrl \
        "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_list_sha1.txt" \
        "nothing" "nothing" \
        $sha1TestResults \
        "List with SHA1 hashes"]

    :local sha256TestResults { \
        "test_string1"={ \
            "hash"="977b49266265ca181d141eabdfe7552eb0b4cc398b109952b0d7532bb091347e"; \
            "hashtype"="sha256"; \
            "listname"="test_data/test_list_sha256.txt"; \
            "scriptname"="test_string1"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string1.txt" \
        }; \
        "test_string2"={ \
            "hash"="8b56b3bfe608ef47fa1d07990382d3ae2a2e6c07bce761cd194bda0985782a95"; \
            "hashtype"="sha256"; \
            "listname"="test_data/test_list_sha256.txt"; \
            "scriptname"="test_string2"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string2.txt" \
        }; \
        "test_string3"={ \
            "hash"="aaee55be2c2dd6a4ff696e9bf75eb5ed9c2d4411386a538ae0ee3dbfff3fab35"; \
            "hashtype"="sha256"; \
            "listname"="test_data/test_list_sha256.txt"; \
            "scriptname"="test_string3"; \
            "url"="https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_string3.txt" \
        } \
    }

    :set res [$RunTestCase $res $ParseScriptsListFromUrl \
        "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/test_list_sha256.txt" \
        "nothing" "nothing" \
        $sha256TestResults \
        "List with SHA256 hashes"]

    :local testGlobalVarName "test-global-var"
    :local hashGlobalVarName "auto-update-test-script-hash"

    $RemoveGlobalVar $testGlobalVarName
    $RemoveGlobalVar $hashGlobalVarName

    # Check for test var. It should not exist before test run
    :set res [$RunTestCase $res $GetGlobalVar $testGlobalVarName "empty" "nothing" "empty" "Check if test var exists"]
    :set res [$RunTestCase $res $GetGlobalVar $hashGlobalVarName "empty" "nothing" "empty" "Check if hash var exists"]

    :local result1 { \
        "error"=false; \
        "failedtorun"=""; \
        "failedtoupdate"=""; \
        "runned"="auto_update_test_script"; \
        "updated"="auto_update_test_script"; \
        "uptodate"="" \
    }

    :set res [$RunTestCase $res $DownloadAndImportScriptsFromList \
        "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/auto_update_test_list.txt" \
        "true" "false" \
        $result1 \
        "Download and run script 1"]

    # Check for test var again
    :set res [$RunTestCase $res $GetGlobalVar $testGlobalVarName "empty" "nothing" "test global var value" "Check test var value"]
    :set res [$RunTestCase $res $GetGlobalVar $hashGlobalVarName "empty" "nothing" "3d2b160a6205b0adc5422f35b6258734" "Check hash var value"]

    # Change to any value
    $SetGlobalVar $testGlobalVarName "some new value"

    # Check for test var again
    :set res [$RunTestCase $res $GetGlobalVar $testGlobalVarName "empty" "nothing" "some new value" "Check test var value"]

    :local result2 { \
        "error"=false; \
        "failedtorun"=""; \
        "failedtoupdate"=""; \
        "runned"="auto_update_test_script"; \
        "updated"=""; \
        "uptodate"="auto_update_test_script" \
    }

    :set res [$RunTestCase $res $DownloadAndImportScriptsFromList \
        "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data/auto_update_test_list.txt" \
        "true" "false" \
        $result2 \
        "Download and run script 2"]

    # Check for test var again
    :set res [$RunTestCase $res $GetGlobalVar $testGlobalVarName "empty" "nothing" "test global var value" "Check test var value"]
    :set res [$RunTestCase $res $GetGlobalVar $hashGlobalVarName "empty" "nothing" "3d2b160a6205b0adc5422f35b6258734" "Check hash var value"]

    $RemoveGlobalVar $testGlobalVarName
    $RemoveGlobalVar $hashGlobalVarName

    :put "Testing completed."
    :return $res
}
