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
# Add script named global_functions_utils and then add call to startup script:
# /system script run global_functions_utils
#
# Sources and original authors:
# https://github.com/eworm-de/routeros-scripts.git
# https://github.com/osamahfarhan/mikrotik.git
# https://forum.mikrotik.com/
# and many others...
#

# global functions
:global LogAndExit
:global GetArgOrDefault
:global GetArgOrExit
:global GetHttpFileContent
:global GetHttpFileContentWithRetry
:global SilentPing
:global RunScript
:global ExportConfiguration
:global EnsureFileWithIdExists
:global GetDhcpClientAddress
:global GetDhcpClientGateway
:global GetRouterOSVersion
:global SendPublicTelegramMessage
:global SendPrivateTelegramMessage
:global FetchWithRedirect
:global DownloadAndImportScript
:global DownloadAndImportScriptsFromList

# Global dependencies:
#   Telegram (if you want to use SendPublicTelegramMessage or SendPrivateTelegramMessage)
#       :global telegramBotToken      - your telegram bot token
#       :global telegramPublicChatID  - your public telegram chat id
#       :global telegramPrivateChatID - your private telegram chat id
#
#   global_functions_array_str:
#       :global GetRandom20CharHex
#       :global TrimStrRight
#       :global ToLowerCase
#       :global ReplaceStr
#       :global SplitStr
#   global_functions_datetime:
#       :global GetCurrentDateTime

:set LogAndExit do={
  :local severity [:tostr $1]
  :local name     [:tostr $2]
  :local message  [:tostr $3]

  :local text ($name . ": " . $message)
  :if ($severity = "info") do={
      :log info $text
  } else={
      :if ($severity = "warning") do={
          :log warning $text
      } else={
          :if ($severity = "error") do={
              :log error $text
          } else={
              :if ($severity = "debug") do={
                  :log debug $text
              } else={
                  :log info $text
              }
          }
      }
  }

  :error $text
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
    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return 0
    }

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
    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return 0
    }

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

# Purpose: Download and return the content of a file from a specified HTTP URL.
# Parameters:
#   $1 - The target URL of the file to fetch (string, required)
# Returns: The downloaded file content as a string; returns an empty string if an error occurs.
:set GetHttpFileContent do={
  :local url $1

  :if ([:len $url] < 7) do={
    :log warning "Url is empty or too short"
    :return ""
  }

  :local result [:toarray ""]

  :do {
    :set result [/tool fetch url="$url" output=user as-value]
  } on-error={
    :log error "An error occurred while downloading file: $url"
    :return ""
  }

  :local maxFileSize 64512

  :local str ($result->"data")
  :if ([:len $str] >= $maxFileSize) do={
    :log warning "File is too big. Max file size is $maxFileSize bytes: $url "
  }

  :return $str
}

