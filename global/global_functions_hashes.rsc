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
:global GetCrc32Sum
:global GetMd5Sum
:global GetSha1Sum
:global GetSha256Sum
:global GetSha512Sum

# EXTERNAL DEPENDENCY
:global DecToChar

# 256-entry byte-to-hex lookup table
:global hexByteTable
:if ([:len $hexByteTable] != 256) do={
    :set hexByteTable [:toarray ""]
    :local strHex "0123456789abcdef"
    :for i from=0 to=255 do={
        :local high [:pick $strHex ($i >> 4) (($i >> 4) + 1)]
        :local low [:pick $strHex ($i & 0xF) (($i & 0xF) + 1)]
        :set ($hexByteTable->$i) ($high . $low)
    }
}

# Automatically generated ASCII code table
:global asciiCodeTable
:if ([:len $asciiCodeTable] != 256) do={
    :set asciiCodeTable [:toarray ""]
    :for i from=0 to=255 do={
        :set ($asciiCodeTable->[$DecToChar $i]) $i
    }
}

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

# Purpose: Calculate the CRC32 checksum for a given string.
# Parameters:
#   $1 - String to calculate the checksum for
# Returns: CRC32 checksum as a string or number
# Example: :put [$GetCrc32Sum "Hello World"]
# Output:
#   4a17b156
:set GetCrc32Sum do={
    :global asciiCodeTable
    :global hexByteTable
    :global crc32Table

    # Convert input to string to ensure proper type
    :local input [:tostr $1]

    # Return initial CRC32 for empty string
    :if ([:len $input] = 0) do={
        :return "00000000"
    }

    # Initial CRC value
    :local crc 0xFFFFFFFF
    :local len ([:len $input] - 1)

    # Loop through each character in the input string
    :for i from=0 to=$len do={
        :set crc (($crc >> 8) ^ ($crc32Table->((($crc ^ ($asciiCodeTable->[:pick $input $i])) & 0xFF))))
    }

    # Final XOR value
    :set crc ($crc ^ 0xFFFFFFFF)

    # Format 8-character hex string output
    :return ( \
        ($hexByteTable->(($crc >> 24) & 0xFF)) . \
        ($hexByteTable->(($crc >> 16) & 0xFF)) . \
        ($hexByteTable->(($crc >> 8) & 0xFF)) . \
        ($hexByteTable->($crc & 0xFF)) \
    )
}

