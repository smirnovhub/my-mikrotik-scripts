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
# Add script named global_functions_auto_update and then add call to startup script
# system script run global_functions_auto_update

# global functions
:global FetchWithRedirect
:global FetchWithRedirectAndRetry
:global ParseScriptsListFromUrl
:global DownloadAndImportScript
:global DownloadAndImportScriptsFromList

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

    :local prefix "FetchWithRedirect:"

    :local currentUrl [:tostr $1]
    :if ([:len $currentUrl] = 0) do={
        :log error "$prefix URL parameter is missing."
        :return ""
    }

    # Redirect markers for different RouterOS versions:
    # " <30" for RouterOS 6
    # failure: closing connection: <302 Found "https://mikrotik.com/"> 159.148.172.205:80 (4)
    #
    # " 30" for RouterOS 7
    # failure: Fetch failed with status 302 (Location: "https://mikrotik.com/") (/tool/fetch; line 1)
    :local redirectMarkers {" <30"; " 30"}

    # RouterOS 6 failure output:
    # failure: closing connection: <404 Not Found> 172.17.17.2:443 (4)
    #
    # RouterOS 7 failure output:
    # failure: Fetch failed with status 404 (/tool/fetch; line 1)
    :local failureMarker "failure:"

    :local maxRedirects 5
    :local redirectCount 0

    :local timeoutMs 10000
    :local checkIntervalMs 500
    :local elapsedMs 0

    :log info "$prefix Fetching $currentUrl"

    :while (true) do={
        :do {
            # Attempt direct sync download in-memory via as-value
            :local fetchRes [/tool fetch url=$currentUrl output=user as-value]
            :if ($fetchRes->"status" = "finished") do={
                :return ($fetchRes->"data")
            } else={
                :log error "$prefix Failed to fetch $currentUrl"
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
                :log error "$prefix Request to $currentUrl timed out"
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
                        :log error ("$prefix Too many redirects (max: " . $maxRedirects . ") for URL: " . $currentUrl)
                        :return ""
                    }

                    # Extract target URL enclosed in quotes
                    :local quoteStart [:find $logContent "\"" $markerPos]
                    :if ([:type $quoteStart] = "num") do={
                        :local startPos ($quoteStart + 1)
                        :local restStr [:pick $logContent $startPos [:len $logContent]]
                        :local endPos [:find $restStr "\""]

                        :if ([:type $endPos] = "num") do={
                            :set nextUrl [:pick $restStr 0 $endPos]
                        }
                    }
                } else={
                    # Parse generic error message
                    :local failurePos [:find $logContent $failureMarker]
                    :if ([:type $failurePos] = "num") do={
                        :set errorMessage [:pick $logContent ($failurePos + [:len $failureMarker]) [:len $logContent]]
                        :set errorMessage [$TrimStr $errorMessage]
                    }
                }
            }

            # If a redirect URL was found, advance to the next iteration
            :if ([:len $nextUrl] > 0) do={
                :if ($nextUrl = $currentUrl) do={
                    :log error "$prefix Circular redirect to $nextUrl"
                    :return ""
                }

                :set redirectCount ($redirectCount + 1)
                :log info ("$prefix Following 3xx redirect (" . $redirectCount . "/" . $maxRedirects . ") to " . $nextUrl)
                :set currentUrl $nextUrl
            } else={
                # Unrecoverable error (HTTP error status, network error, or log extraction failed)
                :if ([:len $errorMessage] > 0) do={
                    :log error "$prefix Error fetching $currentUrl: $errorMessage"
                } else={
                    :log error "$prefix Failed to fetch $currentUrl"
                }
                :return ""
            }
        }
    }

    :log error ("$prefix Too many redirects (max: " . $maxRedirects . ") for URL: " . $currentUrl)
    :return ""
}

