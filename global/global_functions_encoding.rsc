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
# Add script named global_functions_encoding and then add call to startup script:
# /system script run global_functions_encoding
#
# Sources and original authors:
# https://github.com/eworm-de/routeros-scripts.git
# https://github.com/osamahfarhan/mikrotik.git
# https://forum.mikrotik.com/
# and many others...
#
# global functions
:global Base64Encode
:global Base64Decode
:global UrlEncode
:global UrlDecode

# EXTERNAL DEPENDENCY
:global DecToChar

# Automatically generated ASCII code table
:global asciiCodeTable
:if ([:len $asciiCodeTable] != 256) do={
    :set asciiCodeTable [:toarray ""]
    :for i from=0 to=255 do={
        :set ($asciiCodeTable->[$DecToChar $i]) $i
    }
}

# Automatically generated ASCII char table
:global asciiCharTable
:if ([:len $asciiCharTable] != 256) do={
    :set asciiCharTable [:toarray ""]
    :for i from=0 to=255 do={
        :set ($asciiCharTable->$i) [$DecToChar $i]
    }
}

# Purpose: Encode an input string into Base64 format according to RFC 4648 standards.
#          Supports optional URL-safe variant and optional padding removal.
# Parameters:
#   $1 - Input string to be encoded
#   $2 - Optional string containing "url" to use Base64 URL-safe alphabet
#   $3 - Optional string containing "nopad" to remove padding character '='
# Returns: Base64 encoded string
:set Base64Encode do={
    :global asciiCodeTable

    :local input [:tostr "$1"]
    :local options "$2$3"

    # RFC 4648 base64 Standard
    :local arrb64 { \
        "A";"B";"C";"D";"E";"F";"G";"H";"I";"J";"K";"L";"M";"N";"O";"P";"Q";"R";"S";"T";"U";"V";"W";"X";"Y";"Z"; \
        "a";"b";"c";"d";"e";"f";"g";"h";"i";"j";"k";"l";"m";"n";"o";"p";"q";"r";"s";"t";"u";"v";"w";"x";"y";"z"; \
        "0";"1";"2";"3";"4";"5";"6";"7";"8";"9";"+";"/";"=" \
    }

    # If "url" option is present, switch to Base64 URL-safe alphabet
    :if ($options~"url") do={
        :set ($arrb64->62) "-"
        :set ($arrb64->63) "_"
    }

    # If "nopad" option is present, remove the padding character '='
    :if ($options~"nopad") do={
        :set ($arrb64->64) ""
    }

    # Initialize variables for processing
    :local position 0
    :local output ""

    :local inputLen [:len $input]

    # Loop over input string in 3-byte chunks
    :while (($position + 3) <= $inputLen) do={
        # Extract single characters from input
        :local v1 ($asciiCodeTable->[:pick $input $position ($position + 1)])
        :local v2 ($asciiCodeTable->[:pick $input ($position + 1) ($position + 2)])
        :local v3 ($asciiCodeTable->[:pick $input ($position + 2) ($position + 3)])

        # Convert three 8-bit bytes into four 6-bit Base64 values
        :local f6bit   ($v1 >> 2)
        :local s6bit ((($v1 &  3) << 4) + ($v2 >> 4))
        :local t6bit ((($v2 & 15) << 2) + ($v3 >> 6))
        :local q6bit   ($v3 & 63)

        # Append the Base64 characters to output string
        :set output "$output$($arrb64->$f6bit)$($arrb64->$s6bit)$($arrb64->$t6bit)$($arrb64->$q6bit)"

        # Move to next chunk of input
        :set position ($position + 3)
    }

    # Handle remaining tail (1 or 2 bytes) outside the main loop
    :local remaining ($inputLen - $position)
    :if ($remaining > 0) do={
        :local v1 ($asciiCodeTable->[:pick $input $position ($position + 1)])
        :local v2 0
        :local v3 0

        :local t6bit 64
        :local q6bit 64

        :if ($remaining = 2) do={
            :set v2 ($asciiCodeTable->[:pick $input ($position + 1) ($position + 2)])
            :set t6bit ((($v2 & 15) << 2) + ($v3 >> 6))
        }

        :local f6bit ($v1 >> 2)
        :local s6bit ((($v1 & 3) << 4) + ($v2 >> 4))

        :set output "$output$($arrb64->$f6bit)$($arrb64->$s6bit)$($arrb64->$t6bit)$($arrb64->$q6bit)"
    }

    # Return the final Base64 encoded string
    :return $output
}