# Purpose: Fetches HTTP file content with automatic retries and incremental delay.
# Parameters:
#   $1 - Target URL
#   $2 - Maximum retry attempts (optional, default: 3)
# Returns: The downloaded file content as a string or empty string if all attempts failed
:set GetHttpFileContentWithRetry do={
  :local url $1

  :if ([:len $url] < 7) do={
    :log warning "Url is empty or too short"
    :return ""
  }

  # Default to 3 retries if not specified
  :local retries 3
  :if ([:typeof $2] != "nothing") do={
    :set retries [:tonum $2]
  }

  :if ($retries < 1) do={
    :set retries 1
  }

  # Delay between retries in seconds
  :local retryDelay 1

  :local result ""
  :local success false

  :local maxFileSize 64512

  :for i from=1 to=$retries do={
    :do {
      # Attempt to fetch the file content
      :set result [/tool fetch url="$url" output=user as-value]
      :set success true
    } on-error={
      :log warning "Attempt $i of $retries failed to download file: $url"
      :if ($i < $retries) do={
        :delay $retryDelay
        :set retryDelay ($retryDelay + 1)
      }
    }

    # Exit loop early if download succeeded
    :if ($success) do={
      :local str ($result->"data")

      :if ([:len $str] >= $maxFileSize) do={
        :log warning "File is too big. Max file size is $maxFileSize bytes: $url"
      }

      :return $str
    }
  }

  :log error "All $retries attempts failed for: $url"
  :return ""
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

    :if ([:len $2] > 0) do={
        :set count $2
    }

    :local varPrefix "pingresult"

    # --- Case 1: single host ---
    :if ([:typeof $input] != "array") do={
        :local host $input

        # Random string
        :local rnd [$GetRandom20CharHex]

        # Name of global variable to store result
        :local varName ($varPrefix . $rnd)

        # Create temporary global variable
        :execute (":global " . $varName)

        # Run ping in background with error handling
        :local jobCode (":do { \
            :set \$" . $varName . " [:ping count=" . $count . " address=" . $host . "] \
        } on-error={ :set \$" . $varName . " 0 }")

        # Run job
        :local jobID [:execute $jobCode]

        # Wait for pings end
        :delay ($count . "s")

        # Wait until job finishes
        :while ([:len [/system script job find where .id=$jobID]] > 0) do={
            :delay 500ms
        }

        # Read the result
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
        :local varName ($varPrefix . $rnd)

        :set ($varsList->([:len $varsList])) $varName

        # Create temporary global variable
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
    :delay ($count . "s")

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

        :if ($allFinished = true) do={
            /system script environment remove $varsList
            :return $results
        }

        :delay 500ms
    }

    # Return results array
    :return $results
}

# Purpose: Dynamically run another RouterOS script by name, optionally passing up to 6 parameters.
# Parameters:
#   $1 - Name of the script to execute
#   $2..$7 - Optional parameters to pass to the script
# Returns: The result of the executed script (if any)
# Usage: $RunScript my_script_name false true
:set RunScript do={
    :local scriptName [:tostr $1]
    do {
        :local script [:parse [/system script get $scriptName source]]
        $script $2 $3 $4 $5 $6 $7
    } on-error={
        :log error "Error while running script $scriptName"
    }
}

# Purpose: Export the current RouterOS configuration to a file
#          with a standardized name containing the router identity and current date-time.
# Parameters:
#    $1 - Path where the backup file should be saved (e.g. "backups" or "flash")
# Returns: The final filename with its path and extension (e.g. "backups/mikrotik-backup-2026-07-16-14-30-00.rsc")
#          or empty string "" if the export fails (e.g. directory does not exist).
:set ExportConfiguration do={
    :global TrimStrLeft
    :global TrimStrRight
    :global ToLowerCase
    :global ReplaceStr
    :global GetCurrentDateTime

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return ""
    }

    :local path [:tostr $1]

    :local routerName [/system identity get name]
    :set routerName [$ToLowerCase $routerName]
    :local curDate [$GetCurrentDateTime]
    :set curDate [$ReplaceStr $curDate ":" "-"]
    :set curDate [$ReplaceStr $curDate " " "-"]
    :set path [$TrimStrRight $path "/"]
    :set path "$path/$routerName-backup-$curDate"
    :set path [$TrimStrLeft $path "/"]

    :local result ""

    do {
        # Execute actual configuration export
        /export file=$path
        :set result ($path . ".rsc")
    } on-error={
        :log error "ExportConfiguration failed: unable to write file $path"
    }

    :return $result
}

# Purpose: Ensure a file exists with the given name and content, and return its file ID.
# Parameters:
#   $1 - Existing file ID (if any), can be empty
#   $2 - File name
#   $3 - File content
# Returns: File ID of the ensured file
:set EnsureFileWithIdExists do={
    :local fileId [:tostr $1]
    :local fileName [:tostr $2]
    :local fileContent [:tostr $3]

    :if ([:len $fileId] = 0) do={
        /file print file=$fileName
        :delay 1s
        :set fileId [/file find name=$fileName]
        /file set $fileId contents=$fileContent
    }

    :return $fileId
}

