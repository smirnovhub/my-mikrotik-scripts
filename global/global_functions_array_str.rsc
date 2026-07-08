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
# Add script named global_functions_array_str and then add call to startup script:
# /system script run global_functions_array_str
#
# Sources and original authors:
# https://github.com/eworm-de/routeros-scripts.git
# https://github.com/osamahfarhan/mikrotik.git
# https://forum.mikrotik.com/
# and many others...
#

# global functions
:global ParseKeyValueStore
:global GetRandom20CharHex
:global GetRandomNumber
:global HexToNum
:global MapArray
:global JoinArray
:global SplitStr
:global TrimStr
:global TrimStrLeft
:global TrimStrRight
:global ReplaceStr
:global RecursiveMergeSort
:global RecursiveMergeSortStr
:global ToUpperCase
:global ToLowerCase
:global HexToChar
:global DecToChar
:global CompareStr

# Automatically generated ASCII code table
:global AsciiCodeTable

# Purpose: Parse a list of key-value pairs (or standalone keys) into an associative array (map).
# Parameters:
#   $1 - Source data. Can be:
#          - An array of strings (e.g. {"name=router1";"ip=192.168.1.1";"enabled"})
#          - A string of space-separated key-value pairs (requires SplitStr function, delimiter defaults to " ")
#   $2 - (Optional) Delimiter to split a single string into tokens (default: space)
# Returns: An associative array where:
#            "key=value" → Result["key"] = "value"
#            "key"       → Result["key"] = true
# Notes:
#   - Requires a helper function SplitStr to split strings by a delimiter.
#   - Useful for parsing script arguments or configuration strings into structured data.
#   - Standalone keys are treated as flags (boolean true).
#   - Duplicate keys will overwrite previous values.
#
# Examples:
#   :global ParseKeyValueStore
#   :local result [$ParseKeyValueStore ("name=router", "ip=192.168.1.10", "enabled")]
#   :put ("Name    = " . ($result->"name"))    ; # Output: Name    = router
#   :put ("IP      = " . ($result->"ip"))      ; # Output: IP      = 192.168.1.10
#   :put ("Enabled = " . ($result->"enabled")) ; # Output: Enabled = true
#
#   :global ParseKeyValueStore
#   :local result [$ParseKeyValueStore "name=test router,ip=192.168.1.1,enabled=yes" ","]
#   :put ("Name    = " . ($result->"name"))    ; # Output: Name    = test router
#   :put ("IP      = " . ($result->"ip"))      ; # Output: IP      = 192.168.1.1
#   :put ("Enabled = " . ($result->"enabled")) ; # Output: Enabled = yes
#
#   :global ParseKeyValueStore
#   :local result [$ParseKeyValueStore "name=router ip=192.168.1.1 enabled=yes" " "]
#   :put ("Name    = " . ($result->"name"))    ; # Output: Name    = router
#   :put ("IP      = " . ($result->"ip"))      ; # Output: IP      = 192.168.1.1
#   :put ("Enabled = " . ($result->"enabled")) ; # Output: Enabled = yes
#
# Passing parameters to the script:
#   :global ParseKeyValueStore
#   :local args {$1;$2;$3;$4;$5;$6;$7}
#   :local result [$ParseKeyValueStore $args]
#   :put ("Host    = " . ($result->"host"))
#   :put ("IP      = " . ($result->"ip"))
#   :put ("Enabled = " . ($result->"enabled"))
# Call:
#   $RunScript script_name "host=Test Host" "ip=192.168.0.1" "enabled=yes"
# Output:
#   Host    = Test Host
#   IP      = 192.168.0.1
#   Enabled = yes
:set ParseKeyValueStore do={
  :global SplitStr
  :global TrimStr

  :local source $1
  :local delimiter " "

  :if ([:len $2] > 0) do={ :set delimiter $2 }

  :if ([:typeof $source] != "array") do={
    :set source [$SplitStr $1 $delimiter]
  }

  :local result [:toarray ""]
  :foreach src in=$source do={
    :local keyValue [$TrimStr $src " "]
    :local pos [:find $keyValue "="]
    :if ($pos >= 0) do={
      :local key [:pick $keyValue 0 $pos]
      :local val [:pick $keyValue ($pos + 1) [:len $keyValue]]

      :if ($val = "true") do={
          :set val true
      } else={
          :if ($val = "false") do={
              :set val false
          }
      }
      :set ($result->$key) $val
    } else={
      :set ($result->$keyValue) true
    }
  }

  :return $result
}


