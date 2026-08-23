:global RunAllBigIntTests1
:global TestBigIntConversion
:global TestBigIntCleanArr
:global TestBigIntCmp
:global TestBigIntAdd
:global TestBigIntSub
:global TestBigIntMul
:global TestBigIntMod
:global TestBigIntDiv
:global TestBigIntPow
:global TestBigIntPowMod

:set RunAllBigIntTests1 do={
    :global InitTestCaseState
    :global TestBigIntConversion
    :global TestBigIntCleanArr
    :global TestBigIntCmp
    :global TestBigIntAdd
    :global TestBigIntSub
    :global TestBigIntMul
    :global TestBigIntMod
    :global TestBigIntDiv
    :global TestBigIntPow
    :global TestBigIntPowMod

    :local res [$InitTestCaseState $1]

    :put "\1B[35m=== STARTING ALL BIG INT 1 TESTS ===\1B[0m"
    :put "Starting BigInt tests..."

    :set res [$TestBigIntConversion $res]
    :set res [$TestBigIntCleanArr $res]
    :set res [$TestBigIntCmp $res]
    :set res [$TestBigIntAdd $res]
    :set res [$TestBigIntSub $res]
    :set res [$TestBigIntMul $res]
    :set res [$TestBigIntMod $res]
    :set res [$TestBigIntDiv $res]
    :set res [$TestBigIntPow $res]
    :set res [$TestBigIntPowMod $res]

    :put "Testing completed."
    :put "\1B[35m=== ALL BIG INT 1 TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set TestBigIntConversion do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntToArray
    :global ArrayToBigInt

    :local res [$InitTestCaseState $1]

    # ==========================================
    # Conversion Test Cases
    # ==========================================

    # Positive single digits
    :set res [$RunTestCase $res $BigIntToArray "0" "nothing" "nothing" ({"data"=0;"sign"=1}) "Zero array representation"]
    :set res [$RunTestCase $res $BigIntToArray "-0" "nothing" "nothing" ({"data"=0;"sign"=1}) "Negative zero array representation"]
    :set res [$RunTestCase $res $BigIntToArray "1" "nothing" "nothing" ({"data"={1};"sign"=1}) "Single digit 1"]
    :set res [$RunTestCase $res $BigIntToArray "9" "nothing" "nothing" ({"data"={9};"sign"=1}) "Single digit 9"]

    # Negative single digits
    :set res [$RunTestCase $res $BigIntToArray "-1" "nothing" "nothing" ({"data"={1};"sign"=-1}) "Negative single digit 1"]
    :set res [$RunTestCase $res $BigIntToArray "-9" "nothing" "nothing" ({"data"={9};"sign"=-1}) "Negative single digit 9"]

    # Positive small numbers
    :set res [$RunTestCase $res $BigIntToArray "10" "nothing" "nothing" ({"data"={10};"sign"=1}) "Number 10"]
    :set res [$RunTestCase $res $BigIntToArray "99" "nothing" "nothing" ({"data"={99};"sign"=1}) "Number 99"]
    :set res [$RunTestCase $res $BigIntToArray "100" "nothing" "nothing" ({"data"={100};"sign"=1}) "Number 100"]
    :set res [$RunTestCase $res $BigIntToArray "999" "nothing" "nothing" ({"data"={999};"sign"=1}) "Number 999"]
    :set res [$RunTestCase $res $BigIntToArray "1000" "nothing" "nothing" ({"data"={1000};"sign"=1}) "Number 1000"]

    # Negative small numbers
    :set res [$RunTestCase $res $BigIntToArray "-10" "nothing" "nothing" ({"data"={10};"sign"=-1}) "Negative number 10"]
    :set res [$RunTestCase $res $BigIntToArray "-99" "nothing" "nothing" ({"data"={99};"sign"=-1}) "Negative number 99"]
    :set res [$RunTestCase $res $BigIntToArray "-100" "nothing" "nothing" ({"data"={100};"sign"=-1}) "Negative number 100"]
    :set res [$RunTestCase $res $BigIntToArray "-999" "nothing" "nothing" ({"data"={999};"sign"=-1}) "Negative number 999"]
    :set res [$RunTestCase $res $BigIntToArray "-1000" "nothing" "nothing" ({"data"={1000};"sign"=-1}) "Negative number 1000"]

    # Medium numbers
    :set res [$RunTestCase $res $BigIntToArray "123456" "nothing" "nothing" ({"data"={123456};"sign"=1}) "Medium positive 123456"]
    :set res [$RunTestCase $res $BigIntToArray "-123456" "nothing" "nothing" ({"data"={123456};"sign"=-1}) "Medium negative 123456"]
    :set res [$RunTestCase $res $BigIntToArray "123456789" "nothing" "nothing" ({"data"={123456789};"sign"=1}) "Max single chunk positive"]
    :set res [$RunTestCase $res $BigIntToArray "-123456789" "nothing" "nothing" ({"data"={123456789};"sign"=-1}) "Max single chunk negative"]

    # Boundary and multi-chunk numbers
    :set res [$RunTestCase $res $BigIntToArray "1000000000" "nothing" "nothing" ({"data"={0, 1};"sign"=1}) "Exact 1 billion"]
    :set res [$RunTestCase $res $BigIntToArray "-1000000000" "nothing" "nothing" ({"data"={0, 1};"sign"=-1}) "Exact negative 1 billion"]
    :set res [$RunTestCase $res $BigIntToArray "123456789012345" "nothing" "nothing" ({"data"={789012345, 123456};"sign"=1}) "Multi chunk positive 15 digits"]
    :set res [$RunTestCase $res $BigIntToArray "-123456789012345" "nothing" "nothing" ({"data"={789012345, 123456};"sign"=-1}) "Multi chunk negative 15 digits"]
    :set res [$RunTestCase $res $BigIntToArray "999999999999999999" "nothing" "nothing" ({"data"={999999999, 999999999};"sign"=1}) "Large 18-digit nines"]
    :set res [$RunTestCase $res $BigIntToArray "-999999999999999999" "nothing" "nothing" ({"data"={999999999, 999999999};"sign"=-1}) "Large negative 18-digit nines"]

    # Round-trip tests (ArrayToBigInt of BigIntToArray)
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "0"] "nothing" "nothing" "0" "Round-trip zero"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-0"] "nothing" "nothing" "0" "Round-trip negative zero"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "7"] "nothing" "nothing" "7" "Round-trip single digit 7"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-7"] "nothing" "nothing" "-7" "Round-trip negative single digit 7"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "42"] "nothing" "nothing" "42" "Round-trip 42"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-42"] "nothing" "nothing" "-42" "Round-trip negative 42"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "999999999"] "nothing" "nothing" "999999999" "Round-trip max 9-digit chunk"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-999999999"] "nothing" "nothing" "-999999999" "Round-trip negative max 9-digit chunk"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "1000000000"] "nothing" "nothing" "1000000000" "Round-trip 1 billion"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-1000000000"] "nothing" "nothing" "-1000000000" "Round-trip negative 1 billion"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "987654321012345678"] "nothing" "nothing" "987654321012345678" "Round-trip large 18-digit number"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-987654321012345678"] "nothing" "nothing" "-987654321012345678" "Round-trip negative large 18-digit number"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "123456789012345678901234567890"] "nothing" "nothing" "123456789012345678901234567890" "Round-trip very large 30-digit number"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-123456789012345678901234567890"] "nothing" "nothing" "-123456789012345678901234567890" "Round-trip negative very large 30-digit number"]

    # Additional test cases for large multi-chunk numbers

    # Three-chunk positive number direct array verification
    :set res [$RunTestCase $res $BigIntToArray "1234567891234567891234567" "nothing" "nothing" ({"data"={891234567, 891234567, 1234567};"sign"=1}) "Three-chunk positive array structure"]
    :set res [$RunTestCase $res $ArrayToBigInt ({"data"=(567890123, 456789123, 1234567);"sign"=1}) "nothing" "nothing" "1234567456789123567890123" "Three-chunk positive array to string"]

    # Three-chunk negative number direct array verification
    :set res [$RunTestCase $res $BigIntToArray "-1234567891234567891234567" "nothing" "nothing" ({"data"={891234567, 891234567, 1234567};"sign"=-1}) "Three-chunk negative array structure"]
    :set res [$RunTestCase $res $ArrayToBigInt ({"data"=(567890123, 456789123, 1234567);"sign"=-1}) "nothing" "nothing" "-1234567456789123567890123" "Three-chunk negative array to string"]

    # Round-trip multi-chunk validation tests
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "111222333444555666777888999"] "nothing" "nothing" "111222333444555666777888999" "Round-trip three-chunk positive number"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-111222333444555666777888999"] "nothing" "nothing" "-111222333444555666777888999" "Round-trip three-chunk negative number"]

    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "123456789012345678901234567890123456789"] "nothing" "nothing" "123456789012345678901234567890123456789" "Round-trip four-chunk positive number"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-123456789012345678901234567890123456789"] "nothing" "nothing" "-123456789012345678901234567890123456789" "Round-trip four-chunk negative number"]

    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "999888777666555444333222111000999888777666555"] "nothing" "nothing" "999888777666555444333222111000999888777666555" "Round-trip five-chunk positive number"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-999888777666555444333222111000999888777666555"] "nothing" "nothing" "-999888777666555444333222111000999888777666555" "Round-trip five-chunk negative number"]

    # Conversion round-trip boundary tests
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "999999999"] "nothing" "nothing" "999999999" "Round-trip max single chunk"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "1000000000"] "nothing" "nothing" "1000000000" "Round-trip first multi-chunk value"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "999999999999999999"] "nothing" "nothing" "999999999999999999" "Round-trip max two chunks"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "1000000000000000000"] "nothing" "nothing" "1000000000000000000" "Round-trip first three-chunk boundary"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "999999999999999999999999999"] "nothing" "nothing" "999999999999999999999999999" "Round-trip large chunk boundary"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-999999999999999999999999999"] "nothing" "nothing" "-999999999999999999999999999" "Round-trip negative large chunk boundary"]

    :return $res
}