# Purpose: Download content from a URL with support for HTTP 3xx redirects
#          and retry logic. Attempts multiple times with a delay on failure.
# Parameters:
#   $1 - Target URL to fetch content from
#   $2 - (Optional) Maximum number of retries (default: 3)
# Returns: String with downloaded content on success, or empty string on failure
# Example: :put [$FetchWithRedirectAndRetry "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/list.txt" 5]
:set FetchWithRedirectAndRetry do={
    :global FetchWithRedirect

    # Workaround for the MikroTik RouterOS interpreter bug
    :if ([:len $0] = 0) do={
        :return ""
    }

    :local prefix "FetchWithRedirectAndRetry:"

    :local targetUrl [:tostr $1]
    :if ([:len $targetUrl] = 0) do={
        :log error "$prefix URL parameter is missing."
        :return ""
    }

    :local maxRetries 3
    :if ([:len $2] > 0) do={
        :set maxRetries [:tonum $2]
    }

    :local retryDelay 5s
    :local fetchAttempt 0

    :local content ""

    :while ($fetchAttempt < $maxRetries and [:len $content] = 0) do={
        :set fetchAttempt ($fetchAttempt + 1)

        :do {
            :set content [$FetchWithRedirect $targetUrl]
        } on-error={
            :set content ""
        }

        :if ([:len $content] = 0 and $fetchAttempt <= $maxRetries) do={
            :log warning ("$prefix Retry " . $fetchAttempt . "/" . $maxRetries . " downloading from " . $targetUrl)
            :delay $retryDelay
        }
    }

    :if ([:len $content] = 0) do={
        :log error ("$prefix Failed to download URL or its content is empty " . $targetUrl)
    }

    :return $content
}

# Purpose: Download and parse a text file containing script URLs and hashes.
#          Includes retry logic, ignores comments or empty lines, and constructs
#          an associative array with script details.
# Parameters:
#   $1 - Target URL of the .txt list file to fetch and parse
# Returns: Associative array keyed by script name, where each item contains:
#          - url: Cleaned URL for downloading the script
#          - hash: Hash sum provided in the list
#          - hashtype: Auto-detected hash algorithm (md5, sha1, sha256, sha512, unknown)
#          - scriptname: Extracted file name from the URL
#          - listname: Identifier of the source list (last two URL segments)
# Example: :put [$ParseScriptsListFromUrl "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/list.txt"]
:set ParseScriptsListFromUrl do={
    :global SplitStr
    :global TrimStr
    :global EndsWithStr
    :global ExtractFileName
    :global FetchWithRedirectAndRetry

    :local result [:toarray ""]

    # Workaround for the MikroTik RouterOS interpreter bug
    :if ([:len $0] = 0) do={
        :return $result
    }

    :local prefix "ParseScriptsListFromUrl:"

    :local listUrl [:tostr $1]

    :if ([:len $listUrl] = 0) do={
        :log error "$prefix List URL parameter is missing."
        :return $result
    }

    :if ([$EndsWithStr $listUrl ".txt"] = false) do={
        :log error "$prefix File name should end with .txt"
        :return $result
    }

    :local content [$FetchWithRedirectAndRetry $listUrl]

    :if ([:len $content] = 0) do={
        :log error ("$prefix Failed to download URL list or it content is empty " . $listUrl)
        :return $result
    }

    # Extract listname by taking the last two parts of the URL
    :local listParts [$SplitStr $listUrl "/"]
    :local listPartsLen [:len $listParts]
    :local listName ""
    :if ($listPartsLen >= 2) do={
        :set listName (($listParts->($listPartsLen - 2)) . "/" . ($listParts->($listPartsLen - 1)))
    } else={
        :set listName $listUrl
    }

    :local lines [$SplitStr $content ("\n")]

    :foreach rawLine in=$lines do={
        # Remove spaces, carriage returns, line feeds, and tabs from both ends
        :local cleanLine [$TrimStr $rawLine]

        # Ignore empty lines and comment lines
        :if ([:len $cleanLine] > 0 and [:pick $cleanLine 0 1] != "#") do={
            :local parts [$SplitStr $cleanLine " "]

            :if ([:len $parts] >= 2) do={
                :local hash [$TrimStr ($parts->0)]
                :local cleanUrl [$TrimStr ($parts->1)]

                # Extract script name from URL
                :local scriptName [$ExtractFileName $cleanUrl]

                # Determine hash type based on string length
                :local hashLen [:len $hash]
                :local hashType "unknown"
                :if ($hashLen = 8) do={ :set hashType "crc32" }
                :if ($hashLen = 32) do={ :set hashType "md5" }
                :if ($hashLen = 40) do={ :set hashType "sha1" }
                :if ($hashLen = 64) do={ :set hashType "sha256" }
                :if ($hashLen = 128) do={ :set hashType "sha512" }

                # Build associative array and append to result
                :local parsedItem { "url"=$cleanUrl; "hash"=$hash; "hashtype"=$hashType; "scriptname"=$scriptName; "listname"=$listName }

                :set ($result->$scriptName) $parsedItem
            } else={
                :log error ("$prefix Hash sum or URL not found in line " . $cleanLine)
            }
        }
    }

    :return $result
}

