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
:global BigIntIsZeroArr
:global BigIntIsOneArr
:global BigIntAddArr
:global BigIntSubArr
:global BigIntMulArr
:global BigIntModArr
:global BigIntDivArr
:global BigIntDiv2Arr
:global BigIntPowArr
:global BigIntPowModArr
:global BigIntGcdArr
:global BigIntModInverseArr
:global BigIntCleanArr

:global BigIntPowModMontArr
:global BigIntMontDecodeArr
:global BigIntMontEncodeArr
:global BigIntMontMulArr
:global BigIntMontInitArr
:global BigIntMontInvRadixArr

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
            :return (-$leftSign)
        }
    }

    :for chunkIndex from=($leftLen - 1) to=0 step=-1 do={
        :local leftChunk ($leftDigits->$chunkIndex)
        :local rightChunk ($rightDigits->$chunkIndex)

        :if ($leftChunk != $rightChunk) do={
            :if ($leftChunk > $rightChunk) do={
                :return $leftSign
            } else={
                :return (-$leftSign)
            }
        }
    }

    :return 0
}

# Purpose: Check if a BigInt chunked array object is equal to zero.
# Parameters:
#   $1 - BigInt object to check
# Returns: true if the value is 0, false otherwise
# Example: :put [$BigIntIsZeroArr ({"sign"=1; "data"=[:toarray 0]})]
# Output:
#   true
:set BigIntIsZeroArr do={
    :local digits ($1->"data")

    # Check if array is empty
    :if ([:len $digits] = 0) do={
        :return true
    }

    # Check if the only element is 0
    :if ([:len $digits] = 1 && ($digits->0) = 0) do={
        :return true
    }

    :return false
}