:set TestBigIntCleanArr do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntCleanArr

    :local res [$InitTestCaseState $1]

    # ==========================================
    # BigIntCleanArr Test Cases
    # ==========================================

    # Clean array positive and negative chunks
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=[:toarray 123]}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 123]}) "Single positive chunk"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=-1; "data"=[:toarray 123]}) "nothing" "nothing" ({"sign"=-1; "data"=[:toarray 123]}) "Single negative chunk"]

    # Clean array multiple chunks without trailing zeros
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(123, 456)}) "nothing" "nothing" ({"sign"=1; "data"=(123, 456)}) "Multiple chunks without trailing zeros"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=-1; "data"=(123, 456)}) "nothing" "nothing" ({"sign"=-1; "data"=(123, 456)}) "Multiple negative chunks without trailing zeros"]

    # Clean array one trailing zero
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(123, 0)}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 123]}) "One trailing zero positive"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=-1; "data"=(123, 0)}) "nothing" "nothing" ({"sign"=-1; "data"=[:toarray 123]}) "One trailing zero negative"]

    # Clean array multiple trailing zeros
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(123, 0, 0, 0)}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 123]}) "Multiple trailing zeros"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=-1; "data"=(123, 0, 0, 0)}) "nothing" "nothing" ({"sign"=-1; "data"=[:toarray 123]}) "Multiple trailing zeros negative"]

    # Clean array single zero chunks
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=[:toarray 0]}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 0]}) "Single zero chunk positive"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=-1; "data"=[:toarray 0]}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 0]}) "Single zero chunk negative normalizes to positive"]

    # Clean array multiple zero chunks entirely
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(0, 0)}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 0]}) "Two zero chunks positive"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=-1; "data"=(0, 0)}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 0]}) "Two zero chunks negative normalizes to positive"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(0, 0, 0, 0, 0)}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 0]}) "Many zero chunks positive"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=-1; "data"=(0, 0, 0, 0, 0)}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 0]}) "Many zero chunks negative normalizes to positive"]

    # Clean array zeros placed in the middle
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(123, 0, 456)}) "nothing" "nothing" ({"sign"=1; "data"=(123, 0, 456)}) "Zeros in the middle only"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(123, 0, 456, 0, 0)}) "nothing" "nothing" ({"sign"=1; "data"=(123, 0, 456)}) "Zeros in the middle and at the end"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(1, 0, 2, 0, 3, 0)}) "nothing" "nothing" ({"sign"=1; "data"=(1, 0, 2, 0, 3)}) "Zeros separating digits with trailing zero"]

    # Clean array starting with zero chunks
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(0, 123, 0)}) "nothing" "nothing" ({"sign"=1; "data"=(0, 123)}) "Array starts with zero chunk"]
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(0, 0, 123, 0, 0)}) "nothing" "nothing" ({"sign"=1; "data"=(0, 0, 123)}) "Array starts with multiple zero chunks"]

    # Clean array with max chunk boundaries
    :set res [$RunTestCase $res $BigIntCleanArr ({"sign"=1; "data"=(999999999, 0)}) "nothing" "nothing" ({"sign"=1; "data"=[:toarray 999999999]}) "Max chunk size with trailing zero"]

    :return $res
}