# Purpose: Decode a Base64-encoded string into its original representation,
#          supporting standard and URL-safe alphabets as defined by RFC 4648.
# Parameters:
#   $1 - Input Base64 string
#   $2 - (Optional) "url" flag to use Base64URL alphabet
#   $3 - (Optional) "mustpad" flag to enforce correct padding length
#   $4 - (Optional) "ignoreotherchr" flag to skip invalid characters
# Returns: Decoded plain string
:set Base64Decode do={
    :global asciiCharTable

    :local input [:tostr "$1"]
    :local options "$2$3$4"

    # RFC 4648 base64 Standard
    :local arrb64 { \
        "A";"B";"C";"D";"E";"F";"G";"H";"I";"J";"K";"L";"M";"N";"O";"P";"Q";"R";"S";"T";"U";"V";"W";"X";"Y";"Z"; \
        "a";"b";"c";"d";"e";"f";"g";"h";"i";"j";"k";"l";"m";"n";"o";"p";"q";"r";"s";"t";"u";"v";"w";"x";"y";"z"; \
        "0";"1";"2";"3";"4";"5";"6";"7";"8";"9";"+";"/";"=" \
    }

    # If "url" option is present, switch to Base64 URL-safe alphabet
    :if ($options~"url") do={
        :set ($arrb64->62) "-"
        :set ($arrb64->63) "_"
    }

    :local isIgnoreOtherChr ($options~"ignoreotherchr")

    :if ($options~"mustpad") do={
        :if (([:len $input] % 4) != 0) do={:error "Invalid length, must be padded with one or more ="}
    }

    :if ($isIgnoreOtherChr) do={
        :local position 0
        :local tmpchar   ""
        :local tmpstring ""
        :local inputLen  [:len $input]
        :while ($position < $inputLen) do={
            :set tmpchar [:pick $input $position ($position + 1)]
            :if ([:typeof [:find $arrb64 $tmpchar]] != "nil") do={:set tmpstring "$tmpstring$tmpchar"}
            :set position ($position + 1)
        }
        :set input $tmpstring
    }

    :local inputLen [:len $input]
    :local rem ($inputLen % 4)
    :local mainLen ($inputLen - $rem)

    :local position 0
    :local output ""

    # Process full 4-character Base64 blocks
    :while ($position < $mainLen) do={
        :local v1 [:find $arrb64 [:pick $input $position ($position + 1)]]
        :local v2 [:find $arrb64 [:pick $input ($position + 1) ($position + 2)]]
        :local v3 [:find $arrb64 [:pick $input ($position + 2) ($position + 3)]]
        :local v4 [:find $arrb64 [:pick $input ($position + 3) ($position + 4)]]

        :if (([:typeof $v1] = "nil") or ([:typeof $v2] = "nil") or ([:typeof $v3] = "nil") or ([:typeof $v4] = "nil")) do={
            :error "Unexpected character, invalid Base64 sequence"
        }

        :local fchr [:pick $asciiCharTable  (($v1 << 2)       + ($v2 >> 4))]
        :local schr [:pick $asciiCharTable ((($v2 & 15) << 4) + ($v3 >> 2))]
        :local tchr [:pick $asciiCharTable ((($v3 &  3) << 6) +  $v4     ) ]

        :if ($v4 = 64) do={
            :set tchr ""
            :set position $mainLen
        }

        :if ($v3 = 64) do={
            :set schr ""
            :set position $mainLen
        }

        :if ($v2 = 64) do={
            :set fchr ""
            :if ($isIgnoreOtherChr) do={
                :set position $mainLen
            } else={
                :error "Unexpected padding character ="
            }
        }

        :set output "$output$fchr$schr$tchr"
        :set position ($position + 4)
    }

    # Handle remaining tail characters for unpadded input
    :if ($rem > 0) do={
        :local v1 [:find $arrb64 [:pick $input $mainLen ($mainLen + 1)]]
        :local v2 64
        :local v3 64

        :if ([:typeof $v1] = "nil") do={
            :error "Unexpected character, invalid Base64 sequence"
        }

        :if ($rem >= 2) do={
            :set v2 [:find $arrb64 [:pick $input ($mainLen + 1) ($mainLen + 2)]]
            :if ([:typeof $v2] = "nil") do={
                :error "Unexpected character, invalid Base64 sequence"
            }
        }

        :if ($rem = 3) do={
            :set v3 [:find $arrb64 [:pick $input ($mainLen + 2) ($mainLen + 3)]]
            :if ([:typeof $v3] = "nil") do={
                :error "Unexpected character, invalid Base64 sequence"
            }
        }

        :if ($rem = 1) do={
            :if ($isIgnoreOtherChr) do={
                :set v2 64
                :set v3 64
            } else={
                :error "Required 2nd character is missing"
            }
        }

        :if (($rem = 2) and (($v2 & 15) != 0)) do={
            :if ($isIgnoreOtherChr) do={
                :set v3 64
            } else={
                :error "Required 3rd character is missing"
            }
        }

        :if (($rem = 3) and (($v3 & 3) != 0)) do={
            :if ($isIgnoreOtherChr) do={
                # Unused padding fallback for 3rd byte boundary
            } else={
                :error "Required 4th character is missing"
            }
        }

        :local fchr [:pick $charsString (($v1 << 2) + ($v2 >> 4))]
        :local schr [:pick $charsString ((($v2 & 15) << 4) + ($v3 >> 2))]

        :if ($v3 = 64) do={ :set schr "" }
        :if ($v2 = 64) do={ :set fchr "" }

        :set output "$output$fchr$schr"
    }

    :return $output
}