# Purpose: Calculate the MD5 hash checksum for a given string.
# Parameters:
#   $1 - String to calculate the hash for
# Returns: MD5 checksum as a hex string
# Example: :put [$GetMd5Sum "Hello World"]
# Output:
#   b10a8db164e0754105b7a99be72e3fe5
:set GetMd5Sum do={
  :global asciiCodeTable
  :global hexByteTable

  :local strMessage $1
  :local lMessageLength [:len $strMessage]

  # Fast return for empty string
  :if ($lMessageLength = 0) do={
    :return "d41d8cd98f00b204e9800998ecf8427e"
  }

  :local lWordArray [:toarray ""]

  # Pack message bytes into 32-bit words
  :local i 0
  :while (($i + 3) < $lMessageLength) do={
    :set ($lWordArray->($i >> 2)) ( \
      ($asciiCodeTable->[:pick $strMessage $i]) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 8) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 16) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 3)]) << 24) \
    )
    :set i ($i + 4)
  }

  # Pack remaining 1-3 bytes
  :local curVal 0

  :if ($i < $lMessageLength) do={
    :set curVal ($asciiCodeTable->[:pick $strMessage $i])
    :if (($i + 1) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 8))
    }
    :if (($i + 2) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 16))
    }
  }

  # Add padding byte 0x80
  :local padWIndex ($i >> 2)
  :local padBPos (($lMessageLength % 4) * 8)
  :set ($lWordArray->$padWIndex) ($curVal | (0x80 << $padBPos))

  # Fill missing middle words with 0 and place bit length
  :local lNumberOfWords (((($lMessageLength + 8) / 64) + 1) * 16)
  :for w from=($padWIndex + 1) to=($lNumberOfWords - 1) do={
    :set ($lWordArray->$w) 0
  }

  :local bitLen ($lMessageLength * 8)
  :set ($lWordArray->($lNumberOfWords - 2)) ($bitLen & 0xFFFFFFFF)
  :set ($lWordArray->($lNumberOfWords - 1)) (($bitLen >> 32) & 0xFFFFFFFF)

  ### Main Loop (Unrolled Rounds) ###

  :local a 0x67452301
  :local b 0xEFCDAB89
  :local c 0x98BADCFE
  :local d 0x10325476

  :local aa 0x67452301
  :local bb 0xEFCDAB89
  :local cc 0x98BADCFE
  :local dd 0x10325476

  :local tmp1 0

  :local lWordArrLen ([:len $lWordArray] - 1)

  :for lcv from=0 to=$lWordArrLen step=16 do={
    :set aa $a
    :set bb $b
    :set cc $c
    :set dd $d

    :local w0  ($lWordArray->$lcv)
    :local w1  ($lWordArray->($lcv + 1))
    :local w2  ($lWordArray->($lcv + 2))
    :local w3  ($lWordArray->($lcv + 3))
    :local w4  ($lWordArray->($lcv + 4))
    :local w5  ($lWordArray->($lcv + 5))
    :local w6  ($lWordArray->($lcv + 6))
    :local w7  ($lWordArray->($lcv + 7))
    :local w8  ($lWordArray->($lcv + 8))
    :local w9  ($lWordArray->($lcv + 9))
    :local w10 ($lWordArray->($lcv + 10))
    :local w11 ($lWordArray->($lcv + 11))
    :local w12 ($lWordArray->($lcv + 12))
    :local w13 ($lWordArray->($lcv + 13))
    :local w14 ($lWordArray->($lcv + 14))
    :local w15 ($lWordArray->($lcv + 15))

    ### Round 1 ###
    :set tmp1 ((($d ^ ($b & ($c ^ $d))) + $a + 0xD76AA478 + $w0) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 7)  | ($tmp1 >> 25))) & 0xFFFFFFFF)
    :set tmp1 ((($c ^ ($a & ($b ^ $c))) + $d + 0xE8C7B756 + $w1) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 12) | ($tmp1 >> 20))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($d & ($a ^ $b))) + $c + 0x242070DB + $w2) & 0xFFFFFFFF);  :set c (($d + (($tmp1 << 17) | ($tmp1 >> 15))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($c & ($d ^ $a))) + $b + 0xC1BDCEEE + $w3) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 22) | ($tmp1 >> 10))) & 0xFFFFFFFF)

    :set tmp1 ((($d ^ ($b & ($c ^ $d))) + $a + 0xF57C0FAF + $w4) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 7)  | ($tmp1 >> 25))) & 0xFFFFFFFF)
    :set tmp1 ((($c ^ ($a & ($b ^ $c))) + $d + 0x4787C62A + $w5) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 12) | ($tmp1 >> 20))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($d & ($a ^ $b))) + $c + 0xA8304613 + $w6) & 0xFFFFFFFF);  :set c (($d + (($tmp1 << 17) | ($tmp1 >> 15))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($c & ($d ^ $a))) + $b + 0xFD469501 + $w7) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 22) | ($tmp1 >> 10))) & 0xFFFFFFFF)

    :set tmp1 ((($d ^ ($b & ($c ^ $d))) + $a + 0x698098D8 + $w8) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 7)  | ($tmp1 >> 25))) & 0xFFFFFFFF)
    :set tmp1 ((($c ^ ($a & ($b ^ $c))) + $d + 0x8B44F7AF + $w9) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 12) | ($tmp1 >> 20))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($d & ($a ^ $b))) + $c + 0xFFFF5BB1 + $w10) & 0xFFFFFFFF); :set c (($d + (($tmp1 << 17) | ($tmp1 >> 15))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($c & ($d ^ $a))) + $b + 0x895CD7BE + $w11) & 0xFFFFFFFF); :set b (($c + (($tmp1 << 22) | ($tmp1 >> 10))) & 0xFFFFFFFF)

    :set tmp1 ((($d ^ ($b & ($c ^ $d))) + $a + 0x6B901122 + $w12) & 0xFFFFFFFF); :set a (($b + (($tmp1 << 7)  | ($tmp1 >> 25))) & 0xFFFFFFFF)
    :set tmp1 ((($c ^ ($a & ($b ^ $c))) + $d + 0xFD987193 + $w13) & 0xFFFFFFFF); :set d (($a + (($tmp1 << 12) | ($tmp1 >> 20))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($d & ($a ^ $b))) + $c + 0xA679438E + $w14) & 0xFFFFFFFF); :set c (($d + (($tmp1 << 17) | ($tmp1 >> 15))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($c & ($d ^ $a))) + $b + 0x49B40821 + $w15) & 0xFFFFFFFF); :set b (($c + (($tmp1 << 22) | ($tmp1 >> 10))) & 0xFFFFFFFF)

    ### Round 2 ###
    :set tmp1 ((($c ^ ($d & ($b ^ $c))) + $a + 0xF61E2562 + $w1) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 5)  | ($tmp1 >> 27))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($c & ($a ^ $b))) + $d + 0xC040B340 + $w6) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 9)  | ($tmp1 >> 23))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($b & ($d ^ $a))) + $c + 0x265E5A51 + $w11) & 0xFFFFFFFF); :set c (($d + (($tmp1 << 14) | ($tmp1 >> 18))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ ($a & ($c ^ $d))) + $b + 0xE9B6C7AA + $w0) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 20) | ($tmp1 >> 12))) & 0xFFFFFFFF)

    :set tmp1 ((($c ^ ($d & ($b ^ $c))) + $a + 0xD62F105D + $w5) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 5)  | ($tmp1 >> 27))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($c & ($a ^ $b))) + $d + 0x02441453 + $w10) & 0xFFFFFFFF); :set d (($a + (($tmp1 << 9)  | ($tmp1 >> 23))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($b & ($d ^ $a))) + $c + 0xD8A1E681 + $w15) & 0xFFFFFFFF); :set c (($d + (($tmp1 << 14) | ($tmp1 >> 18))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ ($a & ($c ^ $d))) + $b + 0xE7D3FBC8 + $w4) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 20) | ($tmp1 >> 12))) & 0xFFFFFFFF)

    :set tmp1 ((($c ^ ($d & ($b ^ $c))) + $a + 0x21E1CDE6 + $w9) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 5)  | ($tmp1 >> 27))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($c & ($a ^ $b))) + $d + 0xC33707D6 + $w14) & 0xFFFFFFFF); :set d (($a + (($tmp1 << 9)  | ($tmp1 >> 23))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($b & ($d ^ $a))) + $c + 0xF4D50D87 + $w3) & 0xFFFFFFFF);  :set c (($d + (($tmp1 << 14) | ($tmp1 >> 18))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ ($a & ($c ^ $d))) + $b + 0x455A14ED + $w8) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 20) | ($tmp1 >> 12))) & 0xFFFFFFFF)

    :set tmp1 ((($c ^ ($d & ($b ^ $c))) + $a + 0xA9E3E905 + $w13) & 0xFFFFFFFF); :set a (($b + (($tmp1 << 5)  | ($tmp1 >> 27))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($c & ($a ^ $b))) + $d + 0xFCEFA3F8 + $w2) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 9)  | ($tmp1 >> 23))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($b & ($d ^ $a))) + $c + 0x676F02D9 + $w7) & 0xFFFFFFFF);  :set c (($d + (($tmp1 << 14) | ($tmp1 >> 18))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ ($a & ($c ^ $d))) + $b + 0x8D2A4C8A + $w12) & 0xFFFFFFFF); :set b (($c + (($tmp1 << 20) | ($tmp1 >> 12))) & 0xFFFFFFFF)

    ### Round 3 ###
    :set tmp1 ((($b ^ $c ^ $d) + $a + 0xFFFA3942 + $w5) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 4)  | ($tmp1 >> 28))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ $b ^ $c) + $d + 0x8771F681 + $w8) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 11) | ($tmp1 >> 21))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ $a ^ $b) + $c + 0x6D9D6122 + $w11) & 0xFFFFFFFF); :set c (($d + (($tmp1 << 16) | ($tmp1 >> 16))) & 0xFFFFFFFF)
    :set tmp1 ((($c ^ $d ^ $a) + $b + 0xFDE5380C + $w14) & 0xFFFFFFFF); :set b (($c + (($tmp1 << 23) | ($tmp1 >> 9))) & 0xFFFFFFFF)

    :set tmp1 ((($b ^ $c ^ $d) + $a + 0xA4BEEA44 + $w1) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 4)  | ($tmp1 >> 28))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ $b ^ $c) + $d + 0x4BDECFA9 + $w4) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 11) | ($tmp1 >> 21))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ $a ^ $b) + $c + 0xF6BB4B60 + $w7) & 0xFFFFFFFF);  :set c (($d + (($tmp1 << 16) | ($tmp1 >> 16))) & 0xFFFFFFFF)
    :set tmp1 ((($c ^ $d ^ $a) + $b + 0xBEBFBC70 + $w10) & 0xFFFFFFFF); :set b (($c + (($tmp1 << 23) | ($tmp1 >> 9))) & 0xFFFFFFFF)

    :set tmp1 ((($b ^ $c ^ $d) + $a + 0x289B7EC6 + $w13) & 0xFFFFFFFF); :set a (($b + (($tmp1 << 4)  | ($tmp1 >> 28))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ $b ^ $c) + $d + 0xEAA127FA + $w0) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 11) | ($tmp1 >> 21))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ $a ^ $b) + $c + 0xD4EF3085 + $w3) & 0xFFFFFFFF);  :set c (($d + (($tmp1 << 16) | ($tmp1 >> 16))) & 0xFFFFFFFF)
    :set tmp1 ((($c ^ $d ^ $a) + $b + 0x04881D05 + $w6) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 23) | ($tmp1 >> 9))) & 0xFFFFFFFF)

    :set tmp1 ((($b ^ $c ^ $d) + $a + 0xD9D4D039 + $w9) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 4)  | ($tmp1 >> 28))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ $b ^ $c) + $d + 0xE6DB99E5 + $w12) & 0xFFFFFFFF); :set d (($a + (($tmp1 << 11) | ($tmp1 >> 21))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ $a ^ $b) + $c + 0x1FA27CF8 + $w15) & 0xFFFFFFFF); :set c (($d + (($tmp1 << 16) | ($tmp1 >> 16))) & 0xFFFFFFFF)
    :set tmp1 ((($c ^ $d ^ $a) + $b + 0xC4AC5665 + $w2) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 23) | ($tmp1 >> 9))) & 0xFFFFFFFF)

    ### Round 4 ###
    :set tmp1 ((($c ^ ($b | ($d ^ 0xFFFFFFFF))) + $a + 0xF4292244 + $w0) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 6)  | ($tmp1 >> 26))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($a | ($c ^ 0xFFFFFFFF))) + $d + 0x432AFF97 + $w7) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 10) | ($tmp1 >> 22))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($d | ($b ^ 0xFFFFFFFF))) + $c + 0xAB9423A7 + $w14) & 0xFFFFFFFF); :set c (($d + (($tmp1 << 15) | ($tmp1 >> 17))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ ($c | ($a ^ 0xFFFFFFFF))) + $b + 0xFC93A039 + $w5) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 21) | ($tmp1 >> 11))) & 0xFFFFFFFF)

    :set tmp1 ((($c ^ ($b | ($d ^ 0xFFFFFFFF))) + $a + 0x655B59C3 + $w12) & 0xFFFFFFFF); :set a (($b + (($tmp1 << 6)  | ($tmp1 >> 26))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($a | ($c ^ 0xFFFFFFFF))) + $d + 0x8F0CCC92 + $w3) & 0xFFFFFFFF);  :set d (($a + (($tmp1 << 10) | ($tmp1 >> 22))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($d | ($b ^ 0xFFFFFFFF))) + $c + 0xFFEFF47D + $w10) & 0xFFFFFFFF); :set c (($d + (($tmp1 << 15) | ($tmp1 >> 17))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ ($c | ($a ^ 0xFFFFFFFF))) + $b + 0x85845DD1 + $w1) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 21) | ($tmp1 >> 11))) & 0xFFFFFFFF)

    :set tmp1 ((($c ^ ($b | ($d ^ 0xFFFFFFFF))) + $a + 0x6FA87E4F + $w8) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 6)  | ($tmp1 >> 26))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($a | ($c ^ 0xFFFFFFFF))) + $d + 0xFE2CE6E0 + $w15) & 0xFFFFFFFF); :set d (($a + (($tmp1 << 10) | ($tmp1 >> 22))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($d | ($b ^ 0xFFFFFFFF))) + $c + 0xA3014314 + $w6) & 0xFFFFFFFF);  :set c (($d + (($tmp1 << 15) | ($tmp1 >> 17))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ ($c | ($a ^ 0xFFFFFFFF))) + $b + 0x4E0811A1 + $w13) & 0xFFFFFFFF); :set b (($c + (($tmp1 << 21) | ($tmp1 >> 11))) & 0xFFFFFFFF)

    :set tmp1 ((($c ^ ($b | ($d ^ 0xFFFFFFFF))) + $a + 0xF7537E82 + $w4) & 0xFFFFFFFF);  :set a (($b + (($tmp1 << 6)  | ($tmp1 >> 26))) & 0xFFFFFFFF)
    :set tmp1 ((($b ^ ($a | ($c ^ 0xFFFFFFFF))) + $d + 0xBD3AF235 + $w11) & 0xFFFFFFFF); :set d (($a + (($tmp1 << 10) | ($tmp1 >> 22))) & 0xFFFFFFFF)
    :set tmp1 ((($a ^ ($d | ($b ^ 0xFFFFFFFF))) + $c + 0x2AD7D2BB + $w2) & 0xFFFFFFFF);  :set c (($d + (($tmp1 << 15) | ($tmp1 >> 17))) & 0xFFFFFFFF)
    :set tmp1 ((($d ^ ($c | ($a ^ 0xFFFFFFFF))) + $b + 0xEB86D391 + $w9) & 0xFFFFFFFF);  :set b (($c + (($tmp1 << 21) | ($tmp1 >> 11))) & 0xFFFFFFFF)

    :set a (($a + $aa) & 0xFFFFFFFF)
    :set b (($b + $bb) & 0xFFFFFFFF)
    :set c (($c + $cc) & 0xFFFFFFFF)
    :set d (($d + $dd) & 0xFFFFFFFF)
  }

  # Direct conversion of MD5 state (a, b, c, d) to hex string using lookup table
  :return ( \
    ($hexByteTable->($a & 0xFF)) . ($hexByteTable->(($a >> 8) & 0xFF)) . ($hexByteTable->(($a >> 16) & 0xFF)) . ($hexByteTable->(($a >> 24) & 0xFF)) . \
    ($hexByteTable->($b & 0xFF)) . ($hexByteTable->(($b >> 8) & 0xFF)) . ($hexByteTable->(($b >> 16) & 0xFF)) . ($hexByteTable->(($b >> 24) & 0xFF)) . \
    ($hexByteTable->($c & 0xFF)) . ($hexByteTable->(($c >> 8) & 0xFF)) . ($hexByteTable->(($c >> 16) & 0xFF)) . ($hexByteTable->(($c >> 24) & 0xFF)) . \
    ($hexByteTable->($d & 0xFF)) . ($hexByteTable->(($d >> 8) & 0xFF)) . ($hexByteTable->(($d >> 16) & 0xFF)) . ($hexByteTable->(($d >> 24) & 0xFF)) \
  )
}

