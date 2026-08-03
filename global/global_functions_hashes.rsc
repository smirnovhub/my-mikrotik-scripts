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

# 256-entry byte-to-hex lookup table
:global md5HexByteTable

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

# Purpose: Calculate the MD5 hash checksum for a given string or array of bytes.
# Parameters:
#   $1 - String to calculate the hash for
# Returns: MD5 checksum as a hex string
# NOTE: Useful for data integrity verification and cryptographic hashing.
# Example: :put [$GetMd5Sum "Hello World"]
# Output:
#   b10a8db164e0754105b7a99be72e3fe5
:set GetMd5Sum do={
  :global DecToChar
  :global asciiCodeTable
  :global md5HexByteTable
  :local strMessage $1
  :local lMessageLength [:len $strMessage]

  # Fast return for empty string
  :if ($lMessageLength = 0) do={
    :return "d41d8cd98f00b204e9800998ecf8427e"
  }

  # Initialize ASCII lookup table on first use
  :if ([:typeof $asciiCodeTable] = "nothing") do={
      :set asciiCodeTable [:toarray ""]
      :for i from=0 to=255 do={
          :set ($asciiCodeTable->[$DecToChar $i]) $i
      }
  }

  # Initialize 256-entry byte-to-hex lookup table on first use
  :if ([:typeof $md5HexByteTable] = "nothing") do={
      :local strHex "0123456789abcdef"
      :set md5HexByteTable [:toarray ""]
      :for i from=0 to=255 do={
          :local high [:pick $strHex ($i >> 4) (($i >> 4) + 1)]
          :local low [:pick $strHex ($i & 0xF) (($i & 0xF) + 1)]
          :set ($md5HexByteTable->$i) ($high . $low)
      }
  }

  :local a 0x67452301
  :local b 0xEFCDAB89
  :local c 0x98BADCFE
  :local d 0x10325476

  :local AA 0x67452301
  :local BB 0xEFCDAB89
  :local CC 0x98BADCFE
  :local DD 0x10325476

  :local tmp1 0
  :local lNumberOfWords (((($lMessageLength + 8) / 64) + 1) * 16)
  
  :local lWordArray [:toarray ""]

  # Build the initial array
  :for w from=0 to=($lNumberOfWords - 1) do={
    :set ($lWordArray->$w) 0
  }

  # Pack message bytes into 32-bit words
  :local i 0

  :while (($i + 3) < $lMessageLength) do={
    :set ($lWordArray->($i / 4)) ( \
      ($asciiCodeTable->[:pick $strMessage $i]) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 8) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 16) | \
      (($asciiCodeTable->[:pick $strMessage ($i + 3)]) << 24) \
    )
    :set i ($i + 4)
  }

  # Pack remaining 1-3 bytes
  :if ($i < $lMessageLength) do={
    :set ($lWordArray->($i / 4)) ($asciiCodeTable->[:pick $strMessage $i])

    :if (($i + 1) < $lMessageLength) do={
      :set ($lWordArray->($i / 4)) (($lWordArray->($i / 4)) | (($asciiCodeTable->[:pick $strMessage ($i + 1)]) << 8))
    }

    :if (($i + 2) < $lMessageLength) do={
      :set ($lWordArray->($i / 4)) (($lWordArray->($i / 4)) | (($asciiCodeTable->[:pick $strMessage ($i + 2)]) << 16))
    }
  }

  # Add padding byte 0x80
  :local padWIndex ($lMessageLength / 4)
  :local padBPos (($lMessageLength % 4) * 8)
  :local curVal ($lWordArray->$padWIndex)
  :set ($lWordArray->$padWIndex) ($curVal | (0x80 << $padBPos))

  # Append original message length in bits
  :local bitLen ($lMessageLength * 8)
  :set ($lWordArray->($lNumberOfWords - 2)) ($bitLen & 0xFFFFFFFF)
  :set ($lWordArray->($lNumberOfWords - 1)) (($bitLen >> 32) & 0xFFFFFFFF)

  :local lWordArrLen ([:len $lWordArray] - 1)

  ### Main Loop (Unrolled Rounds) ###

  :for lcv from=0 to=$lWordArrLen step=16 do={
    :set AA $a
    :set BB $b
    :set CC $c
    :set DD $d

    :local off $lcv

    :local w0  ($lWordArray->($off + 0))
    :local w1  ($lWordArray->($off + 1))
    :local w2  ($lWordArray->($off + 2))
    :local w3  ($lWordArray->($off + 3))
    :local w4  ($lWordArray->($off + 4))
    :local w5  ($lWordArray->($off + 5))
    :local w6  ($lWordArray->($off + 6))
    :local w7  ($lWordArray->($off + 7))
    :local w8  ($lWordArray->($off + 8))
    :local w9  ($lWordArray->($off + 9))
    :local w10 ($lWordArray->($off + 10))
    :local w11 ($lWordArray->($off + 11))
    :local w12 ($lWordArray->($off + 12))
    :local w13 ($lWordArray->($off + 13))
    :local w14 ($lWordArray->($off + 14))
    :local w15 ($lWordArray->($off + 15))

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

    :set a (($a + $AA) & 0xFFFFFFFF)
    :set b (($b + $BB) & 0xFFFFFFFF)
    :set c (($c + $CC) & 0xFFFFFFFF)
    :set d (($d + $DD) & 0xFFFFFFFF)
  }

  # Direct conversion of MD5 state (a, b, c, d) to hex string using lookup table
  :return ( \
    ($md5HexByteTable->($a & 0xFF)) . \
    ($md5HexByteTable->(($a >> 8) & 0xFF)) . \
    ($md5HexByteTable->(($a >> 16) & 0xFF)) . \
    ($md5HexByteTable->(($a >> 24) & 0xFF)) . \
    ($md5HexByteTable->($b & 0xFF)) . \
    ($md5HexByteTable->(($b >> 8) & 0xFF)) . \
    ($md5HexByteTable->(($b >> 16) & 0xFF)) . \
    ($md5HexByteTable->(($b >> 24) & 0xFF)) . \
    ($md5HexByteTable->($c & 0xFF)) . \
    ($md5HexByteTable->(($c >> 8) & 0xFF)) . \
    ($md5HexByteTable->(($c >> 16) & 0xFF)) . \
    ($md5HexByteTable->(($c >> 24) & 0xFF)) . \
    ($md5HexByteTable->($d & 0xFF)) . \
    ($md5HexByteTable->(($d >> 8) & 0xFF)) . \
    ($md5HexByteTable->(($d >> 16) & 0xFF)) . \
    ($md5HexByteTable->(($d >> 24) & 0xFF)) \
  )
}

# Purpose: Calculate the CRC32 checksum for a given string or array of bytes.
# Parameters:
#   $1 - String to calculate the checksum for
# Returns: CRC32 checksum as a string or number
# Example: :put [$GetCrc32Sum "Hello World"]
# Output:
#   4a17b156
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
    :local len ([:len $input] - 1)

    # Loop through each character in the input string
    :for i from=0 to=$len do={
        :set crc (($crc >> 8) ^ ($crc32Table->((($crc ^ ($asciiCodeTable->[:pick $input $i])) & 0xFF))))
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