# Purpose: Encode a string into URL-encoded format, replacing non-alphanumeric characters with %HH codes.
# Parameters:
#   $1 - Input string to be URL-encoded
# Returns: URL-encoded string with special characters replaced by their %HH representations
# Example: :put [$UrlEncode "encoded! (string) [test]"]
# Output:
#   encoded%21%20%28string%29%20%5Btest%5D
:set UrlEncode do={
    # Convert input to string to ensure proper type
    :local input [:tostr $1]

    # If input is empty, return an empty string immediately
    :if ([:len $input] = 0) do={
        :return ""
    }

    # Initialize the variable that will accumulate the encoded result
    :local encodedResult ""

    # Characters that need to be percent-encoded
    :local specialChars "\00\01\02\03\04\05\06\07\08\t\n\0B\0C\r\0E\0F\10\11\12\13\14\15\16\17\18\19\1A\1B\1C\1D\1E\1F !\"#\$%&'()*+,:;<=>\?@[\\]^`{|}\7F\80\81\82\83\84\85\86\87\88\89\8A\8B\8C\8D\8E\8F\90\91\92\93\94\95\96\97\98\99\9A\9B\9C\9D\9E\9F\A0\A1\A2\A3\A4\A5\A6\A7\A8\A9\AA\AB\AC\AD\AE\AF\B0\B1\B2\B3\B4\B5\B6\B7\B8\B9\BA\BB\BC\BD\BE\BF\C0\C1\C2\C3\C4\C5\C6\C7\C8\C9\CA\CB\CC\CD\CE\CF\D0\D1\D2\D3\D4\D5\D6\D7\D8\D9\DA\DB\DC\DD\DE\DF\E0\E1\E2\E3\E4\E5\E6\E7\E8\E9\EA\EB\EC\ED\EE\EF\F0\F1\F2\F3\F4\F5\F6\F7\F8\F9\FA\FB\FC\FD\FE\FF";

    # Corresponding URL-encoded replacements for each character in specialChars
    :local encodedSubs {
        "%00"; "%01"; "%02"; "%03"; "%04"; "%05"; "%06"; "%07";
        "%08"; "%09"; "%0A"; "%0B"; "%0C"; "%0D"; "%0E"; "%0F";
        "%10"; "%11"; "%12"; "%13"; "%14"; "%15"; "%16"; "%17";
        "%18"; "%19"; "%1A"; "%1B"; "%1C"; "%1D"; "%1E"; "%1F";

        "%20"; "%21"; "%22"; "%23"; "%24"; "%25"; "%26"; "%27";
        "%28"; "%29"; "%2A"; "%2B"; "%2C"; "%3A"; "%3B"; "%3C";
        "%3D"; "%3E"; "%3F"; "%40"; "%5B"; "%5C"; "%5D"; "%5E";
        "%60"; "%7B"; "%7C"; "%7D"; "%7F";

        "%80"; "%81"; "%82"; "%83"; "%84"; "%85"; "%86"; "%87";
        "%88"; "%89"; "%8A"; "%8B"; "%8C"; "%8D"; "%8E"; "%8F";
        "%90"; "%91"; "%92"; "%93"; "%94"; "%95"; "%96"; "%97";
        "%98"; "%99"; "%9A"; "%9B"; "%9C"; "%9D"; "%9E"; "%9F";

        "%A0"; "%A1"; "%A2"; "%A3"; "%A4"; "%A5"; "%A6"; "%A7";
        "%A8"; "%A9"; "%AA"; "%AB"; "%AC"; "%AD"; "%AE"; "%AF";

        "%B0"; "%B1"; "%B2"; "%B3"; "%B4"; "%B5"; "%B6"; "%B7";
        "%B8"; "%B9"; "%BA"; "%BB"; "%BC"; "%BD"; "%BE"; "%BF";

        "%C0"; "%C1"; "%C2"; "%C3"; "%C4"; "%C5"; "%C6"; "%C7";
        "%C8"; "%C9"; "%CA"; "%CB"; "%CC"; "%CD"; "%CE"; "%CF";

        "%D0"; "%D1"; "%D2"; "%D3"; "%D4"; "%D5"; "%D6"; "%D7";
        "%D8"; "%D9"; "%DA"; "%DB"; "%DC"; "%DD"; "%DE"; "%DF";

        "%E0"; "%E1"; "%E2"; "%E3"; "%E4"; "%E5"; "%E6"; "%E7";
        "%E8"; "%E9"; "%EA"; "%EB"; "%EC"; "%ED"; "%EE"; "%EF";

        "%F0"; "%F1"; "%F2"; "%F3"; "%F4"; "%F5"; "%F6"; "%F7";
        "%F8"; "%F9"; "%FA"; "%FB"; "%FC"; "%FD"; "%FE"; "%FF"
    }

    :local inputLen ([:len $input] - 1)

    # Loop over each character in the input string
    :for i from=0 to=$inputLen do={

        # Get the current character
        :local currentChar [:pick $input $i]

        # Find the index of the character in the specialChars string
        :local index [:find $specialChars $currentChar]

        # If the character is found in specialChars, replace it with its encoded equivalent
        :if ([:typeof $index] = "num") do={
            :set currentChar ($encodedSubs->$index)
        }

        # Append the (possibly replaced) character to the result string
        :set encodedResult ($encodedResult . $currentChar)
    }

    # Return the fully URL-encoded string
    :return $encodedResult
}

