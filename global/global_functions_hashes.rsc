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
# Add script named global_functions_hashes and then add call to startup script:
# /system script run global_functions_hashes
#
# global functions
:global GetMd5Sum
:global GetCrc32Sum

# Automatically generated ASCII code table
:global asciiCodeTable

# Standard CRC32 polynomial 0xEDB88320 lookup table
:global crc32Table
:set crc32Table {
    0x00000000; 0x77073096; 0xEE0E612C; 0x990951BA; 0x076DC419; 0x706AF48F; 0xE963A535; 0x9E6495A3;
    0x0EDB8832; 0x79DCB8A4; 0xE0D5E91E; 0x97D2D988; 0x09B64C2B; 0x7EB17CBD; 0xE7B82D07; 0x90BF1D91;
    0x1DB71064; 0x6AB020F2; 0xF3B97148; 0x84BE41DE; 0x1ADAD47D; 0x6DDDE4EB; 0xF4D4B551; 0x83D385C7;
    0x136C9856; 0x646BA8C0; 0xFD62F97A; 0x8A65C9EC; 0x14015C4F; 0x63066CD9; 0xFA0F3D63; 0x8D080DF5;
    0x3B6E20C8; 0x4C69105E; 0xD56041E4; 0xA2677172; 0x3C03E4D1; 0x4B04D447; 0xD20D85FD; 0xA50AB56B;
    0x35B5A8FA; 0x42B2986C; 0xDBBBC9D6; 0xACBCF940; 0x32D86CE3; 0x45DF5C75; 0xDCD60DCF; 0xABD13D59;
    0x26D930AC; 0x51DE003A; 0xC8D75180; 0xBFD06116; 0x21B4F4B5; 0x56B3C423; 0xCFBA9599; 0xB8BDA50F;
    0x2802B89E; 0x5F058808; 0xC60CD9B2; 0xB10BE924; 0x2F6F7C87; 0x58684C11; 0xC1611DAB; 0xB6662D3D;
    0x76DC4190; 0x01DB7106; 0x98D220BC; 0xEFD5102A; 0x71B18589; 0x06B6B51F; 0x9FBFE4A5; 0xE8B8D433;
    0x7807C9A2; 0x0F00F934; 0x9609A88E; 0xE10E9818; 0x7F6A0DBB; 0x086D3D2D; 0x91646C97; 0xE6635C01;
    0x6B6B51F4; 0x1C6C6162; 0x856530D8; 0xF262004E; 0x6C0695ED; 0x1B01A57B; 0x8208F4C1; 0xF50FC457;
    0x65B0D9C6; 0x12B7E950; 0x8BBEB8EA; 0xFCB9887C; 0x62DD1DDF; 0x15DA2D49; 0x8CD37CF3; 0xFBD44C65;
    0x4DB26158; 0x3AB551CE; 0xA3BC0074; 0xD4BB30E2; 0x4ADFA541; 0x3DD895D7; 0xA4D1C46D; 0xD3D6F4FB;
    0x4369E96A; 0x346ED9FC; 0xAD678846; 0xDA60B8D0; 0x44042D73; 0x33031DE5; 0xAA0A4C5F; 0xDD0D7CC9;
    0x5005713C; 0x270241AA; 0xBE0B1010; 0xC90C2086; 0x5768B525; 0x206F85B3; 0xB966D409; 0xCE61E49F;
    0x5EDEF90E; 0x29D9C998; 0xB0D09822; 0xC7D7A8B4; 0x59B33D17; 0x2EB40D81; 0xB7BD5C3B; 0xC0BA6CAD;
    0xEDB88320; 0x9ABFB3B6; 0x03B6E20C; 0x74B1D29A; 0xEAD54739; 0x9DD277AF; 0x04DB2615; 0x73DC1683;
    0xE3630B12; 0x94643B84; 0x0D6D6A3E; 0x7A6A5AA8; 0xE40ECF0B; 0x9309FF9D; 0x0A00AE27; 0x7D079EB1;
    0xF00F9344; 0x8708A3D2; 0x1E01F268; 0x6906C2FE; 0xF762575D; 0x806567CB; 0x196C3671; 0x6E6B06E7;
    0xFED41B76; 0x89D32BE0; 0x10DA7A5A; 0x67DD4ACC; 0xF9B9DF6F; 0x8EBEEFF9; 0x17B7BE43; 0x60B08ED5;
    0xD6D6A3E8; 0xA1D1937E; 0x38D8C2C4; 0x4FDFF252; 0xD1BB67F1; 0xA6BC5767; 0x3FB506DD; 0x48B2364B;
    0xD80D2BDA; 0xAF0A1B4C; 0x36034AF6; 0x41047A60; 0xDF60EFC3; 0xA867DF55; 0x316E8EEF; 0x4669BE79;
    0xCB61B38C; 0xBC66831A; 0x256FD2A0; 0x5268E236; 0xCC0C7795; 0xBB0B4703; 0x220216B9; 0x5505262F;
    0xC5BA3BBE; 0xB2BD0B28; 0x2BB45A92; 0x5CB36A04; 0xC2D7FFA7; 0xB5D0CF31; 0x2CD99E8B; 0x5BDEAE1D;
    0x9B64C2B0; 0xEC63F226; 0x756AA39C; 0x026D930A; 0x9C0906A9; 0xEB0E363F; 0x72076785; 0x05005713;
    0x95BF4A82; 0xE2B87A14; 0x7BB12BAE; 0x0CB61B38; 0x92D28E9B; 0xE5D5BE0D; 0x7CDCEFB7; 0x0BDBDF21;
    0x86D3D2D4; 0xF1D4E242; 0x68DDB3F8; 0x1FDA836E; 0x81BE16CD; 0xF6B9265B; 0x6FB077E1; 0x18B74777;
    0x88085AE6; 0xFF0F6A70; 0x66063BCA; 0x11010B5C; 0x8F659EFF; 0xF862AE69; 0x616BFFD3; 0x166CCF45;
    0xA00AE278; 0xD70DD2EE; 0x4E048354; 0x3903B3C2; 0xA7672661; 0xD06016F7; 0x4969474D; 0x3E6E77DB;
    0xAED16A4A; 0xD9D65ADC; 0x40DF0B66; 0x37D83BF0; 0xA9BCAE53; 0xDEBB9EC5; 0x47B2CF7F; 0x30B5FFE9;
    0xBDBDF21C; 0xCABAC28A; 0x53B39330; 0x24B4A3A6; 0xBAD03605; 0xCDD70693; 0x54DE5729; 0x23D967BF;
    0xB3667A2E; 0xC4614AB8; 0x5D681B02; 0x2A6F2B94; 0xB40BBE37; 0xC30C8EA1; 0x5A05DF1B; 0x2D02EF8D
}

