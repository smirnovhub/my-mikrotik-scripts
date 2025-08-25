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
# Add to startup script:
# /system script run global_functions_encoding
#
# Sources and original authors:
# https://github.com/eworm-de/routeros-scripts.git
# https://github.com/osamahfarhan/mikrotik.git
# https://forum.mikrotik.com/
# and many others...
#
# global functions
:global Base64Encode;
:global Base64Decode;
:global UrlEncode;
:global UrlDecode;

# EXTERNAL DEPENDENCY
:global HexToNum;

# Purpose: Encode an input string into Base64 format according to RFC 4648 standards.
#          Supports optional URL-safe variant and optional padding removal.
# Parameters:
#   $1 - Input string to be encoded
#   $2 - Optional string containing "url" to use Base64 URL-safe alphabet
#   $3 - Optional string containing "nopad" to remove padding character '='
# Returns: Base64 encoded string
:set Base64Encode do={
    :local input   [:tostr "$1"]
    :local options "$2$3"

    # Prepare a character string for hex lookup (0x00 to 0xFF)
    :local charsString ""
    :for x from=0 to=15 step=1 do={ :for y from=0 to=15 step=1 do={
        :local tmpHex "$[:pick "0123456789ABCDEF" $x ($x+1)]$[:pick "0123456789ABCDEF" $y ($y+1)]"
        :set $charsString "$charsString$[[:parse "(\"\\$tmpHex\")"]]"
    } }

    # Function to convert a single character to its integer code
    :local chr2int do={:if (($1="") or ([:len $1] > 1) or ([:typeof $1] = "nothing")) do={:return -1}; :return [:find $2 $1 -1]}

    # RFC 4648 base64 Standard
    :local arrb64 [:toarray "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z\
                            ,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z\
                            ,0,1,2,3,4,5,6,7,8,9,+,/,="]
    # If "url" option is present, switch to Base64 URL-safe alphabet
    :if ($options~"url") do={
        # RFC 4648 base64url URL and filename-safe standard
        :set arrb64 [:toarray "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z\
                              ,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z\
                              ,0,1,2,3,4,5,6,7,8,9,-,_,="]
    }

    # If "nopad" option is present, remove the padding character '='
    :if ($options~"nopad") do={:set ($arrb64->64) ""}

    # Initialize variables for processing
    :local position 0
    :local output   "" ; :local work ""
    :local v1 "" ; :local v2 "" ; :local v3 "" ; :local f6bit 0 ; :local s6bit 0 ; :local t6bit 0 ; :local q6bit 0

    # Loop over input string in 3-byte chunks
    :while ($position < [:len $input]) do={
        # Extract up to 3 bytes from input
        :set work [:pick $input $position ($position + 3)]
        :set v1 [$chr2int [:pick $work 0 1] $charsString]
        :set v2 [$chr2int [:pick $work 1 2] $charsString]
        :set v3 [$chr2int [:pick $work 2 3] $charsString]

        # Convert three 8-bit bytes into four 6-bit Base64 values
        :set f6bit   ($v1 >> 2)
        :set s6bit ((($v1 &  3) * 16) + ($v2 >> 4))
        :set t6bit ((($v2 & 15) *  4) + ($v3 >> 6))
        :set q6bit   ($v3 & 63)

        # Handle padding for input less than 3 bytes
        :if ([:len $work] < 2) do={ :set t6bit 64}
        :if ([:len $work] < 3) do={ :set q6bit 64}

        # Append the Base64 characters to the output string
        :set output   "$output$($arrb64->$f6bit)$($arrb64->$s6bit)$($arrb64->$t6bit)$($arrb64->$q6bit)"
        
        # Move to next chunk of input
        :set position ($position + 3)
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
    :local input   [:tostr "$1"]
    :local options "$2$3$4"

    :local charsString ""
    :for x from=0 to=15 step=1 do={ :for y from=0 to=15 step=1 do={
        :local tmpHex "$[:pick "0123456789ABCDEF" $x ($x+1)]$[:pick "0123456789ABCDEF" $y ($y+1)]"
        :set $charsString "$charsString$[[:parse "(\"\\$tmpHex\")"]]"
    } }

    # RFC 4648 base64 Standard
    :local arrb64 [:toarray "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z\
                            ,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z\
                            ,0,1,2,3,4,5,6,7,8,9,+,/,="]
    :if ($options~"url") do={
        # RFC 4648 base64url URL and filename-safe standard
        :set arrb64 [:toarray "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z\
                              ,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z\
                              ,0,1,2,3,4,5,6,7,8,9,-,_,="]
    }

    :if ($options~"mustpad") do={
        :if (([:len $input] % 4) != 0) do={:error "Invalid length, must be padded with one or more ="}
    }

    :if ($options~"ignoreotherchr") do={
        :local position 0
        :local tmpchar   ""
        :local tmpstring ""
        :while ($position < [:len $input]) do={
            :set tmpchar [:pick $input $position ($position + 1)]
            :if ([:typeof [:find $arrb64 $tmpchar]] != "nil") do={:set tmpstring "$tmpstring$tmpchar"}
            :set position ($position + 1)
        }
        :set input $tmpstring
    }

    :local position 0
    :local output ""
    :local work ""
    :local v1 0
    :local v2 0
    :local v3 0
    :local v4 0
    :local fchr ""
    :local schr ""
    :local tchr ""

    :while ($position < [:len $input]) do={
        :set work [:pick $input $position ($position + 4)]
        :set v1 [:find $arrb64 [:pick $work 0 1]]
        :set v2 [:find $arrb64 [:pick $work 1 2]]
        :set v3 [:find $arrb64 [:pick $work 2 3]]
        :set v4 [:find $arrb64 [:pick $work 3 4]]
        :if (([:typeof $v1] = "nil") or ([:typeof $v2] = "nil") or ([:typeof $v3] = "nil") or ([:typeof $v4] = "nil")) do={
            :error "Unexpected character, invalid Base64 sequence"
        }
        :if ([:typeof [:pick $work 1 2]] = "nil") do={
            :if ($options~"ignoreotherchr") do={:set v2 64 ; :set v3 64 ; :set v4 64} else={:error "Required 2nd character is missing"}
        }
        :if (([:typeof [:pick $work 2 3]] = "nil") and (($v2 & 15) != 0)) do={
            :if ($options~"ignoreotherchr") do={:set v3 64 ; :set v4 64} else={:error "Required 3rd character is missing"}
        }
        :if (([:typeof [:pick $work 3 4]] = "nil") and (($v3 &  3) != 0)) do={
            :if ($options~"ignoreotherchr") do={:set v4 64} else={:error "Required 4th character is missing"}
        }
        :set fchr [:pick $charsString  (($v1 << 2)       + ($v2 >> 4))]
        :set schr [:pick $charsString ((($v2 & 15) << 4) + ($v3 >> 2))]
        :set tchr [:pick $charsString ((($v3 &  3) << 6) +  $v4     ) ]
        :if ($v4 = 64) do={:set tchr "" ; :set position [:len $input]}
        :if ($v3 = 64) do={:set schr "" ; :set position [:len $input]}
        :if ($v2 = 64) do={
            :set fchr "" ;
            :if ($options~"ignoreotherchr") do={
                :set position [:len $input]
            } else={
                :error "Unexpected padding character ="
            }
        }
        :set output   "$output$fchr$schr$tchr"
        :set position ($position + 4)
    }
    :return $output
}