# Purpose: Download a .rsc script from a URL, update or create it in RouterOS 
#          system scripts, and execute it immediately.
# Parameters:
#   $1 - URL to the script file ending with .rsc
# Returns: true on successful script update and execution, or false on failure
# Example: $DownloadAndImportScript "https://example.com/scripts/my_script.rsc"
:set DownloadAndImportScript do={
    :global GetCrc32Sum
    :global GetMd5Sum
    :global GetSha1Sum
    :global EndsWithStr
    :global ExtractFileName
    :global FetchWithRedirectAndRetry

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return false
    }

    :local prefix "DownloadAndImportScript:"

    :local rawUrl [:tostr $1]
    :local expectedHashSum [:tostr $2]

    :if ([:len $rawUrl] = 0) do={
        :log error "$prefix URL parameter is missing."
        :return false
    }

    :local expectedHashLen [:len $expectedHashSum]

    :if ($expectedHashLen = 0) do={
        :log error "$prefix Hash sum parameter is missing."
        :return false
    }

    :if ($expectedHashLen != 8 && $expectedHashLen != 32 && $expectedHashLen != 40) do={
        :log error "$prefix Wrong hash. Only CRC32, MD5 and SHA1 supported."
        :return false
    }

    :if ([$EndsWithStr $rawUrl ".rsc"] = false) do={
        :log error "$prefix File name should end with .rsc"
        :return false
    }

    # Extract script name from URL (filename without extension)
    :local scriptName [$ExtractFileName $rawUrl false]

    :local newSource [$FetchWithRedirectAndRetry $rawUrl]

    :if ([:len $newSource] = 0) do={
        :log error "$prefix $scriptName content is empty"
        :return false
    }

    :local actualHashSum ""

    :if ($expectedHashLen = 8) do={
        :log info "$prefix $scriptName checking CRC32 sum..."
        :set actualHashSum [$GetCrc32Sum $newSource]
    } else={
        :if ($expectedHashLen = 32) do={
            :log info "$prefix $scriptName checking MD5 sum..."
            :set actualHashSum [$GetMd5Sum $newSource]
        } else={
            :log info "$prefix $scriptName checking SHA1 sum..."
            :set actualHashSum [$GetSha1Sum $newSource]
        }
    }

    :if ($expectedHashSum != $actualHashSum) do={
        :log error "$prefix $scriptName hash sum doesn't match: got $actualHashSum but expected $expectedHashSum"
        :return false
    }

    :log info "$prefix $scriptName checksum is valid"

    :do {
        :if ([:len [/system script find name=$scriptName]] > 0) do={
            /system script set [find name=$scriptName] source=$newSource comment=$scriptName
        } else={
            /system script add name=$scriptName source=$newSource comment=$scriptName
        }
    } on-error={
        :log error "$prefix $scriptName failed to import"
        :return false
    }

    :log info "$prefix $scriptName imported successfully"
    :return true
}