# Purpose: Calculate the SHA1 hash checksum for a given string.
# Parameters:
#   $1 - String to calculate the hash for
# Returns: SHA1 checksum as a hex string
# Example: :put [$GetSha1Sum "Hello World"]
# Output:
#   0a4d55a8d778e5022fab701977c5d840bbc486d0
:set GetSha1Sum do={
  :global asciiCodeTable
  :global hexByteTable

  :local strMessage $1
  :local lMessageLength [:len $strMessage]

  # Fast return for empty string
  :if ($lMessageLength = 0) do={
    :return "da39a3ee5e6b4b0d3255bfef95601890afd80709"
  }

  :local lWordArray [:toarray ""]

  # Pack message bytes into 32-bit words
  :local i 0
  :while (($i + 3) < $lMessageLength) do={
    :set ($lWordArray->($i >> 2)) ( \
      (($asciiCodeTable->[:pick $strMessage $i]) << 24) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 16) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 8) | \
      ($asciiCodeTable->[:pick $strMessage ($i + 3)]) \
    )
    :set i ($i + 4)
  }

  # Pack remaining bytes
  :local curVal 0

  :if ($i < $lMessageLength) do={
    :set curVal (($asciiCodeTable->[:pick $strMessage $i]) << 24)
    :if (($i + 1) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 16))
    }
    :if (($i + 2) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 8))
    }
  }

  # Add padding byte 0x80
  :local padWIndex ($i >> 2)
  :local padBPos ((3 - ($lMessageLength % 4)) * 8)
  :set ($lWordArray->$padWIndex) ($curVal | (0x80 << $padBPos))

  # Fill remaining words with 0 and append bit length
  :local lNumberOfWords (((($lMessageLength + 8) / 64) + 1) * 16)
  :for w from=($padWIndex + 1) to=($lNumberOfWords - 1) do={
    :set ($lWordArray->$w) 0
  }

  # High 32-bit length is 0 for RouterOS strings under 536MB
  :set ($lWordArray->($lNumberOfWords - 2)) 0
  :set ($lWordArray->($lNumberOfWords - 1)) (($lMessageLength * 8) & 0xFFFFFFFF)

  ### Initial Hash State ###

  :local h0 0x67452301
  :local h1 0xEFCDAB89
  :local h2 0x98BADCFE
  :local h3 0x10325476
  :local h4 0xC3D2E1F0

  :local lWordArrLen ([:len $lWordArray] - 1)

  :for lcv from=0 to=$lWordArrLen step=16 do={
    # Direct scalar assignments for block words (0..15)
    :local w0  ($lWordArray->($lcv + 0))
    :local w1  ($lWordArray->($lcv + 1))
    :local w2  ($lWordArray->($lcv + 2))
    :local w3  ($lWordArray->($lcv + 3))
    :local w4  ($lWordArray->($lcv + 4))
    :local w5  ($lWordArray->($lcv + 5))
    :local w6  ($lWordArray->($lcv + 6))
    :local w7  ($lWordArray->($lcv + 7))
    :local w8  ($lWordArray->($lcv + 8))
    :local w9  ($lWordArray->($lcv + 9))
    :local w10 ($lWordArray->($lcv + 10))
    :local w11 ($lWordArray->($lcv + 11))
    :local w12 ($lWordArray->($lcv + 12))
    :local w13 ($lWordArray->($lcv + 13))
    :local w14 ($lWordArray->($lcv + 14))
    :local w15 ($lWordArray->($lcv + 15))

    :local a $h0
    :local b $h1
    :local c $h2
    :local d $h3
    :local e $h4

    # Fully unrolled Round 1 (0 to 19)
    :set e (((($a << 5) | ($a >> 27)) + ($d ^ ($b & ($c ^ $d))) + $e + $w0 + 0x5A827999) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($c ^ ($a & ($b ^ $c))) + $d + $w1 + 0x5A827999) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($b ^ ($e & ($a ^ $b))) + $c + $w2 + 0x5A827999) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($a ^ ($d & ($e ^ $a))) + $b + $w3 + 0x5A827999) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($e ^ ($c & ($d ^ $e))) + $a + $w4 + 0x5A827999) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    :set e (((($a << 5) | ($a >> 27)) + ($d ^ ($b & ($c ^ $d))) + $e + $w5 + 0x5A827999) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($c ^ ($a & ($b ^ $c))) + $d + $w6 + 0x5A827999) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($b ^ ($e & ($a ^ $b))) + $c + $w7 + 0x5A827999) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($a ^ ($d & ($e ^ $a))) + $b + $w8 + 0x5A827999) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($e ^ ($c & ($d ^ $e))) + $a + $w9 + 0x5A827999) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    :set e (((($a << 5) | ($a >> 27)) + ($d ^ ($b & ($c ^ $d))) + $e + $w10 + 0x5A827999) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($c ^ ($a & ($b ^ $c))) + $d + $w11 + 0x5A827999) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($b ^ ($e & ($a ^ $b))) + $c + $w12 + 0x5A827999) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($a ^ ($d & ($e ^ $a))) + $b + $w13 + 0x5A827999) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($e ^ ($c & ($d ^ $e))) + $a + $w14 + 0x5A827999) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    :set e (((($a << 5) | ($a >> 27)) + ($d ^ ($b & ($c ^ $d))) + $e + $w15 + 0x5A827999) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w16 overwrites w0
    :set w0 (((($w13 ^ $w8 ^ $w2 ^ $w0) << 1) | ((($w13 ^ $w8 ^ $w2 ^ $w0) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($c ^ ($a & ($b ^ $c))) + $d + $w0 + 0x5A827999) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w17 overwrites w1
    :set w1 (((($w14 ^ $w9 ^ $w3 ^ $w1) << 1) | ((($w14 ^ $w9 ^ $w3 ^ $w1) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($b ^ ($e & ($a ^ $b))) + $c + $w1 + 0x5A827999) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w18 overwrites w2
    :set w2 (((($w15 ^ $w10 ^ $w4 ^ $w2) << 1) | ((($w15 ^ $w10 ^ $w4 ^ $w2) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($a ^ ($d & ($e ^ $a))) + $b + $w2 + 0x5A827999) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w19 overwrites w3
    :set w3 (((($w0 ^ $w11 ^ $w5 ^ $w3) << 1) | ((($w0 ^ $w11 ^ $w5 ^ $w3) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($e ^ ($c & ($d ^ $e))) + $a + $w3 + 0x5A827999) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # Fully unrolled Round 2 (20 to 39)
    # w20 overwrites w4
    :set w4 (((($w1 ^ $w12 ^ $w6 ^ $w4) << 1) | ((($w1 ^ $w12 ^ $w6 ^ $w4) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + ($b ^ $c ^ $d) + $e + $w4 + 0x6ED9EBA1) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w21 overwrites w5
    :set w5 (((($w2 ^ $w13 ^ $w7 ^ $w5) << 1) | ((($w2 ^ $w13 ^ $w7 ^ $w5) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($a ^ $b ^ $c) + $d + $w5 + 0x6ED9EBA1) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w22 overwrites w6
    :set w6 (((($w3 ^ $w14 ^ $w8 ^ $w6) << 1) | ((($w3 ^ $w14 ^ $w8 ^ $w6) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($e ^ $a ^ $b) + $c + $w6 + 0x6ED9EBA1) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w23 overwrites w7
    :set w7 (((($w4 ^ $w15 ^ $w9 ^ $w7) << 1) | ((($w4 ^ $w15 ^ $w9 ^ $w7) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($d ^ $e ^ $a) + $b + $w7 + 0x6ED9EBA1) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w24 overwrites w8
    :set w8 (((($w5 ^ $w0 ^ $w10 ^ $w8) << 1) | ((($w5 ^ $w0 ^ $w10 ^ $w8) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($c ^ $d ^ $e) + $a + $w8 + 0x6ED9EBA1) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # w25 overwrites w9
    :set w9 (((($w6 ^ $w1 ^ $w11 ^ $w9) << 1) | ((($w6 ^ $w1 ^ $w11 ^ $w9) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + ($b ^ $c ^ $d) + $e + $w9 + 0x6ED9EBA1) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w26 overwrites w10
    :set w10 (((($w7 ^ $w2 ^ $w12 ^ $w10) << 1) | ((($w7 ^ $w2 ^ $w12 ^ $w10) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($a ^ $b ^ $c) + $d + $w10 + 0x6ED9EBA1) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w27 overwrites w11
    :set w11 (((($w8 ^ $w3 ^ $w13 ^ $w11) << 1) | ((($w8 ^ $w3 ^ $w13 ^ $w11) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($e ^ $a ^ $b) + $c + $w11 + 0x6ED9EBA1) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w28 overwrites w12
    :set w12 (((($w9 ^ $w4 ^ $w14 ^ $w12) << 1) | ((($w9 ^ $w4 ^ $w14 ^ $w12) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($d ^ $e ^ $a) + $b + $w12 + 0x6ED9EBA1) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w29 overwrites w13
    :set w13 (((($w10 ^ $w5 ^ $w15 ^ $w13) << 1) | ((($w10 ^ $w5 ^ $w15 ^ $w13) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($c ^ $d ^ $e) + $a + $w13 + 0x6ED9EBA1) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # w30 overwrites w14
    :set w14 (((($w11 ^ $w6 ^ $w0 ^ $w14) << 1) | ((($w11 ^ $w6 ^ $w0 ^ $w14) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + ($b ^ $c ^ $d) + $e + $w14 + 0x6ED9EBA1) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w31 overwrites w15
    :set w15 (((($w12 ^ $w7 ^ $w1 ^ $w15) << 1) | ((($w12 ^ $w7 ^ $w1 ^ $w15) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($a ^ $b ^ $c) + $d + $w15 + 0x6ED9EBA1) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w32 overwrites w0
    :set w0 (((($w13 ^ $w8 ^ $w2 ^ $w0) << 1) | ((($w13 ^ $w8 ^ $w2 ^ $w0) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($e ^ $a ^ $b) + $c + $w0 + 0x6ED9EBA1) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w33 overwrites w1
    :set w1 (((($w14 ^ $w9 ^ $w3 ^ $w1) << 1) | ((($w14 ^ $w9 ^ $w3 ^ $w1) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($d ^ $e ^ $a) + $b + $w1 + 0x6ED9EBA1) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w34 overwrites w2
    :set w2 (((($w15 ^ $w10 ^ $w4 ^ $w2) << 1) | ((($w15 ^ $w10 ^ $w4 ^ $w2) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($c ^ $d ^ $e) + $a + $w2 + 0x6ED9EBA1) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # w35 overwrites w3
    :set w3 (((($w0 ^ $w11 ^ $w5 ^ $w3) << 1) | ((($w0 ^ $w11 ^ $w5 ^ $w3) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + ($b ^ $c ^ $d) + $e + $w3 + 0x6ED9EBA1) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w36 overwrites w4
    :set w4 (((($w1 ^ $w12 ^ $w6 ^ $w4) << 1) | ((($w1 ^ $w12 ^ $w6 ^ $w4) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($a ^ $b ^ $c) + $d + $w4 + 0x6ED9EBA1) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w37 overwrites w5
    :set w5 (((($w2 ^ $w13 ^ $w7 ^ $w5) << 1) | ((($w2 ^ $w13 ^ $w7 ^ $w5) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($e ^ $a ^ $b) + $c + $w5 + 0x6ED9EBA1) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w38 overwrites w6
    :set w6 (((($w3 ^ $w14 ^ $w8 ^ $w6) << 1) | ((($w3 ^ $w14 ^ $w8 ^ $w6) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($d ^ $e ^ $a) + $b + $w6 + 0x6ED9EBA1) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w39 overwrites w7
    :set w7 (((($w4 ^ $w15 ^ $w9 ^ $w7) << 1) | ((($w4 ^ $w15 ^ $w9 ^ $w7) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($c ^ $d ^ $e) + $a + $w7 + 0x6ED9EBA1) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # Fully unrolled Round 3 (40 to 59)
    # w40 overwrites w8
    :set w8 (((($w5 ^ $w0 ^ $w10 ^ $w8) << 1) | ((($w5 ^ $w0 ^ $w10 ^ $w8) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + (($b & $c) | ($d & ($b ^ $c))) + $e + $w8 + 0x8F1BBCDC) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w41 overwrites w9
    :set w9 (((($w6 ^ $w1 ^ $w11 ^ $w9) << 1) | ((($w6 ^ $w1 ^ $w11 ^ $w9) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + (($a & $b) | ($c & ($a ^ $b))) + $d + $w9 + 0x8F1BBCDC) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w42 overwrites w10
    :set w10 (((($w7 ^ $w2 ^ $w12 ^ $w10) << 1) | ((($w7 ^ $w2 ^ $w12 ^ $w10) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + (($e & $a) | ($b & ($e ^ $a))) + $c + $w10 + 0x8F1BBCDC) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w43 overwrites w11
    :set w11 (((($w8 ^ $w3 ^ $w13 ^ $w11) << 1) | ((($w8 ^ $w3 ^ $w13 ^ $w11) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + (($d & $e) | ($a & ($d ^ $e))) + $b + $w11 + 0x8F1BBCDC) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w44 overwrites w12
    :set w12 (((($w9 ^ $w4 ^ $w14 ^ $w12) << 1) | ((($w9 ^ $w4 ^ $w14 ^ $w12) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + (($c & $d) | ($e & ($c ^ $d))) + $a + $w12 + 0x8F1BBCDC) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # w45 overwrites w13
    :set w13 (((($w10 ^ $w5 ^ $w15 ^ $w13) << 1) | ((($w10 ^ $w5 ^ $w15 ^ $w13) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + (($b & $c) | ($d & ($b ^ $c))) + $e + $w13 + 0x8F1BBCDC) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w46 overwrites w14
    :set w14 (((($w11 ^ $w6 ^ $w0 ^ $w14) << 1) | ((($w11 ^ $w6 ^ $w0 ^ $w14) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + (($a & $b) | ($c & ($a ^ $b))) + $d + $w14 + 0x8F1BBCDC) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w47 overwrites w15
    :set w15 (((($w12 ^ $w7 ^ $w1 ^ $w15) << 1) | ((($w12 ^ $w7 ^ $w1 ^ $w15) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + (($e & $a) | ($b & ($e ^ $a))) + $c + $w15 + 0x8F1BBCDC) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w48 overwrites w0
    :set w0 (((($w13 ^ $w8 ^ $w2 ^ $w0) << 1) | ((($w13 ^ $w8 ^ $w2 ^ $w0) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + (($d & $e) | ($a & ($d ^ $e))) + $b + $w0 + 0x8F1BBCDC) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w49 overwrites w1
    :set w1 (((($w14 ^ $w9 ^ $w3 ^ $w1) << 1) | ((($w14 ^ $w9 ^ $w3 ^ $w1) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + (($c & $d) | ($e & ($c ^ $d))) + $a + $w1 + 0x8F1BBCDC) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # w50 overwrites w2
    :set w2 (((($w15 ^ $w10 ^ $w4 ^ $w2) << 1) | ((($w15 ^ $w10 ^ $w4 ^ $w2) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + (($b & $c) | ($d & ($b ^ $c))) + $e + $w2 + 0x8F1BBCDC) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w51 overwrites w3
    :set w3 (((($w0 ^ $w11 ^ $w5 ^ $w3) << 1) | ((($w0 ^ $w11 ^ $w5 ^ $w3) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + (($a & $b) | ($c & ($a ^ $b))) + $d + $w3 + 0x8F1BBCDC) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w52 overwrites w4
    :set w4 (((($w1 ^ $w12 ^ $w6 ^ $w4) << 1) | ((($w1 ^ $w12 ^ $w6 ^ $w4) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + (($e & $a) | ($b & ($e ^ $a))) + $c + $w4 + 0x8F1BBCDC) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w53 overwrites w5
    :set w5 (((($w2 ^ $w13 ^ $w7 ^ $w5) << 1) | ((($w2 ^ $w13 ^ $w7 ^ $w5) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + (($d & $e) | ($a & ($d ^ $e))) + $b + $w5 + 0x8F1BBCDC) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w54 overwrites w6
    :set w6 (((($w3 ^ $w14 ^ $w8 ^ $w6) << 1) | ((($w3 ^ $w14 ^ $w8 ^ $w6) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + (($c & $d) | ($e & ($c ^ $d))) + $a + $w6 + 0x8F1BBCDC) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # w55 overwrites w7
    :set w7 (((($w4 ^ $w15 ^ $w9 ^ $w7) << 1) | ((($w4 ^ $w15 ^ $w9 ^ $w7) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + (($b & $c) | ($d & ($b ^ $c))) + $e + $w7 + 0x8F1BBCDC) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w56 overwrites w8
    :set w8 (((($w5 ^ $w0 ^ $w10 ^ $w8) << 1) | ((($w5 ^ $w0 ^ $w10 ^ $w8) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + (($a & $b) | ($c & ($a ^ $b))) + $d + $w8 + 0x8F1BBCDC) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w57 overwrites w9
    :set w9 (((($w6 ^ $w1 ^ $w11 ^ $w9) << 1) | ((($w6 ^ $w1 ^ $w11 ^ $w9) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + (($e & $a) | ($b & ($e ^ $a))) + $c + $w9 + 0x8F1BBCDC) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w58 overwrites w10
    :set w10 (((($w7 ^ $w2 ^ $w12 ^ $w10) << 1) | ((($w7 ^ $w2 ^ $w12 ^ $w10) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + (($d & $e) | ($a & ($d ^ $e))) + $b + $w10 + 0x8F1BBCDC) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w59 overwrites w11
    :set w11 (((($w8 ^ $w3 ^ $w13 ^ $w11) << 1) | ((($w8 ^ $w3 ^ $w13 ^ $w11) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + (($c & $d) | ($e & ($c ^ $d))) + $a + $w11 + 0x8F1BBCDC) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # Fully unrolled Round 4 (60 to 79)
    # w60 overwrites w12
    :set w12 (((($w9 ^ $w4 ^ $w14 ^ $w12) << 1) | ((($w9 ^ $w4 ^ $w14 ^ $w12) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + ($b ^ $c ^ $d) + $e + $w12 + 0xCA62C1D6) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w61 overwrites w13
    :set w13 (((($w10 ^ $w5 ^ $w15 ^ $w13) << 1) | ((($w10 ^ $w5 ^ $w15 ^ $w13) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($a ^ $b ^ $c) + $d + $w13 + 0xCA62C1D6) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w62 overwrites w14
    :set w14 (((($w11 ^ $w6 ^ $w0 ^ $w14) << 1) | ((($w11 ^ $w6 ^ $w0 ^ $w14) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($e ^ $a ^ $b) + $c + $w14 + 0xCA62C1D6) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w63 overwrites w15
    :set w15 (((($w12 ^ $w7 ^ $w1 ^ $w15) << 1) | ((($w12 ^ $w7 ^ $w1 ^ $w15) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($d ^ $e ^ $a) + $b + $w15 + 0xCA62C1D6) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w64 overwrites w0
    :set w0 (((($w13 ^ $w8 ^ $w2 ^ $w0) << 1) | ((($w13 ^ $w8 ^ $w2 ^ $w0) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($c ^ $d ^ $e) + $a + $w0 + 0xCA62C1D6) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # w65 overwrites w1
    :set w1 (((($w14 ^ $w9 ^ $w3 ^ $w1) << 1) | ((($w14 ^ $w9 ^ $w3 ^ $w1) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + ($b ^ $c ^ $d) + $e + $w1 + 0xCA62C1D6) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w66 overwrites w2
    :set w2 (((($w15 ^ $w10 ^ $w4 ^ $w2) << 1) | ((($w15 ^ $w10 ^ $w4 ^ $w2) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($a ^ $b ^ $c) + $d + $w2 + 0xCA62C1D6) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w67 overwrites w3
    :set w3 (((($w0 ^ $w11 ^ $w5 ^ $w3) << 1) | ((($w0 ^ $w11 ^ $w5 ^ $w3) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($e ^ $a ^ $b) + $c + $w3 + 0xCA62C1D6) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w68 overwrites w4
    :set w4 (((($w1 ^ $w12 ^ $w6 ^ $w4) << 1) | ((($w1 ^ $w12 ^ $w6 ^ $w4) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($d ^ $e ^ $a) + $b + $w4 + 0xCA62C1D6) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w69 overwrites w5
    :set w5 (((($w2 ^ $w13 ^ $w7 ^ $w5) << 1) | ((($w2 ^ $w13 ^ $w7 ^ $w5) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($c ^ $d ^ $e) + $a + $w5 + 0xCA62C1D6) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # w70 overwrites w6
    :set w6 (((($w3 ^ $w14 ^ $w8 ^ $w6) << 1) | ((($w3 ^ $w14 ^ $w8 ^ $w6) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + ($b ^ $c ^ $d) + $e + $w6 + 0xCA62C1D6) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w71 overwrites w7
    :set w7 (((($w4 ^ $w15 ^ $w9 ^ $w7) << 1) | ((($w4 ^ $w15 ^ $w9 ^ $w7) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($a ^ $b ^ $c) + $d + $w7 + 0xCA62C1D6) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w72 overwrites w8
    :set w8 (((($w5 ^ $w0 ^ $w10 ^ $w8) << 1) | ((($w5 ^ $w0 ^ $w10 ^ $w8) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($e ^ $a ^ $b) + $c + $w8 + 0xCA62C1D6) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w73 overwrites w9
    :set w9 (((($w6 ^ $w1 ^ $w11 ^ $w9) << 1) | ((($w6 ^ $w1 ^ $w11 ^ $w9) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($d ^ $e ^ $a) + $b + $w9 + 0xCA62C1D6) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w74 overwrites w10
    :set w10 (((($w7 ^ $w2 ^ $w12 ^ $w10) << 1) | ((($w7 ^ $w2 ^ $w12 ^ $w10) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($c ^ $d ^ $e) + $a + $w10 + 0xCA62C1D6) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    # w75 overwrites w11
    :set w11 (((($w8 ^ $w3 ^ $w13 ^ $w11) << 1) | ((($w8 ^ $w3 ^ $w13 ^ $w11) >> 31) & 1)) & 0xFFFFFFFF)
    :set e (((($a << 5) | ($a >> 27)) + ($b ^ $c ^ $d) + $e + $w11 + 0xCA62C1D6) & 0xFFFFFFFF); :set b ((($b << 30) | ($b >> 2)) & 0xFFFFFFFF)

    # w76 overwrites w12
    :set w12 (((($w9 ^ $w4 ^ $w14 ^ $w12) << 1) | ((($w9 ^ $w4 ^ $w14 ^ $w12) >> 31) & 1)) & 0xFFFFFFFF)
    :set d (((($e << 5) | ($e >> 27)) + ($a ^ $b ^ $c) + $d + $w12 + 0xCA62C1D6) & 0xFFFFFFFF); :set a ((($a << 30) | ($a >> 2)) & 0xFFFFFFFF)

    # w77 overwrites w13
    :set w13 (((($w10 ^ $w5 ^ $w15 ^ $w13) << 1) | ((($w10 ^ $w5 ^ $w15 ^ $w13) >> 31) & 1)) & 0xFFFFFFFF)
    :set c (((($d << 5) | ($d >> 27)) + ($e ^ $a ^ $b) + $c + $w13 + 0xCA62C1D6) & 0xFFFFFFFF); :set e ((($e << 30) | ($e >> 2)) & 0xFFFFFFFF)

    # w78 overwrites w14
    :set w14 (((($w11 ^ $w6 ^ $w0 ^ $w14) << 1) | ((($w11 ^ $w6 ^ $w0 ^ $w14) >> 31) & 1)) & 0xFFFFFFFF)
    :set b (((($c << 5) | ($c >> 27)) + ($d ^ $e ^ $a) + $b + $w14 + 0xCA62C1D6) & 0xFFFFFFFF); :set d ((($d << 30) | ($d >> 2)) & 0xFFFFFFFF)

    # w79 overwrites w15
    :set w15 (((($w12 ^ $w7 ^ $w1 ^ $w15) << 1) | ((($w12 ^ $w7 ^ $w1 ^ $w15) >> 31) & 1)) & 0xFFFFFFFF)
    :set a (((($b << 5) | ($b >> 27)) + ($c ^ $d ^ $e) + $a + $w15 + 0xCA62C1D6) & 0xFFFFFFFF); :set c ((($c << 30) | ($c >> 2)) & 0xFFFFFFFF)

    :set h0 (($h0 + $a) & 0xFFFFFFFF)
    :set h1 (($h1 + $b) & 0xFFFFFFFF)
    :set h2 (($h2 + $c) & 0xFFFFFFFF)
    :set h3 (($h3 + $d) & 0xFFFFFFFF)
    :set h4 (($h4 + $e) & 0xFFFFFFFF)
  }

  # Build final Hex string
  return ( \
    ($hexByteTable->(($h0 >> 24) & 0xFF)) . ($hexByteTable->(($h0 >> 16) & 0xFF)) . ($hexByteTable->(($h0 >> 8) & 0xFF)) . ($hexByteTable->($h0 & 0xFF)) . \
    ($hexByteTable->(($h1 >> 24) & 0xFF)) . ($hexByteTable->(($h1 >> 16) & 0xFF)) . ($hexByteTable->(($h1 >> 8) & 0xFF)) . ($hexByteTable->($h1 & 0xFF)) . \
    ($hexByteTable->(($h2 >> 24) & 0xFF)) . ($hexByteTable->(($h2 >> 16) & 0xFF)) . ($hexByteTable->(($h2 >> 8) & 0xFF)) . ($hexByteTable->($h2 & 0xFF)) . \
    ($hexByteTable->(($h3 >> 24) & 0xFF)) . ($hexByteTable->(($h3 >> 16) & 0xFF)) . ($hexByteTable->(($h3 >> 8) & 0xFF)) . ($hexByteTable->($h3 & 0xFF)) . \
    ($hexByteTable->(($h4 >> 24) & 0xFF)) . ($hexByteTable->(($h4 >> 16) & 0xFF)) . ($hexByteTable->(($h4 >> 8) & 0xFF)) . ($hexByteTable->($h4 & 0xFF)) \
  )
}

# Purpose: Calculate the SHA256 hash checksum for a given string.
# Parameters:
#   $1 - String to calculate the hash for
# Returns: SHA256 checksum as a hex string
# Example: :put [$GetSha256Sum "Hello World"]
# Output:
#   a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e
:set GetSha256Sum do={
  :global asciiCodeTable
  :global hexByteTable
  :global sha256KTable

  :local strMessage $1
  :local lMessageLength [:len $strMessage]

  # Fast return for empty string
  :if ($lMessageLength = 0) do={
    :return "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  }

  # Initialize SHA-256 Round Constants (K)
  :if ([:len $sha256KTable] != 64) do={
    :set sha256KTable {
      0x428a2f98; 0x71374491; 0xb5c0fbcf; 0xe9b5dba5; 0x3956c25b; 0x59f111f1; 0x923f82a4; 0xab1c5ed5;
      0xd807aa98; 0x12835b01; 0x243185be; 0x550c7dc3; 0x72be5d74; 0x80deb1fe; 0x9bdc06a7; 0xc19bf174;
      0xe49b69c1; 0xefbe4786; 0x0fc19dc6; 0x240ca1cc; 0x2de92c6f; 0x4a7484aa; 0x5cb0a9dc; 0x76f988da;
      0x983e5152; 0xa831c66d; 0xb00327c8; 0xbf597fc7; 0xc6e00bf3; 0xd5a79147; 0x06ca6351; 0x14292967;
      0x27b70a85; 0x2e1b2138; 0x4d2c6dfc; 0x53380d13; 0x650a7354; 0x766a0abb; 0x81c2c92e; 0x92722c85;
      0xa2bfe8a1; 0xa81a664b; 0xc24b8b70; 0xc76c51a3; 0xd192e819; 0xd6990624; 0xf40e3585; 0x106aa070;
      0x19a4c116; 0x1e376c08; 0x2748774c; 0x34b0bcb5; 0x391c0cb3; 0x4ed8aa4a; 0x5b9cca4f; 0x682e6ff3;
      0x748f82ee; 0x78a5636f; 0x84c87814; 0x8cc70208; 0x90befffa; 0xa4506ceb; 0xbef9a3f7; 0xc67178f2
    }
  }

  :local lWordArray [:toarray ""]

  # Pack message bytes into 32-bit words
  :local i 0
  :while (($i + 3) < $lMessageLength) do={
    :set ($lWordArray->($i >> 2)) ( \
      (($asciiCodeTable->[:pick $strMessage $i]) << 24) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 16) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 8) | \
      ($asciiCodeTable->[:pick $strMessage ($i + 3)]) \
    )
    :set i ($i + 4)
  }

  # Pack remaining bytes
  :local curVal 0
  :if ($i < $lMessageLength) do={
    :set curVal (($asciiCodeTable->[:pick $strMessage $i]) << 24)
    :if (($i + 1) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 16))
    }
    :if (($i + 2) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 8))
    }
  }

  # Add padding byte 0x80
  :local padWIndex ($i >> 2)
  :local padBPos ((3 - ($lMessageLength % 4)) * 8)
  :set ($lWordArray->$padWIndex) ($curVal | (0x80 << $padBPos))

  # Fill remaining words with 0 and append bit length
  :local lNumberOfWords (((($lMessageLength + 8) / 64) + 1) * 16)
  :for w from=($padWIndex + 1) to=($lNumberOfWords - 1) do={
    :set ($lWordArray->$w) 0
  }

  :set ($lWordArray->($lNumberOfWords - 2)) 0
  :set ($lWordArray->($lNumberOfWords - 1)) (($lMessageLength * 8) & 0xFFFFFFFF)

  ### Initial SHA-256 State ###
  :local h0 0x6a09e667
  :local h1 0xbb67ae85
  :local h2 0x3c6ef372
  :local h3 0xa54ff53a
  :local h4 0x510e527f
  :local h5 0x9b05688c
  :local h6 0x1f83d9ab
  :local h7 0x5be0cd19

  :local lWordArrLen ([:len $lWordArray] - 1)
  :local w [:toarray ""]

  :for lcv from=0 to=$lWordArrLen step=16 do={
    :for j from=0 to=15 do={
      :set ($w->$j) ($lWordArray->($lcv + $j))
    }

    :for j from=16 to=63 do={
      :set ($w->$j) ((($w->($j - 16)) + \
        (((($w->($j - 15)) >> 7) | (($w->($j - 15)) << 25)) ^ ((($w->($j - 15)) >> 18) | (($w->($j - 15)) << 14)) ^ (($w->($j - 15)) >> 3)) + \
        ($w->($j - 7)) + \
        (((($w->($j - 2)) >> 17) | (($w->($j - 2)) << 15)) ^ ((($w->($j - 2)) >> 19) | (($w->($j - 2)) << 13)) ^ (($w->($j - 2)) >> 10))) & 0xFFFFFFFF)
    }

    :local a $h0
    :local b $h1
    :local c $h2
    :local d $h3
    :local e $h4
    :local f $h5
    :local g $h6
    :local h $h7

    # Loop-based SHA-256 Rounds with bitwise optimizations
    :for r from=0 to=63 do={
      :local temp1 (($h + (((($e >> 6) | ($e << 26)) ^ (($e >> 11) | ($e << 21)) ^ (($e >> 25) | ($e << 7))) & 0xFFFFFFFF) + ($g ^ ($e & ($f ^ $g))) + ($sha256KTable->$r) + ($w->$r)) & 0xFFFFFFFF)
      :local temp2 (((((($a >> 2) | ($a << 30)) ^ (($a >> 13) | ($a << 19)) ^ (($a >> 22) | ($a << 10))) & 0xFFFFFFFF) + (($a & $b) | ($c & ($a ^ $b)))) & 0xFFFFFFFF)

      :set h $g
      :set g $f
      :set f $e
      :set e (($d + $temp1) & 0xFFFFFFFF)
      :set d $c
      :set c $b
      :set b $a
      :set a (($temp1 + $temp2) & 0xFFFFFFFF)
    }

    :set h0 (($h0 + $a) & 0xFFFFFFFF)
    :set h1 (($h1 + $b) & 0xFFFFFFFF)
    :set h2 (($h2 + $c) & 0xFFFFFFFF)
    :set h3 (($h3 + $d) & 0xFFFFFFFF)
    :set h4 (($h4 + $e) & 0xFFFFFFFF)
    :set h5 (($h5 + $f) & 0xFFFFFFFF)
    :set h6 (($h6 + $g) & 0xFFFFFFFF)
    :set h7 (($h7 + $h) & 0xFFFFFFFF)
  }

  # Build final Hex string
  :return ( \
    ($hexByteTable->(($h0 >> 24) & 0xFF)) . ($hexByteTable->(($h0 >> 16) & 0xFF)) . ($hexByteTable->(($h0 >> 8) & 0xFF)) . ($hexByteTable->($h0 & 0xFF)) . \
    ($hexByteTable->(($h1 >> 24) & 0xFF)) . ($hexByteTable->(($h1 >> 16) & 0xFF)) . ($hexByteTable->(($h1 >> 8) & 0xFF)) . ($hexByteTable->($h1 & 0xFF)) . \
    ($hexByteTable->(($h2 >> 24) & 0xFF)) . ($hexByteTable->(($h2 >> 16) & 0xFF)) . ($hexByteTable->(($h2 >> 8) & 0xFF)) . ($hexByteTable->($h2 & 0xFF)) . \
    ($hexByteTable->(($h3 >> 24) & 0xFF)) . ($hexByteTable->(($h3 >> 16) & 0xFF)) . ($hexByteTable->(($h3 >> 8) & 0xFF)) . ($hexByteTable->($h3 & 0xFF)) . \
    ($hexByteTable->(($h4 >> 24) & 0xFF)) . ($hexByteTable->(($h4 >> 16) & 0xFF)) . ($hexByteTable->(($h4 >> 8) & 0xFF)) . ($hexByteTable->($h4 & 0xFF)) . \
    ($hexByteTable->(($h5 >> 24) & 0xFF)) . ($hexByteTable->(($h5 >> 16) & 0xFF)) . ($hexByteTable->(($h5 >> 8) & 0xFF)) . ($hexByteTable->($h5 & 0xFF)) . \
    ($hexByteTable->(($h6 >> 24) & 0xFF)) . ($hexByteTable->(($h6 >> 16) & 0xFF)) . ($hexByteTable->(($h6 >> 8) & 0xFF)) . ($hexByteTable->($h6 & 0xFF)) . \
    ($hexByteTable->(($h7 >> 24) & 0xFF)) . ($hexByteTable->(($h7 >> 16) & 0xFF)) . ($hexByteTable->(($h7 >> 8) & 0xFF)) . ($hexByteTable->($h7 & 0xFF)) \
  )
}

# Purpose: Calculate the SHA512 hash checksum for a given string.
# Parameters:
#   $1 - String to calculate the hash for
# Returns: SHA512 checksum as a hex string
# Example: :put [$GetSha512Sum "Hello World"]
# Output:
#   2c74fd17edafd80e8447b0d46741ee243b7eb74dd2149a0ab1b9246fb30382f27e853d8585719e0e67cbda0daa8f51671064615d645ae27acb15bfb1447f459b
:set GetSha512Sum do={
  :global asciiCodeTable
  :global hexByteTable
  :global sha512KTable

  :local strMessage $1
  :local lMessageLength [:len $strMessage]

  # Fast return for empty string
  :if ($lMessageLength = 0) do={
    :return "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"
  }

  # Initialize SHA-512 round constants as signed 64 bit decimals
  :if ([:len $sha512KTable] != 80) do={
    :set sha512KTable {
       4794697086780616226;  8158064640168781261; -5349999486874862801; -1606136188198331460;
       4131703408338449720;  6480981068601479193; -7908458776815382629; -6116909921290321640;
      -2880145864133508542;  1334009975649890238;  2608012711638119052;  6128411473006802146;
       8268148722764581231; -9160688886553864527; -7215885187991268811; -4495734319001033068;
      -1973867731355612462; -1171420211273849373;  1135362057144423861;  2597628984639134821;
       3308224258029322869;  5365058923640841347;  6679025012923562964;  8573033837759648693;
      -7476448914759557205; -6327057829258317296; -5763719355590565569; -4658551843659510044;
      -4116276920077217854; -3051310485924567259;   489312712824947311;  1452737877330783856;
       2861767655752347644;  3322285676063803686;  5560940570517711597;  5996557281743188959;
       7280758554555802590;  8532644243296465576; -9096487096722542874; -7894198246740708037;
      -6719396339535248540; -6333637450476146687; -4446306890439682159; -4076793802049405392;
      -3345356375505022440; -2983346525034927856;  -860691631967231958;  1182934255886127544;
       1847814050463011016;  2177327727835720531;  2830643537854262169;  3796741975233480872;
       4115178125766777443;  5681478168544905931;  6601373596472566643;  7507060721942968483;
       8399075790359081724;  8693463985226723168; -8878714635349349518; -8302665154208450068;
      -8016688836872298968; -6606660893046293015; -4685533653050689259; -4147400797238176981;
      -3880063495543823972; -3348786107499101689; -1523767162380948706;  -757361751448694408;
        500013540394364858;   748580250866718886;  1242879168328830382;  1977374033974150939;
       2944078676154940804;  3659926193048069267;  4368137639120453308;  4836135668995329356;
       5532061633213252278;  6448918945643986474;  6902733635092675308;  7801388544844847127
    }
  }

  :local lWordArray [:toarray ""]

  # Pack message bytes into sixty four bit words
  :local i 0
  :while (($i + 7) < $lMessageLength) do={
    :set ($lWordArray->($i >> 3)) ( \
      (($asciiCodeTable->[:pick $strMessage $i]) << 56) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 48) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 40) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 3)]) << 32) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 4)]) << 24) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 5)]) << 16) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 6)]) << 8) | \
      ($asciiCodeTable->[:pick $strMessage ($i + 7)]) \
    )
    :set i ($i + 8)
  }

  # Pack remaining bytes
  :local curVal 0
  :if ($i < $lMessageLength) do={
    :set curVal (($asciiCodeTable->[:pick $strMessage $i]) << 56)
    :if (($i + 1) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 48))
    }
    :if (($i + 2) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 40))
    }
    :if (($i + 3) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 3)]) << 32))
    }
    :if (($i + 4) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 4)]) << 24))
    }
    :if (($i + 5) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 5)]) << 16))
    }
    :if (($i + 6) < $lMessageLength) do={
      :set curVal ($curVal | (($asciiCodeTable->[:pick $strMessage ($i + 6)]) << 8))
    }
  }

  # Add padding byte
  :local padWIndex ($i >> 3)
  :local padBPos ((7 - ($lMessageLength % 8)) * 8)
  :set ($lWordArray->$padWIndex) ($curVal | (0x80 << $padBPos))

  # Fill remaining words with zero and append bit length
  :local lNumberOfWords (((($lMessageLength + 16) / 128) + 1) * 16)
  :for w from=($padWIndex + 1) to=($lNumberOfWords - 1) do={
    :set ($lWordArray->$w) 0
  }

  # Append length in bits as a one hundred twenty eight bit integer
  :set ($lWordArray->($lNumberOfWords - 2)) 0
  :set ($lWordArray->($lNumberOfWords - 1)) ($lMessageLength * 8)

  # Initial SHA-512 state as signed 64 bit decimals
  :local h0  7640891576956012808
  :local h1 -4942790177534073029
  :local h2  4354685564936845355
  :local h3 -6534734903238641935
  :local h4  5840696475078001361
  :local h5 -7276294671716946913
  :local h6  2270897969802886507
  :local h7  6620516959819538809

  :local lWordArrLen ([:len $lWordArray] - 1)
  :local w [:toarray ""]

  :for lcv from=0 to=$lWordArrLen step=16 do={
    :for j from=0 to=15 do={
      :set ($w->$j) ($lWordArray->($lcv + $j))
    }

    :for j from=16 to=79 do={
      :set ($w->$j) ( ($w->($j - 16)) + \
        ( (((($w->($j - 15)) >> 1) & 0x7FFFFFFFFFFFFFFF) | (($w->($j - 15)) << 63)) ^ \
          (((($w->($j - 15)) >> 8) & 0x00FFFFFFFFFFFFFF) | (($w->($j - 15)) << 56)) ^ \
          ((($w->($j - 15)) >> 7) & 0x01FFFFFFFFFFFFFF) ) + \
        ($w->($j - 7)) + \
        ( (((($w->($j - 2)) >> 19) & 0x00001FFFFFFFFFFF) | (($w->($j - 2)) << 45)) ^ \
          (((($w->($j - 2)) >> 61) & 0x0000000000000007) | (($w->($j - 2)) << 3)) ^ \
          ((($w->($j - 2)) >> 6) & 0x03FFFFFFFFFFFFFF) ) )
    }

    :local a $h0
    :local b $h1
    :local c $h2
    :local d $h3
    :local e $h4
    :local f $h5
    :local g $h6
    :local h $h7

    # Loop based SHA-512 Rounds
    :for r from=0 to=79 do={
      :local temp1 ( $h + \
        ( ((($e >> 14) & 0x0003FFFFFFFFFFFF) | ($e << 50)) ^ \
          ((($e >> 18) & 0x00003FFFFFFFFFFF) | ($e << 46)) ^ \
          ((($e >> 41) & 0x00000000007FFFFF) | ($e << 23)) ) + \
        ( $g ^ ($e & ($f ^ $g)) ) + ($sha512KTable->$r) + ($w->$r) )

      :local temp2 ( \
        ( ((($a >> 28) & 0x0000000FFFFFFFFF) | ($a << 36)) ^ \
          ((($a >> 34) & 0x000000003FFFFFFF) | ($a << 30)) ^ \
          ((($a >> 39) & 0x0000000001FFFFFF) | ($a << 25)) ) + \
        ( ($a & $b) | ($c & ($a ^ $b)) ) )

      :set h $g
      :set g $f
      :set f $e
      :set e ($d + $temp1)
      :set d $c
      :set c $b
      :set b $a
      :set a ($temp1 + $temp2)
    }

    :set h0 ($h0 + $a)
    :set h1 ($h1 + $b)
    :set h2 ($h2 + $c)
    :set h3 ($h3 + $d)
    :set h4 ($h4 + $e)
    :set h5 ($h5 + $f)
    :set h6 ($h6 + $g)
    :set h7 ($h7 + $h)
  }

  # Build final Hex string
  :return ( \
    ($hexByteTable->((($h0 >> 56) & 0xFF))) . ($hexByteTable->((($h0 >> 48) & 0xFF))) . ($hexByteTable->((($h0 >> 40) & 0xFF))) . ($hexByteTable->((($h0 >> 32) & 0xFF))) . \
    ($hexByteTable->((($h0 >> 24) & 0xFF))) . ($hexByteTable->((($h0 >> 16) & 0xFF))) . ($hexByteTable->((($h0 >> 8) & 0xFF))) . ($hexByteTable->(($h0 & 0xFF))) . \
    ($hexByteTable->((($h1 >> 56) & 0xFF))) . ($hexByteTable->((($h1 >> 48) & 0xFF))) . ($hexByteTable->((($h1 >> 40) & 0xFF))) . ($hexByteTable->((($h1 >> 32) & 0xFF))) . \
    ($hexByteTable->((($h1 >> 24) & 0xFF))) . ($hexByteTable->((($h1 >> 16) & 0xFF))) . ($hexByteTable->((($h1 >> 8) & 0xFF))) . ($hexByteTable->(($h1 & 0xFF))) . \
    ($hexByteTable->((($h2 >> 56) & 0xFF))) . ($hexByteTable->((($h2 >> 48) & 0xFF))) . ($hexByteTable->((($h2 >> 40) & 0xFF))) . ($hexByteTable->((($h2 >> 32) & 0xFF))) . \
    ($hexByteTable->((($h2 >> 24) & 0xFF))) . ($hexByteTable->((($h2 >> 16) & 0xFF))) . ($hexByteTable->((($h2 >> 8) & 0xFF))) . ($hexByteTable->(($h2 & 0xFF))) . \
    ($hexByteTable->((($h3 >> 56) & 0xFF))) . ($hexByteTable->((($h3 >> 48) & 0xFF))) . ($hexByteTable->((($h3 >> 40) & 0xFF))) . ($hexByteTable->((($h3 >> 32) & 0xFF))) . \
    ($hexByteTable->((($h3 >> 24) & 0xFF))) . ($hexByteTable->((($h3 >> 16) & 0xFF))) . ($hexByteTable->((($h3 >> 8) & 0xFF))) . ($hexByteTable->(($h3 & 0xFF))) . \
    ($hexByteTable->((($h4 >> 56) & 0xFF))) . ($hexByteTable->((($h4 >> 48) & 0xFF))) . ($hexByteTable->((($h4 >> 40) & 0xFF))) . ($hexByteTable->((($h4 >> 32) & 0xFF))) . \
    ($hexByteTable->((($h4 >> 24) & 0xFF))) . ($hexByteTable->((($h4 >> 16) & 0xFF))) . ($hexByteTable->((($h4 >> 8) & 0xFF))) . ($hexByteTable->(($h4 & 0xFF))) . \
    ($hexByteTable->((($h5 >> 56) & 0xFF))) . ($hexByteTable->((($h5 >> 48) & 0xFF))) . ($hexByteTable->((($h5 >> 40) & 0xFF))) . ($hexByteTable->((($h5 >> 32) & 0xFF))) . \
    ($hexByteTable->((($h5 >> 24) & 0xFF))) . ($hexByteTable->((($h5 >> 16) & 0xFF))) . ($hexByteTable->((($h5 >> 8) & 0xFF))) . ($hexByteTable->(($h5 & 0xFF))) . \
    ($hexByteTable->((($h6 >> 56) & 0xFF))) . ($hexByteTable->((($h6 >> 48) & 0xFF))) . ($hexByteTable->((($h6 >> 40) & 0xFF))) . ($hexByteTable->((($h6 >> 32) & 0xFF))) . \
    ($hexByteTable->((($h6 >> 24) & 0xFF))) . ($hexByteTable->((($h6 >> 16) & 0xFF))) . ($hexByteTable->((($h6 >> 8) & 0xFF))) . ($hexByteTable->(($h6 & 0xFF))) . \
    ($hexByteTable->((($h7 >> 56) & 0xFF))) . ($hexByteTable->((($h7 >> 48) & 0xFF))) . ($hexByteTable->((($h7 >> 40) & 0xFF))) . ($hexByteTable->((($h7 >> 32) & 0xFF))) . \
    ($hexByteTable->((($h7 >> 24) & 0xFF))) . ($hexByteTable->((($h7 >> 16) & 0xFF))) . ($hexByteTable->((($h7 >> 8) & 0xFF))) . ($hexByteTable->(($h7 & 0xFF))) \
  )
}