# Purpose: Retrieve the IPv4 address assigned by a bound DHCP client on a given interface.
# Parameters:
#   $1 - Interface name to check for an active DHCP client
# Returns:
#   IPv4 address without prefix length (e.g. "192.168.1.10") if DHCP client is bound;
#   empty string if no DHCP client exists on the interface or if it is not in "bound" state.
:set GetDhcpClientAddress do={
    :global SplitStr

    :local iface [:tostr $1]
    :local dhcpId ""

    # Try to find active DHCP client
    :set dhcpId [/ip dhcp-client find where interface=$iface]

    # No DHCP client on this interface
    :if ([:len $dhcpId] = 0) do={
        :log error ("No DHCP client on interface " . $iface)
        :return ""
    }

    # Check DHCP state
    :local status [/ip dhcp-client get $dhcpId status]
    :if ($status != "bound") do={
        :log warning ("DHCP client not bound on " . $iface . ", status=" . $status)
        :return ""
    }

    # Safe to read parameters
    :local ip [/ip dhcp-client get $dhcpId address]

    :local parts [$SplitStr $ip "/"]

    :if ([:len $parts] < 2) do={
        :return $ip
    }

    :return ($parts->0)
}

# Purpose: Retrieve the default gateway received from a bound DHCP client on a given interface.
# Parameters:
#   $1 - Interface name to check for an active DHCP client
# Returns:
#   Gateway IPv4 address provided by DHCP if the client is in "bound" state;
#   empty string if no DHCP client exists on the interface or if it is not bound.
:set GetDhcpClientGateway do={
    :local iface [:tostr $1]
    :local dhcpId ""

    # Try to find active DHCP client
    :set dhcpId [/ip dhcp-client find where interface=$iface]

    # No DHCP client on this interface
    :if ([:len $dhcpId] = 0) do={
        :log error ("No DHCP client on interface " . $iface)
        :return ""
    }

    # Check DHCP state
    :local status [/ip dhcp-client get $dhcpId status]
    :if ($status != "bound") do={
        :log warning ("DHCP client not bound on " . $iface . ", status=" . $status)
        :return ""
    }

    # Safe to read parameters
    :local gw [/ip dhcp-client get $dhcpId gateway]

    :return $gw
}

# Purpose: Get the RouterOS version string, stripping out any release
# channel or build details after the space.
# Parameters: None
# Returns: String - The cleaned RouterOS version (e.g., "7.21.5")
:set GetRouterOSVersion do={
    # Get the raw version string from system resources
    :local rawVersion [/system resource get version]

    # Find the position of the first space
    :local spacePos [:find $rawVersion " "]

    # Strip everything after the space if it exists
    :if ($spacePos >= 0) do={
        :return [:pick $rawVersion 0 $spacePos]
    }

    :return $rawVersion
}

# Purpose: Send a message to the public Telegram chat using a bot token.
# Parameters:
#   $1 - Message text to send
# Globals:
#   telegramBotToken     - Telegram bot token
#   telegramPublicChatID - Chat ID to send the message to
# Returns: None
:set SendPublicTelegramMessage do={
    :global telegramBotToken
    :global telegramPublicChatID

    :local messageText [:tostr $1]
    :local parseMode "HTML"

    :local url "https://api.telegram.org/bot$telegramBotToken/sendMessage"

    :local payload "chat_id=$telegramPublicChatID&parse_mode=$parseMode&text=$messageText"

    /tool fetch url=$url http-method=post http-data=$payload keep-result=no
    :log info "Send public Telegram message: $messageText"
}