# Purpose: Encode a string into URL-encoded format, replacing non-alphanumeric characters with %HH codes.
# Parameters:
#   $1 - Input string to be URL-encoded
# Returns: URL-encoded string with special characters replaced by their %HH representations
:set UrlEncode do={
    # Convert input to string to ensure proper type
    :local input [:tostr $1];

    # If input is empty, return an empty string immediately
    :if ([:len $input] = 0) do={
        :return "";
    }

    # Initialize the variable that will accumulate the encoded result
    :local encodedResult "";

    # Characters that need to be percent-encoded
    :local specialChars "\n\r !\"#\$%&'()*+,:;<=>\?@[\\]^`{|}~\80\81\82\83\84\85\86\87\88\89\8A\8B\8C\8D\8E\8F\90\91\92\93\94\95\96\97\98\99\9A\9B\9C\9D\9E\9F\A0\A1\A2\A3\A4\A5\A6\A7\A8\A9\AA\AB\AC\AD\AE\AF\B0\B1\B2\B3\B4\B5\B6\B7\B8\B9\BA\BB\BC\BD\BE\BF\C0\C1\C2\C3\C4\C5\C6\C7\C8\C9\CA\CB\CC\CD\CE\CF\D0\D1\D2\D3\D4\D5\D6\D7\D8\D9\DA\DB\DC\DD\DE\DF\E0\E1\E2\E3\E4\E5\E6\E7\E8\E9\EA\EB\EC\ED\EE\EF\F0\F1\F2\F3\F4\F5\F6\F7\F8\F9\FA\FB\FC\FD\FE\FF";

    # Corresponding URL-encoded replacements for each character in specialChars
    :local encodedSubs { "%0A"; "%0D"; "%20"; "%21"; "%22"; "%23"; "%24"; "%25"; "%26"; "%27";
                         "%28"; "%29"; "%2A"; "%2B"; "%2C"; "%3A"; "%3B"; "%3C"; "%3D"; "%3E";
                         "%3F"; "%40"; "%5B"; "%5C"; "%5D"; "%5E"; "%60"; "%7B"; "%7C"; "%7D";
                         "%7E"; "%80"; "%81"; "%82"; "%83"; "%84"; "%85"; "%86"; "%87"; "%88";
                         "%89"; "%8A"; "%8B"; "%8C"; "%8D"; "%8E"; "%8F"; "%90"; "%91"; "%92";
                         "%93"; "%94"; "%95"; "%96"; "%97"; "%98"; "%99"; "%9A"; "%9B"; "%9C";
                         "%9D"; "%9E"; "%9F"; "%A0"; "%A1"; "%A2"; "%A3"; "%A4"; "%A5"; "%A6";
                         "%A7"; "%A8"; "%A9"; "%AA"; "%AB"; "%AC"; "%AD"; "%AE"; "%AF"; "%B0";
                         "%B1"; "%B2"; "%B3"; "%B4"; "%B5"; "%B6"; "%B7"; "%B8"; "%B9"; "%BA";
                         "%BB"; "%BC"; "%BD"; "%BE"; "%BF"; "%C0"; "%C1"; "%C2"; "%C3"; "%C4";
                         "%C5"; "%C6"; "%C7"; "%C8"; "%C9"; "%CA"; "%CB"; "%CC"; "%CD"; "%CE";
                         "%CF"; "%D0"; "%D1"; "%D2"; "%D3"; "%D4"; "%D5"; "%D6"; "%D7"; "%D8";
                         "%D9"; "%DA"; "%DB"; "%DC"; "%DD"; "%DE"; "%DF"; "%E0"; "%E1"; "%E2";
                         "%E3"; "%E4"; "%E5"; "%E6"; "%E7"; "%E8"; "%E9"; "%EA"; "%EB"; "%EC";
                         "%ED"; "%EE"; "%EF"; "%F0"; "%F1"; "%F2"; "%F3"; "%F4"; "%F5"; "%F6";
                         "%F7"; "%F8"; "%F9"; "%FA"; "%FB"; "%FC"; "%FD"; "%FE"; "%FF" };

    # Loop over each character in the input string
    :for i from=0 to=([:len $input] - 1) do={

        # Get the current character
        :local currentChar [:pick $input $i];

        # Find the index of the character in the specialChars string
        :local index [:find $specialChars $currentChar];

        # If the character is found in specialChars, replace it with its encoded equivalent
        :if ([:typeof $index] = "num") do={
            :set currentChar ($encodedSubs->$index);
        }

        # Append the (possibly replaced) character to the result string
        :set encodedResult ($encodedResult . $currentChar);
    }

    # Return the fully URL-encoded string
    :return $encodedResult;
}