# Purpose: Generate a random 20-character hexadecimal string using RouterOS SCEP server OTP generation.
# Parameters: None
# Returns: A 20-character random hexadecimal string
# Notes:
#   - Uses the built-in RouterOS command `/certificate scep-server otp generate` with `minutes-valid=0` to produce a one-time password.
#   - Extracts the "password" field from the returned value.
#   - Can be used as a source of randomness for other scripts or functions requiring random hex strings.
:set GetRandom20CharHex do={
  :return ([/certificate scep-server otp generate minutes-valid=0 as-value]->"password")
}

# Purpose: Generate a pseudo-random number within a specified range using a pre-generated 20-character hex string.
# Parameters:
#   $1 - Optional maximum value for the random number (default is 4294967295)
# Returns: Pseudo-random number between 0 and Max-1
# Notes:
#   - Uses the global function GetRandom20CharHex to provide a random hexadecimal string.
#   - Converts the first hex digit of the string to a numeric value using HexToNum.
#   - Applies modulo operation with the specified Max to obtain the final random number.
#   - If no maximum is provided, defaults to 32-bit unsigned integer range (0 to 4294967295).
:set GetRandomNumber do={
  :global GetRandom20CharHex
  :global HexToNum

  :local max 4294967295
  :if ([:typeof $1] != "nothing") do={
    :set max ([:tonum $1] + 1)
  }

  :return ([$HexToNum [:pick [$GetRandom20CharHex] 0 15]] % $max)
}


# Purpose: Convert a hexadecimal string into its corresponding numeric value.
# Parameters:
#   $1 - Hexadecimal string (e.g. "1A", "ff")
# Returns: Numeric value corresponding to the input hex string (e.g. 26, 255)
:set HexToNum do={
    # Convert input to string in case it isn't already
    :local input [:tostr $1]

    # String containing all hexadecimal digits (both lowercase and uppercase)
    :local hex "0123456789abcdef0123456789ABCDEF"

    # Multiplier represents the current positional value in base-16 (1, 16, 256, ...)
    :local multiplier 1

    # Initialize result to 0; this will accumulate the numeric value
    :local result 0

    # Loop over each character in the input string from rightmost to leftmost
    :for i from=([:len $input] - 1) to=0 do={

        # Find the position of the current hex character in the hex string
        # Use modulo 16 to map both lowercase and uppercase letters correctly
        # Multiply by the positional multiplier and add to the result
        :set result ($result + (([:find $hex [:pick $input $i]] % 16) * $multiplier))

        # Update multiplier for next left character (multiply by 16)
        :set multiplier ($multiplier * 16)
    }

    # Return the final numeric value
    :return $result
}

# Purpose: Apply a transformation function to each element of an associative array (map)
#          and return a new associative array with the same keys but transformed values.
# Parameters:
#   $1 - Source associative array (map) containing key-value pairs to process
#   $2 - Transformation function to apply to each entry.
#        The function will be called with two named arguments:
#          - n = key of the current element
#          - v = value of the current element
# Returns: A new associative array where each key matches the original input,
#          but values are replaced with the result of the transformation function.
# Notes:
#   - This function implements the common "map" operation known in functional programming.
#   - The transformation function ($2) must accept arguments "n" and "v".
#   - The input array ($1) is not modified; a new array is created and returned.
# Examples:
#   :global MapArray
#   :local square do={
#       :return ($v * $v)
#   }
#
#   :local input1 {7; 5; 10}
#   :local input2 {a=4; b=7; c=15}
#
#   :local output1 [$MapArray $input1 $square]
#   :local output2 [$MapArray $input2 $square]
#
#   :put  ("input1  = " . [:tostr $input1])
#   :put  ("output1 = " . [:tostr $output1])
#   :put  ("input2  = " . [:tostr $input2])
#   :put  ("output2 = " . [:tostr $output2])
# Output:
#   input1  = 7;5;10
#   output1 = 49;25;100
#   input2  = a=4;b=7;c=15
#   output2 = a=16;b=49;c=225
:set MapArray do={
    :local result [:toarray ""]
    :foreach n,v in=$1 do={
        :set ($result->$n) [$2 n=$n v=$v]
    }
    :return $result
}