# Purpose: Send a message to the private Telegram chat using a bot token.
# Parameters:
#   $1 - Message text to send
# Globals:
#   telegramBotToken      - Telegram bot token
#   telegramPrivateChatID - Chat ID to send the message to
# Returns: None
:set SendPrivateTelegramMessage do={
    :global telegramBotToken
    :global telegramPrivateChatID

    :local messageText [:tostr $1]
    :local parseMode "HTML"

    :local url "https://api.telegram.org/bot$telegramBotToken/sendMessage"

    :local payload "chat_id=$telegramPrivateChatID&parse_mode=$parseMode&text=$messageText"

    /tool fetch url=$url http-method=post http-data=$payload keep-result=no
    :log info "Send private Telegram message: $messageText"
}

# Purpose: Download content from a URL with support for HTTP 3xx redirects
#          and error logging, storing payload directly in memory via as-value.
# Parameters:
#   $1 - Target URL to fetch content from
# Returns: String with downloaded content on success, or empty string on failure
# Example: :put [$FetchWithRedirect "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/list.txt"]
:set FetchWithRedirect do={
    :global TrimStr
    :global GetRandom20CharHex

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return ""
    }

    :local currentUrl [:tostr $1]
    :if ([:len $currentUrl] = 0) do={
        :log error "FetchWithRedirect: URL parameter is missing."
        :return ""
    }

    # Redirect markers for different RouterOS versions:
    # " <30" for RouterOS 6
    # failure: closing connection: <302 Found "https://mikrotik.com/"> 159.148.172.205:80 (4)
    #
    # " 30" for RouterOS 7
    # failure: Fetch failed with status 302 (Location: "https://mikrotik.com/") (/tool/fetch; line 1)
    :local redirectMarkers {" <30"; " 30"}

    :local failureMarker "failure:"

    :local maxRedirects 5
    :local redirectCount 0

    :local timeoutMs 10000
    :local checkIntervalMs 500
    :local elapsedMs 0

    :log info ("FetchWithRedirect: Fetching " . $currentUrl)

    :while (true) do={
        :do {
            # Attempt direct sync download in-memory via as-value
            :local fetchRes [/tool fetch url=$currentUrl output=user as-value]
            :if ($fetchRes->"status" = "finished") do={
                :return ($fetchRes->"data")
            } else={
                :log error ("FetchWithRedirect: Failed to fetch " . $currentUrl)
                :return ""
            }
        } on-error={
            # Fetch failed (3xx redirect or network error) -> capture error text via :execute
            :local tmpLogFile ([$GetRandom20CharHex] . ".txt")

            # Execute fetch with keep-result=no to record only stderr/stdout
            :local fetchCmd "/tool fetch url=\"$currentUrl\" keep-result=no"
            :local jobId [:execute file=$tmpLogFile script=$fetchCmd]

            :set elapsedMs 0

            :while (([:len [/system script job find where .id=$jobId]] = 1) && ($elapsedMs < $timeoutMs)) do={
                :delay ($checkIntervalMs . "ms")
                :set elapsedMs ($elapsedMs + $checkIntervalMs)
            }

            :if ([:len [/system script job find where .id=$jobId]] = 1) do={
                :log error ("FetchWithRedirect: Request to " . $currentUrl . " timed out")
                /system script job remove [find where .id=$jobId]
                /file remove [find where name=$tmpLogFile]
                :return ""
            }

            :local nextUrl ""
            :local errorMessage ""

            # Extract new Location URL or parse HTTP/network error
            :if ([:len [/file find where name=$tmpLogFile]] = 1) do={
                :local logContent [/file get [find where name=$tmpLogFile] contents]
                /file remove [find where name=$tmpLogFile]

                :local markerPos -1

                :foreach marker in=$redirectMarkers do={
                    :local pos [:find $logContent $marker]
                    :if ([:type $pos] = "num" && $markerPos = -1) do={
                        :set markerPos $pos
                    }
                }

                :if ($markerPos >= 0) do={
                    :if ($redirectCount >= $maxRedirects) do={
                        :log error ("FetchWithRedirect: Too many redirects (max: " . $maxRedirects . ") for URL: " . $currentUrl)
                        :return ""
                    }

                    # Extract target URL enclosed in quotes
                    :local quoteStart [:find $logContent "\"" $markerPos]
                    :if ([:len $quoteStart] > 0) do={
                        :local startPos ($quoteStart + 1)
                        :local restStr [:pick $logContent $startPos [:len $logContent]]
                        :local endPos [:find $restStr "\""]

                        :if ([:len $endPos] > 0) do={
                            :set nextUrl [:pick $restStr 0 $endPos]
                        }
                    }
                } else={
                    # Parse generic error message
                    :local failurePos [:find $logContent $failureMarker]

                    :if ([:type $failurePos] = "num") do={
                        :set errorMessage [:pick $logContent ($failurePos + [:len $failureMarker]) [:len $logContent]]
                        :set errorMessage [$TrimStr $errorMessage ("\r\n\t ")]
                    }
                }
            }

            # If a redirect URL was found, advance to the next iteration
            :if ([:len $nextUrl] > 0) do={
                :if ($nextUrl = $currentUrl) do={
                    :log error ("FetchWithRedirect: Circular redirect to " . $nextUrl)
                    :return ""
                }

                :set redirectCount ($redirectCount + 1)
                :log info ("FetchWithRedirect: Following 3xx redirect (" . $redirectCount . "/" . $maxRedirects . ") to " . $nextUrl)
                :set currentUrl $nextUrl
            } else={
                # Unrecoverable error (HTTP error status, network error, or log extraction failed)
                :if ([:len $errorMessage] > 0) do={
                    :log error ("FetchWithRedirect: Error fetching " . $currentUrl . ": " . $errorMessage)
                } else={
                    :log error ("FetchWithRedirect: Failed to fetch " . $currentUrl)
                }
                :return ""
            }
        }
    }

    :log error ("FetchWithRedirect: Too many redirects (max: " . $maxRedirects . ") for URL: " . $currentUrl)
    :return ""
}

