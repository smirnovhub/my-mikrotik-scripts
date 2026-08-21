# 8888888b.  888     888 888b    888             d8888 88888888888
# 888   Y88b 888     888 8888b   888            d88888     888
# 888    888 888     888 88888b  888           d88P888     888
# 888   d88P 888     888 888Y88b 888          d88P 888     888
# 8888888P"  888     888 888 Y88b888         d88P  888     888
# 888 T88b   888     888 888  Y88888        d88P   888     888
# 888  T88b  Y88b. .d88P 888   Y8888       d8888888888     888
# 888   T88b  "Y88888P"  888    Y888      d88P     888     888
#
#  .d8888b. 88888888888     d8888 8888888b. 88888888888 888
# d88P  Y88b    888        d88888 888   Y88b    888     888
# Y88b.         888       d88P888 888    888    888     888
#  "Y888b.      888      d88P 888 888   d88P    888     888
#     "Y88b.    888     d88P  888 8888888P"     888     888
#       "888    888    d88P   888 888 T88b      888     Y8P
# Y88b  d88P    888   d8888888888 888  T88b     888      " 
#  "Y8888P"     888  d88P     888 888   T88b    888     888
#
# YOU NEED TO RUN THIS SCRIPT AT SYSTEM START!
# OR IF YOU CHANGED SOMETHING IN THIS FILE!
#
# Add script named global_functions_big_int and then add call to startup script
# system script run global_functions_big_int

# global functions
:global BigIntToArray
:global ArrayToBigInt

:global BigIntCmpArr
:global BigIntAddArr
:global BigIntSubArr
:global BigIntMulArr
:global BigIntModArr
:global BigIntDivArr
:global BigIntPowArr
:global BigIntPowModArr
:global BigIntGcdArr
:global BigIntModInverseArr
:global BigIntCleanArr

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

# Purpose: Convert a BigInt string representation into a signed chunked array object.
# Parameters:
#   $1 - Input BigInt string to be converted
# Returns: Object dictionary containing sign and data array of 9-digit chunks (Little-Endian)
# Example: :put [$BigIntToArray "-1234567890123"]
# Output:
#   data=567890123;1234;sign=-1
:set BigIntToArray do={
    :local str $1

    :if ($str = "0" || $str = "-0" || $str = "") do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local isNeg ([:pick $str 0 1] = "-")

    :if ($isNeg) do={
        :set str [:pick $str 1 [:len $str]]
    }

    :local len [:len $str]
    :local dataArr [:toarray ""]
    :local signVal 1

    :if ($isNeg) do={
        :set signVal -1
    }

    :while ($len > 0) do={
        :local start ($len - 9)

        :if ($start < 0) do={
            :set start 0
        }

        :set dataArr ($dataArr, [:tonum [:pick $str $start $len]])
        :set len $start
    }

    :return {"sign"=$signVal; "data"=$dataArr}
}

# Purpose: Convert a signed chunked array object back to a BigInt string representation.
# Parameters:
#   $1 - BigInt object dictionary to be converted
# Returns: BigInt string
# Example: :put [$ArrayToBigInt ({"sign"=-1; "data"=[:toarray "567890123,1234"]})]
# Output:
#   -1234567890123
:set ArrayToBigInt do={
    :local bigIntObj $1
    :local signVal ($bigIntObj->"sign")
    :local arr ($bigIntObj->"data")
    :local len [:len $arr]
    :local i ($len - 1)
    :local str ""

    :while ($i >= 0) do={
        :local chunk [:tostr ($arr->$i)]

        :if ($i < ($len - 1)) do={
            :while ([:len $chunk] < 9) do={
                :set chunk ("0" . $chunk)
            }
        }

        :set str ($str . $chunk)
        :set i ($i - 1)
    }

    :if ($signVal < 0 && $str != "0") do={
        :set str ("-" . $str)
    }

    :return $str
}