# Purpose: Decode a URL-encoded string, converting %HH hex codes back into their original characters.
# Parameters:
#   $1 - URL-encoded input string
# Returns: Decoded string with all %HH sequences replaced by their corresponding characters
:set UrlDecode do={

    # Global function to convert hex strings to numbers
    :global HexToNum

    # Array of all byte values as single-character strings (0x00 to 0xFF)
    :local symbolsHex {"\00";"\01";"\02";"\03";"\04";"\05";"\06";"\07";"\08";"\09";"\0A";"\0B";"\0C";"\0D";"\0E";"\0F";"\10";"\11";"\12";"\13";"\14";"\15";"\16";"\17";"\18";"\19";"\1A";"\1B";"\1C";"\1D";"\1E";"\1F";"\20";"\21";"\22";"\23";"\24";"\25";"\26";"\27";"\28";"\29";"\2A";"\2B";"\2C";"\2D";"\2E";"\2F";"\30";"\31";"\32";"\33";"\34";"\35";"\36";"\37";"\38";"\39";"\3A";"\3B";"\3C";"\3D";"\3E";"\3F";"\40";"\41";"\42";"\43";"\44";"\45";"\46";"\47";"\48";"\49";"\4A";"\4B";"\4C";"\4D";"\4E";"\4F";"\50";"\51";"\52";"\53";"\54";"\55";"\56";"\57";"\58";"\59";"\5A";"\5B";"\5C";"\5D";"\5E";"\5F";"\60";"\61";"\62";"\63";"\64";"\65";"\66";"\67";"\68";"\69";"\6A";"\6B";"\6C";"\6D";"\6E";"\6F";"\70";"\71";"\72";"\73";"\74";"\75";"\76";"\77";"\78";"\79";"\7A";"\7B";"\7C";"\7D";"\7E";"\7F";"\80";"\81";"\82";"\83";"\84";"\85";"\86";"\87";"\88";"\89";"\8A";"\8B";"\8C";"\8D";"\8E";"\8F";"\90";"\91";"\92";"\93";"\94";"\95";"\96";"\97";"\98";"\99";"\9A";"\9B";"\9C";"\9D";"\9E";"\9F";"\A0";"\A1";"\A2";"\A3";"\A4";"\A5";"\A6";"\A7";"\A8";"\A9";"\AA";"\AB";"\AC";"\AD";"\AE";"\AF";"\B0";"\B1";"\B2";"\B3";"\B4";"\B5";"\B6";"\B7";"\B8";"\B9";"\BA";"\BB";"\BC";"\BD";"\BE";"\BF";"\C0";"\C1";"\C2";"\C3";"\C4";"\C5";"\C6";"\C7";"\C8";"\C9";"\CA";"\CB";"\CC";"\CD";"\CE";"\CF";"\D0";"\D1";"\D2";"\D3";"\D4";"\D5";"\D6";"\D7";"\D8";"\D9";"\DA";"\DB";"\DC";"\DD";"\DE";"\DF";"\E0";"\E1";"\E2";"\E3";"\E4";"\E5";"\E6";"\E7";"\E8";"\E9";"\EA";"\EB";"\EC";"\ED";"\EE";"\EF";"\F0";"\F1";"\F2";"\F3";"\F4";"\F5";"\F6";"\F7";"\F8";"\F9";"\FA";"\FB";"\FC";"\FD";"\FE";"\FF"}

    # Convert input to string to ensure proper type
    :local inputString [:tostr $1];

    # Initialize the variable that will accumulate the decoded result
    :local decodedOutput "";

    # Initialize loop index
    :local index 0;

    # Loop over each character in the input string
    :while ($index < [:len $inputString]) do={

        # Get the current character
        :local currentChar [:pick $inputString $index ($index+1)];

        # If current character is "%", decode the following two hex digits
        :if ($currentChar = "%") do={

            # Extract the next two characters representing the hex value
            :local hexCode [:pick $inputString ($index+1) ($index+3)];

            # Convert hex string to numeric value using HexToNum function
            :local charNum [$HexToNum $hexCode];

            # Append the corresponding character from symbolsHex array to output
            :set decodedOutput ($decodedOutput . ($symbolsHex->$charNum));

            # Move index past the two hex digits
            :set index ($index + 2);

        } else={

            # Otherwise, append the character as-is
            :set decodedOutput ($decodedOutput . $currentChar);
        }

        # Move to the next character
        :set index ($index + 1);
    }

    # Return the fully decoded string
    :return $decodedOutput;
}