# Purpose: Download a text file containing script URLs line-by-line, parse valid
#          entries, and import or update each script into RouterOS system scripts.
#          Optionally executes imported and up-to-date scripts after downloading.
# Parameters:
#   $1 - URL to the text file (must end with .txt) containing lines formatted as: "<hash> <script_url>"
#   $2 - (Optional) Boolean flag ("true"/"false"). If true, runs all imported/up-to-date
#        scripts sequentially after processing (default: false)
# Returns: Array with execution state:
#   - "error": Boolean indicating whether a critical list fetch error occurred
#   - "updated": Array of script names that were successfully updated/imported
#   - "uptodate": Array of script names that were already up-to-date
#   - "failedtoupdate": Array of script names that failed to download or import
#   - "runned": Array of script names that executed successfully
#   - "failedtorun": Array of script names that failed during execution
# Example: $DownloadAndImportScriptsFromList "https://example.com/scripts/list.txt" true
:set DownloadAndImportScriptsFromList do={
    :global EndsWithStr
    :global ReplaceStr
    :global GetUnixTimestamp
    :global FormatSecondsLong
    :global SetGlobalVar
    :global GetGlobalVar
    :global DownloadAndImportScript
    :global RecursiveMergeSortStr
    :global SendPrivateTelegramMessage
    :global ParseScriptsListFromUrl

    :global largeGreenCircleEmoji
    :global largeRedCircleEmoji

    :local result [:toarray ""]

    :set ($result->"error") false
    :set ($result->"updated") [:toarray ""]
    :set ($result->"failedtoupdate") [:toarray ""]
    :set ($result->"uptodate") [:toarray ""]
    :set ($result->"runned") [:toarray ""]
    :set ($result->"failedtorun") [:toarray ""]

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return $result
    }

    :local deviceName [/system identity get name]
    :local prefix "DownloadAndImportScriptsFromList:"

    :local successEmoji $largeGreenCircleEmoji
    :local failEmoji $largeRedCircleEmoji

    :local listUrl [:tostr $1]

    :if ([:len $listUrl] = 0) do={
        :set ($result->"error") true
        :log error "$prefix List URL parameter is missing."
        $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> List URL parameter is missing")
        :return $result
    }

    :if ([$EndsWithStr $listUrl ".txt"] = false) do={
        :set ($result->"error") true
        :log error "$prefix File name should end with .txt"
        $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> File name should end with .txt")
        :return $result
    }

    :local runScripts false
    :if ([:tostr $2] = "true") do={
        :set runScripts true
    }

    :local sendMessage true
    :if ([:tostr $3] = "false") do={
        :set sendMessage false
    }

    :local startTs [$GetUnixTimestamp]
    :log info "$prefix Start importing from $listUrl"

    :local parsedList [$ParseScriptsListFromUrl $listUrl]

    :if ([:len $parsedList] = 0) do={
        :set ($result->"error") true
        :log error ("$prefix Failed to download URL list or its content is empty " . $listUrl)
        $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> Failed to download URL list or its content is empty " . $listUrl)
        :return $result
    }

    :local importedScripts [:toarray ""]

    :local GetHashGlobalVarName do={
        :global ReplaceStr
        :return ([$ReplaceStr $1 "_" "-"] . "-hash")
    }

    # Process each parsed item from the list
    :foreach item in=$parsedList do={
        :local scriptName ($item->"scriptname")
        :local hashVarName [$GetHashGlobalVarName $scriptName]
        :local oldHash [$GetGlobalVar $hashVarName ""]
        :local scriptExists ([:len [/system script find name=$scriptName]] > 0)

        :if ($oldHash = ($item->"hash") && $scriptExists) do={
            :log info ("$prefix " . $scriptName . " is already up to date")
            :set ($result->"uptodate") (($result->"uptodate"), $scriptName)
            :set importedScripts ($importedScripts, $scriptName)
        } else={
            :log info ("$prefix " . $scriptName . " downloading from " . ($item->"url"))

            :local res [$DownloadAndImportScript ($item->"url") ($item->"hash")]

            :if ($res = true) do={
                :log info ("$prefix " . $scriptName . " imported successfully")

                :set ($result->"updated") (($result->"updated"), $scriptName)
                :set importedScripts ($importedScripts, $scriptName)

                $SetGlobalVar $hashVarName ($item->"hash")
            } else={
                :log error ("$prefix " . $scriptName . " download error")
                :set ($result->"failedtoupdate") (($result->"failedtoupdate"), $scriptName)
            }
        }
    }

    :local logStr ("$prefix Import completed. Success: " . [:len ($result->"updated")] . ", Failed: " . [:len ($result->"failedtoupdate")] . ", Up to date: " . [:len ($result->"uptodate")])

    :if ([:len ($result->"failedtoupdate")] = 0) do={
        :log info $logStr
    } else={
        :if ([:len ($result->"updated")] = 0) do={
            :log error $logStr
        } else={
            :log warning $logStr
        }
    }

    :if ($runScripts) do={
        :delay 1s

        # Execute all successfully imported scripts
        :foreach scriptName in=$importedScripts do={
            :local hashVarName [$GetHashGlobalVarName $scriptName]

            :if ([:len [/system script find name=$scriptName]] > 0) do={
                :log info ("$prefix Running script " . $scriptName)
                :do {
                    /system script run $scriptName
                    :set ($result->"runned") (($result->"runned"), $scriptName)
                } on-error={
                    :log error ("$prefix Error running " . $scriptName)
                    :set ($result->"failedtorun") (($result->"failedtorun"), $scriptName)

                    # Reset stored hash so the script is retried on next run
                    $SetGlobalVar $hashVarName ""
                }
            } else={
                :log error "Script not found for execution: $scriptName"
                :set ($result->"failedtorun") (($result->"failedtorun"), $scriptName)

                # Reset stored hash so the script is retried on next run
                $SetGlobalVar $hashVarName ""
            }
        }
    }

    :local duration ([$GetUnixTimestamp] - $startTs)
    :log info ("$prefix Finished in " . [$FormatSecondsLong $duration])

    :if ($result->"error") do={
        $SendPrivateTelegramMessage ("$largeRedCircleEmoji <b>$deviceName:</b> Failed to update scripts from $listUrl")
        :return $result
    }

    # There are no updates to report, so exit early
    :if ([:len ($result->"updated")] = 0 && [:len ($result->"failedtoupdate")] = 0 && [:len ($result->"failedtorun")] = 0) do={
        :return $result
    }

    :local msg "<b>$deviceName</b> scripts auto update:%0A"

    :local FormatList do={
        :global EllipsisStrCenter
        :global RecursiveMergeSortStr

        :local list [$RecursiveMergeSortStr $1]
        :local str ""
        :local indent "      "
        :foreach item in=$list do={
            :if ([:len $str] > 0) do={
                :set str ($str . "%0A" . $indent)
            }
            :set str ($str . [$EllipsisStrCenter $item 25])
        }
        :return ($indent . $str)
    }

    :if ([:len ($result->"updated")] > 0) do={
        :set msg ($msg . "$successEmoji <b>Updated:</b>%0A" . [$FormatList ($result->"updated")] . "%0A")
    }

    :if ([:len ($result->"uptodate")] > 0) do={
        :set msg ($msg . "$successEmoji <b>Up to date:</b>%0A" . [$FormatList ($result->"uptodate")] . "%0A")
    }

    :if ([:len ($result->"failedtoupdate")] > 0) do={
        :set msg ($msg . "$failEmoji <b>Failed to update:</b>%0A" . [$FormatList ($result->"failedtoupdate")] . "%0A")
    }

    :if ([:len ($result->"failedtorun")] > 0) do={
        :set msg ($msg . "$failEmoji <b>Failed to run:</b>%0A" . [$FormatList ($result->"failedtorun")] . "%0A")
    }

    :set msg ($msg . "<i>Source: $listUrl</i>")

    :if ($sendMessage) do={
        $SendPrivateTelegramMessage $msg
    }

    :return $result
}