:set TestBigIntCmp do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntCmp

    :local res [$InitTestCaseState $1]

    # ==========================================
    # BigIntCmp Test Cases
    # ==========================================
    :set res [$RunTestCase $res $BigIntCmp "5" "5" "nothing" "0" "Compare equal positive numbers"]
    :set res [$RunTestCase $res $BigIntCmp "10" "5" "nothing" "1" "Compare greater left operand"]
    :set res [$RunTestCase $res $BigIntCmp "5" "10" "nothing" "-1" "Compare smaller left operand"]
    :set res [$RunTestCase $res $BigIntCmp "-5" "5" "nothing" "-1" "Compare negative vs positive"]
    :set res [$RunTestCase $res $BigIntCmp "5" "-5" "nothing" "1" "Compare positive vs negative"]
    :set res [$RunTestCase $res $BigIntCmp "-10" "-5" "nothing" "-1" "Compare negative numbers magnitude order"]
    :set res [$RunTestCase $res $BigIntCmp "100" "99" "nothing" "1" "Compare different lengths positive"]
    :set res [$RunTestCase $res $BigIntCmp "0" "0" "nothing" "0" "Compare zeros"]

    # Equal numbers test cases
    :set res [$RunTestCase $res $BigIntCmp "0" "0" "nothing" "0" "Compare zero and zero"]
    :set res [$RunTestCase $res $BigIntCmp "5" "5" "nothing" "0" "Compare equal positive numbers"]
    :set res [$RunTestCase $res $BigIntCmp "12345" "12345" "nothing" "0" "Compare equal multi-digit numbers"]
    :set res [$RunTestCase $res $BigIntCmp "-5" "-5" "nothing" "0" "Compare equal negative numbers"]
    :set res [$RunTestCase $res $BigIntCmp "-0" "0" "nothing" "0" "Compare negative zero and zero"]

    # Greater left operand test cases (same length)
    :set res [$RunTestCase $res $BigIntCmp "6" "5" "nothing" "1" "Compare single digit greater left"]
    :set res [$RunTestCase $res $BigIntCmp "5" "6" "nothing" "-1" "Compare single digit smaller left"]
    :set res [$RunTestCase $res $BigIntCmp "15" "12" "nothing" "1" "Compare same length greater left"]
    :set res [$RunTestCase $res $BigIntCmp "12" "15" "nothing" "-1" "Compare same length smaller left"]
    :set res [$RunTestCase $res $BigIntCmp "999" "888" "nothing" "1" "Compare triple digits greater left"]

    # Different lengths positive numbers
    :set res [$RunTestCase $res $BigIntCmp "10" "5" "nothing" "1" "Compare longer left positive number"]
    :set res [$RunTestCase $res $BigIntCmp "5" "10" "nothing" "-1" "Compare shorter left positive number"]
    :set res [$RunTestCase $res $BigIntCmp "100" "99" "nothing" "1" "Compare boundary length increase positive"]
    :set res [$RunTestCase $res $BigIntCmp "99" "100" "nothing" "-1" "Compare boundary length decrease positive"]
    :set res [$RunTestCase $res $BigIntCmp "1000" "999" "nothing" "1" "Compare thousands vs hundreds"]
    :set res [$RunTestCase $res $BigIntCmp "12345" "9999" "nothing" "1" "Compare five digits vs four digits"]

    # Sign combinations and cross-sign comparisons
    :set res [$RunTestCase $res $BigIntCmp "-5" "5" "nothing" "-1" "Compare negative vs positive"]
    :set res [$RunTestCase $res $BigIntCmp "5" "-5" "nothing" "1" "Compare positive vs negative"]
    :set res [$RunTestCase $res $BigIntCmp "-100" "1" "nothing" "-1" "Compare large negative vs small positive"]
    :set res [$RunTestCase $res $BigIntCmp "0" "-5" "nothing" "1" "Compare zero vs negative"]
    :set res [$RunTestCase $res $BigIntCmp "-5" "0" "nothing" "-1" "Compare negative vs zero"]

    # Negative numbers magnitude ordering
    :set res [$RunTestCase $res $BigIntCmp "-10" "-5" "nothing" "-1" "Compare negative magnitude order smaller left"]
    :set res [$RunTestCase $res $BigIntCmp "-5" "-10" "nothing" "1" "Compare negative magnitude order greater left"]
    :set res [$RunTestCase $res $BigIntCmp "-100" "-99" "nothing" "-1" "Compare negative length difference smaller left"]
    :set res [$RunTestCase $res $BigIntCmp "-99" "-100" "nothing" "1" "Compare negative length difference greater left"]
    :set res [$RunTestCase $res $BigIntCmp "-1234" "-5678" "nothing" "1" "Compare large negative magnitudes reversed"]

    # Large scale and complex comparisons
    :set res [$RunTestCase $res $BigIntCmp "987654321" "123456789" "nothing" "1" "Compare large scale numbers greater left"]
    :set res [$RunTestCase $res $BigIntCmp "123456789" "987654321" "nothing" "-1" "Compare large scale numbers smaller left"]
    :set res [$RunTestCase $res $BigIntCmp "1000000" "999999" "nothing" "1" "Compare million vs near million"]
    :set res [$RunTestCase $res $BigIntCmp "000987" "000986" "nothing" "1" "Compare padded close numbers greater"]
    :set res [$RunTestCase $res $BigIntCmp "-000987" "-000986" "nothing" "-1" "Compare padded close negative numbers"]

    # Comparison consistency
    :set res [$RunTestCase $res $BigIntCmp "123456789123456789" "987654321987654321" "nothing" "-1" "Comparison ordered large values"]
    :set res [$RunTestCase $res $BigIntCmp "987654321987654321" "123456789123456789" "nothing" "1" "Comparison reverse ordered large values"]
    :set res [$RunTestCase $res $BigIntCmp "-987654321987654321" "-123456789123456789" "nothing" "-1" "Comparison ordered negative values"]
    :set res [$RunTestCase $res $BigIntCmp "-123456789123456789" "-987654321987654321" "nothing" "1" "Comparison reverse ordered negative values"]
    :set res [$RunTestCase $res $BigIntCmp "123456789123456789" "123456789123456789" "nothing" "0" "Comparison identical large values"]

    :return $res
}

:set TestBigIntAdd do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntAdd
    :global BigIntSub

    :local res [$InitTestCaseState $1]

    # ==========================================
    # BigIntAdd Test Cases
    # ==========================================
    :set res [$RunTestCase $res $BigIntAdd "5" "5" "nothing" "10" "Add simple positives"]
    :set res [$RunTestCase $res $BigIntAdd "123" "457" "nothing" "580" "Add with carry propagation"]
    :set res [$RunTestCase $res $BigIntAdd "999" "1" "nothing" "1000" "Add boundary carry expansion"]
    :set res [$RunTestCase $res $BigIntAdd "10" "-5" "nothing" "5" "Add positive and negative resulting positive"]
    :set res [$RunTestCase $res $BigIntAdd "5" "-10" "nothing" "-5" "Add positive and negative resulting negative"]
    :set res [$RunTestCase $res $BigIntAdd "-10" "-10" "nothing" "-20" "Add two negatives"]
    :set res [$RunTestCase $res $BigIntAdd "0" "123" "nothing" "123" "Add zero to number"]

    # Basic positive numbers and zero additions
    :set res [$RunTestCase $res $BigIntAdd "5" "5" "nothing" "10" "Add simple positives"]
    :set res [$RunTestCase $res $BigIntAdd "0" "0" "nothing" "0" "Add zero to zero"]
    :set res [$RunTestCase $res $BigIntAdd "123" "0" "nothing" "123" "Add zero to number"]
    :set res [$RunTestCase $res $BigIntAdd "0" "456" "nothing" "456" "Add number to zero"]
    :set res [$RunTestCase $res $BigIntAdd "1" "1" "nothing" "2" "Add small units"]

    # Carry propagation and boundary expansions
    :set res [$RunTestCase $res $BigIntAdd "9" "1" "nothing" "10" "Add single digit carry boundary"]
    :set res [$RunTestCase $res $BigIntAdd "99" "1" "nothing" "100" "Add two nines carry boundary"]
    :set res [$RunTestCase $res $BigIntAdd "999" "1" "nothing" "1000" "Add three nines carry boundary"]
    :set res [$RunTestCase $res $BigIntAdd "9999" "1" "nothing" "10000" "Add four nines carry boundary"]
    :set res [$RunTestCase $res $BigIntAdd "99999" "1" "nothing" "100000" "Add five nines carry boundary"]
    :set res [$RunTestCase $res $BigIntAdd "00999" "001" "nothing" "1000" "Add boundary with leading zeros"]
    :set res [$RunTestCase $res $BigIntAdd "999" "999" "nothing" "1998" "Add large boundary numbers"]

    # Mixed signs resulting in various outcomes
    :set res [$RunTestCase $res $BigIntAdd "10" "-5" "nothing" "5" "Add positive and negative resulting positive"]
    :set res [$RunTestCase $res $BigIntAdd "5" "-10" "nothing" "-5" "Add positive and negative resulting negative"]
    :set res [$RunTestCase $res $BigIntAdd "-10" "5" "nothing" "-5" "Add negative and positive resulting negative"]
    :set res [$RunTestCase $res $BigIntAdd "-5" "10" "nothing" "5" "Add negative and positive resulting positive"]
    :set res [$RunTestCase $res $BigIntAdd "10" "-10" "nothing" "0" "Add opposite numbers resulting in zero"]
    :set res [$RunTestCase $res $BigIntAdd "-10" "10" "nothing" "0" "Add negative to positive resulting in zero"]
    :set res [$RunTestCase $res $BigIntAdd "0" "-5" "nothing" "-5" "Add negative to zero"]
    :set res [$RunTestCase $res $BigIntAdd "-5" "0" "nothing" "-5" "Add zero to negative"]

    # Two negative operands
    :set res [$RunTestCase $res $BigIntAdd "-10" "-10" "nothing" "-20" "Add two negatives"]
    :set res [$RunTestCase $res $BigIntAdd "-123" "-457" "nothing" "-580" "Add two large negatives"]
    :set res [$RunTestCase $res $BigIntAdd "-0010" "-0010" "nothing" "-20" "Add two negatives with leading zeros"]
    :set res [$RunTestCase $res $BigIntAdd "-999" "-1" "nothing" "-1000" "Add negative boundary carry"]

    # Large scale numbers and complex carry chains
    :set res [$RunTestCase $res $BigIntAdd "123456789" "987654321" "nothing" "1111111110" "Add large distinct numbers"]
    :set res [$RunTestCase $res $BigIntAdd "987654321" "123456789" "nothing" "1111111110" "Commutative add large distinct numbers"]
    :set res [$RunTestCase $res $BigIntAdd "45345345345345345" "53453453453453453" "nothing" "98798798798798798" "Add massive scale numbers"]
    :set res [$RunTestCase $res $BigIntAdd "1000000" "1000000" "nothing" "2000000" "Add millions"]
    :set res [$RunTestCase $res $BigIntAdd "5000" "5000" "nothing" "10000" "Add thousands boundary"]
    :set res [$RunTestCase $res $BigIntAdd "000987" "00013" "nothing" "1000" "Add padded numbers with carry"]
    :set res [$RunTestCase $res $BigIntAdd "999999999" "1" "nothing" "1000000000" "Add billion boundary"]
    :set res [$RunTestCase $res $BigIntAdd "-45345345345345345" "-53453453453453453" "nothing" "-98798798798798798" "Add massive scale negatives"]
    :set res [$RunTestCase $res $BigIntAdd "1005" "2005" "nothing" "3010" "Add numbers with inner zeros"]
    :set res [$RunTestCase $res $BigIntAdd "123456789123456789" "-123456789123456788" "nothing" "1" "Leading zero test"]

    # Addition operations with padded inputs testing clean output propagation
    :set res [$RunTestCase $res $BigIntAdd "005" "000" "nothing" "5" "Addition padded zero with single digit"]
    :set res [$RunTestCase $res $BigIntAdd "000" "005" "nothing" "5" "Addition zero with padded single digit"]
    :set res [$RunTestCase $res $BigIntAdd "009" "001" "nothing" "10" "Addition clean boundary tens"]
    :set res [$RunTestCase $res $BigIntAdd "00099" "00001" "nothing" "100" "Addition clean heavy padded boundary"]

    # Extreme big numbers
    :set res [$RunTestCase $res $BigIntAdd \
        "78467056652122474322352994821898150938468142257513328624" \
        "155816117716540682014331966477183092459182471129987" \
        "nothing" \
        "78467212468240190863035009153864628121560601439984458611" \
        "Extreme big numbers add"]

    :return $res
}

