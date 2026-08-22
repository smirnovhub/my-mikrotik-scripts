:global RunAllBigIntTests2
:global BigIntTest2

:set RunAllBigIntTests2 do={
    :global InitTestCaseState
    :global BigIntTest2

    :local res [$InitTestCaseState $1]

    :put "\1B[35m=== STARTING ALL BIG INT 2 TESTS ===\1B[0m"

    :set res [$BigIntTest2 $res]

    :put "\1B[35m=== ALL BIG INT 2 TESTS COMPLETED ===\1B[0m"

    :return $res
}

:set BigIntTest2 do={
    :global InitTestCaseState
    :global RunTestCase
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntCmp
    :global BigIntAdd
    :global BigIntSub
    :global BigIntMul
    :global BigIntMod
    :global BigIntDiv
    :global BigIntPow
    :global BigIntPowMod
    :global BigIntGcd
    :global BigIntModInverse

    :local res [$InitTestCaseState $1]

    :put "Starting BigInt tests..."

    # Basic small GCD tests
    :set res [$RunTestCase $res $BigIntGcd "12" "15" "nothing" "3" "GCD of twelve and fifteen"]
    :set res [$RunTestCase $res $BigIntGcd "24" "36" "nothing" "12" "GCD of twenty four and thirty six"]
    :set res [$RunTestCase $res $BigIntGcd "17" "19" "nothing" "1" "GCD of two primes"]
    :set res [$RunTestCase $res $BigIntGcd "100" "75" "nothing" "25" "GCD of hundred and seventy five"]
    :set res [$RunTestCase $res $BigIntGcd "8" "12" "nothing" "4" "GCD of eight and twelve"]
    :set res [$RunTestCase $res $BigIntGcd "54" "24" "nothing" "6" "GCD of fifty four and twenty four"]
    :set res [$RunTestCase $res $BigIntGcd "48" "18" "nothing" "6" "GCD of forty eight and eighteen"]
    :set res [$RunTestCase $res $BigIntGcd "20" "30" "nothing" "10" "GCD of twenty and thirty"]

    # Edge cases with zero and one
    :set res [$RunTestCase $res $BigIntGcd "0" "5" "nothing" "5" "GCD of zero and five"]
    :set res [$RunTestCase $res $BigIntGcd "7" "0" "nothing" "7" "GCD of seven and zero"]
    :set res [$RunTestCase $res $BigIntGcd "0" "0" "nothing" "0" "GCD of zero and zero"]
    :set res [$RunTestCase $res $BigIntGcd "1" "100" "nothing" "1" "GCD of one and hundred"]
    :set res [$RunTestCase $res $BigIntGcd "12345" "1" "nothing" "1" "GCD with one"]
    :set res [$RunTestCase $res $BigIntGcd "999" "999" "nothing" "999" "GCD of identical numbers"]

    # Negative numbers handling
    :set res [$RunTestCase $res $BigIntGcd "-12" "15" "nothing" "3" "GCD with negative first argument"]
    :set res [$RunTestCase $res $BigIntGcd "12" "-15" "nothing" "3" "GCD with negative second argument"]
    :set res [$RunTestCase $res $BigIntGcd "-24" "-36" "nothing" "12" "GCD with both negative arguments"]
    :set res [$RunTestCase $res $BigIntGcd "-100" "0" "nothing" "100" "GCD of negative and zero"]

    # Co-prime numbers and large spacing
    :set res [$RunTestCase $res $BigIntGcd "101" "103" "nothing" "1" "GCD of large consecutive primes"]
    :set res [$RunTestCase $res $BigIntGcd "997" "991" "nothing" "1" "GCD of large prime numbers"]
    :set res [$RunTestCase $res $BigIntGcd "1000" "3" "nothing" "1" "GCD of thousand and three"]
    :set res [$RunTestCase $res $BigIntGcd "123456" "789" "nothing" "3" "GCD of medium numbers"]

    # Multiples and divisors
    :set res [$RunTestCase $res $BigIntGcd "1000" "100" "nothing" "100" "GCD where one divides another"]
    :set res [$RunTestCase $res $BigIntGcd "999999999" "3" "nothing" "3" "GCD of max chunk and three"]
    :set res [$RunTestCase $res $BigIntGcd "1000000000" "5" "nothing" "5" "GCD of chunk boundary and five"]
    :set res [$RunTestCase $res $BigIntGcd "123456789123456789" "123456789" "nothing" "123456789" "GCD of large numbers with common factor"]

    # Massive numbers across multiple chunks
    :set res [$RunTestCase $res $BigIntGcd "340282366920938463463374607431768211456" "6553" "nothing" "1" "GCD of 128-bit boundary and prime"]
    :set res [$RunTestCase $res $BigIntGcd "1000000000000000000" "500000000000000000" "nothing" "500000000000000000" "GCD of massive multiples"]
    :set res [$RunTestCase $res $BigIntGcd "999999999999999999999" "111111111111111111111" "nothing" "111111111111111111111" "GCD of repeated digit massive numbers"]
    :set res [$RunTestCase $res $BigIntGcd "1000000000000" "999999999999" "nothing" "1" "GCD of numbers differing by one"]

# Basic small modular inverse tests
    :set res [$RunTestCase $res $BigIntModInverse "3" "11" "nothing" "4" "Modular inverse of three modulo eleven"]
    :set res [$RunTestCase $res $BigIntModInverse "2" "7" "nothing" "4" "Modular inverse of two modulo seven"]
    :set res [$RunTestCase $res $BigIntModInverse "3" "7" "nothing" "5" "Modular inverse of three modulo seven"]
    :set res [$RunTestCase $res $BigIntModInverse "4" "7" "nothing" "2" "Modular inverse of four modulo seven"]
    :set res [$RunTestCase $res $BigIntModInverse "5" "11" "nothing" "9" "Modular inverse of five modulo eleven"]
    :set res [$RunTestCase $res $BigIntModInverse "7" "13" "nothing" "2" "Modular inverse of seven modulo thirteen"]
    :set res [$RunTestCase $res $BigIntModInverse "2" "5" "nothing" "3" "Modular inverse of two modulo five"]
    :set res [$RunTestCase $res $BigIntModInverse "4" "9" "nothing" "7" "Modular inverse of four modulo nine"]

    # Edge cases where inverse does not exist (GCD != 1)
    :set res [$RunTestCase $res $BigIntModInverse "2" "4" "nothing" "0" "No inverse when sharing common factor two"]
    :set res [$RunTestCase $res $BigIntModInverse "3" "9" "nothing" "0" "No inverse when sharing common factor three"]
    :set res [$RunTestCase $res $BigIntModInverse "0" "5" "nothing" "0" "Modular inverse of zero is zero"]
    :set res [$RunTestCase $res $BigIntModInverse "5" "0" "nothing" "0" "Modular inverse with zero modulus is zero"]
    :set res [$RunTestCase $res $BigIntModInverse "4" "2" "nothing" "0" "No inverse when base greater than modulus with factor"]

    # Self-inverse numbers (where x = x^-1 mod m)
    :set res [$RunTestCase $res $BigIntModInverse "1" "11" "nothing" "1" "Modular inverse of one is one"]
    :set res [$RunTestCase $res $BigIntModInverse "6" "7" "nothing" "6" "Self inverse six modulo seven"]
    :set res [$RunTestCase $res $BigIntModInverse "10" "11" "nothing" "10" "Self inverse ten modulo eleven"]
    :set res [$RunTestCase $res $BigIntModInverse "12" "13" "nothing" "12" "Self inverse twelve modulo thirteen"]

    # Larger prime moduli and composite numbers
    :set res [$RunTestCase $res $BigIntModInverse "123" "1000" "nothing" "187" "Modular inverse of hundred twenty three modulo thousand"]
    :set res [$RunTestCase $res $BigIntModInverse "50" "97" "nothing" "33" "Modular inverse with prime ninety seven"]
    :set res [$RunTestCase $res $BigIntModInverse "12345" "65537" "nothing" "31651" "Modular inverse with Fermat prime modulus"]
    :set res [$RunTestCase $res $BigIntModInverse "999" "1000" "nothing" "999" "Modular inverse of nine hundred ninety nine modulo thousand"]

    # Negative base values
    :set res [$RunTestCase $res $BigIntModInverse "-3" "11" "nothing" "7" "Modular inverse of negative three modulo eleven"]
    :set res [$RunTestCase $res $BigIntModInverse "-2" "7" "nothing" "3" "Modular inverse of negative two modulo seven"]
    :set res [$RunTestCase $res $BigIntModInverse "-5" "13" "nothing" "5" "Modular inverse of negative five modulo thirteen"]

    # Massive numbers across multiple chunks
    :set res [$RunTestCase $res $BigIntModInverse "123456789123456789" "1000000000000000003" "nothing" "244581051350687566" "Modular inverse of large numbers across chunks"]
    :set res [$RunTestCase $res $BigIntModInverse "987654321" "1000000007" "nothing" "152057246" "Modular inverse with standard crypto prime"]

    # Additional small prime moduli tests
    :set res [$RunTestCase $res $BigIntModInverse "3" "13" "nothing" "9" "Modular inverse of three modulo thirteen"]
    :set res [$RunTestCase $res $BigIntModInverse "4" "13" "nothing" "10" "Modular inverse of four modulo thirteen"]
    :set res [$RunTestCase $res $BigIntModInverse "5" "13" "nothing" "8" "Modular inverse of five modulo thirteen"]
    :set res [$RunTestCase $res $BigIntModInverse "6" "13" "nothing" "11" "Modular inverse of six modulo thirteen"]
    :set res [$RunTestCase $res $BigIntModInverse "8" "13" "nothing" "5" "Modular inverse of eight modulo thirteen"]
    :set res [$RunTestCase $res $BigIntModInverse "9" "13" "nothing" "3" "Modular inverse of nine modulo thirteen"]
    :set res [$RunTestCase $res $BigIntModInverse "10" "13" "nothing" "4" "Modular inverse of ten modulo thirteen"]
    :set res [$RunTestCase $res $BigIntModInverse "11" "13" "nothing" "6" "Modular inverse of eleven modulo thirteen"]

    # Modulo seventeen tests
    :set res [$RunTestCase $res $BigIntModInverse "2" "17" "nothing" "9" "Modular inverse of two modulo seventeen"]
    :set res [$RunTestCase $res $BigIntModInverse "3" "17" "nothing" "6" "Modular inverse of three modulo seventeen"]
    :set res [$RunTestCase $res $BigIntModInverse "5" "17" "nothing" "7" "Modular inverse of five modulo seventeen"]
    :set res [$RunTestCase $res $BigIntModInverse "10" "17" "nothing" "12" "Modular inverse of ten modulo seventeen"]
    :set res [$RunTestCase $res $BigIntModInverse "15" "17" "nothing" "8" "Modular inverse of fifteen modulo seventeen"]

    # Modulo nineteen tests
    :set res [$RunTestCase $res $BigIntModInverse "4" "19" "nothing" "5" "Modular inverse of four modulo nineteen"]
    :set res [$RunTestCase $res $BigIntModInverse "7" "19" "nothing" "11" "Modular inverse of seven modulo nineteen"]
    :set res [$RunTestCase $res $BigIntModInverse "11" "19" "nothing" "7" "Modular inverse of eleven modulo nineteen"]
    :set res [$RunTestCase $res $BigIntModInverse "16" "19" "nothing" "6" "Modular inverse of sixteen modulo nineteen"]

    # Composite moduli tests
    :set res [$RunTestCase $res $BigIntModInverse "3" "25" "nothing" "17" "Modular inverse of three modulo twenty five"]
    :set res [$RunTestCase $res $BigIntModInverse "7" "25" "nothing" "18" "Modular inverse of seven modulo twenty five"]
    :set res [$RunTestCase $res $BigIntModInverse "2" "27" "nothing" "14" "Modular inverse of two modulo twenty seven"]
    :set res [$RunTestCase $res $BigIntModInverse "5" "26" "nothing" "21" "Modular inverse of five modulo twenty six"]
    :set res [$RunTestCase $res $BigIntModInverse "7" "30" "nothing" "13" "Modular inverse of seven modulo thirty"]
    :set res [$RunTestCase $res $BigIntModInverse "11" "30" "nothing" "11" "Modular inverse of eleven modulo thirty"]
    :set res [$RunTestCase $res $BigIntModInverse "13" "35" "nothing" "27" "Modular inverse of thirteen modulo thirty five"]

    # Negative numbers and mixed signs
    :set res [$RunTestCase $res $BigIntModInverse "-4" "13" "nothing" "3" "Modular inverse of negative four modulo thirteen"]
    :set res [$RunTestCase $res $BigIntModInverse "-7" "17" "nothing" "12" "Modular inverse of negative seven modulo seventeen"]
    :set res [$RunTestCase $res $BigIntModInverse "-11" "19" "nothing" "12" "Modular inverse of negative eleven modulo nineteen"]
    :set res [$RunTestCase $res $BigIntModInverse "-3" "25" "nothing" "8" "Modular inverse of negative three modulo twenty five"]

    # Larger moduli and chunk boundaries
    :set res [$RunTestCase $res $BigIntModInverse "1234" "9999" "nothing" "5275" "Modular inverse of thousand two hundred thirty four modulo nine thousand nine hundred ninety nine"]
    :set res [$RunTestCase $res $BigIntModInverse "5555" "10007" "nothing" "1751" "Modular inverse with prime ten thousand seven"]
    :set res [$RunTestCase $res $BigIntModInverse "9876" "32767" "nothing" "30554" "Modular inverse with fifteen bit modulus"]

    # Basic positive modulus inverses
    :set res [$RunTestCase $res $BigIntModInverse "3" "11" "nothing" "4" "Python basic mod inverse"]
    :set res [$RunTestCase $res $BigIntModInverse "5" "7" "nothing" "3" "Python basic mod inverse"]
    :set res [$RunTestCase $res $BigIntModInverse "17" "3120" "nothing" "2753" "Python larger mod inverse"]
    :set res [$RunTestCase $res $BigIntModInverse "99" "100" "nothing" "99" "Python base minus one inverse"]

    # Edge cases where inverse does not exist
    # Python raises ValueError, script gracefully returns 0
    :set res [$RunTestCase $res $BigIntModInverse "2" "4" "nothing" "0" "Python non-coprime returns zero"]
    :set res [$RunTestCase $res $BigIntModInverse "3" "9" "nothing" "0" "Python non-coprime returns zero"]
    :set res [$RunTestCase $res $BigIntModInverse "0" "5" "nothing" "0" "Python zero base returns zero"]
    :set res [$RunTestCase $res $BigIntModInverse "5" "1" "nothing" "0" "Python mod one returns zero"]

    # Edge cases with base 1 and -1
    :set res [$RunTestCase $res $BigIntModInverse "1" "5" "nothing" "1" "Python one base returns one"]
    :set res [$RunTestCase $res $BigIntModInverse "-1" "5" "nothing" "4" "Python negative one base"]

    # Negative base a
    :set res [$RunTestCase $res $BigIntModInverse "-3" "11" "nothing" "7" "Python negative base mod inverse"]
    :set res [$RunTestCase $res $BigIntModInverse "-5" "7" "nothing" "4" "Python negative base mod inverse"]
    :set res [$RunTestCase $res $BigIntModInverse "-3" "10" "nothing" "3" "Python negative base even mod"]
    :set res [$RunTestCase $res $BigIntModInverse "-17" "3120" "nothing" "367" "Python large negative base"]

    # Negative modulus m (Python supports this, result has the same sign as modulus)
    :set res [$RunTestCase $res $BigIntModInverse "3" "-11" "nothing" "-7" "Python negative mod"]
    :set res [$RunTestCase $res $BigIntModInverse "5" "-7" "nothing" "-4" "Python negative mod"]
    :set res [$RunTestCase $res $BigIntModInverse "17" "-3120" "nothing" "-367" "Python larger negative mod"]

    # Combined negative base and negative modulus
    :set res [$RunTestCase $res $BigIntModInverse "-3" "-11" "nothing" "-4" "Python negative base and negative mod"]
    :set res [$RunTestCase $res $BigIntModInverse "-5" "-7" "nothing" "-3" "Python negative base and negative mod"]

    # ------------------------------------------
    # BigIntAdd / BigIntSub inverse properties
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntSub [$BigIntAdd "123456789" "987654321"] "987654321" "nothing" "123456789" "Add then subtract restores first operand"]
    :set res [$RunTestCase $res $BigIntSub [$BigIntAdd "-123456789" "987654321"] "987654321" "nothing" "-123456789" "Add then subtract restores negative first operand"]
    :set res [$RunTestCase $res $BigIntSub [$BigIntAdd "987654321" "-123456789"] "-123456789" "nothing" "987654321" "Add then subtract restores with negative second operand"]
    :set res [$RunTestCase $res $BigIntSub [$BigIntAdd "-987654321" "-123456789"] "-123456789" "nothing" "-987654321" "Add then subtract restores both negative operands"]

    :set res [$RunTestCase $res $BigIntAdd [$BigIntSub "123456789" "987654321"] "987654321" "nothing" "123456789" "Subtract then add restores first operand"]
    :set res [$RunTestCase $res $BigIntAdd [$BigIntSub "-123456789" "987654321"] "987654321" "nothing" "-123456789" "Subtract then add restores negative first operand"]
    :set res [$RunTestCase $res $BigIntAdd [$BigIntSub "987654321" "-123456789"] "-123456789" "nothing" "987654321" "Subtract negative then add restores operand"]

    # ------------------------------------------
    # BigIntAdd commutativity
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntAdd "123456789123456789" "987654321987654321" "nothing" [$BigIntAdd "987654321987654321" "123456789123456789"] "Add commutativity large positive"]
    :set res [$RunTestCase $res $BigIntAdd "-123456789123456789" "987654321987654321" "nothing" [$BigIntAdd "987654321987654321" "-123456789123456789"] "Add commutativity mixed signs"]
    :set res [$RunTestCase $res $BigIntAdd "-123456789123456789" "-987654321987654321" "nothing" [$BigIntAdd "-987654321987654321" "-123456789123456789"] "Add commutativity negative numbers"]

    # ------------------------------------------
    # BigIntSub antisymmetry
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntSub "123456789123456789" "987654321987654321" "nothing" [$BigIntMul [$BigIntSub "987654321987654321" "123456789123456789"] "-1"] "Subtraction antisymmetry positive"]
    :set res [$RunTestCase $res $BigIntSub "-123456789123456789" "987654321987654321" "nothing" [$BigIntMul [$BigIntSub "987654321987654321" "-123456789123456789"] "-1"] "Subtraction antisymmetry mixed signs"]

    # ------------------------------------------
    # BigIntMul commutativity
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntMul "123456789123456789" "987654321987654321" "nothing" [$BigIntMul "987654321987654321" "123456789123456789"] "Multiply commutativity large positive"]
    :set res [$RunTestCase $res $BigIntMul "-123456789123456789" "987654321987654321" "nothing" [$BigIntMul "987654321987654321" "-123456789123456789"] "Multiply commutativity mixed signs"]
    :set res [$RunTestCase $res $BigIntMul "-123456789123456789" "-987654321987654321" "nothing" [$BigIntMul "-987654321987654321" "-123456789123456789"] "Multiply commutativity negative numbers"]

    # ------------------------------------------
    # BigIntMul identity properties
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntMul "123456789123456789" "1" "nothing" "123456789123456789" "Multiply by one identity positive"]
    :set res [$RunTestCase $res $BigIntMul "-123456789123456789" "1" "nothing" "-123456789123456789" "Multiply by one identity negative"]
    :set res [$RunTestCase $res $BigIntMul "123456789123456789" "0" "nothing" "0" "Multiply by zero identity positive"]
    :set res [$RunTestCase $res $BigIntMul "-123456789123456789" "0" "nothing" "0" "Multiply by zero identity negative"]

    # ------------------------------------------
    # BigIntMul distributive property
    # a * (b + c) = a*b + a*c
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul "12345" "67890"] \
        [$BigIntMul "12345" "11111"] \
        "nothing" \
        [$BigIntMul "12345" [$BigIntAdd "67890" "11111"]] \
        "Multiplication distributive property positive"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul "-12345" "67890"] \
        [$BigIntMul "-12345" "11111"] \
        "nothing" \
        [$BigIntMul "-12345" [$BigIntAdd "67890" "11111"]] \
        "Multiplication distributive property negative multiplier"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul "12345" "-67890"] \
        [$BigIntMul "12345" "11111"] \
        "nothing" \
        [$BigIntMul "12345" [$BigIntAdd "-67890" "11111"]] \
        "Multiplication distributive property mixed signs"]

    # ------------------------------------------
    # BigIntDiv / BigIntMod consistency
    #
    # a = q*b + r
    # q = trunc(a / b)
    # 0 <= r < |b|
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "123456789123456789" "12345"] "12345"] \
        [$BigIntMod "123456789123456789" "12345"] \
        "nothing" \
        "123456789123456789" \
        "DivMod identity positive"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "-123456789123456789" "12345"] "12345"] \
        [$BigIntMod "-123456789123456789" "12345"] \
        "nothing" \
        "-123456789123456789" \
        "DivMod identity negative dividend"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "123456789123456789" "-12345"] "-12345"] \
        [$BigIntMod "123456789123456789" "-12345"] \
        "nothing" \
        "123456789123456789" \
        "DivMod identity negative divisor"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "-123456789123456789" "-12345"] "-12345"] \
        [$BigIntMod "-123456789123456789" "-12345"] \
        "nothing" \
        "-123456789123456789" \
        "DivMod identity both negative"]

    # ------------------------------------------
    # BigIntMod remainder bounds
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntCmp [$BigIntMod "123456789123456789" "12345"] "0" "nothing" "1" "Modulo result is positive"]
    :set res [$RunTestCase $res $BigIntCmp [$BigIntMod "-123456789123456789" "12345"] "0" "nothing" "1" "Negative dividend modulo is non-negative"]

    :set res [$RunTestCase $res $BigIntCmp [$BigIntMod "123456789123456789" "12345"] "12345" "nothing" "-1" "Modulo result is less than positive divisor"]
    :set res [$RunTestCase $res $BigIntCmp [$BigIntMod "-123456789123456789" "12345"] "12345" "nothing" "-1" "Negative modulo result is less than divisor"]

    :set res [$RunTestCase $res $BigIntCmp [$BigIntMod "123456789123456789" "-12345"] "12345" "nothing" "-1" "Modulo result is less than absolute negative divisor"]
    :set res [$RunTestCase $res $BigIntCmp [$BigIntMod "-123456789123456789" "-12345"] "12345" "nothing" "-1" "Negative modulo result is less than absolute negative divisor"]

    # ------------------------------------------
    # BigIntDiv & BigIntMod Floor Division (Python-style)
    # ------------------------------------------

    # Standard positive divisions
    :set res [$RunTestCase $res $BigIntDiv "11" "3" "nothing" "3" "Floor div positive operands exact floor"]
    :set res [$RunTestCase $res $BigIntMod "11" "3" "nothing" "2" "Modulo positive operands"]
    :set res [$RunTestCase $res $BigIntDiv "10" "5" "nothing" "2" "Floor div exact division positives"]
    :set res [$RunTestCase $res $BigIntMod "10" "5" "nothing" "0" "Modulo exact division positives"]

    # Negative dividend (Python rounds down: -11 // 3 = -4, remainder = 1)
    :set res [$RunTestCase $res $BigIntDiv "-11" "3" "nothing" "-4" "Floor div negative dividend rounds toward negative infinity"]
    :set res [$RunTestCase $res $BigIntMod "-11" "3" "nothing" "1" "Modulo matches floor division negative dividend"]
    :set res [$RunTestCase $res $BigIntDiv "-10" "3" "nothing" "-4" "Floor div negative dividend case 2"]
    :set res [$RunTestCase $res $BigIntMod "-10" "3" "nothing" "2" "Modulo negative dividend case 2"]
    :set res [$RunTestCase $res $BigIntDiv "-12" "3" "nothing" "-4" "Floor div negative dividend exact multiple"]
    :set res [$RunTestCase $res $BigIntMod "-12" "3" "nothing" "0" "Modulo negative dividend exact multiple"]

    # Negative divisor (Python rounds down: 11 // -3 = -4, remainder = -1)
    :set res [$RunTestCase $res $BigIntDiv "11" "-3" "nothing" "-4" "Floor div negative divisor rounds toward negative infinity"]
    :set res [$RunTestCase $res $BigIntMod "11" "-3" "nothing" "-1" "Modulo matches floor division negative divisor"]
    :set res [$RunTestCase $res $BigIntDiv "10" "-3" "nothing" "-4" "Floor div negative divisor case 2"]
    :set res [$RunTestCase $res $BigIntMod "10" "-3" "nothing" "-2" "Modulo negative divisor case 2"]
    :set res [$RunTestCase $res $BigIntDiv "12" "-3" "nothing" "-4" "Floor div negative divisor exact multiple"]
    :set res [$RunTestCase $res $BigIntMod "12" "-3" "nothing" "0" "Modulo negative divisor exact multiple"]

    # Both negative operands (Python: -11 // -3 = 3, remainder = -2)
    :set res [$RunTestCase $res $BigIntDiv "-11" "-3" "nothing" "3" "Floor div both negative operands"]
    :set res [$RunTestCase $res $BigIntMod "-11" "-3" "nothing" "-2" "Modulo matches floor division both negative"]
    :set res [$RunTestCase $res $BigIntDiv "-10" "-3" "nothing" "3" "Floor div both negative case 2"]
    :set res [$RunTestCase $res $BigIntMod "-10" "-3" "nothing" "-1" "Modulo both negative case 2"]
    :set res [$RunTestCase $res $BigIntDiv "-12" "-3" "nothing" "4" "Floor div both negative exact multiple"]
    :set res [$RunTestCase $res $BigIntMod "-12" "-3" "nothing" "0" "Modulo both negative exact multiple"]

    # Small numbers and boundaries where absolute dividend < absolute divisor
    :set res [$RunTestCase $res $BigIntDiv "2" "5" "nothing" "0" "Floor div dividend less than divisor positive"]
    :set res [$RunTestCase $res $BigIntMod "2" "5" "nothing" "2" "Modulo dividend less than divisor positive"]
    :set res [$RunTestCase $res $BigIntDiv "-2" "5" "nothing" "-1" "Floor div dividend less than divisor negative dividend"]
    :set res [$RunTestCase $res $BigIntMod "-2" "5" "nothing" "3" "Modulo dividend less than divisor negative dividend"]
    :set res [$RunTestCase $res $BigIntDiv "2" "-5" "nothing" "-1" "Floor div dividend less than divisor negative divisor"]
    :set res [$RunTestCase $res $BigIntMod "2" "-5" "nothing" "-3" "Modulo dividend less than divisor negative divisor"]
    :set res [$RunTestCase $res $BigIntDiv "-2" "-5" "nothing" "0" "Floor div both small negative"]
    :set res [$RunTestCase $res $BigIntMod "-2" "-5" "nothing" "-2" "Modulo both small negative"]

    # Zero dividend tests
    :set res [$RunTestCase $res $BigIntDiv "0" "5" "nothing" "0" "Floor div zero dividend positive divisor"]
    :set res [$RunTestCase $res $BigIntMod "0" "5" "nothing" "0" "Modulo zero dividend positive divisor"]
    :set res [$RunTestCase $res $BigIntDiv "0" "-5" "nothing" "0" "Floor div zero dividend negative divisor"]
    :set res [$RunTestCase $res $BigIntMod "0" "-5" "nothing" "0" "Modulo zero dividend negative divisor"]

    # ------------------------------------------
    # BigIntPow algebraic properties
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntPow "12" "2" "nothing" [$BigIntMul "12" "12"] "Pow exponent two equals square"]
    :set res [$RunTestCase $res $BigIntPow "-12" "2" "nothing" [$BigIntMul "-12" "-12"] "Pow negative base exponent two equals square"]

    :set res [$RunTestCase $res $BigIntPow "7" "3" "nothing" [$BigIntMul [$BigIntMul "7" "7"] "7"] "Pow exponent three equals cube"]

    :set res [$RunTestCase $res $BigIntPow "3" "6" "nothing" [$BigIntMul [$BigIntPow "3" "2"] [$BigIntPow "3" "4"]] "Pow exponent decomposition"]

    :set res [$RunTestCase $res $BigIntPow "5" "7" "nothing" [$BigIntMul [$BigIntPow "5" "3"] [$BigIntPow "5" "4"]] "Pow additive exponent property"]

    # ------------------------------------------
    # BigIntPow recurrence
    # a^(n+1) = a^n * a
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntMul [$BigIntPow "7" "6"] "7" "nothing" [$BigIntPow "7" "7"] "Pow recurrence positive"]

    :set res [$RunTestCase $res $BigIntMul [$BigIntPow "-7" "6"] "-7" "nothing" [$BigIntPow "-7" "7"] "Pow recurrence negative base"]

    # ------------------------------------------
    # BigIntPowMod algebraic properties
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntPowMod "7" "5" "1000" [$BigIntMod [$BigIntPow "7" "5"] "1000"] "PowMod equals Pow modulo"]
    :set res [$RunTestCase $res $BigIntPowMod "12345" "6" "1000003" [$BigIntMod [$BigIntPow "12345" "6"] "1000003"] "PowMod large base equals Pow modulo"]
    :set res [$RunTestCase $res $BigIntPowMod "2" "20" "1000" [$BigIntMod [$BigIntPow "2" "20"] "1000"] "PowMod exact cross check"]

    # ------------------------------------------
    # BigIntPowMod recurrence
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul [$BigIntPowMod "7" "10" "1000003"] "7"] \
        "1000003" \
        "nothing" \
        [$BigIntPowMod "7" "11" "1000003"] \
        "PowMod recurrence positive"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul [$BigIntPowMod "-7" "10" "1000003"] "-7"] \
        "1000003" \
        "nothing" \
        [$BigIntPowMod "-7" "11" "1000003"] \
        "PowMod recurrence negative base"]

    # ------------------------------------------
    # BigIntGcd properties
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntGcd "123456789123456789" "987654321987654321" "nothing" [$BigIntGcd "987654321987654321" "123456789123456789"] "GCD commutativity"]

    :set res [$RunTestCase $res $BigIntGcd "-123456789123456789" "987654321987654321" "nothing" [$BigIntGcd "987654321987654321" "-123456789123456789"] "GCD commutativity mixed signs"]

    :set res [$RunTestCase $res $BigIntGcd "-123456789123456789" "-987654321987654321" "nothing" [$BigIntGcd "-987654321987654321" "-123456789123456789"] "GCD commutativity negative numbers"]

    # ------------------------------------------
    # Euclidean GCD identity
    # gcd(a,b) = gcd(b,a mod b)
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntGcd \
        "123456789123456789" \
        "987654321" \
        "nothing" \
        [$BigIntGcd "987654321" [$BigIntMod "123456789123456789" "987654321"]] \
        "GCD Euclidean identity"]

    :set res [$RunTestCase $res $BigIntGcd \
        "-123456789123456789" \
        "987654321" \
        "nothing" \
        [$BigIntGcd "987654321" [$BigIntMod "-123456789123456789" "987654321"]] \
        "GCD Euclidean identity negative dividend"]

    # ------------------------------------------
    # GCD divides both operands
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntMod \
        "123456789123456789" \
        [$BigIntGcd "123456789123456789" "987654321987654321"] \
        "nothing" \
        "0" \
        "GCD divides first operand"]

    :set res [$RunTestCase $res $BigIntMod \
        "987654321987654321" \
        [$BigIntGcd "123456789123456789" "987654321987654321"] \
        "nothing" \
        "0" \
        "GCD divides second operand"]

    :set res [$RunTestCase $res $BigIntMod \
        "-123456789123456789" \
        [$BigIntGcd "-123456789123456789" "987654321987654321"] \
        "nothing" \
        "0" \
        "GCD divides negative first operand"]

    # ------------------------------------------
    # GCD scaling property
    # gcd(k*a, k*b) = |k| * gcd(a,b)
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntGcd \
        [$BigIntMul "37" "123456"] \
        [$BigIntMul "37" "789012"] \
        "nothing" \
        [$BigIntMul "37" [$BigIntGcd "123456" "789012"]] \
        "GCD scaling property"]

    :set res [$RunTestCase $res $BigIntGcd \
        [$BigIntMul "-37" "123456"] \
        [$BigIntMul "-37" "789012"] \
        "nothing" \
        [$BigIntMul "37" [$BigIntGcd "123456" "789012"]] \
        "GCD scaling property negative scale"]

    # ------------------------------------------
    # BigIntModInverse invariant
    # a * inverse(a,m) mod m = 1
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul "3" [$BigIntModInverse "3" "11"]] \
        "11" \
        "nothing" \
        "1" \
        "ModInverse invariant 3 modulo 11"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul "123" [$BigIntModInverse "123" "1000"]] \
        "1000" \
        "nothing" \
        "1" \
        "ModInverse invariant 123 modulo 1000"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul "12345" [$BigIntModInverse "12345" "65537"]] \
        "65537" \
        "nothing" \
        "1" \
        "ModInverse invariant 12345 modulo 65537"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul "-3" [$BigIntModInverse "-3" "11"]] \
        "11" \
        "nothing" \
        "1" \
        "ModInverse invariant negative base"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul "-123" [$BigIntModInverse "-123" "1000"]] \
        "1000" \
        "nothing" \
        "1" \
        "ModInverse invariant large negative base"]

    # ------------------------------------------
    # BigIntModInverse result bounds
    # 0 < inverse < modulus
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntCmp [$BigIntModInverse "3" "11"] "0" "nothing" "1" "ModInverse result greater than zero"]
    :set res [$RunTestCase $res $BigIntCmp [$BigIntModInverse "3" "11"] "11" "nothing" "-1" "ModInverse result less than modulus"]

    :set res [$RunTestCase $res $BigIntCmp [$BigIntModInverse "123" "1000"] "0" "nothing" "1" "Large ModInverse result greater than zero"]
    :set res [$RunTestCase $res $BigIntCmp [$BigIntModInverse "123" "1000"] "1000" "nothing" "-1" "Large ModInverse result less than modulus"]

    # ------------------------------------------
    # Conversion round-trip boundary tests
    # ------------------------------------------

    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "999999999"] "nothing" "nothing" "999999999" "Round-trip max single chunk"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "1000000000"] "nothing" "nothing" "1000000000" "Round-trip first multi-chunk value"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "999999999999999999"] "nothing" "nothing" "999999999999999999" "Round-trip max two chunks"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "1000000000000000000"] "nothing" "nothing" "1000000000000000000" "Round-trip first three-chunk boundary"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "999999999999999999999999999"] "nothing" "nothing" "999999999999999999999999999" "Round-trip large chunk boundary"]
    :set res [$RunTestCase $res $ArrayToBigInt [$BigIntToArray "-999999999999999999999999999"] "nothing" "nothing" "-999999999999999999999999999" "Round-trip negative large chunk boundary"]

    # ------------------------------------------
    # Additional chunk-boundary arithmetic tests
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntAdd "999999999" "1" "nothing" "1000000000" "Add across chunk boundary"]
    :set res [$RunTestCase $res $BigIntAdd "999999999999999999" "1" "nothing" "1000000000000000000" "Add across two chunk boundaries"]

    :set res [$RunTestCase $res $BigIntSub "1000000000" "1" "nothing" "999999999" "Subtract across chunk boundary"]
    :set res [$RunTestCase $res $BigIntSub "1000000000000000000" "1" "nothing" "999999999999999999" "Subtract across two chunk boundaries"]

    :set res [$RunTestCase $res $BigIntMul "1000000000" "1000000000" "nothing" "1000000000000000000" "Multiply chunk boundary values"]

    :set res [$RunTestCase $res $BigIntDiv "1000000000" "999999999" "nothing" "1" "Divide adjacent chunk boundaries"]
    :set res [$RunTestCase $res $BigIntMod "1000000000" "999999999" "nothing" "1" "Modulo adjacent chunk boundaries"]

    # ------------------------------------------
    # Algebraic combined-operation tests
    # ------------------------------------------

    # (a+b)*c = a*c + b*c
    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul "123456" "789"] \
        [$BigIntMul "654321" "789"] \
        "nothing" \
        [$BigIntMul [$BigIntAdd "123456" "654321"] "789"] \
        "Combined distributive identity"]

    # (a-b)*c = a*c - b*c
    :set res [$RunTestCase $res $BigIntSub \
        [$BigIntMul "123456" "789"] \
        [$BigIntMul "654321" "789"] \
        "nothing" \
        [$BigIntMul [$BigIntSub "123456" "654321"] "789"] \
        "Subtraction distributive identity"]

    # a*(b-c) = a*b-a*c
    :set res [$RunTestCase $res $BigIntSub \
        [$BigIntMul "789" "123456"] \
        [$BigIntMul "789" "654321"] \
        "nothing" \
        [$BigIntMul "789" [$BigIntSub "123456" "654321"]] \
        "Multiplication over subtraction identity"]

    # ------------------------------------------
    # Comparison consistency
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntCmp "123456789123456789" "987654321987654321" "nothing" "-1" "Comparison ordered large values"]
    :set res [$RunTestCase $res $BigIntCmp "987654321987654321" "123456789123456789" "nothing" "1" "Comparison reverse ordered large values"]

    :set res [$RunTestCase $res $BigIntCmp "-987654321987654321" "-123456789123456789" "nothing" "-1" "Comparison ordered negative values"]
    :set res [$RunTestCase $res $BigIntCmp "-123456789123456789" "-987654321987654321" "nothing" "1" "Comparison reverse ordered negative values"]

    :set res [$RunTestCase $res $BigIntCmp "123456789123456789" "123456789123456789" "nothing" "0" "Comparison identical large values"]

    # ------------------------------------------
    # Associativity of addition
    # (a+b)+c = a+(b+c)
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntAdd "123456789" "987654321"] \
        "111111111" \
        "nothing" \
        [$BigIntAdd "123456789" [$BigIntAdd "987654321" "111111111"]] \
        "Addition associativity positive"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntAdd "-123456789" "987654321"] \
        "-111111111" \
        "nothing" \
        [$BigIntAdd "-123456789" [$BigIntAdd "987654321" "-111111111"]] \
        "Addition associativity mixed signs"]

    # ------------------------------------------
    # Associativity of multiplication
    # (a*b)*c = a*(b*c)
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntMul \
        [$BigIntMul "12345" "6789"] \
        "111" \
        "nothing" \
        [$BigIntMul "12345" [$BigIntMul "6789" "111"]] \
        "Multiplication associativity positive"]

    :set res [$RunTestCase $res $BigIntMul \
        [$BigIntMul "-12345" "6789"] \
        "-111" \
        "nothing" \
        [$BigIntMul "-12345" [$BigIntMul "6789" "-111"]] \
        "Multiplication associativity mixed signs"]

    # ------------------------------------------
    # Power multiplication identity
    # a^m * a^n = a^(m+n)
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntMul \
        [$BigIntPow "7" "8"] \
        [$BigIntPow "7" "5"] \
        "nothing" \
        [$BigIntPow "7" [$BigIntAdd "8" "5"]] \
        "Power multiplication identity"]

    :set res [$RunTestCase $res $BigIntMul \
        [$BigIntPow "-7" "8"] \
        [$BigIntPow "-7" "5"] \
        "nothing" \
        [$BigIntPow "-7" [$BigIntAdd "8" "5"]] \
        "Power multiplication identity negative base"]

    # ------------------------------------------
    # Power of a power
    # (a^m)^n = a^(m*n)
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntPow \
        [$BigIntPow "3" "4"] \
        "5" \
        "nothing" \
        [$BigIntPow "3" [$BigIntMul "4" "5"]] \
        "Power of a power identity"]

    :set res [$RunTestCase $res $BigIntPow \
        [$BigIntPow "-3" "4"] \
        "5" \
        "nothing" \
        [$BigIntPow "-3" [$BigIntMul "4" "5"]] \
        "Power of a power negative base"]

    # ------------------------------------------
    # PowMod exponent decomposition
    # a^(m+n) mod p =
    # ((a^m mod p) * (a^n mod p)) mod p
    # ------------------------------------------

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul [$BigIntPowMod "7" "8" "1000003"] [$BigIntPowMod "7" "5" "1000003"]] \
        "1000003" \
        "nothing" \
        [$BigIntPowMod "7" "13" "1000003"] \
        "PowMod exponent decomposition"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul [$BigIntPowMod "-7" "8" "1000003"] [$BigIntPowMod "-7" "5" "1000003"]] \
        "1000003" \
        "nothing" \
        [$BigIntPowMod "-7" "13" "1000003"] \
        "PowMod exponent decomposition negative base"]

    # Floor division when dividend absolute value is smaller than divisor
    :set res [$RunTestCase $res $BigIntDiv "-3" "7" "nothing" "-1" "Python floor div small negative dividend"]
    :set res [$RunTestCase $res $BigIntMod "-3" "7" "nothing" "4" "Python mod small negative dividend"]

    :set res [$RunTestCase $res $BigIntDiv "3" "-7" "nothing" "-1" "Python floor div small negative divisor"]
    :set res [$RunTestCase $res $BigIntMod "3" "-7" "nothing" "-4" "Python mod small negative divisor"]

    # Python math.gcd always returns positive result
    :set res [$RunTestCase $res $BigIntGcd "-12" "-18" "nothing" "6" "GCD of negative numbers is positive in Python"]
    :set res [$RunTestCase $res $BigIntGcd "-7" "0" "nothing" "7" "GCD of negative and zero is positive"]

    # Python pow with negative exponent using modular inverse
    # pow(3, -2, 11) -> mod inverse of 3 mod 11 is 4 -> pow(4, 2, 11) = 5
    :set res [$RunTestCase $res $BigIntPowMod "3" "-2" "11" "5" "Python pow with negative exponent"]

    # Zero base to zero exponent edge cases
    :set res [$RunTestCase $res $BigIntPow "0" "0" "nothing" "1" "Python pow zero to zero power"]
    :set res [$RunTestCase $res $BigIntPowMod "0" "0" "1" "0" "Python powmod zero to zero with modulus 1"]
    :set res [$RunTestCase $res $BigIntPowMod "0" "0" "5" "1" "Python powmod zero to zero with modulus 5"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntSub "123456789123456789" "-987654321987654321"] \
        "1111111111111111110" \
        "nothing" \
        "2222222222222222220" \
        "Sub inverse positive-negative"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntSub "-123456789123456789" "987654321987654321"] \
        "-1111111111111111110" \
        "nothing" \
        "-2222222222222222220" \
        "Sub inverse negative-positive"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntSub "123456789123456789" "123456789123456789"] \
        "0" \
        "nothing" \
        "0" \
        "Sub self"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntSub "123456789123456789" "0"] \
        "123456789123456789" \
        "nothing" \
        "246913578246913578" \
        "Sub zero"]

    :set res [$RunTestCase $res $BigIntDiv \
        [$BigIntMul "123456789" "-12345"] \
        "-12345" \
        "nothing" \
        "123456789" \
        "MulDiv exact negative"]

    :set res [$RunTestCase $res $BigIntDiv \
        [$BigIntMul "-123456789" "-12345"] \
        "-12345" \
        "nothing" \
        "-123456789" \
        "MulDiv exact both negative"]

    :set res [$RunTestCase $res $BigIntDiv \
        [$BigIntMul "987654321" "123456789"] \
        "123456789" \
        "nothing" \
        "987654321" \
        "MulDiv exact positive"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "123456789123456789" "12345"] "12345"] \
        [$BigIntMod "123456789123456789" "12345"] \
        "nothing" \
        "123456789123456789" \
        "DivMod identity ++"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "-123456789123456789" "12345"] "12345"] \
        [$BigIntMod "-123456789123456789" "12345"] \
        "nothing" \
        "-123456789123456789" \
        "DivMod identity -+"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "123456789123456789" "-12345"] "-12345"] \
        [$BigIntMod "123456789123456789" "-12345"] \
        "nothing" \
        "123456789123456789" \
        "DivMod identity +-"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "-123456789123456789" "-12345"] "-12345"] \
        [$BigIntMod "-123456789123456789" "-12345"] \
        "nothing" \
        "-123456789123456789" \
        "DivMod identity --"]

    :set res [$RunTestCase $res $BigIntDiv \
        "-1" "2" "nothing" "-1" \
        "Floor -1/2"]

    :set res [$RunTestCase $res $BigIntDiv \
        "1" "-2" "nothing" "-1" \
        "Floor 1/-2"]

    :set res [$RunTestCase $res $BigIntDiv \
        "-1" "-2" "nothing" "0" \
        "Floor -1/-2"]

    :set res [$RunTestCase $res $BigIntDiv \
        "1" "2" "nothing" "0" \
        "Floor 1/2"]

    :set res [$RunTestCase $res $BigIntDiv \
        "-10" "3" "nothing" "-4" \
        "Floor -10/3"]

    :set res [$RunTestCase $res $BigIntDiv \
        "10" "-3" "nothing" "-4" \
        "Floor 10/-3"]

    :set res [$RunTestCase $res $BigIntDiv \
        "-10" "-3" "nothing" "3" \
        "Floor -10/-3"]

    :set res [$RunTestCase $res $BigIntMod \
        "-1" "2" "nothing" "1" \
        "Mod -1/2"]

    :set res [$RunTestCase $res $BigIntMod \
        "1" "-2" "nothing" "-1" \
        "Mod 1/-2"]

    :set res [$RunTestCase $res $BigIntMod \
        "-1" "-2" "nothing" "-1" \
        "Mod -1/-2"]

    :set res [$RunTestCase $res $BigIntMod \
        "10" "-3" "nothing" "-2" \
        "Mod 10/-3"]

    :set res [$RunTestCase $res $BigIntMod \
        "-10" "3" "nothing" "2" \
        "Mod -10/3"]

    :set res [$RunTestCase $res $BigIntMod \
        "-10" "-3" "nothing" "-1" \
        "Mod -10/-3"]

    :set res [$RunTestCase $res $BigIntPow \
        "123456789" "0" "nothing" "1" \
        "Pow zero"]

    :set res [$RunTestCase $res $BigIntPow \
        "-12345" "1" "nothing" "-12345" \
        "Pow one negative"]

    :set res [$RunTestCase $res $BigIntPow \
        "-12" "2" "nothing" "144" \
        "Pow negative even"]

    :set res [$RunTestCase $res $BigIntPow \
        "-12" "3" "nothing" "-1728" \
        "Pow negative odd"]

    :set res [$RunTestCase $res $BigIntPow \
        "12345" "4" "nothing" "23225462820950625" \
        "Pow large"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntPow "12345" "7"] \
        "97" \
        "nothing" \
        [$BigIntPowMod "12345" "7" "97"] \
        "Pow versus PowMod"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntPow "-12345" "8"] \
        "97" \
        "nothing" \
        [$BigIntPowMod "-12345" "8" "97"] \
        "Pow versus PowMod negative even"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntPow "-12345" "9"] \
        "97" \
        "nothing" \
        [$BigIntPowMod "-12345" "9" "97"] \
        "Pow versus PowMod negative odd"]

    :set res [$RunTestCase $res $BigIntMod \
        "123456789123456789" \
        [$BigIntGcd "123456789123456789" "987654321"] \
        "nothing" \
        "0" \
        "GCD divides first"]

    :set res [$RunTestCase $res $BigIntMod \
        "987654321" \
        [$BigIntGcd "123456789123456789" "987654321"] \
        "nothing" \
        "0" \
        "GCD divides second"]

    :set res [$RunTestCase $res $BigIntGcd \
        "987654321" \
        "123456789123456789" \
        "nothing" \
        [$BigIntGcd "123456789123456789" "987654321"] \
        "GCD symmetry"]

    :set res [$RunTestCase $res $BigIntGcd \
        "123456789123456789" \
        "987654321" \
        "nothing" \
        [$BigIntGcd "987654321" [$BigIntMod "123456789123456789" "987654321"]] \
        "GCD Euclidean step"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul "17" [$BigIntModInverse "17" "3120"]] \
        "3120" \
        "nothing" \
        "1" \
        "ModInverse identity"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul "3" [$BigIntModInverse "3" "11"]] \
        "11" \
        "nothing" \
        "1" \
        "ModInverse 3/11"]

    :set res [$RunTestCase $res $BigIntMod \
        [$BigIntMul "1234567" [$BigIntModInverse "1234567" "10000019"]] \
        "10000019" \
        "nothing" \
        "1" \
        "ModInverse large"]

    :set res [$RunTestCase $res $BigIntGcd \
        "17" "3120" "nothing" "1" \
        "Inverse GCD"]

    :set res [$RunTestCase $res $BigIntGcd \
        "12" "18" "nothing" "6" \
        "Non-coprime GCD"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "987654321987654321987654321" "123456789"] "123456789"] \
        [$BigIntMod "987654321987654321987654321" "123456789"] \
        "nothing" \
        "987654321987654321987654321" \
        "Large DivMod identity"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "-987654321987654321987654321" "123456789"] "123456789"] \
        [$BigIntMod "-987654321987654321987654321" "123456789"] \
        "nothing" \
        "-987654321987654321987654321" \
        "Large DivMod identity negative"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "987654321987654321987654321" "-123456789"] "-123456789"] \
        [$BigIntMod "987654321987654321987654321" "-123456789"] \
        "nothing" \
        "987654321987654321987654321" \
        "Large DivMod identity negative divisor"]

    :set res [$RunTestCase $res $BigIntAdd \
        [$BigIntMul [$BigIntDiv "-987654321987654321987654321" "-123456789"] "-123456789"] \
        [$BigIntMod "-987654321987654321987654321" "-123456789"] \
        "nothing" \
        "-987654321987654321987654321" \
        "Large DivMod identity both negative"]

    :put "Testing completed."
    :return $res
}