# Purpose: Compare two BigInt chunked array objects.
# Parameters:
#   $1 - Left BigInt object
#   $2 - Right BigInt object
# Returns: Integer (-1 if left < right, 0 if equal, 1 if left > right)
# Example: :put [$BigIntCmpArr [$BigIntToArray "5"] [$BigIntToArray "10"]]
# Output:
#   -1
:set BigIntCmpArr do={
    :local leftObj $1
    :local rightObj $2
    :local leftSign ($leftObj->"sign")
    :local rightSign ($rightObj->"sign")
    :local leftDigits ($leftObj->"data")
    :local rightDigits ($rightObj->"data")

    :if ($leftSign != $rightSign) do={
        :if ($leftSign > $rightSign) do={
            :return 1
        } else={
            :return -1
        }
    }

    :local leftLen [:len $leftDigits]
    :local rightLen [:len $rightDigits]

    :if ($leftLen != $rightLen) do={
        :if ($leftLen > $rightLen) do={
            :return $leftSign
        } else={
            :return ($leftSign * -1)
        }
    }

    :for chunkIndex from=($leftLen - 1) to=0 step=-1 do={
        :local leftChunk ($leftDigits->$chunkIndex)
        :local rightChunk ($rightDigits->$chunkIndex)

        :if ($leftChunk != $rightChunk) do={
            :if ($leftChunk > $rightChunk) do={
                :return $leftSign
            } else={
                :return ($leftSign * -1)
            }
        }
    }

    :return 0
}

# Purpose: Add two BigInt chunked array objects.
# Parameters:
#   $1 - Left BigInt object
#   $2 - Right BigInt object
# Returns: BigInt object containing the sum
# Example: :put [$ArrayToBigInt [$BigIntAddArr [$BigIntToArray "500"] [$BigIntToArray "700"]]]
# Output:
#   1200
:set BigIntAddArr do={
    :global BigIntSubArr

    :local leftObj $1
    :local rightObj $2
    :local leftSign ($leftObj->"sign")
    :local rightSign ($rightObj->"sign")
    :local leftDigits ($leftObj->"data")
    :local rightDigits ($rightObj->"data")

    :if ($leftSign != $rightSign) do={
        :local invertedRight {"sign"=($rightSign * -1); "data"=$rightDigits}
        :return [$BigIntSubArr $leftObj $invertedRight]
    }

    :local sumDigits [:toarray ""]
    :local carryValue 0
    :local maxLen [:len $leftDigits]
    :local rightLen [:len $rightDigits]

    :if ($rightLen > $maxLen) do={
        :set maxLen $rightLen
    }

    :for chunkIndex from=0 to=($maxLen - 1) do={
        :local leftVal 0
        :local rightVal 0

        :if ($chunkIndex < [:len $leftDigits]) do={
            :set leftVal ($leftDigits->$chunkIndex)
        }
        :if ($chunkIndex < [:len $rightDigits]) do={
            :set rightVal ($rightDigits->$chunkIndex)
        }

        :local totalSum ($carryValue + $leftVal + $rightVal)
        :set sumDigits ($sumDigits, ($totalSum % 1000000000))
        :set carryValue ($totalSum / 1000000000)
    }

    :if ($carryValue > 0) do={
        :set sumDigits ($sumDigits, $carryValue)
    }

    :return {"sign"=$leftSign; "data"=$sumDigits}
}