:set TestBigIntSub do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntSub

    :local res [$InitTestCaseState $1]

    # ==========================================
    # BigIntSub Test Cases
    # ==========================================
    :set res [$RunTestCase $res $BigIntSub "10" "5" "nothing" "5" "Subtract standard positive result"]
    :set res [$RunTestCase $res $BigIntSub "5" "10" "nothing" "-5" "Subtract resulting negative"]
    :set res [$RunTestCase $res $BigIntSub "100" "100" "nothing" "0" "Subtract to zero"]
    :set res [$RunTestCase $res $BigIntSub "10" "-5" "nothing" "15" "Subtract negative equivalent to add"]
    :set res [$RunTestCase $res $BigIntSub "-10" "5" "nothing" "-15" "Subtract positive from negative"]
    :set res [$RunTestCase $res $BigIntSub "-10" "-5" "nothing" "-5" "Subtract two negatives"]
    :set res [$RunTestCase $res $BigIntSub "45345345345345345" "53453453453453453" "nothing" "-8108108108108108" "Subtract large cross-borrow case"]

    # Basic subtraction and zeros
    :set res [$RunTestCase $res $BigIntSub "10" "5" "nothing" "5" "Subtract standard positive result"]
    :set res [$RunTestCase $res $BigIntSub "5" "10" "nothing" "-5" "Subtract resulting negative"]
    :set res [$RunTestCase $res $BigIntSub "100" "100" "nothing" "0" "Subtract identical numbers to zero"]
    :set res [$RunTestCase $res $BigIntSub "0" "0" "nothing" "0" "Subtract zero from zero"]
    :set res [$RunTestCase $res $BigIntSub "500" "0" "nothing" "500" "Subtract zero from number"]
    :set res [$RunTestCase $res $BigIntSub "0" "500" "nothing" "-500" "Subtract number from zero"]

    # Borrow chains and inner zeros generation
    :set res [$RunTestCase $res $BigIntSub "1005" "1000" "nothing" "5" "Borrow chain generating single digit remainder"]
    :set res [$RunTestCase $res $BigIntSub "1000" "1" "nothing" "999" "Borrow across multiple zero digits"]
    :set res [$RunTestCase $res $BigIntSub "10000" "1" "nothing" "9999" "Borrow across four zero digits"]
    :set res [$RunTestCase $res $BigIntSub "100000" "1" "nothing" "99999" "Borrow across five zero digits"]
    :set res [$RunTestCase $res $BigIntSub "2000" "1" "nothing" "1999" "Borrow from thousands boundary"]
    :set res [$RunTestCase $res $BigIntSub "10005" "10000" "nothing" "5" "Large scale borrow chain single digit"]
    :set res [$RunTestCase $res $BigIntSub "100000" "99991" "nothing" "9" "Multi-zero borrow resulting in single digit"]
    :set res [$RunTestCase $res $BigIntSub "100" "98" "nothing" "2" "Small bounds single digit result"]

    :set res [$RunTestCase $res $BigIntSub \
        "1000000000000000000000000000100" \
        "1000000000000000000000000000000" \
        "nothing" \
        "100" \
        "Leading zeros removing"]

    # Sign combinations and negative arithmetic
    :set res [$RunTestCase $res $BigIntSub "10" "-5" "nothing" "15" "Subtract negative equivalent to addition"]
    :set res [$RunTestCase $res $BigIntSub "-10" "5" "nothing" "-15" "Subtract positive from negative"]
    :set res [$RunTestCase $res $BigIntSub "-10" "-5" "nothing" "-5" "Subtract two negatives resulting in negative"]
    :set res [$RunTestCase $res $BigIntSub "-5" "-10" "nothing" "5" "Subtract two negatives resulting in positive"]
    :set res [$RunTestCase $res $BigIntSub "0" "-5" "nothing" "5" "Subtract negative from zero"]
    :set res [$RunTestCase $res $BigIntSub "-5" "0" "nothing" "-5" "Subtract zero from negative"]
    :set res [$RunTestCase $res $BigIntSub "-0010" "-0005" "nothing" "-5" "Subtract negatives with leading zeros"]

    # Large values and cross-borrow scenarios
    :set res [$RunTestCase $res $BigIntSub "999999" "1" "nothing" "999998" "Subtract from large nines string"]
    :set res [$RunTestCase $res $BigIntSub "1000000" "1" "nothing" "999999" "Subtract from million boundary"]
    :set res [$RunTestCase $res $BigIntSub "45345345345345345" "53453453453453453" "nothing" "-8108108108108108" "Large cross-borrow negative case"]
    :set res [$RunTestCase $res $BigIntSub "987654321" "123456789" "nothing" "864197532" "Subtract large distinct numbers"]
    :set res [$RunTestCase $res $BigIntSub "123456789" "987654321" "nothing" "-864197532" "Subtract large distinct resulting negative"]
    :set res [$RunTestCase $res $BigIntSub "1000000000" "500000000" "nothing" "500000000" "Subtract large scale halves"]
    :set res [$RunTestCase $res $BigIntSub "000987" "00010" "nothing" "977" "Padded large numbers subtraction"]
    :set res [$RunTestCase $res $BigIntSub "50000" "49999" "nothing" "1" "Adjacent large scale subtraction"]
    :set res [$RunTestCase $res $BigIntSub "9999" "9998" "nothing" "1" "Adjacent boundary subtraction"]
    :set res [$RunTestCase $res $BigIntSub "-99999" "-99998" "nothing" "-1" "Adjacent negative boundary subtraction"]
    :set res [$RunTestCase $res $BigIntSub "123456789123456789" "123456789123456788" "nothing" "1" "Massive string adjacent difference"]

    # Subtraction operations prone to uncleaned leading zeros during borrow chains
    :set res [$RunTestCase $res $BigIntSub "1000" "995" "nothing" "5" "Subtraction borrow chain resulting in single digit"]
    :set res [$RunTestCase $res $BigIntSub "10005" "10000" "nothing" "5" "Subtraction large borrow chain single digit"]
    :set res [$RunTestCase $res $BigIntSub "100000" "99991" "nothing" "9" "Subtraction multi-zero borrow resulting in nine"]
    :set res [$RunTestCase $res $BigIntSub "100" "98" "nothing" "2" "Subtraction small bounds single digit"]
    :set res [$RunTestCase $res $BigIntSub "1000000" "999991" "nothing" "9" "Subtraction heavy zero crossing"]

    # Extreme big numbers
    :set res [$RunTestCase $res $BigIntSub \
        "78467056652122474322352994821898150938468142257513328624" \
        "155816117716540682014331966477183092459182471129987" \
        "nothing" \
        "78466900836004757781670980489931673755375683075042198637" \
        "Extreme big numbers sub"]

    :return $res
}

