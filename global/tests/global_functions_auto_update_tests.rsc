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
    :global FetchWithRedirect

    :local res [$InitTestCaseState $1]

    :put "Starting FetchWithRedirect tests..."

    :set res [$RunTestCase $res $FetchWithRedirect \
        "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/test_string.txt" \
        "nothing" "nothing" "This is test string. Do not change" "Test string fetching"]

    :put "Testing completed."
    :return $res
}