# Purpose: Subtract one BigInt chunked array object from another.
# Parameters:
#   $1 - Left BigInt object (Minuend)
#   $2 - Right BigInt object (Subtrahend)
# Returns: BigInt object containing the difference
# Example: :put [$ArrayToBigInt [$BigIntSubArr [$BigIntToArray "100"] [$BigIntToArray "30"]]]
# Output:
#   70
:set BigIntSubArr do={
    :global BigIntAddArr
    :global BigIntCmpArr
    :global BigIntCleanArr

    :local leftObj $1
    :local rightObj $2
    :local leftSign ($leftObj->"sign")
    :local rightSign ($rightObj->"sign")
    :local leftDigits ($leftObj->"data")
    :local rightDigits ($rightObj->"data")

    :if ($leftSign != $rightSign) do={
        :local invertedRight {"sign"=($rightSign * -1); "data"=$rightDigits}
        :return [$BigIntAddArr $leftObj $invertedRight]
    }

    :local absLeft {"sign"=1; "data"=$leftDigits}
    :local absRight {"sign"=1; "data"=$rightDigits}
    :local comparisonResult [$BigIntCmpArr $absLeft $absRight]

    :if ($comparisonResult = 0) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local largerDigits $leftDigits
    :local smallerDigits $rightDigits
    :local resultSign $leftSign

    :if ($comparisonResult = -1) do={
        :set largerDigits $rightDigits
        :set smallerDigits $leftDigits
        :set resultSign ($leftSign * -1)
    }

    :local diffDigits [:toarray ""]
    :local borrowValue 0
    :local largerLen [:len $largerDigits]
    :local smallerLen [:len $smallerDigits]

    :for chunkIndex from=0 to=($largerLen - 1) do={
        :local smallerVal 0
        :if ($chunkIndex < $smallerLen) do={
            :set smallerVal ($smallerDigits->$chunkIndex)
        }

        :local currentDiff (($largerDigits->$chunkIndex) - $smallerVal - $borrowValue)
        :if ($currentDiff < 0) do={
            :set diffDigits ($diffDigits, ($currentDiff + 1000000000))
            :set borrowValue 1
        } else={
            :set diffDigits ($diffDigits, $currentDiff)
            :set borrowValue 0
        }
    }

    :return [$BigIntCleanArr ({"sign"=$resultSign; "data"=$diffDigits})]
}

# Purpose: Multiply two BigInt chunked array objects.
# Parameters:
#   $1 - Left BigInt object
#   $2 - Right BigInt object
# Returns: BigInt object containing the product
# Example: :put [$ArrayToBigInt [$BigIntMulArr [$BigIntToArray "25"] [$BigIntToArray "4"]]]
# Output:
#   100
:set BigIntMulArr do={
    :global BigIntAddArr

    :local leftObj $1
    :local rightObj $2
    :local leftSign ($leftObj->"sign")
    :local rightSign ($rightObj->"sign")
    :local leftDigits ($leftObj->"data")
    :local rightDigits ($rightObj->"data")

    :if (([:len $leftDigits] = 1 && ($leftDigits->0) = 0) || ([:len $rightDigits] = 1 && ($rightDigits->0) = 0)) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local accumulatedProduct [:toarray 0]
    :local rightLen [:len $rightDigits]
    :local leftLen [:len $leftDigits]

    :for rightIndex from=0 to=($rightLen - 1) do={
        :local multiplierChunk ($rightDigits->$rightIndex)
        :if ($multiplierChunk > 0) do={
            :local partialLevel [:toarray ""]
            :if ($rightIndex > 0) do={
                :for offset from=1 to=$rightIndex do={
                    :set partialLevel ($partialLevel, 0)
                }
            }

            :local carryVal 0
            :for leftIndex from=0 to=($leftLen - 1) do={
                :local productVal ((($leftDigits->$leftIndex) * $multiplierChunk) + $carryVal)
                :set partialLevel ($partialLevel, ($productVal % 1000000000))
                :set carryVal ($productVal / 1000000000)
            }

            :if ($carryVal > 0) do={
                :set partialLevel ($partialLevel, $carryVal)
            }

            :local additionResult [$BigIntAddArr ({"sign"=1; "data"=$accumulatedProduct}) ({"sign"=1; "data"=$partialLevel})]
            :set accumulatedProduct ($additionResult->"data")
        }
    }

    :return {"sign"=($leftSign * $rightSign); "data"=$accumulatedProduct}
}