# String message to MD5 Hash
# Creates a MD5 hash from a message string
# Version 1.00, 6/17/2012, Created by TealFrog
# Version 1.1 2/11/2016, Modified by FAMS
# Script tested and developed under MikroTik ROS 6.3 to 6.33
# 
#
# This software is identified as using and is based on the, "RSA Data Security, 
# Inc. MD5 Message-Digest Algorithm".  This program is a derived work from the RSA Data
# Security, Inc. MD5 Message-Digest Algorithm.
# See http://www.ietf.org/rfc/rfc1321.txt for further information.
#
# The author of this program makes no representations concerning either
# the merchantability of this software or the suitability of this
# software for any particular purpose or non-infringement.
# This program is provided "as is" without express or implied warranty of any kind.
# The author makes no representations or warranties of any kind as to the 
# completeness, accuracy, timeliness, availability, functionality and compliance
# with applicable laws. By using this software you accept the risk that the 
# information may be incomplete or inaccurate or may not meet your needs 
# and requirements. The author shall not be liable for any damages or 
# injury arising out of the use of this program. Use this program at your own risk. 
#
# MD5 has been shown to not be collision resistant, as such MD5 is not suitable 
# for certain applications involving security and/or cryptography, 
# see http://en.wikipedia.org/wiki/Md5 for additional information.
#
:set GetMd5Sum do={
  :global DecToChar
  :global asciiCodeTable
  :local strMessage $1

  # $strHexValues, Used to create hexadecimal output
  :local strHexValues "0123456789abcdef"
  # To have uppercase hexadecimal A-F use the next line instead of the above
  # :local strHexValues "0123456789ABCDEF"

  # No futher modification required beyond this point unless customizing script
  # Start by defining constant values

  # Initialize ASCII lookup table on first use
  :if ([:typeof $asciiCodeTable] = "nothing") do={
      :set asciiCodeTable [:toarray ""]

      :for i from=0 to=255 do={
          :set ($asciiCodeTable->[$DecToChar $i]) $i
      }
  }

  # k[i] = floor(abs(sin(i + 1))  4294967296) 
  # Or just use the following table $k[0..63]:
  :local k ( 0xD76AA478, 0xE8C7B756, 0x242070DB, 0xC1BDCEEE, \
            0xF57C0FAF, 0x4787C62A, 0xA8304613, 0xFD469501, \
            0x698098D8, 0x8B44F7AF, 0xFFFF5BB1, 0x895CD7BE, \
            0x6B901122, 0xFD987193, 0xA679438E, 0x49B40821, \
            0xF61E2562, 0xC040B340, 0x265E5A51, 0xE9B6C7AA, \
            0xD62F105D, 0x02441453, 0xD8A1E681, 0xE7D3FBC8, \
            0x21E1CDE6, 0xC33707D6, 0xF4D50D87, 0x455A14ED, \
            0xA9E3E905, 0xFCEFA3F8, 0x676F02D9, 0x8D2A4C8A, \
            0xFFFA3942, 0x8771F681, 0x6D9D6122, 0xFDE5380C, \
            0xA4BEEA44, 0x4BDECFA9, 0xF6BB4B60, 0xBEBFBC70, \
            0x289B7EC6, 0xEAA127FA, 0xD4EF3085, 0x04881D05, \
            0xD9D4D039, 0xE6DB99E5, 0x1FA27CF8, 0xC4AC5665, \
            0xF4292244, 0x432AFF97, 0xAB9423A7, 0xFC93A039, \
            0x655B59C3, 0x8F0CCC92, 0xFFEFF47D, 0x85845DD1, \
            0x6FA87E4F, 0xFE2CE6E0, 0xA3014314, 0x4E0811A1, \
            0xF7537E82, 0xBD3AF235, 0x2AD7D2BB, 0xEB86D391 )

  :local a 0x67452301
  :local b 0xEFCDAB89
  :local c 0x98BADCFE
  :local d 0x10325476

  :local AA 0x67452301
  :local BB 0xEFCDAB89
  :local CC 0x98BADCFE
  :local DD 0x10325476

  :local s1 ( 7, 12, 17, 22 )
  :local s2 ( 5, 9, 14, 20 )
  :local s3 ( 4, 11, 16, 23 )
  :local s4 ( 6, 10, 15, 21 )

  :local i 0
  :local j 0
  :local x 0
  :local S 0
  :local T 0
  :local lcv 0
  :local tmp1 0

  :local arrMd5State []
  :local arrWordArray []
  :local ch ""
  :local iByteCount 0
  :local iCharVal 3
  :local iDec 0
  :local iHexDigit 8
  :local iMd5State 0
  :local lBytePosition 0
  :local lMessageLength 0
  :local lNumberOfWords 0
  :local lShiftedVal 0
  :local lWordArray []
  :local lWordArrLen 0
  :local lWordCount 0
  :local sHex ""
  :local sMd5Hash ""
  :local sMd5Output ""
  :local iteration 0

  :set lMessageLength [:len $strMessage]

  # Number of 32-bit words.
  :set lNumberOfWords (((($lMessageLength + 8) / 64) + 1) * 16)

  # Build the initial array.
  #
  # This is intentionally done in one operation instead of repeatedly
  # prepending to a string.
  :set arrWordArray []

  :for i from=0 to=($lNumberOfWords - 1) do={
    :set arrWordArray ($arrWordArray, 0)
  }

  # Convert message to word array.
  #
  # IMPORTANT:
  # The original implementation uses a rotated value here:
  #
  #   (value << position) | (value >> (32 - position))
  #
  # Keep exactly the same behavior.

  :set iByteCount 0

  :while ($iByteCount < $lMessageLength) do={
    :set lWordCount ($iByteCount / 4)
    :set lBytePosition (($iByteCount % 4) * 8)

    :set ch [:pick $strMessage $iByteCount]

    # Get byte numeric value directly from global ASCII hash map
    :local iCharVal ($asciiCodeTable->$ch)

    :set lShiftedVal ( \
      (($iCharVal) << $lBytePosition) | \
      (($iCharVal) >> (32 - $lBytePosition)) \
    )

    :set lShiftedVal ([:tonum $lShiftedVal] + 0)

    :set lShiftedVal ( \
      (([:tonum [:pick $arrWordArray $lWordCount]] + 0) | \
       $lShiftedVal) & 0xFFFFFFFF \
    )

    # Replace only the required element.
    #
    # Constructing the complete array with:
    #   [ :pick left ], value, [ :pick right ]
    # was the major performance problem.
    #
    # RouterOS array element assignment is used only here.
    :set ($arrWordArray->$lWordCount) $lShiftedVal

    :set iByteCount ($iByteCount + 1)
  }

  # Add MD5 padding byte.
  :set lWordCount ($iByteCount / 4)
  :set lBytePosition (($iByteCount % 4) * 8)

  :set lShiftedVal ( \
    (0x80 << $lBytePosition) | \
    (0x80 >> (32 - $lBytePosition)) \
  )

  :set lShiftedVal ( \
    (([:tonum [:pick $arrWordArray $lWordCount]] + 0) | \
     ([:tonum $lShiftedVal] + 0)) & 0xFFFFFFFF \
  )

  :set ($arrWordArray->$lWordCount) $lShiftedVal

  # Append original message length in bits.
  :set ($arrWordArray->($lNumberOfWords - 2)) ( \
    ( \
      (([:tonum $lMessageLength] + 0) << 3) | \
      (([:tonum $lMessageLength] + 0) >> 29) \
    ) & 0xFFFFFFFF \
  )

  :set ($arrWordArray->($lNumberOfWords - 1)) ( \
    (([:tonum $lMessageLength] + 0) >> 29) & 0xFFFFFFFF \
  )

  :set lWordArray [:toarray $arrWordArray]
  :set lWordArrLen ([:len $lWordArray] - 1)

  ### Main Loop ###

  :set tmp1 0
  :set x 0
  :set T 0
  :set S 0
  :set i 0
  :set j 0
  :set iteration 0

  :for lcv from=0 to=$lWordArrLen step=16 do={
    :set AA [:tonum $a]
    :set BB [:tonum $b]
    :set CC [:tonum $c]
    :set DD [:tonum $d]

    :local chuckoffset ($iteration * 16)

    ### Round 1 ###

    :for i from=0 to=15 do={
      :set x ([:tonum [:pick $lWordArray (($i & 15) + $chuckoffset)]] + 0)
      :set T ([:tonum [:pick $k $i]] + 0)
      :set S ([:tonum [:pick $s1 ($i & 3)]] + 0)

      :set tmp1 ( \
        (($d ^ ($b & ($c ^ $d))) + $a + $T + $x) & 0xFFFFFFFF \
      )

      :set tmp1 ((($tmp1 << $S) | ($tmp1 >> (32 - $S))) & 0xFFFFFFFF)
      :set tmp1 (($tmp1 + $b) & 0xFFFFFFFF)
  # Rotate a,b,c,d params positions, e.g. d, a, b, c ... c, d, a, b ... b, c, d, a 
  # and a gets new value from tmp1
      :set a (([:tonum $d] + 0) & 0xFFFFFFFF)
      :set d (([:tonum $c] + 0) & 0xFFFFFFFF)
      :set c (([:tonum $b] + 0) & 0xFFFFFFFF)
      :set b (([:tonum $tmp1] + 0) & 0xFFFFFFFF)
    }

    ### Round 2 ###

    :set j 1

    :for i from=0 to=15 do={
      :set x ( \
        [:tonum [:pick $lWordArray \
          ((($j & 15) + $chuckoffset))]] + 0 \
      )

      :set T ([:tonum [:pick $k ($i + 16)]] + 0)
      :set S ([:tonum [:pick $s2 ($i & 3)]] + 0)

      :set tmp1 ( \
        (($c ^ ($d & ($b ^ $c))) + $a + $T + $x) & 0xFFFFFFFF \
      )

      :set tmp1 ((($tmp1 << $S) | ($tmp1 >> (32 - $S))) & 0xFFFFFFFF)
      :set tmp1 (($tmp1 + $b) & 0xFFFFFFFF)
  # Rotate a,b,c,d param positions, e.g. d, a, b, c ... c, d, a, b ... b, c, d, a
      :set a (([:tonum $d] + 0) & 0xFFFFFFFF)
      :set d (([:tonum $c] + 0) & 0xFFFFFFFF)
      :set c (([:tonum $b] + 0) & 0xFFFFFFFF)
      :set b (([:tonum $tmp1] + 0) & 0xFFFFFFFF)

      :set j ($j + 5)
    }

    ### Round 3 ###

    :set j 5

    :for i from=0 to=15 do={
      :set x ( \
        [:tonum [:pick $lWordArray \
          ((($j & 15) + $chuckoffset))]] + 0 \
      )

      :set T ([:tonum [:pick $k ($i + 32)]] + 0)
      :set S ([:tonum [:pick $s3 ($i & 3)]] + 0)

      :set tmp1 ( \
        (($b ^ $c ^ $d) + $a + $T + $x) & 0xFFFFFFFF \
      )

      :set tmp1 ((($tmp1 << $S) | ($tmp1 >> (32 - $S))) & 0xFFFFFFFF)
      :set tmp1 (($tmp1 + $b) & 0xFFFFFFFF)
  # Rotate a,b,c,d param positions, e.g. d, a, b, c ... c, d, a, b ... b, c, d, a
      :set a (([:tonum $d] + 0) & 0xFFFFFFFF)
      :set d (([:tonum $c] + 0) & 0xFFFFFFFF)
      :set c (([:tonum $b] + 0) & 0xFFFFFFFF)
      :set b (([:tonum $tmp1] + 0) & 0xFFFFFFFF)

      :set j ($j + 3)
    }

    ### Round 4 ###

    :set j 0

    :for i from=0 to=15 do={
      :set x ( \
        [:tonum [:pick $lWordArray \
          ((($j & 15) + $chuckoffset))]] + 0 \
      )

      :set T ([:tonum [:pick $k ($i + 48)]] + 0)
      :set S ([:tonum [:pick $s4 ($i & 3)]] + 0)

      :set tmp1 ( \
        ($c ^ ($b | (-1 * ($d + 1)))) & 0xFFFFFFFF \
      )

      :set tmp1 (($tmp1 + $a + $T + $x) & 0xFFFFFFFF)
      :set tmp1 ((($tmp1 << $S) | ($tmp1 >> (32 - $S))) & 0xFFFFFFFF)
      :set tmp1 (($tmp1 + $b) & 0xFFFFFFFF)

      :set a (([:tonum $d] + 0) & 0xFFFFFFFF)
      :set d (([:tonum $c] + 0) & 0xFFFFFFFF)
      :set c (([:tonum $b] + 0) & 0xFFFFFFFF)
      :set b (([:tonum $tmp1] + 0) & 0xFFFFFFFF)

      :set j ($j + 7)
    }

    :set a (($a + $AA) & 0xFFFFFFFF)
    :set b (($b + $BB) & 0xFFFFFFFF)
    :set c (($c + $CC) & 0xFFFFFFFF)
    :set d (($d + $DD) & 0xFFFFFFFF)

    :set iteration ($iteration + 1)
  }

  # Convert MD5 state to hexadecimal output.
  #
  # This section is kept equivalent to the original implementation.

  :set arrMd5State [:toarray "$a, $b, $c, $d"]
  :set sMd5Hash ""
  :set sMd5Output ""
  :set iDec 0
  :set iMd5State 0
  :set sHex ""

  :for i from=0 to=3 do={
    :set iMd5State [:pick $arrMd5State $i]

    :for j from=0 to=3 do={
      :set iMd5State ([:tonum $iMd5State] & 0xFFFFFFFF)

      :if ($j < 1) do={
        :set iDec ([:tonum $iMd5State] & 255)
      } else={
        :set iDec ( \
          ($iMd5State & 0x7FFFFFFE) / \
          (2 << (($j * 8) - 1)) \
        )

        :if (($iMd5State & 0x80000000) > 0) do={
          :set iDec ( \
            $iDec | \
            (0x40000000 / (2 << (($j * 8) - 2))) \
          )
        }

        :set iDec ($iDec & 0xFF)
      }

      :set sHex ""

      :for k from=0 to=(4 * ($iHexDigit - 1)) step=4 do={
        :set sHex ( \
          [:pick $strHexValues \
            (($iDec >> $k) & 0xF) \
            ((($iDec >> $k) & 0xF) + 1) \
          ] . $sHex \
        )
      }

      :set sHex [:tostr $sHex]
      :set sHex [:pick $sHex ([:len $sHex] - 2) [:len $sHex]]

      :set sMd5Output ($sMd5Output . $sHex)
    }
  }

  :return $sMd5Output
}