# Purpose: Concatenate all elements of an input array into a single string,
#          inserting a specified separator between each element.
# Parameters:
#   $1 - Array of strings to be joined
#   $2 - Separator string to insert between elements
# Returns: A single string with all elements joined by the separator
# Example: :put [$JoinArray (1,3,4,2,7,5) "+"]
# Output:
#   1+3+4+2+7+5
:set JoinArray do={
    # String to hold the joined result
    :local resultString

    # Loop over each element in the input array
    :foreach item in=$1 do={
        # Append current item and the separator to the result string
        :set resultString ($resultString.$item.$2)
    }

    # Remove the last appended separator and return the final string
    :return [:pick $resultString 0 ([:len $resultString]-[:len $2])]
}

# Purpose: Split a string into an array of substrings based on a specified delimiter.
# Parameters:
#   $1 - Input string to be split
#   $2 - Delimiter string to split by
#   $3 - Optional maximum number of parts to return
# Returns: Array of substrings resulting from the split
# Example: :put [$SplitStr "1+3+4+2+7+5" "+"]
# Output:
#   1;3;4;2;7;5
:set SplitStr do={
    # Array to hold the resulting split parts
    :local result

    # Length of the delimiter string
    :local delimiterLength [:len $2]

    # Start index for the next substring to extract
    :local substringStart 0

    # Loop counter initialized as negative delimiter length
    :local i (0-$delimiterLength)

    # Edge offset for handling empty delimiter case
    :local edgeOffset 0

    # If delimiter length is 0, set edgeOffset to 1 to avoid zero-length issues
    :if ($delimiterLength=0) do={
      :set edgeOffset 1
    }

    # Loop while delimiter is found in the string
    :while ([:set i [:find $1 $2 ($i+$delimiterLength-1+$edgeOffset)]; (any$i)]) do={
        # Append substring from 'substringStart' to found delimiter index 'i' to result
        :set result ($result, ([:pick $1 $substringStart $i]))

        # Move 'substringStart' to the character after the found delimiter
        :set substringStart ($i+$delimiterLength)

        # If the result array has reached the maximum number of parts ($3),
        # append the rest of the string and return
        :if ([:len $result]=$3) do={
          :return ($result, ([:pick $1 $substringStart [:len $1]]))
        }
    }

    # After the loop, append the remaining part of the string to the result array
    :return ($result, ([:pick $1 $substringStart [:len $1]]))
}

# Purpose: Remove all leading characters from a string that match any character in a given set.
# Parameters:
#   $1 - Input string to trim
#   $2 - Set of characters to remove from the left side
# Returns: The trimmed string with specified leading characters removed
# Example: :put [$TrimStrLeft "TrimmedString" "Trng"]
# Output:
#   immedString
:set TrimStrLeft do={
    :local s $1
    :local chars $2
    :local cont true

    :while (($cont = true) and ([:len $s] > 0)) do={
        :set cont false
        :local first [:pick $s 0 1]

        # check if first char is in trim set
        :for i from=0 to=([:len $chars] - 1) do={
            :local ch [:pick $chars $i ($i + 1)]
            :if ($ch = $first) do={
                :set s [:pick $s 1 [:len $s]]
                :set cont true
            }
        }
    }

    :return $s
}

# Purpose: Remove all trailing characters from a string that match any character in a given set.
# Parameters:
#   $1 - Input string to trim
#   $2 - Set of characters to remove from the right side
# Returns: The trimmed string with specified trailing characters removed
# Example: :put [$TrimStrRight "TrimmedString" "Trng"]
# Output:
#   TrimmedStri
:set TrimStrRight do={
    :local s $1
    :local chars $2
    :local cont true

    :while (($cont = true) and ([:len $s] > 0)) do={
        :set cont false
        :local last [:pick $s ([:len $s] - 1) [:len $s]]

        # check if last char is in trim set
        :for i from=0 to=([:len $chars] - 1) do={
            :local ch [:pick $chars $i ($i + 1)]
            :if ($ch = $last) do={
                :set s [:pick $s 0 ([:len $s] - 1)]
                :set cont true
            }
        }
    }

    :return $s
}