# Purpose: Download a .rsc script from a URL, update or create it in RouterOS 
#          system scripts, and execute it immediately.
# Parameters:
#   $1 - URL to the script file ending with .rsc
# Returns: true on successful script update and execution, or false on failure
# Example: $DownloadAndImportScript "https://example.com/scripts/my_script.rsc"
:set DownloadAndImportScript do={
    :global EndsWithStr
    :global FetchWithRedirect

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return false
    }

    :local rawUrl [:tostr $1]

    :if ([:len $rawUrl] = 0) do={
        :log error "DownloadAndImportScript: URL parameter is missing."
        :return false
    }

    :if ([$EndsWithStr $rawUrl ".rsc"] = false) do={
        :log error "DownloadAndImportScript: file name should end with .rsc"
        :return false
    }

    # Extract script name from URL (filename without extension)
    :local fileName ""
    :local lastSlash 0
    :for i from=0 to=([:len $rawUrl] - 1) do={
        :if ([:pick $rawUrl $i ($i + 1)] = "/") do={
            :set lastSlash $i
        }
    }

    :set fileName [:pick $rawUrl ($lastSlash + 1) [:len $rawUrl]]

    # Remove .rsc extension if present
    :local scriptName $fileName
    :if ([:pick $fileName ([:len $fileName] - 4) [:len $fileName]] = ".rsc") do={
        :set scriptName [:pick $fileName 0 ([:len $fileName] - 4)]
    }

    :do {
        :local newSource [$FetchWithRedirect $rawUrl]
        :if ([:len $newSource] > 0) do={
            :if ([:len [/system script find name=$scriptName]] > 0) do={
                /system script set [find name=$scriptName] source=$newSource comment=$scriptName
            } else={
                /system script add name=$scriptName source=$newSource comment=$scriptName
            }

            :log info "DownloadAndImportScript: Script '$scriptName' updated successfully."
            :return true
        }
    } on-error={
        :log error ("DownloadAndImportScript: Failed to download from " . $rawUrl)
        :return false
    }
}

