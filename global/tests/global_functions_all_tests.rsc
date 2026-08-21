:global RunAllTestSuites

:set RunAllTestSuites do={
    :global RunAllArrayStrTests1
    :global RunAllArrayStrTests2
    :global RunAllArrayStrTests3
    :global RunAllAutoUpdateTests
    :global RunAllBigIntTests1
    :global RunAllBigIntTests2
    :global RunAllDateTimeTests1
    :global RunAllDateTimeTests2
    :global RunAllEncodingTests
    :global RunAllGlobalVarTests
    :global RunAllHashesTests1
    :global RunAllHashesTests2
    :global RunAllUtilsTests

    :local RunTestSuite do={
        :global InitTestCaseState

        # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
        :if ([:len $0] = 0) do={
            :return [:toarray ""]
        }

        :local res $1
        :local suiteName $2
        :local suiteCode $3

        :local state [$InitTestCaseState]

        # Execute the test suite passing the accumulator
        :do {
            :local result [$suiteCode $state]
            :if ([:typeof $result] = "array" && [:len $result] > 0) do={
                :set state $result
                :set ($state->"error") false
            } else={
                :set ($state->"error") true
                /log error "RunAllTestSuites: result is empty after run $suiteName"
            }
        } on-error={
            /log error "RunAllTestSuites: failed to run $suiteName"
            :set ($state->"error") true
        }

        :set ($res->$suiteName) $state
        :return $res
    }

    # Run all test suites
    :local res [:toarray ""]

    :set res [$RunTestSuite $res "ArrayStr1" $RunAllArrayStrTests1]
    :set res [$RunTestSuite $res "ArrayStr2" $RunAllArrayStrTests2]
    :set res [$RunTestSuite $res "ArrayStr3" $RunAllArrayStrTests3]
    :set res [$RunTestSuite $res "AutoUpdate" $RunAllAutoUpdateTests]
    :set res [$RunTestSuite $res "BigInt1" $RunAllBigIntTests1]
    :set res [$RunTestSuite $res "BigInt2" $RunAllBigIntTests2]
    :set res [$RunTestSuite $res "DateTime1" $RunAllDateTimeTests1]
    :set res [$RunTestSuite $res "DateTime2" $RunAllDateTimeTests2]
    :set res [$RunTestSuite $res "Encoding" $RunAllEncodingTests]
    :set res [$RunTestSuite $res "GlobalVar" $RunAllGlobalVarTests]
    :set res [$RunTestSuite $res "Hashes1" $RunAllHashesTests1]
    :set res [$RunTestSuite $res "Hashes2" $RunAllHashesTests2]
    :set res [$RunTestSuite $res "Utils" $RunAllUtilsTests]

    :return $res
}