:set TestBigIntMul do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntMul

    :local res [$InitTestCaseState $1]

    # ==========================================
    # BigIntMul Test Cases
    # ==========================================

    # Basic small numbers and zeros
    :set res [$RunTestCase $res $BigIntMul "0" "0" "nothing" "0" "Multiply zero by zero"]
    :set res [$RunTestCase $res $BigIntMul "1" "1" "nothing" "1" "Multiply one by one"]
    :set res [$RunTestCase $res $BigIntMul "5" "5" "nothing" "25" "Multiply single digits"]
    :set res [$RunTestCase $res $BigIntMul "9" "9" "nothing" "81" "Multiply max single digits"]

    # Multiplication by zero and edge forms
    :set res [$RunTestCase $res $BigIntMul "100" "0" "nothing" "0" "Multiply by zero"]
    :set res [$RunTestCase $res $BigIntMul "0" "500" "nothing" "0" "Multiply zero by number"]
    :set res [$RunTestCase $res $BigIntMul "12345" "0" "nothing" "0" "Multiply large number by zero"]
    :set res [$RunTestCase $res $BigIntMul "0" "98765" "nothing" "0" "Multiply zero by large number"]
    :set res [$RunTestCase $res $BigIntMul "000" "123" "nothing" "0" "Multiply zero with leading zeros"]
    :set res [$RunTestCase $res $BigIntMul "456" "000" "nothing" "0" "Multiply by zero with leading zeros"]
    :set res [$RunTestCase $res $BigIntMul "0000" "0000" "nothing" "0" "Multiple zero strings test"]
    :set res [$RunTestCase $res $BigIntMul "-0" "-0" "nothing" "0" "Negative zeros multiplication"]

    # Multiplication by units and signs
    :set res [$RunTestCase $res $BigIntMul "456" "1" "nothing" "456" "Multiply by one"]
    :set res [$RunTestCase $res $BigIntMul "1" "789" "nothing" "789" "Multiply one by number"]
    :set res [$RunTestCase $res $BigIntMul "456" "-1" "nothing" "-456" "Multiply by negative one"]
    :set res [$RunTestCase $res $BigIntMul "-1" "789" "nothing" "-789" "Multiply negative one by number"]

    # Sign combinations
    :set res [$RunTestCase $res $BigIntMul "12" "12" "nothing" "144" "Multiply positive by positive"]
    :set res [$RunTestCase $res $BigIntMul "-12" "12" "nothing" "-144" "Multiply negative by positive"]
    :set res [$RunTestCase $res $BigIntMul "12" "-12" "nothing" "-144" "Multiply positive by negative"]
    :set res [$RunTestCase $res $BigIntMul "-12" "-12" "nothing" "144" "Multiply negative by negative"]

    # Inputs with leading zeros
    :set res [$RunTestCase $res $BigIntMul "007" "008" "nothing" "56" "Multiply with leading zeros on both"]
    :set res [$RunTestCase $res $BigIntMul "010" "010" "nothing" "100" "Multiply tens with leading zeros"]
    :set res [$RunTestCase $res $BigIntMul "-005" "005" "nothing" "-25" "Multiply negative with leading zeros"]
    :set res [$RunTestCase $res $BigIntMul "00123" "0" "nothing" "0" "Multiply leading zero string by zero"]
    :set res [$RunTestCase $res $BigIntMul "-00012" "-00012" "nothing" "144" "Multiply negative numbers with heavy leading zeros"]
    :set res [$RunTestCase $res $BigIntMul "000045" "00002" "nothing" "90" "Multiply heavy padded inputs"]

    # Powers of ten and boundaries
    :set res [$RunTestCase $res $BigIntMul "10" "10" "nothing" "100" "Multiply base tens"]
    :set res [$RunTestCase $res $BigIntMul "100" "100" "nothing" "10000" "Multiply hundreds"]
    :set res [$RunTestCase $res $BigIntMul "1000" "5" "nothing" "5000" "Multiply thousand by single digit"]
    :set res [$RunTestCase $res $BigIntMul "999" "1" "nothing" "999" "Multiply by boundary value"]
    :set res [$RunTestCase $res $BigIntMul "999" "999" "nothing" "998001" "Multiply large boundary numbers"]
    :set res [$RunTestCase $res $BigIntMul "1000" "1000" "nothing" "1000000" "Multiply powers of ten"]

    # Standard multi-digit and commutativity
    :set res [$RunTestCase $res $BigIntMul "123" "456" "nothing" "56088" "Multiply standard multi-digit numbers"]
    :set res [$RunTestCase $res $BigIntMul "456" "123" "nothing" "56088" "Commutativity check reversed operands"]
    :set res [$RunTestCase $res $BigIntMul "1005" "2" "nothing" "2010" "Multiply number with inner zeros"]
    :set res [$RunTestCase $res $BigIntMul "500" "200" "nothing" "100000" "Multiply numbers ending in zeros"]
    :set res [$RunTestCase $res $BigIntMul "777" "888" "nothing" "689976" "Triple digits cross product"]

    # Large values and complex cross products
    :set res [$RunTestCase $res $BigIntMul "98765" "4321" "nothing" "426763565" "Multiply large numbers"]
    :set res [$RunTestCase $res $BigIntMul "-98765" "4321" "nothing" "-426763565" "Large numbers mixed signs"]
    :set res [$RunTestCase $res $BigIntMul "-98765" "-4321" "nothing" "426763565" "Large numbers both negative"]
    :set res [$RunTestCase $res $BigIntMul "000987" "00010" "nothing" "9870" "Large numbers with heavy leading zeros"]
    :set res [$RunTestCase $res $BigIntMul "11111" "11111" "nothing" "123454321" "Symmetrical pattern multiplication"]
    :set res [$RunTestCase $res $BigIntMul "9999" "9999" "nothing" "99980001" "Four nines multiplication boundary"]
    :set res [$RunTestCase $res $BigIntMul "314159" "271828" "nothing" "85397212652" "Prefix multiplication case"]
    :set res [$RunTestCase $res $BigIntMul "1000000" "1000000" "nothing" "1000000000000" "Million by million"]
    :set res [$RunTestCase $res $BigIntMul "-1000000" "1000000" "nothing" "-1000000000000" "Million by million negative result"]
    :set res [$RunTestCase $res $BigIntMul "10000" "99999" "nothing" "999990000" "Large offset scale factor"]

    # Extreme big numbers
    :set res [$RunTestCase $res $BigIntMul \
        "35928729388071179953415568387770083088308701474" \
        "12701716703394386699433071733393975813309839929625546840" \
        "nothing" \
        "456356542200200488365402686644775650889764882652723412037979516785810588924372587279215304497564042160" \
        "Extreme big numbers mult"]

    :return $res
}