# Purpose: Decode a URL-encoded string, converting %HH hex codes back into their original characters.
# Parameters:
#   $1 - URL-encoded input string
# Returns: Decoded string with all %HH sequences replaced by their corresponding characters
# Example: :put [$UrlDecode "decoded%21%20%28string%29%20%5Btest%5D"]
# Output:
#   decoded! (string) [test]
:set UrlDecode do={
    :global asciiCharTable

    # Convert input to string to ensure proper type
    :local inputString [:tostr $1]

    # Initialize the variable that will accumulate the decoded result
    :local decodedOutput ""

    # Initialize loop index
    :local index 0

    :local inputStringLen [:len $inputString]

    # Loop over each character in the input string
    :while ($index < $inputStringLen) do={
        # Get the current character
        :local currentChar [:pick $inputString $index ($index + 1)]

        # If current character is "%", decode the following two hex digits
        :if ($currentChar = "%") do={
            # Extract the next two characters representing the hex value
            :local hexCode [:pick $inputString ($index + 1) ($index + 3)]

            # Append the corresponding character from asciiCharTable array to output
            :set decodedOutput ($decodedOutput . ($asciiCharTable->([:tonum ("0x" . $hexCode)])))

            # Move index past the two hex digits
            :set index ($index + 3)
        } else={
            # Otherwise, append the character as-is
            :set decodedOutput ($decodedOutput . $currentChar)

            # Move to the next character
            :set index ($index + 1)
        }
    }

    # Return the fully decoded string
    :return $decodedOutput
}