# Purpose: Download a text file containing script URLs line-by-line, parse valid
#          entries, and import each script into RouterOS. Optionally cleans up
#          uppercase environment variables and executes all imported scripts.
# Parameters:
#   $1 - URL to the text file ending with .txt containing list of script URLs
#   $2 - (Optional) Boolean flag. If true, removes uppercase environment variables
#        and runs all newly imported scripts after downloading (default: false)
# Returns: true on successful list processing, or false on error
# Example: $DownloadAndImportScriptsFromList "https://example.com/scripts/list.txt" true
:set DownloadAndImportScriptsFromList do={
    :global SplitStr
    :global TrimStr
    :global EndsWithStr
    :global FetchWithRedirect
    :global DownloadAndImportScript

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return false
    }

    :local listUrl [:tostr $1]

    :if ([:len $listUrl] = 0) do={
        :log error "DownloadAndImportScriptsFromList: List URL parameter is missing."
        :return false
    }

    :if ([$EndsWithStr $listUrl ".txt"] = false) do={
        :log error "DownloadAndImportScriptsFromList: file name should end with .txt"
        :return false
    }

    :local cleanupAndRun false
    :if ([:tostr $2] = "true") do={
        :set cleanupAndRun true
    }

    :do {
        :local content [$FetchWithRedirect $listUrl]
        :if ([:len $content] > 0) do={
            :local lines [$SplitStr $content ("\n")]
            :local successCount 0
            :local failCount 0
            :local importedScripts [:toarray ""]

            :foreach rawLine in=$lines do={
                # Remove spaces, carriage returns, line feeds, and tabs from both ends
                :local cleanUrl [$TrimStr $rawLine ("\r\n\t ")]

                # Ignore empty lines and comment lines (starting with #)
                :if ([:len $cleanUrl] > 0 and [:pick $cleanUrl 0 1] != "#") do={
                    :local res [$DownloadAndImportScript $cleanUrl]
                    :if ($res = true) do={
                        :log info ($cleanUrl . " downloaded successfully")
                        :set successCount ($successCount + 1)

                        # Extract script name to add to the execution list
                        :local fileName ""
                        :local lastSlash 0
                        :for i from=0 to=([:len $cleanUrl] - 1) do={
                            :if ([:pick $cleanUrl $i ($i + 1)] = "/") do={
                                :set lastSlash $i
                            }
                        }
                        :set fileName [:pick $cleanUrl ($lastSlash + 1) [:len $cleanUrl]]

                        :local scriptName $fileName
                        :if ([:pick $fileName ([:len $fileName] - 4) [:len $fileName]] = ".rsc") do={
                            :set scriptName [:pick $fileName 0 ([:len $fileName] - 4)]
                        }

                        :set importedScripts ($importedScripts , $scriptName)
                    } else={
                        :log error ($cleanUrl . " download error")
                        :set failCount ($failCount + 1)
                    }
                }
            }

            :log info ("DownloadAndImportScriptsFromList: Processed list. Success: " . $successCount . ", Failed: " . $failCount)

            :if ($cleanupAndRun = true) do={
                :delay 1s

                # Clean up global environment variables starting with an uppercase letter
                :log info "DownloadAndImportScriptsFromList: Removing environment variables..."

                :local upper "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                :foreach id in=[/system script environment find] do={
                    :local envName [/system script environment get $id name]
                    :if ([:len $envName] > 0) do={
                        :local firstChar [:pick $envName 0 1]
                        :if ([:type [:find $upper $firstChar]] = "num") do={
                            /system script environment remove $id
                        }
                    }
                }

                :delay 1s

                # Execute all successfully imported scripts
                :foreach scriptName in=$importedScripts do={
                    :if ([:len [/system script find name=$scriptName]] > 0) do={
                        :log info ("DownloadAndImportScriptsFromList: Running script " . $scriptName)
                        /system script run $scriptName
                    }
                }
            }

            :return true
        }
    } on-error={
        :log error ("DownloadAndImportScriptsFromList: Failed to download list from " . $listUrl)
        :return false
    }
}