:set TestBigIntMod do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntMod

    :local res [$InitTestCaseState $1]

    # ==========================================
    # BigIntMod Test Cases
    # ==========================================

    # Basic modulo operations
    :set res [$RunTestCase $res $BigIntMod "10" "3" "nothing" "1" "Modulo standard remainder"]
    :set res [$RunTestCase $res $BigIntMod "10" "5" "nothing" "0" "Modulo exact division remainder zero"]
    :set res [$RunTestCase $res $BigIntMod "5" "10" "nothing" "5" "Modulo number smaller than divisor"]
    :set res [$RunTestCase $res $BigIntMod "7" "1" "nothing" "0" "Modulo divisor one"]
    :set res [$RunTestCase $res $BigIntMod "1" "7" "nothing" "1" "Modulo dividend smaller than divisor one"]

    # Equal numbers and zero inputs
    :set res [$RunTestCase $res $BigIntMod "5" "5" "nothing" "0" "Modulo equal operands"]
    :set res [$RunTestCase $res $BigIntMod "100" "100" "nothing" "0" "Modulo large equal operands"]
    :set res [$RunTestCase $res $BigIntMod "0" "5" "nothing" "0" "Modulo zero dividend"]
    :set res [$RunTestCase $res $BigIntMod "10" "0" "nothing" "0" "Modulo division by zero safety"]
    :set res [$RunTestCase $res $BigIntMod "0" "0" "nothing" "0" "Modulo zero by zero safety"]

    # Negative dividends and mathematical modulo behavior
    :set res [$RunTestCase $res $BigIntMod "-10" "3" "nothing" "2" "Mathematical modulo negative dividend"]
    :set res [$RunTestCase $res $BigIntMod "-5" "5" "nothing" "0" "Mathematical modulo negative exact match"]
    :set res [$RunTestCase $res $BigIntMod "-1" "3" "nothing" "2" "Mathematical modulo small negative dividend"]
    :set res [$RunTestCase $res $BigIntMod "-100" "30" "nothing" "20" "Mathematical modulo large negative dividend"]

    # Modulo operations prone to uncleaned leading zeros in results
    :set res [$RunTestCase $res $BigIntMod "1005" "100" "nothing" "5" "Modulo resulting in single digit with potential zero padding"]
    :set res [$RunTestCase $res $BigIntMod "1009" "100" "nothing" "9" "Modulo resulting in single digit nine"]
    :set res [$RunTestCase $res $BigIntMod "10001" "1000" "nothing" "1" "Modulo large scale single digit remainder"]
    :set res [$RunTestCase $res $BigIntMod "100005" "100000" "nothing" "5" "Modulo massive scale single digit remainder"]
    :set res [$RunTestCase $res $BigIntMod "2008" "2000" "nothing" "8" "Modulo inner zero offset remainder"]

    # Large numbers and multi-digit remainders
    :set res [$RunTestCase $res $BigIntMod "1005" "100" "nothing" "5" "Modulo large numbers with inner zero"]
    :set res [$RunTestCase $res $BigIntMod "9999" "10" "nothing" "9" "Modulo large nine string by ten"]
    :set res [$RunTestCase $res $BigIntMod "123456789" "10" "nothing" "9" "Modulo long number by ten"]
    :set res [$RunTestCase $res $BigIntMod "123456789" "100" "nothing" "89" "Modulo long number by hundred"]
    :set res [$RunTestCase $res $BigIntMod "987654321" "1000" "nothing" "321" "Modulo long number by thousand"]
    :set res [$RunTestCase $res $BigIntMod "1000000" "3" "nothing" "1" "Modulo million by three"]
    :set res [$RunTestCase $res $BigIntMod "999999" "1000" "nothing" "999" "Modulo large block boundary"]

    # Edge boundary configurations
    :set res [$RunTestCase $res $BigIntMod "999" "998" "nothing" "1" "Modulo consecutive large boundary values"]
    :set res [$RunTestCase $res $BigIntMod "5000" "2500" "nothing" "0" "Modulo clean half divisor"]
    :set res [$RunTestCase $res $BigIntMod "5001" "2500" "nothing" "1" "Modulo half divisor with offset one"]
    :set res [$RunTestCase $res $BigIntMod "12345" "12345" "nothing" "0" "Modulo identical large numbers"]
    :set res [$RunTestCase $res $BigIntMod "987654321" "1" "nothing" "0" "Modulo large number by one"]
    :set res [$RunTestCase $res $BigIntMod "45678" "10000" "nothing" "5678" "Modulo extraction of lower digits"]
    :set res [$RunTestCase $res $BigIntMod "1000000000" "7" "nothing" "6" "Modulo billion by prime seven"]
    :set res [$RunTestCase $res $BigIntMod "987654321987" "100" "nothing" "87" "Modulo extra large string"]
    :set res [$RunTestCase $res $BigIntMod "-987654321" "100" "nothing" "79" "Negative extra large string modulo hundred"]

    # Extreme big numbers
    :set res [$RunTestCase $res $BigIntMod \
        "340282366920938463463374607431768211456" \
        "6555" \
        "nothing" \
        "2911" \
        "Extreme big numbers mod 1"]

    :set res [$RunTestCase $res $BigIntMod \
        "78467056652122474322352994821898150938468142257513328624" \
        "155816117716540682014331966477183092459182471129987" \
        "nothing" \
        "85379602901888801602819552948956225819168576565255" \
        "Extreme big numbers mod 2"]

    :return $res
}

:set TestBigIntDiv do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntDiv

    :local res [$InitTestCaseState $1]

    # Basic positive division and exact division
    :set res [$RunTestCase $res $BigIntDiv "10" "2" "nothing" "5" "Divide small positive even"]
    :set res [$RunTestCase $res $BigIntDiv "123" "1" "nothing" "123" "Divide by one"]
    :set res [$RunTestCase $res $BigIntDiv "100" "10" "nothing" "10" "Divide power of ten"]
    :set res [$RunTestCase $res $BigIntDiv "999" "9" "nothing" "111" "Divide repeated nines"]
    :set res [$RunTestCase $res $BigIntDiv "1000" "5" "nothing" "200" "Divide round thousands"]

    # Division with remainder truncating towards zero
    :set res [$RunTestCase $res $BigIntDiv "10" "3" "nothing" "3" "Divide with remainder basic"]
    :set res [$RunTestCase $res $BigIntDiv "99" "10" "nothing" "9" "Divide near multiple truncated"]
    :set res [$RunTestCase $res $BigIntDiv "7" "2" "nothing" "3" "Divide odd by two truncated"]
    :set res [$RunTestCase $res $BigIntDiv "12345" "100" "nothing" "123" "Divide multi digit truncated"]

    # Divisor equal or larger than dividend
    :set res [$RunTestCase $res $BigIntDiv "5" "5" "nothing" "1" "Divide equal numbers"]
    :set res [$RunTestCase $res $BigIntDiv "5" "10" "nothing" "0" "Divide smaller by larger"]
    :set res [$RunTestCase $res $BigIntDiv "1" "1000" "nothing" "0" "Divide one by large divisor"]
    :set res [$RunTestCase $res $BigIntDiv "999" "1000" "nothing" "0" "Divide near boundary smaller"]

    # Division involving zero and zero handling
    :set res [$RunTestCase $res $BigIntDiv "0" "5" "nothing" "0" "Divide zero by positive"]
    :set res [$RunTestCase $res $BigIntDiv "0" "-5" "nothing" "0" "Divide zero by negative"]
    :set res [$RunTestCase $res $BigIntDiv "-0" "5" "nothing" "0" "Divide negative zero by positive"]
    :set res [$RunTestCase $res $BigIntDiv "10" "0" "nothing" "0" "Divide positive by zero error"]
    :set res [$RunTestCase $res $BigIntDiv "-10" "0" "nothing" "0" "Divide negative by zero error"]
    :set res [$RunTestCase $res $BigIntDiv "0" "0" "nothing" "0" "Divide zero by zero error"]

    # Negative numbers combinations
    :set res [$RunTestCase $res $BigIntDiv "-10" "2" "nothing" "-5" "Divide negative by positive"]
    :set res [$RunTestCase $res $BigIntDiv "10" "-2" "nothing" "-5" "Divide positive by negative"]
    :set res [$RunTestCase $res $BigIntDiv "-10" "-2" "nothing" "5" "Divide negative by negative"]
    :set res [$RunTestCase $res $BigIntDiv "-10" "3" "nothing" "-4" "Divide negative with remainder truncated"]
    :set res [$RunTestCase $res $BigIntDiv "10" "-3" "nothing" "-4" "Divide positive by negative with remainder"]
    :set res [$RunTestCase $res $BigIntDiv "-10" "-3" "nothing" "3" "Divide negative by negative with remainder"]
    :set res [$RunTestCase $res $BigIntDiv "-5" "-5" "nothing" "1" "Divide equal negatives"]
    :set res [$RunTestCase $res $BigIntDiv "-5" "5" "nothing" "-1" "Divide equal absolute value opposite signs"]

    # Large scale numbers long division
    :set res [$RunTestCase $res $BigIntDiv "1000000000" "10" "nothing" "100000000" "Divide billion by ten"]
    :set res [$RunTestCase $res $BigIntDiv "12345678987654321" "123456789" "nothing" "100000000" "Divide large scale symmetric"]
    :set res [$RunTestCase $res $BigIntDiv "9876543210" "123456789" "nothing" "80" "Divide large distinct scale"]
    :set res [$RunTestCase $res $BigIntDiv "1000000000000000000" "1000000000" "nothing" "1000000000" "Divide quintillion by billion"]
    :set res [$RunTestCase $res $BigIntDiv "-9876543210" "123456789" "nothing" "-81" "Divide large negative distinct scale"]

    :return $res
}