# Purpose: Calculate the remainder of division of two BigInt chunked array objects.
# Parameters:
#   $1 - Dividend BigInt object
#   $2 - Divisor BigInt object
# Returns: BigInt object containing the modulo result
# Example: :put [$ArrayToBigInt [$BigIntModArr [$BigIntToArray "14"] [$BigIntToArray "5"]]]
# Output:
#   4
:set BigIntModArr do={
    :global BigIntCmpArr
    :global BigIntSubArr
    :global BigIntMulArr

    :local numObj $1
    :local modObj $2
    :local numSign ($numObj->"sign")
    :local modSign ($modObj->"sign")
    :local numDigits ($numObj->"data")
    :local modDigits ($modObj->"data")

    :if ([:len $modDigits] = 1 && ($modDigits->0) = 0) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local absMod {"sign"=1; "data"=$modDigits}

    :local remainderDigits [:toarray 0]
    :local numLen [:len $numDigits]

    :for chunkIndex from=($numLen - 1) to=0 step=-1 do={
        :local nextChunkValue ($numDigits->$chunkIndex)

        # Shift remainder left by one base-10^9 chunk and append next chunk.
        :if ([:len $remainderDigits] = 1 && ($remainderDigits->0) = 0) do={
            :set remainderDigits [:toarray $nextChunkValue]
        } else={
            :local extendedRem [:toarray $nextChunkValue]
            :local remLen [:len $remainderDigits]

            :for remIndex from=0 to=($remLen - 1) do={
                :set extendedRem ($extendedRem, ($remainderDigits->$remIndex))
            }

            :set remainderDigits $extendedRem
        }

        :local searchLow 0
        :local searchHigh 999999999

        :while ($searchLow <= $searchHigh) do={
            :local midVal (($searchLow + $searchHigh) >> 1)
            :local candidateProduct [$BigIntMulArr $absMod ({"sign"=1; "data"=[:toarray $midVal]})]

            :if ([$BigIntCmpArr $candidateProduct ({"sign"=1; "data"=$remainderDigits})] = 1) do={
                :set searchHigh ($midVal - 1)
            } else={
                :set searchLow ($midVal + 1)
            }
        }

        :if ($searchHigh > 0) do={
            :local subtractionAmount [$BigIntMulArr $absMod ({"sign"=1; "data"=[:toarray $searchHigh]})]
            :local subtractionResult [$BigIntSubArr ({"sign"=1; "data"=$remainderDigits}) $subtractionAmount]
            :set remainderDigits ($subtractionResult->"data")
        }
    }

    :local isZero ([:len $remainderDigits] = 1 && ($remainderDigits->0) = 0)
    :if ($isZero) do={
        :return {"sign"=1; "data"=$remainderDigits}
    }

    # Python floor-division remainder must have the divisor's sign.
    :if ($numSign != $modSign) do={
        :local adjustedRemainder [$BigIntSubArr $absMod ({"sign"=1; "data"=$remainderDigits})]
        :set remainderDigits ($adjustedRemainder->"data")
        :return {"sign"=$modSign; "data"=$remainderDigits}
    }

    :return {"sign"=$modSign; "data"=$remainderDigits}
}

