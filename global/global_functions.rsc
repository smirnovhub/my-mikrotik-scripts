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
# /system script run global_functions
#
# Sources and original authors:
# https://github.com/eworm-de/routeros-scripts.git
# https://github.com/osamahfarhan/mikrotik.git
# https://forum.mikrotik.com/
# and many others...
#
# global functions
:global LogAndExit;
:global ParseKeyValueStore;
:global GetArgOrDefault;
:global GetArgOrExit;
:global GetRandom20CharHex;
:global GetRandomNumber;
:global SilentPing;
:global HexToNum;
:global MapArray;
:global JoinArray;
:global SplitStr;
:global TrimStr;
:global TrimStrLeft;
:global TrimStrRight;
:global ReplaceStr;
:global RunScript;
:global ExportConfiguration;
:global RecursiveMergeSort;
:global DivideIntAndRound;
:global GetCurrentDateTime;
:global ParseDateTime;
:global EnsureFileWithIdExists;
:global ToUpperCase;
:global ToLowerCase;
:global ToUnixTimestamp;
:global GetUnixTimestamp;
:global FromUnixTimestamp;
:global GetWeekday;
:global FormatSecondsLong;
:global FormatSecondsShort;
:global SendTelegramMessage;

:global DNSIsResolving;
:global WaitDNSResolving;
:global DefaultRouteIsReachable;
:global WaitDefaultRouteReachable;
:global WaitFullyConnected;

# Global dependencies:
#   Telegram (if you want to use SendTelegramMessage)
#       :global telegramBotToken - your telegram bot token
#       :global telegramChatID - your telegram chat id

:set LogAndExit do={
  :local Severity [ :tostr $1 ];
  :local Name     [ :tostr $2 ];
  :local Message  [ :tostr $3 ];

  :local Log ($Name . ": " . $Message);
  :if ($Severity = "info") do={
      :log info $Log
  } else={
      :if ($Severity = "warning") do={
          :log warning $Log
      } else={
          :if ($Severity = "error") do={
              :log error $Log
          } else={
              :if ($Severity = "debug") do={
                  :log debug $Log
              } else={
                  :log info $Log
              }
          }
      }
  }

  :error ($Log);
}


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

  :if ([ :typeof $source ] != "array") do={
    :set source [ $SplitStr $1 $delimiter]
  }

  :local result [ :toarray "" ]
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

# Purpose: Retrieve a specific argument from an associative array (map) or return a default value.
# Parameters:
#   $1 - Associative array of arguments (e.g. $args->key = "value")
#   $2 - Name of the argument to retrieve
#   $3 - Default value to return if the argument is not present or empty
# Returns:
#   - The value of the argument if it exists
#   - The specified default value if the argument is missing or empty
#   - Boolean true/false if the argument explicitly equals "true"/"false"
# Notes:
#   - Logs an error and exits if $3 (defaultValue) is not provided
#   - Relies on a global helper function LogAndExit for error handling
#   - Useful for parsing command-line parameters or configuration maps
# Examples:
#   :global ParseKeyValueStore
#   :global GetArgOrExit
#   :global GetArgOrDefault
#
#   :local args [$ParseKeyValueStore ("name=123", "ip=192.168.1.10", "enabled")]
#
#   :local arg1 [$GetArgOrExit $args "ip" "Test script"]
#   :put $arg1
#   :local arg2 [$GetArgOrDefault $args "noarg" "192.168.1.103" "Test script"]
#   :put $arg2
:set GetArgOrDefault do={
    :global LogAndExit

    :local args $1
    :local argName $2
    :local defaultValue $3

    :if ([:len $defaultValue] = 0) do={
        [$LogAndExit "error" "GetArgOrDefault" "parameter 'defaultValue' should be specified"]
    }

    :local arg ($args->$argName)

    :if ([:len $arg] = 0) do={
        :return $defaultValue
    }

    :if ($arg = false || $arg = "false") do={
        :return false
    } else={
        :if ($arg = true || $arg = "true") do={
            :return true
        }
    }

    :return $arg
}