:set TestBigIntPow do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntPow

    :local res [$InitTestCaseState $1]

    # Zero and one boundary rules
    :set res [$RunTestCase $res $BigIntPow "5" "0" "nothing" "1" "Power of zero returns one"]
    :set res [$RunTestCase $res $BigIntPow "0" "5" "nothing" "0" "Zero to positive power returns zero"]
    :set res [$RunTestCase $res $BigIntPow "0" "0" "nothing" "1" "Zero to power of zero returns one"]
    :set res [$RunTestCase $res $BigIntPow "1" "100" "nothing" "1" "One to any power returns one"]
    :set res [$RunTestCase $res $BigIntPow "12345" "1" "nothing" "12345" "Number to power of one returns base"]
    :set res [$RunTestCase $res $BigIntPow "1" "0" "nothing" "1" "One to power of zero returns one"]

    # Small numbers standard exponentiation
    :set res [$RunTestCase $res $BigIntPow "2" "2" "nothing" "4" "Square of two"]
    :set res [$RunTestCase $res $BigIntPow "2" "3" "nothing" "8" "Cube of two"]
    :set res [$RunTestCase $res $BigIntPow "3" "2" "nothing" "9" "Square of three"]
    :set res [$RunTestCase $res $BigIntPow "3" "3" "nothing" "27" "Cube of three"]
    :set res [$RunTestCase $res $BigIntPow "5" "4" "nothing" "625" "Five to the fourth power"]
    :set res [$RunTestCase $res $BigIntPow "4" "4" "nothing" "256" "Four to the fourth power"]

    # Powers of two
    :set res [$RunTestCase $res $BigIntPow "2" "8" "nothing" "256" "Two to the eighth power"]
    :set res [$RunTestCase $res $BigIntPow "2" "10" "nothing" "1024" "Two to the tenth power"]
    :set res [$RunTestCase $res $BigIntPow "2" "16" "nothing" "65536" "Two to the sixteenth power"]

    # Powers of ten
    :set res [$RunTestCase $res $BigIntPow "10" "2" "nothing" "100" "Ten squared"]
    :set res [$RunTestCase $res $BigIntPow "10" "3" "nothing" "1000" "Ten cubed"]
    :set res [$RunTestCase $res $BigIntPow "10" "6" "nothing" "1000000" "Ten to the sixth power"]

    # Negative base handling
    :set res [$RunTestCase $res $BigIntPow "-2" "2" "nothing" "4" "Negative base even exponent positive result"]
    :set res [$RunTestCase $res $BigIntPow "-2" "3" "nothing" "-8" "Negative base odd exponent negative result"]
    :set res [$RunTestCase $res $BigIntPow "-1" "100" "nothing" "1" "Negative one even exponent"]
    :set res [$RunTestCase $res $BigIntPow "-1" "101" "nothing" "-1" "Negative one odd exponent"]
    :set res [$RunTestCase $res $BigIntPow "-5" "0" "nothing" "1" "Negative base to zero power"]
    :set res [$RunTestCase $res $BigIntPow "-10" "3" "nothing" "-1000" "Negative ten cubed"]

    # Large values exponentiation
    :set res [$RunTestCase $res $BigIntPow "99" "2" "nothing" "9801" "Large two digit squared"]
    :set res [$RunTestCase $res $BigIntPow "999" "2" "nothing" "998001" "Large three digit squared"]
    :set res [$RunTestCase $res $BigIntPow "12345" "2" "nothing" "152399025" "Five digit squared"]
    :set res [$RunTestCase $res $BigIntPow "9" "9" "nothing" "387420489" "Nine to the ninth power"]
    :set res [$RunTestCase $res $BigIntPow "100" "4" "nothing" "100000000" "Hundred to fourth power"]
    :set res [$RunTestCase $res $BigIntPow "-99" "3" "nothing" "-970299" "Large negative base cubed"]

    # Negative exponent error handling
    :set res [$RunTestCase $res $BigIntPow "10" "-2" "nothing" "0" "Reject negative exponent positive base"]
    :set res [$RunTestCase $res $BigIntPow "-10" "-2" "nothing" "0" "Reject negative exponent negative base"]
    :set res [$RunTestCase $res $BigIntPow "0" "-5" "nothing" "0" "Reject negative exponent zero base"]

    # Extreme big numbers
    :set res [$RunTestCase $res $BigIntPow \
        "2" \
        "128" \
        "nothing" \
        "340282366920938463463374607431768211456" \
        "2 pow 128"]

    :set res [$RunTestCase $res $BigIntPow \
        "5" \
        "73" \
        "nothing" \
        "1058791184067875423835403125849552452564239501953125" \
        "5 pow 73"]

    :set res [$RunTestCase $res $BigIntPow \
        "781936345870195933245368379441061400465076853022090" \
        "3" \
        "nothing" \
        "478094999421155150422985667277310426143689613841376402956943893710007433030697521627089424034492049170903669577619543090049379379551666773377947115329000" \
        "781936345870195933245368379441061400465076853022090 pow 3"]

    :return $res
}