# Purpose: Remove all leading and trailing characters from a string
#          that match any character in a given set.
# Parameters:
#   $1 - Input string to trim
#   $2 - Set of characters to remove from both ends
# Returns: The trimmed string with specified leading and trailing characters removed
# Example: :put [$TrimStr "TrimmedString" "Trng"]
# Output:
#   immedStri
:set TrimStr do={
    :global TrimStrLeft
    :global TrimStrRight

    :local s $1

    # Trim left using TrimStrLeft
    :set s [$TrimStrLeft $s $2]

    # Trim right using TrimStrRight
    :set s [$TrimStrRight $s $2]

    :return $s
}

# Purpose: Replace all occurrences of a substring within a string with another substring.
# Parameters:
#   $1 - Original string
#   $2 - Substring to find and replace
#   $3 - Substring to replace with
# Returns: A new string with all occurrences replaced
# Example: :put [$ReplaceStr "StringToReplace" "e" "777"]
# Output:
#   StringToR777plac777
:set ReplaceStr do={
  :local string [:tostr $1]
  :local replaceFrom [:tostr $2]
  :local replaceWith [:tostr $3]
  :local result ""

  :if ($replaceFrom = "") do={
    :return $string
  }

  :while ([:typeof [:find $string $replaceFrom]] != "nil") do={
    :local pos [:find $string $replaceFrom]
    :set result ($result . [:pick $string 0 $pos] . $replaceWith)
    :set string [:pick $string ($pos + [:len $replaceFrom]) [:len $string]]
  }

  :return ($result . $string)
}


# Purpose: Perform a merge sort on a simple array of items that can be compared using '<'.
# Parameters:
#   $1 - Array to sort
# Returns: A new array containing the sorted elements
# NOTE: This only works if each array item can
# be compared using the '<' operator. It doesn't work for a strings!
# Example: :put [$RecursiveMergeSort (7,1,3,4,2,7,7,0,1)]
# Output:
#   0;1;1;2;3;4;7;7;7
:set RecursiveMergeSort do={
  :global RecursiveMergeSort

  :local out [:toarray $1]
  :local l [:len $out]
  :if ($l>1) do={
    # Split the list in two, recursively sort, then merge results

    # Pick split point index:
    :local s ($l/2)

    # Recursively sort each half-list:
    :local a [$RecursiveMergeSort [:pick $out 0 $s]]
    :local b [$RecursiveMergeSort [:pick $out $s $l]]

    # Merge results:
    :set out [:toarray ""]
    :set l [:len $b]
    :local s 0; # Use $s as index into array $b
    :foreach i in=$a do={
      :local j [:pick $b $s]
      :while ($s<$l && $j<$i) do={
        :set out ($out,$j)
        :set s ($s+1)
        :set j [:pick $b $s]
      }
      :set out ($out,$i)
    }
    :while ($s<$l) do={
      :set out ($out,[:pick $b $s])
      :set s ($s+1)
    }
  }
  :return $out
}

# Purpose: Sort an array of strings in ascending lexicographical order using the merge sort algorithm.
# Parameters:
#   $1 - Array of strings to sort
# Returns: A new array containing the sorted strings
# Example: :put [$RecursiveMergeSortStr ("banana","apple","cherry")]
# Output:
#   apple;banana;cherry
:set RecursiveMergeSortStr do={
  :global CompareStr
  :global RecursiveMergeSortStr

  :local out [:toarray $1]
  :local l [:len $out]
  :if ($l>1) do={
    # Split the list in two, recursively sort, then merge results

    # Pick split point index:
    :local s ($l/2)

    # Recursively sort each half-list:
    :local a [$RecursiveMergeSortStr [:pick $out 0 $s]]
    :local b [$RecursiveMergeSortStr [:pick $out $s $l]]

    # Merge results:
    :set out [:toarray ""]
    :set l [:len $b]
    :local s 0; # Use $s as index into array $b
    :foreach i in=$a do={
      :local j [:pick $b $s]
      :while (($s < $l) && ([$CompareStr $j $i] < 0)) do={
        :set out ($out,$j)
        :set s ($s+1)
        :set j [:pick $b $s]
      }
      :set out ($out,$i)
    }
    :while ($s<$l) do={
      :set out ($out,[:pick $b $s])
      :set s ($s+1)
    }
  }
  :return $out
}