# Purpose: Check if a BigInt chunked array object is equal to one.
# Parameters:
#   $1 - BigInt object to check
# Returns: true if the value is 1, false otherwise
# Example: :put [$BigIntIsOneArr ({"sign"=1; "data"=[:toarray 1]})]
# Output:
#   true
:set BigIntIsOneArr do={
    :local numObj $1

    # Check if sign is positive
    :if (($numObj->"sign") != 1) do={
        :return false
    }

    # Check if data contains only 1
    :local digits ($numObj->"data")
    :if ([:len $digits] = 1 && ($digits->0) = 1) do={
        :return true
    }

    :return false
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
        :local invertedRight {"sign"=(-$rightSign); "data"=$rightDigits}
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
        :local invertedRight {"sign"=(-$rightSign); "data"=$rightDigits}
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
        :set resultSign (-$leftSign)
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

# Purpose: Multiply two BigInt chunked array objects using sequential convolution.
# Parameters:
#   $1 - Left BigInt object
#   $2 - Right BigInt object
# Returns: BigInt object containing the product
# Example: :put [$ArrayToBigInt [$BigIntMulArr [$BigIntToArray "25"] [$BigIntToArray "4"]]]
# Output:
#   100
:set BigIntMulArr do={
    :global BigIntIsZeroArr

    :local leftObj $1
    :local rightObj $2

    :if ([$BigIntIsZeroArr $leftObj] = true || [$BigIntIsZeroArr $rightObj] = true) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local leftDigits ($leftObj->"data")
    :local rightDigits ($rightObj->"data")
    :local leftLen [:len $leftDigits]
    :local rightLen [:len $rightDigits]
    
    :local prodDigits [:toarray ""]
    :local carry 0
    
    :for k from=0 to=($leftLen + $rightLen - 2) do={
        :local currentChunk $carry
        :set carry 0
        
        :local minI 0
        :if ($k >= $leftLen) do={
            :set minI ($k - $leftLen + 1)
        }
        
        :local maxI $k
        :if ($k >= $rightLen) do={
            :set maxI ($rightLen - 1)
        }
        
        :for i from=$minI to=$maxI do={
            :local prod (($rightDigits->$i) * ($leftDigits->($k - $i)))
            :set currentChunk ($currentChunk + ($prod % 1000000000))
            :set carry ($carry + ($prod / 1000000000))
        }
        
        :if ([:len $prodDigits] = 0) do={
            :set prodDigits [:toarray ($currentChunk % 1000000000)]
        } else={
            :set prodDigits ($prodDigits, ($currentChunk % 1000000000))
        }
        
        :set carry ($carry + ($currentChunk / 1000000000))
    }
    
    :if ($carry > 0) do={
        :set prodDigits ($prodDigits, $carry)
    }
    
    :local finalSign ($leftObj->"sign" * $rightObj->"sign")
    :return {"sign"=$finalSign; "data"=$prodDigits}
}

# Purpose: Calculate the remainder of division of two BigInt chunked array objects using Knuth Algorithm D.
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
    :global BigIntDivArr
    :global BigIntIsZeroArr

    :local numObj $1
    :local modObj $2
    :local numSign ($numObj->"sign")
    :local modSign ($modObj->"sign")
    :local numDigits ($numObj->"data")
    :local modDigits ($modObj->"data")

    # Fast return for division by zero
    :if ([$BigIntIsZeroArr $modObj] = true) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    # Zero dividend always produces zero remainder
    :if ([$BigIntIsZeroArr $numObj] = true) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local absNum {"sign"=1; "data"=$numDigits}
    :local absMod {"sign"=1; "data"=$modDigits}
    
    :local remainderDigits [:toarray 0]
    :local comparisonState [$BigIntCmpArr $absNum $absMod]
    
    # Fast path: dividend is smaller than divisor
    :if ($comparisonState = -1) do={
        :set remainderDigits $numDigits
    } else={
        # Fast path: dividend equals divisor
        :if ($comparisonState = 0) do={
            :return {"sign"=1; "data"=[:toarray 0]}
        } else={
            # Knuth Algorithm D Normalization phase
            :local modLen [:len $modDigits]
            :local modTop ($modDigits->($modLen - 1))
            :local normScale (1000000000 / ($modTop + 1))

            :local normNumObj $absNum
            :local normModObj $absMod

            :if ($normScale > 1) do={
                :local scaleObj {"sign"=1; "data"=[:toarray $normScale]}
                :set normNumObj [$BigIntMulArr $absNum $scaleObj]
                :set normModObj [$BigIntMulArr $absMod $scaleObj]
            }

            :local normNumData ($normNumObj->"data")
            :local normModData ($normModObj->"data")
            :local normModLen [:len $normModData]
            :local normModTop ($normModData->($normModLen - 1))

            :local numLen [:len $normNumData]

            # Main modulo evaluation loop
            :for chunkIndex from=($numLen - 1) to=0 step=-1 do={
                :local nextChunkValue ($normNumData->$chunkIndex)

                # Shift remainder using native flat array concatenation
                :if ([:len $remainderDigits] = 1 && ($remainderDigits->0) = 0) do={
                    :set remainderDigits [:toarray $nextChunkValue]
                } else={
                    :set remainderDigits ([:toarray $nextChunkValue], $remainderDigits)
                }

                :local remLen [:len $remainderDigits]
                :local qEst 0

                # Estimate quotient chunk
                :if ($remLen < $normModLen) do={
                    :set qEst 0
                } else={
                    :if ($remLen = $normModLen) do={
                        :set qEst (($remainderDigits->($remLen - 1)) / $normModTop)
                    } else={
                        # Combine top two remainder chunks in a 64-bit integer
                        :local remTopHigh ($remainderDigits->($remLen - 1))
                        :local remTopLow ($remainderDigits->($remLen - 2))
                        :local combined (($remTopHigh * 1000000000) + $remTopLow)
                        :set qEst ($combined / $normModTop)
                        
                        :if ($qEst > 999999999) do={
                            :set qEst 999999999
                        }
                    }
                }

                # Apply and adjust the estimated quotient
                :if ($qEst > 0) do={
                    :local qCorrect false
                    :local subtractionAmountObj {"sign"=1; "data"=[:toarray 0]}

                    :while (!$qCorrect && $qEst > 0) do={
                        :set subtractionAmountObj [$BigIntMulArr $normModObj ({"sign"=1; "data"=[:toarray $qEst]})]
                        :if ([$BigIntCmpArr $subtractionAmountObj ({"sign"=1; "data"=$remainderDigits})] = 1) do={
                            :set qEst ($qEst - 1)
                        } else={
                            :set qCorrect true
                        }
                    }

                    :if ($qEst > 0) do={
                        :local subtractionResult [$BigIntSubArr ({"sign"=1; "data"=$remainderDigits}) $subtractionAmountObj]
                        :set remainderDigits ($subtractionResult->"data")
                    }
                }
            }
            
            # Denormalization phase to restore true remainder scale
            :if ($normScale > 1) do={
                :local scaleObj {"sign"=1; "data"=[:toarray $normScale]}
                :local denormResult [$BigIntDivArr ({"sign"=1; "data"=$remainderDigits}) $scaleObj]
                :set remainderDigits ($denormResult->"data")
            }
        }
    }

    :local isZero ([:len $remainderDigits] = 1 && ($remainderDigits->0) = 0)
    :if ($isZero) do={
        :return {"sign"=1; "data"=$remainderDigits}
    }

    # Python floor-division remainder must have the divisor's sign
    :if ($numSign != $modSign) do={
        :local adjustedRemainder [$BigIntSubArr $absMod ({"sign"=1; "data"=$remainderDigits})]
        :set remainderDigits ($adjustedRemainder->"data")
    }

    :return {"sign"=$modSign; "data"=$remainderDigits}
}