:set TestBigIntPowMod do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntPowMod

    :local res [$InitTestCaseState $1]

    # Basic small modular arithmetic
    :set res [$RunTestCase $res $BigIntPowMod "2" "2" "3" "1" "Square of two modulo three"]
    :set res [$RunTestCase $res $BigIntPowMod "2" "3" "5" "3" "Cube of two modulo five"]
    :set res [$RunTestCase $res $BigIntPowMod "3" "2" "7" "2" "Square of three modulo seven"]
    :set res [$RunTestCase $res $BigIntPowMod "3" "3" "10" "7" "Cube of three modulo ten"]
    :set res [$RunTestCase $res $BigIntPowMod "4" "4" "15" "1" "Four to the fourth modulo fifteen"]
    :set res [$RunTestCase $res $BigIntPowMod "5" "3" "12" "5" "Cube of five modulo twelve"]
    :set res [$RunTestCase $res $BigIntPowMod "6" "3" "7" "6" "Cube of six modulo seven"]
    :set res [$RunTestCase $res $BigIntPowMod "10" "3" "13" "12" "Cube of ten modulo thirteen"]

    # Edge cases with zero and one
    :set res [$RunTestCase $res $BigIntPowMod "123" "0" "10" "1" "Any number to zero power modulo is one"]
    :set res [$RunTestCase $res $BigIntPowMod "0" "10" "10" "0" "Zero base modulo is zero"]
    :set res [$RunTestCase $res $BigIntPowMod "1" "100" "99" "1" "One base modulo is one"]
    :set res [$RunTestCase $res $BigIntPowMod "12345" "10" "1" "0" "Modulo one always returns zero"]
    :set res [$RunTestCase $res $BigIntPowMod "10" "1" "10" "0" "Power of one modulo itself is zero"]
    :set res [$RunTestCase $res $BigIntPowMod "10" "5" "10" "0" "Power modulo itself is zero"]
    :set res [$RunTestCase $res $BigIntPowMod "7" "3" "7" "0" "Base equals modulo returns zero"]

    # Fermat's Little Theorem with prime moduli
    :set res [$RunTestCase $res $BigIntPowMod "2" "10" "11" "1" "Fermat prime mod eleven"]
    :set res [$RunTestCase $res $BigIntPowMod "3" "16" "17" "1" "Fermat prime mod seventeen"]
    :set res [$RunTestCase $res $BigIntPowMod "5" "6" "7" "1" "Fermat prime mod seven"]
    :set res [$RunTestCase $res $BigIntPowMod "12" "22" "23" "1" "Fermat prime mod twenty three"]
    :set res [$RunTestCase $res $BigIntPowMod "100" "96" "97" "1" "Fermat prime mod ninety seven"]

    # Large numbers and properties of powers
    :set res [$RunTestCase $res $BigIntPowMod "10" "2" "99" "1" "Hundred modulo ninety nine"]
    :set res [$RunTestCase $res $BigIntPowMod "10" "4" "99" "1" "Ten thousand modulo ninety nine"]
    :set res [$RunTestCase $res $BigIntPowMod "10" "6" "999" "1" "Million modulo nine hundred ninety nine"]
    :set res [$RunTestCase $res $BigIntPowMod "10" "10" "99999" "1" "Power of ten boundary mod nines"]
    :set res [$RunTestCase $res $BigIntPowMod "11" "10" "100" "1" "Eleven to tenth ends in zero one"]
    :set res [$RunTestCase $res $BigIntPowMod "99" "99" "100" "99" "Ninety nine to odd power ends in ninety nine"]

    # Negative base testing
    :set res [$RunTestCase $res $BigIntPowMod "-2" "2" "5" "4" "Negative two square modulo five"]
    :set res [$RunTestCase $res $BigIntPowMod "-2" "3" "5" "2" "Negative two cube modulo five"]
    :set res [$RunTestCase $res $BigIntPowMod "-3" "3" "10" "3" "Negative three cube modulo ten"]
    :set res [$RunTestCase $res $BigIntPowMod "-10" "3" "13" "1" "Negative ten cube modulo thirteen"]

    # Automorphic numbers and cyclic properties
    :set res [$RunTestCase $res $BigIntPowMod "5" "123" "10" "5" "Powers of five end in five"]
    :set res [$RunTestCase $res $BigIntPowMod "6" "123" "10" "6" "Powers of six end in six"]
    :set res [$RunTestCase $res $BigIntPowMod "25" "25" "100" "25" "Powers of twenty five end in twenty five"]
    :set res [$RunTestCase $res $BigIntPowMod "76" "76" "100" "76" "Powers of seventy six end in seventy six"]

    # Chunk boundaries and massive number simulations
    :set res [$RunTestCase $res $BigIntPowMod "123456789" "2" "10" "1" "Large chunk squared modulo ten"]
    :set res [$RunTestCase $res $BigIntPowMod "999999999" "2" "1000000000" "1" "Max chunk minus one squared modulo max chunk"]
    :set res [$RunTestCase $res $BigIntPowMod "1000000000" "2" "999999999" "1" "Max chunk squared modulo max chunk minus one"]
    :set res [$RunTestCase $res $BigIntPowMod "2" "100" "10" "6" "Two to hundredth power modulo ten"]
    :set res [$RunTestCase $res $BigIntPowMod "3" "100" "10" "1" "Three to hundredth power modulo ten"]
    :set res [$RunTestCase $res $BigIntPowMod "7" "100" "10" "1" "Seven to hundredth power modulo ten"]
    :set res [$RunTestCase $res $BigIntPowMod "2" "30" "100" "24" "Two to thirtieth modulo hundred"]
    :set res [$RunTestCase $res $BigIntPowMod "2" "20" "100" "76" "Two to twentieth modulo hundred"]

    # Very big numbers
    :set res [$RunTestCase $res $BigIntPowMod "2" "4096" "6555" "4501" "Modular exponentiation with power of two base"]
    :set res [$RunTestCase $res $BigIntPowMod "7" "7684" "3743" "273" "Modular exponentiation with prime base and composite modulus"]
    :set res [$RunTestCase $res $BigIntPowMod "3" "5345345" "653453455" "97594538" "Modular exponentiation with large exponent values"]
    :set res [$RunTestCase $res $BigIntPowMod "345453453" "53" "1039565" "685728" "Modular exponentiation with large base and small exponent"]

    # Basic positive exponents
    :set res [$RunTestCase $res $BigIntPowMod "2" "3" "5" "3" "Python basic powmod"]
    :set res [$RunTestCase $res $BigIntPowMod "5" "3" "7" "6" "Python basic powmod"]
    :set res [$RunTestCase $res $BigIntPowMod "10" "5" "123" "1" "Python powmod yielding one"]

    # Edge cases with zeros and ones
    :set res [$RunTestCase $res $BigIntPowMod "0" "0" "1" "0" "Python zero base zero exp mod one"]
    :set res [$RunTestCase $res $BigIntPowMod "0" "0" "5" "1" "Python zero base zero exp mod five"]
    :set res [$RunTestCase $res $BigIntPowMod "10" "0" "1" "0" "Python positive base zero exp mod one"]
    :set res [$RunTestCase $res $BigIntPowMod "10" "0" "5" "1" "Python positive base zero exp mod five"]
    :set res [$RunTestCase $res $BigIntPowMod "0" "5" "7" "0" "Python zero base positive exp"]
    :set res [$RunTestCase $res $BigIntPowMod "1" "5" "7" "1" "Python one base positive exp"]

    # Negative base with Python modulo semantics
    :set res [$RunTestCase $res $BigIntPowMod "-2" "3" "5" "2" "Python negative base odd exp"]
    :set res [$RunTestCase $res $BigIntPowMod "-2" "2" "5" "4" "Python negative base even exp"]
    :set res [$RunTestCase $res $BigIntPowMod "-5" "3" "7" "1" "Python negative base odd exp mod seven"]
    :set res [$RunTestCase $res $BigIntPowMod "-5" "4" "7" "2" "Python negative base even exp mod seven"]
    :set res [$RunTestCase $res $BigIntPowMod "-10" "5" "123" "122" "Python negative base resulting in large remainder"]

    # Negative exponent requiring modular inverse
    :set res [$RunTestCase $res $BigIntPowMod "3" "-1" "11" "4" "Python simple modular inverse"]
    :set res [$RunTestCase $res $BigIntPowMod "3" "-2" "11" "5" "Python negative exp power of two"]
    :set res [$RunTestCase $res $BigIntPowMod "11" "-1" "13" "6" "Python modular inverse mod thirteen"]
    :set res [$RunTestCase $res $BigIntPowMod "11" "-2" "13" "10" "Python negative exp power of two mod thirteen"]
    :set res [$RunTestCase $res $BigIntPowMod "7" "-3" "17" "6" "Python negative odd exp mod seventeen"]
    :set res [$RunTestCase $res $BigIntPowMod "2" "-10" "11" "1" "Python Fermat little theorem inverse"]

    # Combined negative base and negative exponent
    :set res [$RunTestCase $res $BigIntPowMod "-3" "-1" "11" "7" "Python negative base and negative exp"]
    :set res [$RunTestCase $res $BigIntPowMod "-3" "-2" "11" "5" "Python negative base and negative even exp"]
    :set res [$RunTestCase $res $BigIntPowMod "-11" "-1" "13" "7" "Python large negative base and negative exp"]
    :set res [$RunTestCase $res $BigIntPowMod "-11" "-2" "13" "10" "Python large negative base and negative even exp"]

    # Negative modulus
    :set res [$RunTestCase $res $BigIntPowMod "2" "3" "-5" "-2" "Python positive base negative mod"]
    :set res [$RunTestCase $res $BigIntPowMod "-2" "3" "-5" "-3" "Python negative base negative mod"]
    :set res [$RunTestCase $res $BigIntPowMod "5" "2" "-7" "-3" "Python even power negative mod"]
    :set res [$RunTestCase $res $BigIntPowMod "-5" "2" "-7" "-3" "Python negative base even power negative mod"]

    # Large values simulating BigInt operations
    :set res [$RunTestCase $res $BigIntPowMod "12345" "3" "100000" "63625" "Python large base and mod"]
    :set res [$RunTestCase $res $BigIntPowMod "999999" "2" "1000000" "1" "Python base minus one even exp"]
    :set res [$RunTestCase $res $BigIntPowMod "999999" "3" "1000000" "999999" "Python base minus one odd exp"]
    :set res [$RunTestCase $res $BigIntPowMod "999999" "-1" "1000000" "999999" "Python base minus one negative exp"]
    :set res [$RunTestCase $res $BigIntPowMod "999999" "-2" "1000000" "1" "Python base minus one negative even exp"]

    :return $res
}
