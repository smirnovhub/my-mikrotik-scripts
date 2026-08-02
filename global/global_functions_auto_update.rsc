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
    :global GetMd5Sum
    :global EndsWithStr
    :global FetchWithRedirect

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return false
    }

    :local rawUrl [:tostr $1]
    :local expectedMd5Sum [:tostr $2]

    :if ([:len $rawUrl] = 0) do={
        :log error "DownloadAndImportScript: URL parameter is missing."
        :return false
    }

    :if ([:len $expectedMd5Sum] != 32) do={
        :log error "DownloadAndImportScript: Wrong expected MD5 sum."
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
            :local actualMd5Sum [$GetMd5Sum $newSource]
            :if ($expectedMd5Sum != $actualMd5Sum) do={
                :log info ("MD5 sum for " . $scriptName . " doesn't match: got " . $actualMd5Sum . " but expected " . $expectedMd5Sum)
                :return false
            }

            :if ([:len [/system script find name=$scriptName]] > 0) do={
                /system script set [find name=$scriptName] source=$newSource comment=$scriptName
            } else={
                /system script add name=$scriptName source=$newSource comment=$scriptName
            }

            :log info "DownloadAndImportScript: Script $scriptName updated successfully."
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

    :local runScripts false
    :if ([:tostr $2] = "true") do={
        :set runScripts true
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
                :local cleanLine [$TrimStr $rawLine ("\r\n\t ")]

                # Ignore empty lines and comment lines (starting with #)
                :if ([:len $cleanLine] > 0 and [:pick $cleanLine 0 1] != "#") do={
                    :local parts [$SplitStr $cleanLine " "]
                    :local cleanUrl ""
                    :local res false

                    :if ([:len $parts] >= 2) do={
                        :local md5 ($parts->0)
                        :set cleanUrl ($parts->1)
                        :set res [$DownloadAndImportScript $cleanUrl $md5]
                    } else={
                        :log error ("MD5 hash or URL not found in line " . $cleanLine)
                    }

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
                        :log error ($cleanLine . " download error")
                        :set failCount ($failCount + 1)
                    }
                }
            }

            :log info ("DownloadAndImportScriptsFromList: Processed list. Success: " . $successCount . ", Failed: " . $failCount)

            :if ($runScripts = true) do={
                :delay 1s

                # Execute all successfully imported scripts
                :foreach scriptName in=$importedScripts do={
                    :if ([:len [/system script find name=$scriptName]] > 0) do={
                        :log info ("DownloadAndImportScriptsFromList: Running script " . $scriptName)
                        :do {
                            /system script run $scriptName
                        } on-error={
                            :log error ("DownloadAndImportScriptsFromList: Error running " . $scriptName)
                        }
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