# Purpose: Retrieve a specific argument from an associative array (map) and exit with an error if it is missing.
# Parameters:
#   $1 - Associative array of arguments (e.g. $args->key = "value")
#   $2 - Name of the argument to retrieve
#   $3 - (Optional) Description of the argument or context for logging purposes
# Returns:
#   - The value of the argument if it exists
#   - Boolean true/false if the argument explicitly equals "true"/"false"
# Notes:
#   - Logs an error and exits using the global LogAndExit function if the argument is missing or empty
#   - Useful for mandatory parameters in command-line arguments or configuration maps
#   - Ensures that required arguments are always provided before proceeding
# Examples:
#   :global ParseKeyValueStore
#   :global GetArgOrExit
#   :global GetArgOrDefault
#
#   :local args [$ParseKeyValueStore ("name=123", "ip=192.168.1.10", "enabled")]
#
#   :local arg1 [$GetArgOrExit $args "ip" "Test script"]
#   :put $arg1
#   :local arg2 [$GetArgOrDefault $args "noarg" "192.168.1.103" "Test script"]
#   :put $arg2
:set GetArgOrExit do={
    :global LogAndExit

    :local args $1
    :local argName $2
    :local description $3

    :if ([:len $description] = 0) do={
        :set description "GetArgOrExit"
    }

    :local arg ($args->$argName)

    :if ([:len $arg] = 0) do={
        [$LogAndExit "error" $description ("parameter '$argName' should be specified")]
    }

    :if ($arg = false || $arg = "false") do={
        :return false
    } else={
        :if ($arg = true || $arg = "true") do={
            :return true
        }
    }

    :return $arg
}

# check if DNS is resolving
:set DNSIsResolving do={
  :do {
    :resolve "dns.google";
  } on-error={
    :return false;
  }
  :return true;
}

# wait for DNS to resolve
:set WaitDNSResolving do={
  :global DNSIsResolving;

  :while ([ $DNSIsResolving ] = false) do={
    :delay 1s;
  }
}

# default route is reachable
:set DefaultRouteIsReachable do={
  :if ([ :len [ / ip route find where dst-address=0.0.0.0/0 active !blackhole !routing-mark !unreachable gateway!=loopback ] ] > 0) do={
    :return true;
  }
  :return false;
}

# wait for default route to be reachable
:set WaitDefaultRouteReachable do={
  :global DefaultRouteIsReachable;

  :while ([ $DefaultRouteIsReachable ] = false) do={
    :delay 1s;
  }
}

# wait to be fully connected (default route is reachable, time is sync, DNS resolves)
:set WaitFullyConnected do={
  :global WaitDefaultRouteReachable;
  :global WaitDNSResolving;

  $WaitDefaultRouteReachable;
  $WaitDNSResolving;
}

# Purpose: Generate a random 20-character hexadecimal string using RouterOS SCEP server OTP generation.
# Parameters: None
# Returns: A 20-character random hexadecimal string
# Notes:
#   - Uses the built-in RouterOS command `/certificate scep-server otp generate` with `minutes-valid=0` to produce a one-time password.
#   - Extracts the "password" field from the returned value.
#   - Can be used as a source of randomness for other scripts or functions requiring random hex strings.
:set GetRandom20CharHex do={
  :return ([ / certificate scep-server otp generate minutes-valid=0 as-value ]->"password");
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
  :local Max 4294967295;
  :if ([ :typeof $1 ] != "nothing" ) do={
    :set Max ([ :tonum $1 ] + 1);
  }

  :global GetRandom20CharHex;
  :global HexToNum;

  :return ([ $HexToNum [ :pick [ $GetRandom20CharHex ] 0 15 ] ] % $Max);
}