# Purpose: Convert all lowercase letters in a string to uppercase.
# Parameters:
#   $1 - Input string
# Returns: A new string with all lowercase letters converted to uppercase
# Example: :put [$ToUpperCase "Convert All Lowercase Letters"]
# Output:
#   CONVERT ALL LOWERCASE LETTERS
:set ToUpperCase do={
    :local lower [:toarray "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"]
    :local upper [:toarray "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"]
    :local result

    :for idx from=0 to=([:len $1] - 1) do={ 
        :local char [:pick $1 $idx]
        :local match
        :for i from=0 to=([:len $lower] - 1) do={
            :set match ($lower->$i)
            :if ($char = $match) do={:set char ($upper->$i)}
        }
        :set result ($result.$char)
    }
    :return $result
}

# Purpose: Convert all uppercase letters in a string to lowercase.
# Parameters:
#   $1 - Input string
# Returns: A new string with all uppercase letters converted to lowercase
# Example: :put [$ToLowerCase "Convert All Lowercase Letters"]
# Output:
#   convert all lowercase letters
:set ToLowerCase do={
    :local lower [:toarray "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"]
    :local upper [:toarray "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"]
    :local result

    :for idx from=0 to=([:len $1] - 1) do={ 
        :local char [:pick $1 $idx]
        :local match
        :for i from=0 to=([:len $upper] - 1) do={
            :set match ($upper->$i)
            :if ($char = $match) do={:set char ($lower->$i)}
        }
        :set result ($result.$char)
    }
    :return $result
}

# Purpose: Convert a two-digit hexadecimal ASCII value to its corresponding character.
# Parameters:
#   $1 - Two-digit hexadecimal ASCII value (00-FF)
# Returns: The corresponding ASCII character
# Example: :put [$HexToChar "41"]
# Output:
#   A
:set HexToChar do={
    :return [[:parse "(\"\\$1\")"]]
}

# Purpose: Convert a decimal ASCII value to its corresponding character.
# Parameters:
#   $1 - Decimal ASCII value (0-255)
# Returns: The corresponding ASCII character
# Example: :put [$DecToChar 65]
# Output:
#   A
:set DecToChar do={
    :local input [:tonum $1]
    :local hexchars "0123456789ABCDEF"

    :local convert [:pick $hexchars (($input >> 4) & 0xF)]
    :set convert ($convert . [:pick $hexchars ($input & 0xF)])

    :return [[:parse "(\"\\$convert\")"]]
}

# Purpose: Compare two strings lexicographically using ASCII character codes.
# Parameters:
#   $1 - First input string
#   $2 - Second input string
# Returns:
#   -1 if the first string is less than the second string
#    0 if both strings are equal
#    1 if the first string is greater than the second string
# Example: :put [$CompareStr "apple" "banana"]
# Output:
#   -1
:set CompareStr do={
    :global AsciiCodeTable
    :global DecToChar

    # Initialize ASCII lookup table on first use
    :if ([:typeof $AsciiCodeTable] = "nothing") do={
        :set AsciiCodeTable [:toarray ""]

        :for i from=0 to=255 do={
            :set ($AsciiCodeTable->[$DecToChar $i]) $i
        }
    }

    :local s1 [:tostr $1]
    :local s2 [:tostr $2]

    :local l1 [:len $s1]
    :local l2 [:len $s2]

    :local minL $l1
    :if ($l2 < $minL) do={
        :set minL $l2
    }

    :for i from=0 to=($minL - 1) do={
        :local c1 ($AsciiCodeTable->[:pick $s1 $i])
        :local c2 ($AsciiCodeTable->[:pick $s2 $i])

        :if ($c1 < $c2) do={ :return -1 }
        :if ($c1 > $c2) do={ :return 1 }
    }

    :if ($l1 < $l2) do={ :return -1 }
    :if ($l1 > $l2) do={ :return 1 }

    :return 0
}