# Purpose: Divide one BigInt chunked array object by another using Knuth Algorithm D.
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
    :global BigIntIsZeroArr

    :local numObj $1
    :local divObj $2

    :local numSign ($numObj->"sign")
    :local divSign ($divObj->"sign")
    :local numDigits ($numObj->"data")
    :local divDigits ($divObj->"data")

    # Fast return for division by zero
    :if ([$BigIntIsZeroArr $divObj] = true) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    # Zero dividend always produces zero
    :if ([$BigIntIsZeroArr $numObj] = true) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local finalSign 1
    :if ($numSign != $divSign) do={
        :set finalSign -1
    }

    :local absNum {"sign"=1; "data"=$numDigits}
    :local absDiv {"sign"=1; "data"=$divDigits}
    :local comparisonState [$BigIntCmpArr $absNum $absDiv]

    # Dividend is strictly less than divisor
    :if ($comparisonState = -1) do={
        :if ($finalSign = -1) do={
            :return {"sign"=-1; "data"=[:toarray 1]}
        }
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    # Dividend equals divisor
    :if ($comparisonState = 0) do={
        :return {"sign"=$finalSign; "data"=[:toarray 1]}
    }

    # Knuth Algorithm D Normalization phase
    # Scale numbers so the top chunk of divisor is >= 500000000
    :local divLen [:len $divDigits]
    :local divTop ($divDigits->($divLen - 1))
    :local normScale (1000000000 / ($divTop + 1))

    :local normNumObj $absNum
    :local normDivObj $absDiv

    :if ($normScale > 1) do={
        :local scaleObj {"sign"=1; "data"=[:toarray $normScale]}
        :set normNumObj [$BigIntMulArr $absNum $scaleObj]
        :set normDivObj [$BigIntMulArr $absDiv $scaleObj]
    }

    :local normNumData ($normNumObj->"data")
    :local normDivData ($normDivObj->"data")
    :local normDivLen [:len $normDivData]
    :local normDivTop ($normDivData->($normDivLen - 1))

    :local quotientDigits [:toarray ""]
    :local quotientStarted false
    :local remainderDigits [:toarray 0]
    :local numLen [:len $normNumData]

    # Main division loop
    :for chunkIndex from=($numLen - 1) to=0 step=-1 do={
        :local nextChunkValue ($normNumData->$chunkIndex)

        # Shift remainder using native flat array concatenation
        :if ([:len $remainderDigits] = 1 && ($remainderDigits->0) = 0) do={
            :set remainderDigits [:toarray $nextChunkValue]
        } else={
            :set remainderDigits ([:toarray $nextChunkValue], $remainderDigits)
        }

        :local remLen [:len $remainderDigits]
        :local qEst 0

        # Estimate quotient chunk
        :if ($remLen < $normDivLen) do={
            :set qEst 0
        } else={
            :if ($remLen = $normDivLen) do={
                :set qEst (($remainderDigits->($remLen - 1)) / $normDivTop)
            } else={
                # Combine top two remainder chunks in a 64-bit integer
                :local remTopHigh ($remainderDigits->($remLen - 1))
                :local remTopLow ($remainderDigits->($remLen - 2))
                :local combined (($remTopHigh * 1000000000) + $remTopLow)
                :set qEst ($combined / $normDivTop)
                
                :if ($qEst > 999999999) do={
                    :set qEst 999999999
                }
            }
        }

        # Apply and adjust the estimated quotient
        :if ($qEst > 0) do={
            :local qCorrect false
            :local subtractionAmountObj {"sign"=1; "data"=[:toarray 0]}

            # Due to normalization this while loop executes at most 2 times
            :while (!$qCorrect && $qEst > 0) do={
                :set subtractionAmountObj [$BigIntMulArr $normDivObj ({"sign"=1; "data"=[:toarray $qEst]})]
                :if ([$BigIntCmpArr $subtractionAmountObj ({"sign"=1; "data"=$remainderDigits})] = 1) do={
                    :set qEst ($qEst - 1)
                } else={
                    :set qCorrect true
                }
            }

            :if ($qEst > 0) do={
                :local subtractionResult [$BigIntSubArr ({"sign"=1; "data"=$remainderDigits}) $subtractionAmountObj]
                :set remainderDigits ($subtractionResult->"data")
            }
        }

        # Prepend to quotient array using native comma operator
        :if ($quotientStarted || $qEst > 0) do={
            :if (!$quotientStarted) do={
                :set quotientDigits [:toarray $qEst]
                :set quotientStarted true
            } else={
                :set quotientDigits ([:toarray $qEst], $quotientDigits)
            }
        }
    }

    # Handle fully zero result
    :if (!$quotientStarted) do={
        :set quotientDigits [:toarray 0]
    }

    # Floor division adjustment for negative quotients with non-zero remainder
    :if ($finalSign = -1 && !([:len $remainderDigits] = 1 && ($remainderDigits->0) = 0)) do={
        :local incrementedQuotient [$BigIntAddArr ({"sign"=1; "data"=$quotientDigits}) ({"sign"=1; "data"=[:toarray 1]})]
        :set quotientDigits ($incrementedQuotient->"data")
    }

    :return {"sign"=$finalSign; "data"=$quotientDigits}
}