# Purpose: Perform "silent ping" operations in RouterOS to either:
#          - A single host (string input), or
#          - Multiple hosts provided as a key-value array (dictionary).
#          The function runs pings in background jobs, waits for all jobs
#          to finish, and collects the number of successful replies.
#          Function works without producing console output.
#          Uses a dynamically created unique global variable (with prefix "pingresult")
#          to store the ping result temporarily, and handles errors gracefully if the host
#          is invalid or unreachable.
# Parameters:
#   $1 - Either:
#          (a) A single host (IP address or domain name, string), OR
#          (b) An associative array (dictionary) where:
#                 • key   = identifier (label)
#                 • value = host to ping
#   $2 - Optional number of ping packets to send (default is 1)
# Returns:
#   - If $1 is a single host: returns an integer (successful replies count)
#   - If $1 is an array: returns an array with the same keys, but
#     values replaced by the number of successful replies for each host
# Notes:
#   - Each ping runs in a separate background job.
#   - Temporary global variables are created with random suffixes
#     (using GetRandom20CharHex) to prevent naming collisions.
#   - All temporary variables are removed once results are collected.
#   - If a host is invalid or unreachable, result is 0.
#   - Array input launches all pings in parallel and synchronizes at the end.
# Examples:
# ping single host
# :put [$SilentPing "1.1.1.1" 5]
# output: 5
#
# ping multiple hosts
# :put [$SilentPing [:toarray {"mail"="i.ua"; "google"="8.8.8.8"; "unknown"="1.8.7.6"; "cloudflare"="1.1.1.1"}] 5]
# output: cloudflare=5;google=5;mail=5;unknown=0
#
# usage from scripts
# :global SilentPing
# :local hosts {"mail"="i.ua"; "unknown"="1.8.7.6"; "google"="8.8.8.8"; "cloudflare"="1.1.1.1"}
# :local result [$SilentPing $hosts 5]
# :put ("Mail       = " . $result->"mail")
# :put ("Google     = " . $result->"google")
# :put ("Cloudflare = " . $result->"cloudflare")
# :put ("Unknown    = " . $result->"unknown")
# output:
# Mail       = 5
# Google     = 5
# Cloudflare = 5
# Unknown    = 0
:set SilentPing do={
    :global GetRandom20CharHex

    :local input $1
    :local count 1

    :if ([:len $2] > 0) do={ :set count $2 }

    :local varPrefix "pingresult"

    # --- Case 1: single host ---
    :if ([:typeof $input] != "array") do={
        :local host $input
 
        # Random string
        :local rnd [$GetRandom20CharHex]
        # Name of global variable to store result
        :local varName "$varPrefix$rnd"
      
        # Dynamically create global variable using :parse
        :execute (":global " . $varName)
      
        # Run ping in background with error handling using :do on-error
        :local jobCode (":do { \
            :set \$" . $varName . " [:ping count=" . $count . " address=" . $host . "] \
        } on-error={ :set \$" . $varName . " 0 }")
      
        # Run job
        :local jobID [:execute $jobCode]

        # Wait for pings end
        :delay ($count."s")

        # Wait until job finishes
        :while ([:len [/system script job find where .id=$jobID]] > 0) do={
            :delay 500ms
        }
      
        # Read the result from the dynamic global variable
        :local script [:parse ":global $varName; :return \$$varName"]
        :local result [$script]
      
        # Remove the temporary global variable
        /system script environment remove [find name=$varName]
      
        :return $result
    }

    # Case 2: input is an array, iterate over key-value pairs
    :local results [:toarray ""]
    :local jobs [:toarray ""]
    :local vars [:toarray ""]
    :local varsList [:toarray ""]

    # Iterate over each key in array
    :foreach k,v in=$input do={
        :local host $v
        :local rnd [$GetRandom20CharHex]
        :local varName "$varPrefix$rnd"

        :set ($varsList->([:len $varsList])) $varName

        # Create global variable placeholder
        :execute (":global " . $varName)

        # Job code for each host
        :local jobCode (":do { \
            :set \$" . $varName . " [:ping count=" . $count . " address=" . $host . "] \
        } on-error={ :set \$" . $varName . " 0 }")

        # Launch background job
        :local jobID [:execute $jobCode]

        # Convert to string
        :set jobID [:tostr $jobID]

        # Store mapping job (key, varName) for later retrieval
        :set ($jobs->$jobID) $k
        :set ($vars->$k) $varName
    }

    # Wait for pings end
    :delay ($count."s")

    # Wait until ALL jobs finish
    :while (true) do={
        :local allFinished true
        :foreach j,k in=$jobs do={
            :if ([:len [/system script job find where .id=$j]] = 0) do={
                # Job finished, fetch result
                :local varName ($vars->$k)
                :local script [:parse ":global $varName; :return \$$varName"]
                :local result [$script]

                # Save result into return array
                :set ($results->$k) $result
            } else={
                :set allFinished false
            }
        }

        if ($allFinished = true) do={
            /system script environment remove $varsList
            :return $results
        }

        :delay 500ms
    }

    # Return results array
    :return $results
}