# Purpose: Divide one BigInt chunked array object by another.
# Parameters:
#   $1 - Dividend BigInt object
#   $2 - Divisor BigInt object
# Returns: BigInt object containing the integer quotient
# Example: :put [$ArrayToBigInt [$BigIntDivArr [$BigIntToArray "20"] [$BigIntToArray "3"]]]
# Output:
#   6
:set BigIntDivArr do={
    :global BigIntCmpArr
    :global BigIntSubArr
    :global BigIntMulArr
    :global BigIntAddArr

    :local numObj $1
    :local divObj $2
    :local numSign ($numObj->"sign")
    :local divSign ($divObj->"sign")
    :local numDigits ($numObj->"data")
    :local divDigits ($divObj->"data")

    :if ([:len $divDigits] = 1 && ($divDigits->0) = 0) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    # Zero dividend always produces zero.
    :if ([:len $numDigits] = 1 && ($numDigits->0) = 0) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local finalSign 1
    :if ($numSign != $divSign) do={
        :set finalSign -1
    }

    :local absNum {"sign"=1; "data"=$numDigits}
    :local absDiv {"sign"=1; "data"=$divDigits}
    :local comparisonState [$BigIntCmpArr $absNum $absDiv]

    :if ($comparisonState = -1) do={
        :if ($finalSign = -1) do={
            :return {"sign"=-1; "data"=[:toarray 1]}
        }
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :if ($comparisonState = 0) do={
        :return {"sign"=$finalSign; "data"=[:toarray 1]}
    }

    :local quotientDigits [:toarray ""]
    :local remainderDigits [:toarray 0]
    :local numLen [:len $numDigits]

    :for chunkIndex from=($numLen - 1) to=0 step=-1 do={
        :local nextChunkValue ($numDigits->$chunkIndex)

        # Shift remainder left by one base-10^9 chunk and append next chunk.
        :if ([:len $remainderDigits] = 1 && ($remainderDigits->0) = 0) do={
            :set remainderDigits [:toarray $nextChunkValue]
        } else={
            :local extendedRem [:toarray $nextChunkValue]
            :local remLen [:len $remainderDigits]

            :for remIndex from=0 to=($remLen - 1) do={
                :set extendedRem ($extendedRem, ($remainderDigits->$remIndex))
            }

            :set remainderDigits $extendedRem
        }

        :local searchLow 0
        :local searchHigh 999999999

        :while ($searchLow <= $searchHigh) do={
            :local midVal (($searchLow + $searchHigh) >> 1)
            :local candidateProduct [$BigIntMulArr $absDiv ({"sign"=1; "data"=[:toarray $midVal]})]

            :if ([$BigIntCmpArr $candidateProduct ({"sign"=1; "data"=$remainderDigits})] = 1) do={
                :set searchHigh ($midVal - 1)
            } else={
                :set searchLow ($midVal + 1)
            }
        }

        :if ($searchHigh > 0) do={
            :local subtractionAmount [$BigIntMulArr $absDiv ({"sign"=1; "data"=[:toarray $searchHigh]})]
            :local subtractionResult [$BigIntSubArr ({"sign"=1; "data"=$remainderDigits}) $subtractionAmount]
            :set remainderDigits ($subtractionResult->"data")
        }

        :if ([:len $quotientDigits] > 0 || $searchHigh > 0) do={
            :local updatedQuotient [:toarray $searchHigh]
            :local quotLen [:len $quotientDigits]

            :for quotIndex from=0 to=($quotLen - 1) do={
                :set updatedQuotient ($updatedQuotient, ($quotientDigits->$quotIndex))
            }

            :set quotientDigits $updatedQuotient
        }
    }

    # Floor division adjustment.
    # For a negative result with a non-zero remainder,
    # floor(x / y) is one less than truncation toward zero.
    :if ($finalSign = -1 && !([:len $remainderDigits] = 1 && ($remainderDigits->0) = 0)) do={
        :local incrementedQuotient [$BigIntAddArr ({"sign"=1; "data"=$quotientDigits}) ({"sign"=1; "data"=[:toarray 1]})]
        :set quotientDigits ($incrementedQuotient->"data")
    }

    :return {"sign"=$finalSign; "data"=$quotientDigits}
}

# Purpose: Raise a BigInt chunked array object to a specific power.
# Parameters:
#   $1 - Base BigInt object
#   $2 - Exponent BigInt object
# Returns: BigInt object containing the exponentiation result
# Example: :put [$ArrayToBigInt [$BigIntPowArr [$BigIntToArray "2"] [$BigIntToArray "8"]]]
# Output:
#   256
:set BigIntPowArr do={
    :global BigIntMulArr
    :global BigIntDivArr
    :global BigIntCmpArr

    :local baseObj $1
    :local expObj $2
    :local expSign ($expObj->"sign")

    :if ($expSign = -1) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local zeroObj {"sign"=1; "data"=[:toarray 0]}
    :local oneObj {"sign"=1; "data"=[:toarray 1]}

    :if ([$BigIntCmpArr $expObj $zeroObj] = 0) do={
        :return $oneObj
    }

    :if ([$BigIntCmpArr $expObj $oneObj] = 0) do={
        :return $baseObj
    }

    :if ([$BigIntCmpArr $baseObj $zeroObj] = 0) do={
        :return $zeroObj
    }

    :if ([$BigIntCmpArr $baseObj $oneObj] = 0) do={
        :return $oneObj
    }

    :local currentResult $oneObj
    :local activeBase $baseObj
    :local activeExp $expObj

    :while ([$BigIntCmpArr $activeExp $zeroObj] = 1) do={
        :local expDigits ($activeExp->"data")
        :local lowestExpChunk ($expDigits->0)
        :if (($lowestExpChunk % 2) != 0) do={
            :set currentResult [$BigIntMulArr $currentResult $activeBase]
        }

        :set activeExp [$BigIntDivArr $activeExp ({"sign"=1; "data"=[:toarray 2]})]

        :if ([$BigIntCmpArr $activeExp $zeroObj] != 0) do={
            :set activeBase [$BigIntMulArr $activeBase $activeBase]
        }
    }

    :return $currentResult
}

# Purpose: Calculate the modular exponentiation of a BigInt chunked array object.
# Parameters:
#   $1 - Base BigInt object
#   $2 - Exponent BigInt object
#   $3 - Modulus BigInt object
# Returns: BigInt object containing the modular power result
# Example: :put [$ArrayToBigInt [$BigIntPowModArr [$BigIntToArray "2"] [$BigIntToArray "10"] [$BigIntToArray "1000"]]]
# Output:
#   24
:set BigIntPowModArr do={
    :global BigIntMulArr
    :global BigIntDivArr
    :global BigIntModArr
    :global BigIntCmpArr

    :local baseObj $1
    :local expObj $2
    :local modObj $3
    :local expSign ($expObj->"sign")

    # Handle negative exponent as zero or unsupported
    :if ($expSign = -1) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local zeroObj {"sign"=1; "data"=[:toarray 0]}
    :local oneObj {"sign"=1; "data"=[:toarray 1]}

    # Modulo by 1 or 0 results in 0
    :if ([$BigIntCmpArr $modObj $oneObj] = 0 || [$BigIntCmpArr $modObj $zeroObj] = 0) do={
        :return $zeroObj
    }

    # Any base to the power of 0 is 1
    :if ([$BigIntCmpArr $expObj $zeroObj] = 0) do={
        :return $oneObj
    }

    :local currentResult $oneObj
    :local activeBase [$BigIntModArr $baseObj $modObj]
    :local activeExp $expObj

    :while ([$BigIntCmpArr $activeExp $zeroObj] = 1) do={
        :local expDigits ($activeExp->"data")
        :local lowestExpChunk ($expDigits->0)

        # If the lowest chunk is odd
        :if (($lowestExpChunk % 2) != 0) do={
            :set currentResult [$BigIntModArr [$BigIntMulArr $currentResult $activeBase] $modObj]
        }

        :set activeExp [$BigIntDivArr $activeExp ({"sign"=1; "data"=[:toarray 2]})]

        :if ([$BigIntCmpArr $activeExp $zeroObj] != 0) do={
            :set activeBase [$BigIntModArr [$BigIntMulArr $activeBase $activeBase] $modObj]
        }
    }

    :return $currentResult
}

# Purpose: Calculate the Greatest Common Divisor of two BigInt chunked array objects.
# Parameters:
#   $1 - First BigInt object
#   $2 - Second BigInt object
# Returns: BigInt object representing the GCD
# Example: :put [$ArrayToBigInt [$BigIntGcdArr [$BigIntToArray "54"] [$BigIntToArray "24"]]]
# Output:
#   6
:set BigIntGcdArr do={
    :global BigIntModArr
    :global BigIntCmpArr

    :local aObj $1
    :local bObj $2

    :local zeroObj {"sign"=1; "data"=[:toarray 0]}

    # If both numbers are zero, return zero
    :if ([$BigIntCmpArr $aObj $zeroObj] = 0 && [$BigIntCmpArr $bObj $zeroObj] = 0) do={
        :return $zeroObj
    }

    # Work with absolute values since GCD is positive
    :local absA {"sign"=1; "data"=($aObj->"data")}
    :local absB {"sign"=1; "data"=($bObj->"data")}

    # Euclidean algorithm loop
    :while ([$BigIntCmpArr $absB $zeroObj] != 0) do={
        :local tempRem [$BigIntModArr $absA $absB]
        :set absA $absB
        :set absB $tempRem
    }

    :return $absA
}

# Purpose: Calculate the modular multiplicative inverse of a BigInt chunked array object.
# Parameters:
#   $1 - Base BigInt object
#   $2 - Modulus BigInt object
# Returns: BigInt object containing the inverse element, or zero if none exists
# Example: :put [$ArrayToBigInt [$BigIntModInverseArr [$BigIntToArray "3"] [$BigIntToArray "11"]]]
# Output:
#   4
:set BigIntModInverseArr do={
    :global BigIntModArr
    :global BigIntDivArr
    :global BigIntMulArr
    :global BigIntSubArr
    :global BigIntAddArr
    :global BigIntCmpArr

    :local aObj $1
    :local mObj $2

    :local zeroObj {"sign"=1; "data"=[:toarray 0]}
    :local oneObj {"sign"=1; "data"=[:toarray 1]}

    :if ([$BigIntCmpArr $mObj $oneObj] != 1) do={
        :return $zeroObj
    }

    :local tObj $zeroObj
    :local newTObj $oneObj
    :local rObj $mObj
    :local newRObj [$BigIntModArr $aObj $mObj]

    :local quotient $zeroObj
    :local temp $zeroObj

    :while ([$BigIntCmpArr $newRObj $zeroObj] != 0) do={
        :set quotient [$BigIntDivArr $rObj $newRObj]

        :set temp $newRObj
        :set newRObj [$BigIntSubArr $rObj [$BigIntMulArr $quotient $newRObj]]
        :set rObj $temp

        :set temp $newTObj
        :set newTObj [$BigIntSubArr $tObj [$BigIntMulArr $quotient $newTObj]]
        :set tObj $temp
    }

    # If r > 1, then gcd(a, m) != 1, so inverse does not exist
    :if ([$BigIntCmpArr $rObj $oneObj] != 0) do={
        :return $zeroObj
    }

    # If t < 0, add modulus m to make it positive
    :if (($tObj->"sign") = -1) do={
        :set tObj [$BigIntAddArr $tObj $mObj]
    }

    :return $tObj
}

# Purpose: Remove trailing zero chunks from the data array of a BigInt chunked array object.
# Parameters:
#   $1 - BigInt object to clean
# Returns: Cleaned BigInt object
# Example: :put [$ArrayToBigInt [$BigIntCleanArr ({"sign"=1; "data"=[:toarray "123,0,0"]})]]
# Output:
#   123
:set BigIntCleanArr do={
    :local arr ($1->"data")
    :local arrLen [:len $arr]

    :while ($arrLen > 1 && ($arr->($arrLen - 1)) = 0) do={
        :set arr [:pick $arr 0 ($arrLen - 1)]
        :set arrLen ($arrLen - 1)
    }

    :if ($arrLen = 1 && ($arr->0) = 0) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :return {"sign"=($1->"sign"); "data"=$arr}
}

# Purpose: Compare two BigInt string representations.
# Parameters:
#   $1 - Left BigInt string
#   $2 - Right BigInt string
# Returns: Integer (-1 if left < right, 0 if equal, 1 if left > right)
# Example: :put [$BigIntCmp "200" "100"]
# Output:
#   1
:set BigIntCmp do={
    :global BigIntToArray
    :global BigIntCmpArr
    :return [$BigIntCmpArr [$BigIntToArray $1] [$BigIntToArray $2]]
}

# Purpose: Add two BigInt string representations.
# Parameters:
#   $1 - Left BigInt string
#   $2 - Right BigInt string
# Returns: String containing the sum
# Example: :put [$BigIntAdd "1000" "250"]
# Output:
#   1250
:set BigIntAdd do={
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntAddArr
    :return [$ArrayToBigInt [$BigIntAddArr [$BigIntToArray $1] [$BigIntToArray $2]]]
}

# Purpose: Subtract one BigInt string representation from another.
# Parameters:
#   $1 - Left BigInt string (Minuend)
#   $2 - Right BigInt string (Subtrahend)
# Returns: String containing the difference
# Example: :put [$BigIntSub "50" "20"]
# Output:
#   30
:set BigIntSub do={
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntSubArr
    :return [$ArrayToBigInt [$BigIntSubArr [$BigIntToArray $1] [$BigIntToArray $2]]]
}

# Purpose: Multiply two BigInt string representations.
# Parameters:
#   $1 - Left BigInt string
#   $2 - Right BigInt string
# Returns: String containing the product
# Example: :put [$BigIntMul "15" "3"]
# Output:
#   45
:set BigIntMul do={
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntMulArr
    :return [$ArrayToBigInt [$BigIntMulArr [$BigIntToArray $1] [$BigIntToArray $2]]]
}

# Purpose: Calculate the remainder of division of two BigInt string representations.
# Parameters:
#   $1 - Dividend BigInt string
#   $2 - Divisor BigInt string
# Returns: String containing the modulo result
# Example: :put [$BigIntMod "100" "30"]
# Output:
#   10
:set BigIntMod do={
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntModArr
    :return [$ArrayToBigInt [$BigIntModArr [$BigIntToArray $1] [$BigIntToArray $2]]]
}

# Purpose: Divide one BigInt string representation by another.
# Parameters:
#   $1 - Dividend BigInt string
#   $2 - Divisor BigInt string
# Returns: String containing the integer quotient
# Example: :put [$BigIntDiv "150" "10"]
# Output:
#   15
:set BigIntDiv do={
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntDivArr
    :return [$ArrayToBigInt [$BigIntDivArr [$BigIntToArray $1] [$BigIntToArray $2]]]
}

# Purpose: Raise a BigInt string representation to a specific power.
# Parameters:
#   $1 - Base BigInt string
#   $2 - Exponent BigInt string
# Returns: String containing the exponentiation result
# Example: :put [$BigIntPow "2" "128"]
# Output:
#   340282366920938463463374607431768211456
:set BigIntPow do={
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntPowArr
    :return [$ArrayToBigInt [$BigIntPowArr [$BigIntToArray $1] [$BigIntToArray $2]]]
}

# Purpose: Calculate the modular exponentiation of BigInt string representations.
# Parameters:
#   $1 - Base BigInt string
#   $2 - Exponent BigInt string
#   $3 - Modulus BigInt string
# Returns: String containing the modular power result
# Example: :put [$BigIntPowMod "2" "10" "1000"]
# Output:
#   24
:set BigIntPowMod do={
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntPowModArr

    :return [$ArrayToBigInt [$BigIntPowModArr [$BigIntToArray $1] [$BigIntToArray $2] [$BigIntToArray $3]]]
}

# Purpose: Calculate the Greatest Common Divisor of two BigInt string representations.
# Parameters:
#   $1 - First BigInt string
#   $2 - Second BigInt string
# Returns: String representing the GCD
# Example: :put [$BigIntGcd "54" "24"]
# Output:
#   6
:set BigIntGcd do={
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntGcdArr

    :return [$ArrayToBigInt [$BigIntGcdArr [$BigIntToArray $1] [$BigIntToArray $2]]]
}

# Purpose: Calculate the modular multiplicative inverse of a BigInt string representation.
# Parameters:
#   $1 - Base BigInt string
#   $2 - Modulus BigInt string
# Returns: String containing the inverse element, or zero if none exists
# Example: :put [$BigIntModInverse "3" "11"]
# Output:
#   4
:set BigIntModInverse do={
    :global BigIntToArray
    :global ArrayToBigInt
    :global BigIntModInverseArr

    :return [$ArrayToBigInt [$BigIntModInverseArr [$BigIntToArray $1] [$BigIntToArray $2]]]
}