# Purpose: Divide a BigInt chunked array object by 2.
# Parameters:
#    $1 - BigInt object to divide
# Returns: BigInt object containing the division result
# Example: :put [$ArrayToBigInt [$BigIntDiv2Arr [$BigIntToArray "10"]]]
# Output:
#    5
:set BigIntDiv2Arr do={
    :local res [:toarray ""]
    :local carry 0

    :for i from=([:len ($1->"data")] - 1) to=0 step=-1 do={
        :set res ([:toarray ((($carry * 1000000000) + (($1->"data")->$i)) >> 1)], $res)
        :set carry ((($carry * 1000000000) + (($1->"data")->$i)) % 2)
    }

    :while ([:len $res] > 1 && ($res->([:len $res] - 1)) = 0) do={
        :set res [:pick $res 0 ([:len $res] - 1)]
    }

    :if ([:len $res] = 0) do={
        :set res [:toarray 0]
    }

    :return {"sign"=($1->"sign"); "data"=$res}
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
    :global BigIntDiv2Arr
    :global BigIntIsZeroArr
    :global BigIntIsOneArr

    :local baseObj $1
    :local expObj $2
    :local expSign ($expObj->"sign")

    # Handle negative exponent case
    :if ($expSign = -1) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local zeroObj {"sign"=1; "data"=[:toarray 0]}
    :local oneObj {"sign"=1; "data"=[:toarray 1]}

    # Use optimized checks instead of comparing with full object
    :if ([$BigIntIsZeroArr $expObj] = true) do={
        :return $oneObj
    }

    :if ([$BigIntIsOneArr $expObj] = true) do={
        :return $baseObj
    }

    :if ([$BigIntIsZeroArr $baseObj] = true) do={
        :return $zeroObj
    }

    :if ([$BigIntIsOneArr $baseObj] = true) do={
        :return $oneObj
    }

    :local currentResult $oneObj
    :local activeBase $baseObj
    :local activeExp $expObj

    # Loop while activeExp is not zero
    :while ([$BigIntIsZeroArr $activeExp] = false) do={
        :local expDigits ($activeExp->"data")
        :local lowestExpChunk ($expDigits->0)

        # Check if exponent is odd
        :if (($lowestExpChunk % 2) != 0) do={
            :set currentResult [$BigIntMulArr $currentResult $activeBase]
        }

        :set activeExp [$BigIntDiv2Arr $activeExp]

        # If exponent is still not zero, square the base
        :if ([$BigIntIsZeroArr $activeExp] = false) do={
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
    :global BigIntDiv2Arr
    :global BigIntModArr
    :global BigIntCmpArr
    :global BigIntModInverseArr
    :global BigIntIsZeroArr
    :global BigIntIsOneArr
    :global BigIntPowModMontArr

    :local baseObj $1
    :local expObj $2
    :local modObj $3

    # Handle negative exponent using modular inverse
    :if (($expObj->"sign") = -1) do={
        :set baseObj [$BigIntModInverseArr $baseObj $modObj]
        :set expObj {"sign"=1; "data"=($expObj->"data")}
    }

    :local zeroObj {"sign"=1; "data"=[:toarray 0]}
    :local oneObj {"sign"=1; "data"=[:toarray 1]}

    # Modulo by 1 or 0 results in 0
    :if ([$BigIntIsOneArr $modObj] = true || [$BigIntIsZeroArr $modObj] = true) do={
        :return $zeroObj
    }

    # Any base to the power of 0 is 1
    :if ([$BigIntIsZeroArr $expObj] = true) do={
        :return $oneObj
    }

    # Use Montgomery multiplication when the modulus is coprime
    # with the Montgomery radix 1000000000.
    :local n0 (($modObj->"data")->0)
    :if (($n0 % 2) != 0 && ($n0 % 5) != 0) do={
        :return [$BigIntPowModMontArr $baseObj $expObj $modObj]
    }

    :local currentResult $oneObj
    :local activeBase [$BigIntModArr $baseObj $modObj]

    :while ([$BigIntIsZeroArr $expObj] = false) do={
        # If the lowest chunk is odd
        :if (((($expObj->"data")->0) % 2) != 0) do={
            :set currentResult [$BigIntModArr [$BigIntMulArr $currentResult $activeBase] $modObj]
        }

        :set expObj [$BigIntDiv2Arr $expObj]

        :if ([$BigIntIsZeroArr $expObj] = false) do={
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
    :global BigIntIsZeroArr

    :local aObj $1
    :local bObj $2

    :local zeroObj {"sign"=1; "data"=[:toarray 0]}

    # If both numbers are zero, return zero
    :if ([$BigIntIsZeroArr $aObj] = true && [$BigIntIsZeroArr $bObj] = true) do={
        :return $zeroObj
    }

    # Work with absolute values since GCD is positive
    :local absA {"sign"=1; "data"=($aObj->"data")}
    :local absB {"sign"=1; "data"=($bObj->"data")}

    # Euclidean algorithm loop
    :while ([$BigIntIsZeroArr $absB] = false) do={
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
    :global BigIntIsZeroArr
    :global BigIntIsOneArr

    :local aObj $1
    :local mObj $2

    :local zeroObj {"sign"=1; "data"=[:toarray 0]}
    :local oneObj {"sign"=1; "data"=[:toarray 1]}

    :local originalMSign ($mObj->"sign")
    :local absMObj {"sign"=1; "data"=($mObj->"data")}

    # Guard against absolute modulus less than or equal to one
    :if ([$BigIntIsZeroArr $absMObj] = true || [$BigIntIsOneArr $absMObj] = true) do={
        :return $zeroObj
    }

    :local tObj $zeroObj
    :local newTObj $oneObj
    :local rObj $absMObj
    :local newRObj [$BigIntModArr $aObj $absMObj]

    # Extended Euclidean Algorithm
    :while ([$BigIntIsZeroArr $newRObj] = false) do={
        :local quotient [$BigIntDivArr $rObj $newRObj]
        :local temp $newRObj

        :set newRObj [$BigIntSubArr $rObj [$BigIntMulArr $quotient $newRObj]]
        :set rObj $temp

        :set temp $newTObj
        :set newTObj [$BigIntSubArr $tObj [$BigIntMulArr $quotient $newTObj]]
        :set tObj $temp
    }

    # If r is not one, then greatest common divisor is not one and inverse does not exist
    :if ([$BigIntIsOneArr $rObj] = false) do={
        :return $zeroObj
    }

    # Make t positive if it is negative
    :if (($tObj->"sign") = -1) do={
        :set tObj [$BigIntAddArr $tObj $absMObj]
    }

    # Shift result to negative space if original modulus was negative
    :if ($originalMSign = -1 && [$BigIntIsZeroArr $tObj] = false) do={
        :set tObj [$BigIntSubArr $tObj $absMObj]
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
        :set arrLen ($arrLen - 1)
    }

    :if ($arrLen = 1 && ($arr->0) = 0) do={
        :return {"sign"=1; "data"=[:toarray 0]}
    }

    :local trimmed [:toarray ""]
    :for i from=0 to=($arrLen - 1) do={
        :set trimmed ($trimmed, ($arr->$i))
    }

    :return {"sign"=($1->"sign"); "data"=$trimmed}
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

# Purpose: Compute the negative modular inverse of the radix chunk for Montgomery arithmetic.
# Parameters:
#    $1 - Least significant chunk of the modulus array
# Returns: Integer representing -a^(-1) mod radix
# Example: :put [$BigIntMontInvRadixArr 17]
# Output:
#    294117647
:set BigIntMontInvRadixArr do={
    :local a $1

    # Compute -a^(-1) mod 1000000000.
    # Montgomery multiplication requires gcd(a, 1000000000) = 1.

    :local radix 1000000000

    :local oldR $a
    :local r $radix
    :local oldS 1
    :local s 0

    :while ($r != 0) do={
        :local q ($oldR / $r)

        :local tmpR $oldR
        :set oldR $r
        :set r ($tmpR - ($q * $r))

        :local tmpS $oldS
        :set oldS $s
        :set s ($tmpS - ($q * $s))
    }

    :if ($oldR != 1) do={
        :error "Montgomery radix is not coprime with modulus"
    }

    :local inv ($oldS % $radix)

    :if ($inv < 0) do={
        :set inv ($inv + $radix)
    }

    :return (($radix - $inv) % $radix)
}

# Purpose: Initialize the Montgomery context containing precomputed values for reduction and multiplication.
# Parameters:
#    $1 - Modulus BigInt object
# Returns: Array context containing mod, k, n0Inv, rMod, and r2 elements
:set BigIntMontInitArr do={
    :global BigIntModArr
    :global BigIntMulArr
    :global BigIntMontInvRadixArr

    :local k [:len ($1->"data")]
    :local rDigits [:toarray ""]
    :for i from=0 to=$k do={
        :if ($i = $k) do={
            :set rDigits ($rDigits, 1)
        } else={
            :set rDigits ($rDigits, 0)
        }
    }
    
    :local rModObj [$BigIntModArr ({"sign"=1; "data"=$rDigits}) $1]
    :return {
        "mod"=$1;
        "k"=$k;
        "n0Inv"=[$BigIntMontInvRadixArr (($1->"data")->0)];
        "rMod"=$rModObj;
        "r2"=[$BigIntModArr [$BigIntMulArr $rModObj $rModObj] $1]
    }
}

# Purpose: Multiply two BigInt chunked arrays in the Montgomery domain.
# Parameters:
#    $1 - Montgomery context object created by BigIntMontInitArr
#    $2 - First operand BigInt object
#    $3 - Second operand BigInt object
# Returns: BigInt object representing the Montgomery product result
:set BigIntMontMulArr do={
    :global BigIntCmpArr
    :global BigIntSubArr

    :local ctx $1
    :local k ($ctx->"k")
    :local n ($ctx->"mod"->"data")

    # Pad arrays to completely remove bounds checking inside hot loops
    :local a ($2->"data")
    :while ([:len $a] < $k) do={ :set a ($a, 0) }

    :local b ($3->"data")
    :while ([:len $b] < $k) do={ :set b ($b, 0) }

    # T array initialized with zeros
    :local t [:toarray ""]
    :for i from=0 to=($k + 1) do={ :set t ($t, 0) }

    :local k1 ($k - 1)
    :local n0Inv ($ctx->"n0Inv")

    # Coarsely Integrated Operand Scanning loop integration
    :for i from=0 to=$k1 do={
        :local carry 0
        :for j from=0 to=$k1 do={
            :set carry (($t->$j) + (($a->$i) * ($b->$j)) + $carry)
            :set ($t->$j) ($carry % 1000000000)
            :set carry ($carry / 1000000000)
        }
        :set carry (($t->$k) + $carry)
        :set ($t->$k) ($carry % 1000000000)
        :set ($t->($k + 1)) ($carry / 1000000000)

        :local m ((($t->0) * $n0Inv) % 1000000000)
        :set carry (($t->0) + ($m * ($n->0)))
        :set carry ($carry / 1000000000)

        # Added condition to prevent negative step inference and out-of-bounds access
        :if ($k1 >= 1) do={
            :for j from=1 to=$k1 do={
                :set carry (($t->$j) + ($m * ($n->$j)) + $carry)
                :set ($t->($j - 1)) ($carry % 1000000000)
                :set carry ($carry / 1000000000)
            }
        }

        :set carry (($t->$k) + $carry)
        :set ($t->($k - 1)) ($carry % 1000000000)
        :set ($t->$k) (($t->($k + 1)) + ($carry / 1000000000))
        :set ($t->($k + 1)) 0
    }

    # Clean leading zeros
    :while ([:len $t] > 1 && ($t->([:len $t] - 1)) = 0) do={
        :set t [:pick $t 0 ([:len $t] - 1)]
    }
    :local resultObj {"sign"=1; "data"=$t}

    :if ([$BigIntCmpArr $resultObj ($ctx->"mod")] >= 0) do={
        :set resultObj [$BigIntSubArr $resultObj ($ctx->"mod")]
    }
    :return $resultObj
}

# Purpose: Transform a standard BigInt value into the Montgomery domain representation.
# Parameters:
#    $1 - Montgomery context object
#    $2 - BigInt value object to encode
# Returns: BigInt object encoded in the Montgomery domain
:set BigIntMontEncodeArr do={
    :global BigIntMontMulArr

    :local ctx $1
    :local valueObj $2

    # x * R mod N = MontMul(x, R^2).
    :return [$BigIntMontMulArr $ctx $valueObj ($ctx->"r2")]
}

# Purpose: Transform a Montgomery domain value back to standard BigInt representation.
# Parameters:
#    $1 - Montgomery context object
#    $2 - BigInt value object to decode
# Returns: Decoded standard BigInt object
:set BigIntMontDecodeArr do={
    :global BigIntMontMulArr

    :local ctx $1
    :local valueObj $2

    # x * R^-1 mod N = MontMul(x, 1).
    :local oneObj {"sign"=1; "data"=[:toarray 1]}

    :return [$BigIntMontMulArr $ctx $valueObj $oneObj]
}

# Purpose: Perform modular exponentiation using the Montgomery ladder algorithm.
# Parameters:
#    $1 - Base BigInt object
#    $2 - Exponent BigInt object
#    $3 - Modulus BigInt object
# Returns: BigInt object containing the modular exponentiation result
:set BigIntPowModMontArr do={
    :global BigIntIsZeroArr
    :global BigIntIsOneArr
    :global BigIntModArr
    :global BigIntDiv2Arr
    :global BigIntMontInitArr
    :global BigIntMontMulArr
    :global BigIntMontEncodeArr
    :global BigIntMontDecodeArr
    :global BigIntModInverseArr
    :global BigIntSubArr

    :local baseObj $1
    :local expObj $2
    :local modObj $3

    :local zeroObj {"sign"=1; "data"=[:toarray 0]}
    :local oneObj {"sign"=1; "data"=[:toarray 1]}

    :if (($expObj->"sign") = -1) do={
        :set expObj {"sign"=1; "data"=($expObj->"data")}
    }

    # Modulo by 1 or 0 results in 0.
    :if ([$BigIntIsOneArr $modObj] = true || [$BigIntIsZeroArr $modObj] = true) do={
        :return $zeroObj
    }

    # Any base to the power of 0 is 1.
    :if ([$BigIntIsZeroArr $expObj] = true) do={
        :return $oneObj
    }
    :if ([$BigIntIsZeroArr $baseObj] = true) do={
        :return $zeroObj
    }

    :local absModObj {"sign"=1; "data"=($modObj->"data")}
    :local ctx [$BigIntMontInitArr $absModObj]
    
    :set baseObj [$BigIntModArr $baseObj $absModObj]
    :if (($expObj->"sign") = -1) do={
        :set baseObj [$BigIntModInverseArr $baseObj $modObj]
    }

    :local activeBase [$BigIntMontEncodeArr $ctx $baseObj]
    :local currentResult [$BigIntMontEncodeArr $ctx ({"sign"=1; "data"=[:toarray 1]})]

    :while ([$BigIntIsZeroArr $expObj] = false) do={
        :if (((($expObj->"data")->0) % 2) != 0) do={
            :set currentResult [$BigIntMontMulArr $ctx $currentResult $activeBase]
        }
        :set expObj [$BigIntDiv2Arr $expObj]
        :if ([$BigIntIsZeroArr $expObj] = false) do={
            :set activeBase [$BigIntMontMulArr $ctx $activeBase $activeBase]
        }
    }

    :local finalResult [$BigIntMontDecodeArr $ctx $currentResult]
    :if (($modObj->"sign") = -1 && !([$BigIntIsZeroArr $finalResult] = true)) do={
        :set finalResult [$BigIntSubArr $absModObj $finalResult]
        :set finalResult {"sign"=-1; "data"=($finalResult->"data")}
    }
    :return $finalResult
}