:set GetCrc32Sum do={
    :global DecToChar
    :global asciiCodeTable
    :global crc32Table

    # Initialize ASCII lookup table on first use
    :if ([:typeof $asciiCodeTable] = "nothing") do={
        :set asciiCodeTable [:toarray ""]

        :for i from=0 to=255 do={
            :set ($asciiCodeTable->[$DecToChar $i]) $i
        }
    }

    # Convert input to string to ensure proper type
    :local input [:tostr $1]

    # Return initial CRC32 for empty string
    :if ([:len $input] = 0) do={
        :return "00000000"
    }

    :local hexTable "0123456789abcdef"

    # Initial CRC value
    :local crc 0xFFFFFFFF

    # Loop through each character in the input string
    :for i from=0 to=([:len $input] - 1) do={
        # Get byte numeric value directly from global ASCII hash map
        :local byteVal ($asciiCodeTable->[:pick $input $i])

        # Calculate table index and update CRC value
        :local tableIndex (($crc ^ $byteVal) & 0xFF)
        :set crc (($crc >> 8) ^ ($crc32Table->$tableIndex))
    }

    # Final XOR value
    :set crc ($crc ^ 0xFFFFFFFF)

    # Format 8-character hex string output
    :local encodedResult ""
    :for byteIdx from=3 to=0 step=-1 do={
        :local bVal (($crc >> ($byteIdx * 8)) & 0xFF)
        :local h1 [:pick $hexTable (($bVal >> 4) & 0x0F) ((($bVal >> 4) & 0x0F) + 1)]
        :local h2 [:pick $hexTable ($bVal & 0x0F) (($bVal & 0x0F) + 1)]
        :set encodedResult ($encodedResult . $h1 . $h2)
    }

    :return $encodedResult
}
