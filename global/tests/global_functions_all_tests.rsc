:global RunAllTestSuites

:set RunAllTestSuites do={
    :global RunAllArrayStrTests1
    :global RunAllArrayStrTests2
    :global RunAllArrayStrTests3
    :global RunAllDateTimeTests1
    :global RunAllDateTimeTests2
    :global RunAllEncodingTests
    :global RunAllGlobalVarTests
    :global RunAllHashesTests
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
            :set state [$suiteCode $state]
            :if ([:len $state] = 0) do={
                :set state [$InitTestCaseState]
                :set ($state->"error") true
                /log error "RunAllTestSuites: result is empty after run $suiteName"
            } else={
                :set ($state->"error") false
            }
        } on-error={
            /log error "RunAllTestSuites: failed to run $suiteName"
            :set state [$InitTestCaseState]
            :set ($state->"error") true
        }

        :set ($res->$suiteName) $state
        :return $res
    }

    # Run all test suites
    :local res [:toarray ""]

    [$RunTestSuite $res "ArrayStr1" $RunAllArrayStrTests1]
    [$RunTestSuite $res "ArrayStr2" $RunAllArrayStrTests2]
    [$RunTestSuite $res "ArrayStr3" $RunAllArrayStrTests3]
    [$RunTestSuite $res "DateTime1" $RunAllDateTimeTests1]
    [$RunTestSuite $res "DateTime2" $RunAllDateTimeTests2]
    [$RunTestSuite $res "Encoding" $RunAllEncodingTests]
    [$RunTestSuite $res "GlobalVar" $RunAllGlobalVarTests]
    [$RunTestSuite $res "Hashes" $RunAllHashesTests]
    [$RunTestSuite $res "Utils" $RunAllUtilsTests]

    :return $res
}
