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
    :global GetCrc32Sum
    :global GetMd5Sum
    :global GetSha1Sum
    :global GetSha256Sum
    :global GetSha512Sum

    :local res [$InitTestCaseState $1]

    :put "Starting FetchWithRedirect tests..."

    :local testString1 "This is a first test string. Do not change"
    :local testString2 "This is a second test string. Do not change"
    :local testString3 "This is a third test string. Do not change"

    :local prefixUrl "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_data"

    :set res [$RunTestCase $res $FetchWithRedirect \
        ("$prefixUrl/test_string1.txt") \
        "nothing" "nothing" $testString1 "File fetching"]

    :local crc32TestResults { \
        "test_string1"={ \
            "hash"=[$GetCrc32Sum $testString1]; \
            "hashtype"="crc32"; \
            "listname"="test_data/test_list_crc32.txt"; \
            "scriptname"="test_string1"; \
            "url"=("$prefixUrl/test_string1.txt") \
        }; \
        "test_string2"={ \
            "hash"=[$GetCrc32Sum $testString2]; \
            "hashtype"="crc32"; \
            "listname"="test_data/test_list_crc32.txt"; \
            "scriptname"="test_string2"; \
            "url"=("$prefixUrl/test_string2.txt") \
        }; \
        "test_string3"={ \
            "hash"=[$GetCrc32Sum $testString3]; \
            "hashtype"="crc32"; \
            "listname"="test_data/test_list_crc32.txt"; \
            "scriptname"="test_string3"; \
            "url"=("$prefixUrl/test_string3.txt") \
        } \
    }

    :set res [$RunTestCase $res $ParseScriptsListFromUrl \
        ("$prefixUrl/test_list_crc32.txt") \
        "nothing" "nothing" \
        $crc32TestResults \
        "List with CRC32 hashes"]

    :local md5TestResults { \
        "test_string1"={ \
            "hash"=[$GetMd5Sum $testString1]; \
            "hashtype"="md5"; \
            "listname"="test_data/test_list_md5.txt"; \
            "scriptname"="test_string1"; \
            "url"=("$prefixUrl/test_string1.txt") \
        }; \
        "test_string2"={ \
            "hash"=[$GetMd5Sum $testString2]; \
            "hashtype"="md5"; \
            "listname"="test_data/test_list_md5.txt"; \
            "scriptname"="test_string2"; \
            "url"=("$prefixUrl/test_string2.txt") \
        }; \
        "test_string3"={ \
            "hash"=[$GetMd5Sum $testString3]; \
            "hashtype"="md5"; \
            "listname"="test_data/test_list_md5.txt"; \
            "scriptname"="test_string3"; \
            "url"=("$prefixUrl/test_string3.txt") \
        } \
    }

    :set res [$RunTestCase $res $ParseScriptsListFromUrl \
        ("$prefixUrl/test_list_md5.txt") \
        "nothing" "nothing" \
        $md5TestResults \
        "List with MD5 hashes"]

    :local sha1TestResults { \
        "test_string1"={ \
            "hash"=[$GetSha1Sum $testString1]; \
            "hashtype"="sha1"; \
            "listname"="test_data/test_list_sha1.txt"; \
            "scriptname"="test_string1"; \
            "url"=("$prefixUrl/test_string1.txt") \
        }; \
        "test_string2"={ \
            "hash"=[$GetSha1Sum $testString2]; \
            "hashtype"="sha1"; \
            "listname"="test_data/test_list_sha1.txt"; \
            "scriptname"="test_string2"; \
            "url"=("$prefixUrl/test_string2.txt") \
        }; \
        "test_string3"={ \
            "hash"=[$GetSha1Sum $testString3]; \
            "hashtype"="sha1"; \
            "listname"="test_data/test_list_sha1.txt"; \
            "scriptname"="test_string3"; \
            "url"=("$prefixUrl/test_string3.txt") \
        } \
    }

    :set res [$RunTestCase $res $ParseScriptsListFromUrl \
        ("$prefixUrl/test_list_sha1.txt") \
        "nothing" "nothing" \
        $sha1TestResults \
        "List with SHA1 hashes"]

    :local sha256TestResults { \
        "test_string1"={ \
            "hash"=[$GetSha256Sum $testString1]; \
            "hashtype"="sha256"; \
            "listname"="test_data/test_list_sha256.txt"; \
            "scriptname"="test_string1"; \
            "url"=("$prefixUrl/test_string1.txt") \
        }; \
        "test_string2"={ \
            "hash"=[$GetSha256Sum $testString2]; \
            "hashtype"="sha256"; \
            "listname"="test_data/test_list_sha256.txt"; \
            "scriptname"="test_string2"; \
            "url"=("$prefixUrl/test_string2.txt") \
        }; \
        "test_string3"={ \
            "hash"=[$GetSha256Sum $testString3]; \
            "hashtype"="sha256"; \
            "listname"="test_data/test_list_sha256.txt"; \
            "scriptname"="test_string3"; \
            "url"=("$prefixUrl/test_string3.txt") \
        } \
    }

    :set res [$RunTestCase $res $ParseScriptsListFromUrl \
        ("$prefixUrl/test_list_sha256.txt") \
        "nothing" "nothing" \
        $sha256TestResults \
        "List with SHA256 hashes"]

    :local sha512TestResults { \
        "test_string1"={ \
            "hash"=[$GetSha512Sum $testString1]; \
            "hashtype"="sha512"; \
            "listname"="test_data/test_list_sha512.txt"; \
            "scriptname"="test_string1"; \
            "url"=("$prefixUrl/test_string1.txt") \
        }; \
        "test_string2"={ \
            "hash"=[$GetSha512Sum $testString2]; \
            "hashtype"="sha512"; \
            "listname"="test_data/test_list_sha512.txt"; \
            "scriptname"="test_string2"; \
            "url"=("$prefixUrl/test_string2.txt") \
        }; \
        "test_string3"={ \
            "hash"=[$GetSha512Sum $testString3]; \
            "hashtype"="sha512"; \
            "listname"="test_data/test_list_sha512.txt"; \
            "scriptname"="test_string3"; \
            "url"=("$prefixUrl/test_string3.txt") \
        } \
    }

    :set res [$RunTestCase $res $ParseScriptsListFromUrl \
        ("$prefixUrl/test_list_sha512.txt") \
        "nothing" "nothing" \
        $sha512TestResults \
        "List with SHA512 hashes"]

    :local testGlobalVarName "test-global-var"
    :local hashGlobalVarName "auto-update-test-script-hash"
    :local testScriptName "auto_update_test_script"

    $RemoveGlobalVar $testGlobalVarName
    $RemoveGlobalVar $hashGlobalVarName

    /system script remove [find name=$testScriptName]

    # Check for test var. It should not exist before test run
    :set res [$RunTestCase $res $GetGlobalVar $testGlobalVarName "empty" "nothing" "empty" "Check if test var exists"]
    :set res [$RunTestCase $res $GetGlobalVar $hashGlobalVarName "empty" "nothing" "empty" "Check if hash var exists"]

    :local result1 { \
        "error"=false; \
        "failedtorun"=""; \
        "failedtoupdate"=""; \
        "runned"=""; \
        "updated"=$testScriptName; \
        "uptodate"="" \
    }

    :set res [$RunTestCase $res $DownloadAndImportScriptsFromList \
        ("$prefixUrl/auto_update_test_list.txt") \
        "false" "false" \
        $result1 \
        "Download without run"]

    :set res [$RunTestCase $res [:len [/system script find name=$testScriptName]] "nothing" "nothing" "nothing" 1 "Check if test script exists"]
    :set res [$RunTestCase $res $GetGlobalVar $testGlobalVarName "empty" "nothing" "empty" "Check if test var exists"]
    :set res [$RunTestCase $res $GetGlobalVar $hashGlobalVarName "empty" "nothing" "3d2b160a6205b0adc5422f35b6258734" "Check hash var value"]

    $RemoveGlobalVar $testGlobalVarName
    $RemoveGlobalVar $hashGlobalVarName

    /system script remove [find name=$testScriptName]

    :set res [$RunTestCase $res [:len [/system script find name=$testScriptName]] "nothing" "nothing" "nothing" 0 "Check if test script doesn't exist"]

    :local result2 { \
        "error"=false; \
        "failedtorun"=""; \
        "failedtoupdate"=""; \
        "runned"=$testScriptName; \
        "updated"=$testScriptName; \
        "uptodate"="" \
    }

    :set res [$RunTestCase $res $DownloadAndImportScriptsFromList \
        ("$prefixUrl/auto_update_test_list.txt") \
        "true" "false" \
        $result2 \
        "Download and run"]

    # Check for test var again
    :set res [$RunTestCase $res [:len [/system script find name=$testScriptName]] "nothing" "nothing" "nothing" 1 "Check if test script exists"]
    :set res [$RunTestCase $res $GetGlobalVar $testGlobalVarName "empty" "nothing" "test global var value" "Check test var value"]
    :set res [$RunTestCase $res $GetGlobalVar $hashGlobalVarName "empty" "nothing" "3d2b160a6205b0adc5422f35b6258734" "Check hash var value"]

    # Change to any value
    $SetGlobalVar $testGlobalVarName "some new value"

    # Check for test var again
    :set res [$RunTestCase $res $GetGlobalVar $testGlobalVarName "empty" "nothing" "some new value" "Check test var value"]

    :local result3 { \
        "error"=false; \
        "failedtorun"=""; \
        "failedtoupdate"=""; \
        "runned"=$testScriptName; \
        "updated"=""; \
        "uptodate"=$testScriptName \
    }

    :set res [$RunTestCase $res $DownloadAndImportScriptsFromList \
        ("$prefixUrl/auto_update_test_list.txt") \
        "true" "false" \
        $result3 \
        "Download and run again"]

    # Check for test var again
    :set res [$RunTestCase $res [:len [/system script find name=$testScriptName]] "nothing" "nothing" "nothing" 1 "Check if test script exists"]
    :set res [$RunTestCase $res $GetGlobalVar $testGlobalVarName "empty" "nothing" "test global var value" "Check test var value"]
    :set res [$RunTestCase $res $GetGlobalVar $hashGlobalVarName "empty" "nothing" "3d2b160a6205b0adc5422f35b6258734" "Check hash var value"]

    $RemoveGlobalVar $testGlobalVarName
    $RemoveGlobalVar $hashGlobalVarName

    /system script remove [find name=$testScriptName]

    :put "Testing completed."
    :return $res
}