# Purpose: Convert a hexadecimal string into its corresponding numeric value.
# Parameters:
#   $1 - Hexadecimal string (e.g. "1A", "ff")
# Returns: Numeric value corresponding to the input hex string (e.g. 26, 255)
:set HexToNum do={
    # Convert input to string in case it isn't already
    :local input [:tostr $1];

    # String containing all hexadecimal digits (both lowercase and uppercase)
    :local hex "0123456789abcdef0123456789ABCDEF";

    # Multiplier represents the current positional value in base-16 (1, 16, 256, ...)
    :local multiplier 1;

    # Initialize result to 0; this will accumulate the numeric value
    :local result 0;

    # Loop over each character in the input string from rightmost to leftmost
    :for i from=([:len $input] - 1) to=0 do={

        # Find the position of the current hex character in the hex string
        # Use modulo 16 to map both lowercase and uppercase letters correctly
        # Multiply by the positional multiplier and add to the result
        :set result ($result + (([:find $hex [:pick $input $i]] % 16) * $multiplier));

        # Update multiplier for next left character (multiply by 16)
        :set multiplier ($multiplier * 16);
    }

    # Return the final numeric value
    :return $result;
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
#   :put  ("input1  = " . [:tostr $input1] )
#   :put  ("output1 = " . [:tostr $output1] )
#   :put  ("input2  = " . [:tostr $input2] )
#   :put  ("output2 = " . [:tostr $output2] )
# Output:
#   input1  = 7;5;10
#   output1 = 49;25;100
#   input2  = a=4;b=7;c=15
#   output2 = a=16;b=49;c=225
:set MapArray do={
    :local result [:toarray ""];
    :foreach n,v in=$1 do={
        :set ($result->$n) [$2 n=$n v=$v];
    }
    :return $result;
}

# Purpose: Concatenate all elements of an input array into a single string,
#          inserting a specified separator between each element.
# Parameters:
#   $1 - Array of strings to be joined
#   $2 - Separator string to insert between elements
# Returns: A single string with all elements joined by the separator
# Example: :put [$JoinArray (1,3,4,2,7,5) ","]
:set JoinArray do={
    # String to hold the joined result
    :local resultString;

    # Loop over each element in the input array
    :foreach item in=$1 do={
        # Append current item and the separator to the result string
        :set $resultString ($resultString.$item.$2);
    }

    # Remove the last appended separator and return the final string
    :return [:pick $resultString 0 ([:len $resultString]-[:len $2])];
}

# Purpose: Split a string into an array of substrings based on a specified delimiter.
# Parameters:
#   $1 - Input string to be split
#   $2 - Delimiter string to split by
#   $3 - Optional maximum number of parts to return
# Returns: Array of substrings resulting from the split
:set SplitStr do={
    # Array to hold the resulting split parts
    :local result;

    # Length of the delimiter string
    :local delimiterLength [:len $2];

    # Start index for the next substring to extract
    :local substringStart 0;

    # Loop counter initialized as negative delimiter length
    :local i (0-$delimiterLength);

    # Edge offset for handling empty delimiter case
    :local edgeOffset 0;

    # If delimiter length is 0, set edgeOffset to 1 to avoid zero-length issues
    :if ($delimiterLength=0) do={:set $edgeOffset 1;}

    # Loop while delimiter is found in the string
    :while ([:set $i [:find $1 $2 ($i+$delimiterLength-1+$edgeOffset)]; (any$i)]) do={

        # Append substring from 'substringStart' to found delimiter index 'i' to result
        :set $result ($result, ([:pick $1 $substringStart $i]));

        # Move 'substringStart' to the character after the found delimiter
        :set $substringStart ($i+$delimiterLength);

        # If the result array has reached the maximum number of parts ($3),
        # append the rest of the string and return
        :if ([:len $result]=$3) do={:return ($result, ([:pick $1 $substringStart [:len $1]]));}
    }

    # After the loop, append the remaining part of the string to the result array
    :return ($result, ([:pick $1 $substringStart [:len $1]]));
}

# Purpose: Remove all leading characters from a string that match any character in a given set.
# Parameters:
#   $1 - Input string to trim
#   $2 - Set of characters to remove from the left side
# Returns: The trimmed string with specified leading characters removed
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
:set TrimStr do={
    :global TrimStrLeft;
    :global TrimStrRight;

    :local s $1

    # Trim left using TrimStrLeft
    :set s [$TrimStrLeft $s $2]

    # Trim right using TrimStrRight
    :set s [$TrimStrRight $s $2]

    :return $s
}

# Purpose: Dynamically run another RouterOS script by name, optionally passing up to 6 parameters.
# Parameters:
#   $1 - Name of the script to execute
#   $2..$7 - Optional parameters to pass to the script
# Returns: The result of the executed script (if any)
# Usage: $RunScript my_script_name false true
:set RunScript do={
    :local scriptName [ :tostr $1 ];
    :local script [:parse [/system script get $scriptName source]]
    $script $2 $3 $4 $5 $6 $7
}

# Purpose: Export the current RouterOS configuration to a file
#          with a standardized name containing the router identity and current date-time.
# Parameters:
#   $1 - Path where the backup file should be saved
# Returns: None (creates an export file at the specified path)
:set ExportConfiguration do={
    :global TrimStrRight
    :global ToLowerCase
    :global ReplaceStr
    :global GetCurrentDateTime

    :local path [ :tostr $1 ];

    :local routerName [/system identity get name]
    :set routerName [$ToLowerCase $routerName]
    :local curDate [$GetCurrentDateTime]
    :set curDate [$ReplaceStr $curDate ":" "-"]
    :set curDate [$ReplaceStr $curDate " " "-"]
    :set path [$TrimStrRight $path "/"]
    :set path "$path/$routerName-backup-$curDate"
    /export file=$path
}

# Purpose: Perform a merge sort on a simple array of items that can be compared using '<'.
# Parameters:
#   $1 - Array to sort
# Returns: A new array containing the sorted elements
# NOTE: This only works if each array item can
# be compared using the '<' operator.
:set RecursiveMergeSort do={
  :global RecursiveMergeSort;

  :local out [:toarray $1];
  :local l [:len $out];
  :if ($l>1) do={
    # Split the list in two, recursively sort, then merge results

    # Pick split point index:
    :local s ($l/2);

    # Recursively sort each half-list:
    :local a [$RecursiveMergeSort [:pick $out 0 $s]];
    :local b [$RecursiveMergeSort [:pick $out $s $l]];

    # Merge results:
    :set out [:toarray ""];
    :set l [:len $b];
    :local s 0;       # Use $s as index into array $b
    :foreach i in=$a do={
      :local j [:pick $b $s];
      :while ($s<$l && $j<$i) do={
        :set out ($out,$j);
        :set s ($s+1);
        :set j [:pick $b $s];
      };
      :set out ($out,$i);
    };
    :while ($s<$l) do={
      :set out ($out,[:pick $b $s]);
      :set s ($s+1);
    };
  };
  :return $out;
}

# Purpose: Replace all occurrences of a substring within a string with another substring.
# Parameters:
#   $1 - Original string
#   $2 - Substring to find and replace
#   $3 - Substring to replace with
# Returns: A new string with all occurrences replaced
:set ReplaceStr do={
  :local String [ :tostr $1 ];
  :local ReplaceFrom [ :tostr $2 ];
  :local ReplaceWith [ :tostr $3 ];
  :local Return "";

  :if ($ReplaceFrom = "") do={
    :return $String;
  }

  :while ([ :typeof [ :find $String $ReplaceFrom ] ] != "nil") do={
    :local Pos [ :find $String $ReplaceFrom ];
    :set Return ($Return . [ :pick $String 0 $Pos ] . $ReplaceWith);
    :set String [ :pick $String ($Pos + [ :len $ReplaceFrom ]) [ :len $String ] ];
  }

  :return ($Return . $String);
}

# Purpose: Perform division of two integers and round the result to a specified number of decimal places.
# Parameters:
#   $1 - Numerator
#   $2 - Denominator
#   $3 - Number of decimal places to round to
# Returns: The result as a string with the specified number of decimal places
:set DivideIntAndRound do={
    # Convert inputs to numbers
    :local numerator [:tonum $1]
    :local denominator [:tonum $2]
    :local decimalPlaces [:tonum $3]

    # Check division by zero
    :if ($denominator = 0) do={
        :return "Division by zero error"
    }

    # Special case: decimalPlaces = 0
    :if ($decimalPlaces = 0) do={
        # Regular integer division
        :local result ($numerator / $denominator)
        # Compute remainder for rounding
        :local remainder ($numerator % $denominator)
        # Round: if remainder*2 >= denominator, increment result
        :if (($remainder * 2) >= $denominator) do={
            :set result ($result + 1)
        }
        :return ("" . $result)
    }

    # Compute factor = 10^decimalPlaces
    :local factor 1
    :for i from=1 to=$decimalPlaces do={
        :set factor ($factor * 10)
    }

    # Scale numerator
    :local scaledNum ($numerator * $factor)

    # Compute integer division and remainder
    :local result ($scaledNum / $denominator)
    :local remainder ($scaledNum % $denominator)

    # Round: if remainder*2 >= denominator, increment result
    :if (($remainder * 2) >= $denominator) do={
        :set result ($result + 1)
    }

    # Convert result to string
    :local resultStr ("" . $result)

    # Pad with leading zeros if needed
    :while ([:len $resultStr] <= $decimalPlaces) do={
        :set resultStr ("0" . $resultStr)
    }

    # Insert decimal point
    :set resultStr ([:pick $resultStr 0 ([:len $resultStr] - $decimalPlaces)] . "." . [:pick $resultStr ([:len $resultStr] - $decimalPlaces) [:len $resultStr]])

    :return $resultStr
}

# Purpose: Retrieve the current system date and time, formatted as "YYYY-MM-DD HH:MM:SS"
# Parameters: None
# Returns: Formatted date-time string
:set GetCurrentDateTime do={
    :global ParseDateTime

    # Get current date and time from system clock
    :local currentDate [/system clock get date]   ; # Example: "aug/17/2025"
    :local currentTime [/system clock get time]   ; # Example: "14:32:07"
    # Return parsed date and time
    :return [$ParseDateTime ($currentDate . " " . $currentTime)]
}

# Purpose: Parse RouterOS date-time string like "aug/22/2025 12:03:04"
# Parameters:
#   $1 - Input date-time string
# Returns: Formatted date-time string "YYYY-MM-DD HH:MM:SS"
:set ParseDateTime do={
    :local input $1

    # Extract month short name (first 3 chars)
    :local month [:pick $input 0 3]              ; # "aug"
    # Extract day (characters 4-6, may be 1 or 2 digits)
    :local day [:pick $input 4 6]                ; # "17"
    # Extract year (characters 7-11)
    :local year [:pick $input 7 11]              ; # "2025"
    # Extract time part (characters after space, starting at pos 12)
    :local time [:pick $input 12 [:len $input]]  ; # "14:32:07"

    # Convert month short name to numeric string
    :local months {"jan"="01"; "feb"="02"; "mar"="03"; "apr"="04"; "may"="05"; "jun"="06"; "jul"="07"; "aug"="08"; "sep"="09"; "oct"="10"; "nov"="11"; "dec"="12"}
    :local monthNum ($months->$month)

    # Ensure day is always 2 digits (prefix with 0 if needed)
    :if ([:len $day] = 1) do={ :set day ("0" . $day) }

    # Build final formatted datetime string
    :local formattedDateTime ($year . "-" . $monthNum . "-" . $day . " " . $time)

    :return $formattedDateTime
}

# Purpose: Ensure a file exists with the given name and content, and return its file ID.
# Parameters:
#   $1 - Existing file ID (if any), can be empty
#   $2 - File name
#   $3 - File content
# Returns: File ID of the ensured file
:set EnsureFileWithIdExists do={
    :local fileId [ :tostr $1 ];
    :local fileName [ :tostr $2 ];
    :local fileContent [ :tostr $3 ];

    :if ([:len $fileId] = 0) do={
        /file print file=$fileName
        :delay 1s
        :set fileId [/file find name=$fileName]
        /file set $fileId contents=$fileContent
    }

    :return $fileId
}

# Purpose: Convert all lowercase letters in a string to uppercase.
# Parameters:
#   $1 - Input string
# Returns: A new string with all lowercase letters converted to uppercase
:set ToUpperCase do={
    :local lower [:toarray "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"]
    :local upper [:toarray "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"]
    :local result

    :for idx from=0 to=([:len $1] - 1) do={ 
        :local char [:pick $1 $idx]
        :local match
        :for i from=0 to=[:len $lower] do={
            :set $match ($lower->$i)
            :if ($char = $match) do={:set $char ($upper->$i)}
        }
        :set $result ($result.$char)
    }
    :return $result
}

# Purpose: Convert all uppercase letters in a string to lowercase.
# Parameters:
#   $1 - Input string
# Returns: A new string with all uppercase letters converted to lowercase
:set ToLowerCase do={
    :local lower [:toarray "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"]
    :local upper [:toarray "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"]
    :local result

    :for idx from=0 to=([:len $1] - 1) do={ 
        :local char [:pick $1 $idx]
        :local match
        :for i from=0 to=[:len $upper] do={
            :set $match ($upper->$i)
            :if ($char = $match) do={:set $char ($lower->$i)}
        }
        :set $result ($result.$char)
    }
    :return $result
}

# Purpose: Convert a date-time string in "YYYY-MM-DD HH:MM:SS" format to Unix timestamp.
# Parameters:
#   $1 - Date-time string "YYYY-MM-DD HH:MM:SS"
# Returns: Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
:set ToUnixTimestamp do={
    :local dt [ :tostr $1 ];
    
    # Extract year, month, day, hour, minute, second
    :local year [:tonum [:pick $dt 0 4]]
    :local month [:tonum [:pick $dt 5 7]]
    :local day [:tonum [:pick $dt 8 10]]
    :local hour [:tonum [:pick $dt 11 13]]
    :local min [:tonum [:pick $dt 14 16]]
    :local sec [:tonum [:pick $dt 17 19]]
    
    # Days in months
    :local monthDays {31;28;31;30;31;30;31;31;30;31;30;31}
    # Leap year adjustment
    :if (($year % 4 = 0 && $year % 100 != 0) || ($year % 400 = 0)) do={ :set ($monthDays->1) 29 }
    
    # Count total days from 1970 to previous year
    :local days 0
    :for y from=1970 to=($year - 1) do={
        :set days ($days + 365)
        :if (($y % 4 = 0 && $y % 100 != 0) || ($y % 400 = 0)) do={ :set days ($days + 1) }
    }
    
    # Count days in previous months of current year
    :for i from=1 to=($month - 1) do={ :set days ($days + ($monthDays->($i - 1))) }
    
    # Add days in current month
    :set days ($days + $day - 1)
    
    # Convert total days + hours, minutes, seconds to seconds
    :local timestamp ($days * 86400 + $hour * 3600 + $min * 60 + $sec)
    
    :return $timestamp
}

# Purpose: Retrieve the current system date and time and convert it to a Unix timestamp.
# Parameters: None
# Returns: Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
:set GetUnixTimestamp do={
    # Get current system date in format "aug/17/2025"
    :local date [/system clock get date]    
    
    # Get current system time in format "22:10:45"
    :local time [/system clock get time]    
    
    # Extract the month as a string (first 3 letters of date, e.g. "aug")
    :local monthStr [:pick $date 0 3]
    
    # Extract the day part (characters 4-6, e.g. "17") and convert to number
    :local day [:tonum [:pick $date 4 6]]
    
    # Extract the year part (characters 7-11, e.g. "2025") and convert to number
    :local year [:tonum [:pick $date 7 11]]
    
    # Mapping of month abbreviations to numeric values
    :local months {"jan"=1;"feb"=2;"mar"=3;"apr"=4;"may"=5;"jun"=6;"jul"=7;"aug"=8;"sep"=9;"oct"=10;"nov"=11;"dec"=12}
    
    # Get numeric month value using the mapping
    :local month (:$months->$monthStr)
    
    # Extract the hour part from time string and convert to number
    :local hour [:tonum [:pick $time 0 2]]
    
    # Extract the minute part from time string and convert to number
    :local minute [:tonum [:pick $time 3 5]]
    
    # Extract the second part from time string and convert to number
    :local second [:tonum [:pick $time 6 8]]
    
    # Create local copies for year, month, and day
    :local y $year
    :local m $month
    :local d $day
    
    # Initialize days counter (number of days since 1970-01-01)
    :local days (0)
    
    # Add days for all full years since 1970
    :for i from=1970 to=($y - 1) do={
        # Add 365 days for each year
        :set days ($days + 365)
    
        # If year is leap year, add one extra day
        :if (($i % 4 = 0 && $i % 100 != 0) || ($i % 400 = 0)) do={ 
            :set days ($days + 1) 
        }
    }
    
    # Number of days in each month for a regular year
    :local monthDays {31;28;31;30;31;30;31;31;30;31;30;31}
    
    # If current year is leap year, adjust February to 29 days
    :if (($y % 4 = 0 && $y % 100 != 0) || ($y % 400 = 0)) do={
        :set ($monthDays->1) 29
    }
    
    # Add days from previous months of the current year
    :for i from=1 to=($m - 1) do={
        :set days ($days + ($monthDays->($i - 1)))
    }
    
    # Add days from the current month (subtract 1 because day count starts at 0)
    :set days ($days + $d - 1)
    
    # Convert total days + time into seconds (Unix timestamp)
    :local timestamp ($days * 86400 + $hour * 3600 + $minute * 60 + $second)
    
    # Return calculated Unix timestamp
    :return $timestamp
}

# Purpose: Convert a Unix timestamp (seconds since 1970-01-01 00:00:00 UTC) to a formatted date-time string "YYYY-MM-DD HH:MM:SS"
# Parameters:
#   $1 - Unix timestamp
# Returns: Formatted date-time string
:set FromUnixTimestamp do={
    # Input parameter: Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
    :local ts [ :tonum $1 ];
    
    # Extract seconds part (remaining after dividing by 60)
    :local sec ($ts % 60)
    
    # Convert timestamp from seconds to minutes
    :set ts ($ts / 60)
    
    # Extract minutes part (remaining after dividing by 60)
    :local min ($ts % 60)
    
    # Convert timestamp from minutes to hours
    :set ts ($ts / 60)
    
    # Extract hours part (remaining after dividing by 24)
    :local hour ($ts % 24)
    
    # Convert timestamp from hours to days
    :set ts ($ts / 24)
    
    # Now "ts" contains number of full days since 1970-01-01
    :local year 1970
    
    # Determine year by subtracting full years from "ts" (no break)
    :while ($ts >= 365) do={
    
        # Default number of days in the current year
        :local daysInYear 365
    
        # If year is a leap year, adjust days to 366
        :if (($year % 4 = 0 && $year % 100 != 0) || ($year % 400 = 0)) do={
            :set daysInYear 366
        }
    
        # Only subtract if ts is still greater or equal to daysInYear
        :if ($ts >= $daysInYear) do={
            :set ts ($ts - $daysInYear)
            :set year ($year + 1)
        }
    }
    
    # Array with number of days in each month for a regular year
    :local monthDays {31;28;31;30;31;30;31;31;30;31;30;31}
    
    # Adjust February to 29 days if current year is a leap year
    :if (($year % 4 = 0 && $year % 100 != 0) || ($year % 400 = 0)) do={
        :set ($monthDays->1) 29
    }
    
    # Initialize month counter
    :local month 1
    
    # Determine month by subtracting full months from "ts" (no break)
    :local i 0
    :while ($i < 12 && $ts >= ($monthDays->$i)) do={
        :set ts ($ts - ($monthDays->$i))
        :set month ($month + 1)
        :set i ($i + 1)
    }
    
    # Day is the remainder + 1 (since counting starts from 0)
    :local day ($ts + 1)
    
    # Format result as "YYYY-MM-DD"
    :local result ([:tostr $year] . "-" . \
                   [:pick ("0" . $month) ([:len ("0" . $month)] - 2) [:len ("0" . $month)]] . "-" . \
                   [:pick ("0" . $day) ([:len ("0" . $day)] - 2) [:len ("0" . $day)]])
    
    # Append "HH:MM:SS" to result string
    :set result ($result . " " . \
                 [:pick ("0" . $hour) ([:len ("0" . $hour)] - 2) [:len ("0" . $hour)]] . ":" . \
                 [:pick ("0" . $min) ([:len ("0" . $min)] - 2) [:len ("0" . $min)]] . ":" . \
                 [:pick ("0" . $sec) ([:len ("0" . $sec)] - 2) [:len ("0" . $sec)]])
    
    # Return formatted date-time string
    :return $result
}

# Purpose: Return the day of the week as a full English word (e.g., "monday", "tuesday")
#          for a given UNIX timestamp.
# Parameters:
#   $1 - UNIX timestamp (number of seconds since 1970-01-01 00:00:00 UTC)
# Returns:
#   - String with the full English name of the weekday
#     ("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday").
# Notes:
#   - UNIX epoch (1970-01-01) started on a Thursday, so a +4 day offset is applied
#     when calculating the weekday number.
#   - Indexing: 0 = Sunday, 1 = Monday, ..., 6 = Saturday.
#   - To get the current weekday, pass [$GetUnixTimestamp] as the parameter.
# Example usage:
#   :put [$GetWeekday [$GetUnixTimestamp]]
:set GetWeekday do={
    # Read function argument: UNIX timestamp
    :local ts $1

    # Convert timestamp into total number of days since 1970-01-01
    :local days ($ts / 86400)

    # Calculate weekday number with offset (0=Sunday, …, 6=Saturday)
    :local weekday (($days + 4) % 7)

    # Define lookup table with weekday names
    :local weekdays {"sunday";"monday";"tuesday";"wednesday";"thursday";"friday";"saturday"}

    # Return the weekday name as a string
    :return ($weekdays->$weekday)
}

# Purpose: Convert a total number of seconds into a human-readable string with days, hours, minutes, and seconds.
# Parameters:
#   $1 - Total seconds (integer)
# Returns: Formatted string, e.g., "2d 3h 15m 10s", skipping any zero components
:set FormatSecondsLong do={
    # Input parameter: total seconds
    :local totalSec [ :tonum $1 ];
    
    # Calculate total days
    :local days ($totalSec / 86400)
    :set totalSec ($totalSec % 86400)
    
    # Calculate hours
    :local hours ($totalSec / 3600)
    :set totalSec ($totalSec % 3600)
    
    # Calculate minutes
    :local minutes ($totalSec / 60)
    
    # Remaining seconds
    :local seconds ($totalSec % 60)
    
    # Build result string, skipping zeros
    :local result ""
    :if ($days > 0) do={ :set result ($result . $days . "d ") }
    :if ($hours > 0) do={ :set result ($result . $hours . "h ") }
    :if ($minutes > 0) do={ :set result ($result . $minutes . "m ") }
    :if ($seconds > 0) do={ :set result ($result . $seconds . "s") }
    
    # Trim any trailing space
    :set result [:pick $result 0 [:len $result]]
    
    # Return result
    :return $result
}

# Purpose: Convert total seconds into a short, human-readable format using the largest unit only.
# Parameters:
#   $1 - Total seconds (integer)
# Returns: Formatted string, e.g., "3 days", "5 hrs", "12 min", or "30 sec"
:set FormatSecondsShort do={
    # Input parameter: total seconds
    :local sec [ :tonum $1 ];

    # Prepare an empty formattedTime variable (string)
    :local formattedTime ""

    # Calculate how many full days are in the total seconds
    :local days ($sec / 86400)
    # Remove the number of seconds that are already counted as days
    :set sec ($sec % 86400)

    # Calculate how many full hours are left after removing days
    :local hours ($sec / 3600)
    # Remove the number of seconds that are already counted as hours
    :set sec ($sec % 3600)

    # Calculate how many full minutes are left after removing hours
    :local minutes ($sec / 60)
    # Remaining seconds after removing minutes
    :set sec ($sec % 60)

    # Decide which time unit to return:
    # If there are one or more days, return only days
    :if ($days > 0) do={
        :set formattedTime ($days . " days")
    } else={
        # Otherwise, if there are one or more hours, return only hours
        :if ($hours > 0) do={
            :set formattedTime ($hours . " hrs")
        } else={
            # Otherwise, if there are one or more minutes, return only minutes
            :if ($minutes > 0) do={
                :set formattedTime ($minutes . " min")
            } else={
                # If none of the above, return only seconds
                :set formattedTime ($sec . " sec")
            }
        }
    }

    # Return result
    :return $formattedTime
}

# Purpose: Send a message to a Telegram chat using a bot token.
# Parameters:
#   $1 - Message text to send
# Globals:
#   telegramBotToken - Telegram bot token
#   telegramChatID   - Chat ID to send the message to
# Returns: None
:set SendTelegramMessage do={
    :global telegramBotToken
    :global telegramChatID

    :local messageText [ :tostr $1 ];
    :local parseMode "HTML";
    /tool fetch url="https://api.telegram.org/bot$telegramBotToken/sendMessage\?chat_id=$telegramChatID&parse_mode=$parseMode&text=$messageText" keep-result=no;
    :log info "Send Telegram message: $messageText";
}
