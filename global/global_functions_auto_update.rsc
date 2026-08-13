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
:global GetGitHubLastCommitHash
:global DownloadAndImportScript
:global DownloadAndImportScriptsFromList
:global DownloadAndImportScriptsFromGitHubList

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

# Purpose: Query GitHub API to fetch the latest commit SHA hash for a given branch.
# Parameters:
#   $1 - Repository owner (organization or username)
#   $2 - Repository name
#   $3 - Branch name
# Returns: SHA hash string of the latest commit on success, or empty string on error
# Example: :put [$GetGitHubLastCommitHash "smirnovhub" "my-mikrotik-scripts" "master"]
:set GetGitHubLastCommitHash do={
    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return ""
    }

    :local repoOwner [:tostr $1]
    :local repoName [:tostr $2]
    :local repoBranch [:tostr $3]

    :local prefix "GetGitHubLastCommitHash:"

    :if ([:len $repoOwner] = 0) do={
        :log error "$prefix Repository owner parameter is missing."
        :return ""
    }

    :if ([:len $repoName] = 0) do={
        :log error "$prefix Repository name parameter is missing."
        :return ""
    }

    :if ([:len $repoBranch] = 0) do={
        :log error "$prefix Repository branch parameter is missing."
        :return ""
    }

    :local url "https://api.github.com/repos/$repoOwner/$repoName/git/ref/heads/$repoBranch"

    # Prepare HTTP headers
    :local httpHeaders "Accept: application/vnd.github+json,X-GitHub-Api-Version: 2026-03-10"

    :local result [:toarray ""]

    # Fetch data from GitHub API
    :do {
        :set result [/tool fetch url=$url http-header-field=$httpHeaders output=user as-value]
    } on-error={
        :log error "$prefix Failed to execute HTTP request"
        return ""
    }

    :local content ($result->"data")

    # Simple JSON extraction logic for "sha":"<hash>"
    :local searchKey "\"sha\":\""
    :local keyPos [:find $content $searchKey]

    :if ([:type $keyPos] = "num") do={
        :local startPos ($keyPos + [:len $searchKey])
        :local endPos [:find $content "\"" $startPos]

        :if ([:type $endPos] = "num") do={
            :local sha [:pick $content $startPos $endPos]
            :log info "$prefix Latest commit SHA: $sha"
            :return $sha
        } else={
            :log error "$prefix Closing quote for SHA not found"
            :return ""
        }
    } else={
        :log error "$prefix SHA key not found in response"
        :return ""
    }
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
    :global FetchWithRedirect

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
            :local actualHashSum ""
            :if ($expectedHashLen = 8) do={
                :log info "$prefix Checking CRC32 sum..."
                :set actualHashSum [$GetCrc32Sum $newSource]
            } else={
                :if ($expectedHashLen = 32) do={
                    :log info "$prefix Checking MD5 sum..."
                    :set actualHashSum [$GetMd5Sum $newSource]
                } else={
                    :log info "$prefix Checking SHA1 sum..."
                    :set actualHashSum [$GetSha1Sum $newSource]
                }
            }

            :if ($expectedHashSum != $actualHashSum) do={
                :log error "$prefix Hash sum for $scriptName doesn't match: got $actualHashSum but expected $expectedHashSum"
                :return false
            }

            :log info "$prefix Checksum is valid"

            :if ([:len [/system script find name=$scriptName]] > 0) do={
                /system script set [find name=$scriptName] source=$newSource comment=$scriptName
            } else={
                /system script add name=$scriptName source=$newSource comment=$scriptName
            }

            :log info "$prefix Script $scriptName updated successfully."
            :return true
        }
    } on-error={
        :log error ("$prefix Failed to download from $rawUrl")
        :return false
    }
}

# Purpose: Download a text file containing script URLs line-by-line, parse valid
#          entries, and import each script into RouterOS. Optionally cleans up
#          uppercase environment variables and executes all imported scripts.
# Parameters:
#   $1 - URL to the text file (must end with .txt) containing lines formatted as: "<hash> <script_url>"
#   $2 - (Optional) Boolean flag ("true"/"false"). If true, runs all newly imported
#        scripts sequentially after downloading (default: false)
# Returns: Array with execution state:
#   - "error": Boolean indicating whether a critical list fetch error occurred
#   - "success": Number of successfully imported scripts
#   - "failed": Number of scripts that failed to download or import
# Example: $DownloadAndImportScriptsFromList "https://example.com/scripts/list.txt" true
:set DownloadAndImportScriptsFromList do={
    :global SplitStr
    :global TrimStr
    :global EndsWithStr
    :global GetUnixTimestamp
    :global FormatSecondsLong
    :global FetchWithRedirect
    :global DownloadAndImportScript

    :local result [:toarray ""]
    :set ($result->"error") false
    :set ($result->"success") 0
    :set ($result->"failed") 0

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return $result
    }

    :local prefix "DownloadAndImportScriptsFromList:"

    :local listUrl [:tostr $1]

    :if ([:len $listUrl] = 0) do={
        :log error "$prefix List URL parameter is missing."
        :set ($result->"error") true
        :return $result
    }

    :if ([$EndsWithStr $listUrl ".txt"] = false) do={
        :log error "$prefix File name should end with .txt"
        :set ($result->"error") true
        :return $result
    }

    :local runScripts false
    :if ([:tostr $2] = "true") do={
        :set runScripts true
    }

    :local startTs [$GetUnixTimestamp]
    :log info "$prefix Start importing from $listUrl"

    :local maxRetries 3
    :local retryDelay 5s

    :local content ""
    :local fetchAttempt 0

    :while ($fetchAttempt < $maxRetries and [:len $content] = 0) do={
        :set fetchAttempt ($fetchAttempt + 1)
        
        :do {
            :set content [$FetchWithRedirect $listUrl]
        } on-error={
            :set content ""
        }

        :if ([:len $content] = 0 and $fetchAttempt < $maxRetries) do={
            :log warning ("$prefix Retry " . $fetchAttempt . "/" . $maxRetries . " downloading list from " . $listUrl)
            :delay $retryDelay
        }
    }

    :if ([:len $content] = 0) do={
        :log error ("$prefix Failed to download list or content is empty " . $listUrl)
        :set ($result->"error") true
        :return $result
    }

    :local lines [$SplitStr $content ("\n")]
    :local importedScripts [:toarray ""]

    :foreach rawLine in=$lines do={
        # Remove spaces, carriage returns, line feeds, and tabs from both ends
        :local cleanLine [$TrimStr $rawLine]

        # Ignore empty lines and comment lines (starting with #)
        :if ([:len $cleanLine] > 0 and [:pick $cleanLine 0 1] != "#") do={
            :local parts [$SplitStr $cleanLine " "]

            :if ([:len $parts] >= 2) do={
                :local hash [$TrimStr ($parts->0)]
                :local cleanUrl [$TrimStr ($parts->1)]
                :local res false
                :local attempt 0

                :while ($attempt < $maxRetries and $res = false) do={
                    :set attempt ($attempt + 1)
                    :set res [$DownloadAndImportScript $cleanUrl $hash]

                    :if ($res = false and $attempt < $maxRetries) do={
                        :log warning ("$prefix Retry " . $attempt . "/" . $maxRetries . " for " . $cleanUrl)
                        :delay $retryDelay
                    }
                }

                :if ($res = true) do={
                    :log info ("$prefix " . $cleanUrl . " downloaded successfully")
                    :set ($result->"success") ($result->"success" + 1)

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
                    :log error ("$prefix " . $cleanUrl . " download error")
                    :set ($result->"failed") ($result->"failed" + 1)
                }
            } else={
                :log error ("$prefix Hash sum or URL not found in line " . $cleanLine)
                :set ($result->"failed") ($result->"failed" + 1)
            }
        }
    }

    :local logStr ("$prefix Import completed. Success: " . ($result->"success") . ", Failed: " . ($result->"failed"))

    :if ($result->"failed" = 0) do={
        :log info $logStr
    } else={
        :if ($result->"success" = 0) do={
            :log error $logStr
        } else={
            :log warning $logStr
        }
    }

    :if ($runScripts = true) do={
        :delay 1s

        # Execute all successfully imported scripts
        :foreach scriptName in=$importedScripts do={
            :if ([:len [/system script find name=$scriptName]] > 0) do={
                :log info ("$prefix Running script " . $scriptName)
                :do {
                    /system script run $scriptName
                } on-error={
                    :log error ("$prefix Error running " . $scriptName)
                    :set ($result->"success") ($result->"success" - 1)
                    :set ($result->"failed") ($result->"failed" + 1)
                }
            } else={
                :log error "Script not found for execution: $scriptName"
                :set ($result->"success") ($result->"success" - 1)
                :set ($result->"failed") ($result->"failed" + 1)
            }
        }
    }

    :local duration ([$GetUnixTimestamp] - $startTs)
    :log info ("$prefix Finished in " . [$FormatSecondsLong $duration])

    :return $result
}

# Purpose: Check GitHub repository for new commits via API, and if updated,
#          download and import RouterOS scripts from a specified list file URL.
#          Sends Telegram notifications on parsing errors or execution status.
# Parameters:
#   $1 - URL to the .txt file on GitHub containing a list of script URLs
#   $2 - (Optional) Boolean flag/string ("true"). If true, executes imported scripts
# Returns: true on success (or if scripts are already up to date), false on error
# Example: $DownloadAndImportScriptsFromGitHubList "https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/list.txt" true
:set DownloadAndImportScriptsFromGitHubList do={
    :global EndsWithStr
    :global GetSha1Sum
    :global SetGlobalVar
    :global GetGlobalVarOrDefault
    :global GetGitHubLastCommitHash
    :global SendPrivateTelegramMessage
    :global DownloadAndImportScriptsFromList

    :global largeGreenCircleEmoji
    :global largeRedCircleEmoji

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return false
    }

    :local deviceName [/system identity get name]
    :local prefix "DownloadAndImportScriptsFromGitHubList:"

    :local successEmoji $largeGreenCircleEmoji
    :local failEmoji $largeRedCircleEmoji

    :local listUrl [:tostr $1]

    :if ([:len $listUrl] = 0) do={
        :log error "$prefix List URL parameter is missing."
        $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> List URL parameter is missing")
        :return false
    }

    :if ([$EndsWithStr $listUrl ".txt"] = false) do={
        :log error "$prefix File name should end with .txt"
        $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> File name should end with .txt")
        :return false
    }

    :local runScripts false
    :if ([:tostr $2] = "true") do={
        :set runScripts true
    }

    :local owner ""
    :local repo ""
    :local branch ""
    :local filePath ""
    :local lastCommitHash ""

    :local domain "github.com/"
    :local domainPos [:find $listUrl $domain]

    :if ([:type $domainPos] != "num") do={
        :log error "$prefix Failed to parse GitHub URL $listUrl"
        $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> Failed to parse GitHub URL $listUrl")
        :return false
    }

    :local pathStart ($domainPos + [:len $domain])
    :local urlPath [:pick $listUrl $pathStart [:len $listUrl]]

    # Find owner
    :local slash1 [:find $urlPath "/"]
    :set owner [:pick $urlPath 0 $slash1]

    # Find repo
    :local slash2 [:find $urlPath "/" ($slash1 + 1)]
    :set repo [:pick $urlPath ($slash1 + 1) $slash2]

    # Check which URL format we are dealing with
    :local headsMarker "/raw/refs/heads/"
    :local headsPos [:find $urlPath $headsMarker]

    :if ([:type $headsPos] = "num") do={
        # Standard format: .../raw/refs/heads/<branch>/<filePath>
        :local branchStart ($headsPos + [:len $headsMarker])
        :local slash3 [:find $urlPath "/" $branchStart]

        :if ([:type $slash3] != "num") do={
            :log error "$prefix Failed to parse GitHub URL $listUrl"
            $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> Failed to parse GitHub URL $listUrl")
            :return false
        }

        :set branch [:pick $urlPath $branchStart $slash3]
        :set filePath [:pick $urlPath ($slash3 + 1) [:len $urlPath]]

        :set lastCommitHash [$GetGitHubLastCommitHash $owner $repo $branch]
    } else={
        # Direct commit hash format: owner/repo/raw/<commitHash>/<filePath>
        # slash3 = end of "/raw/", slash4 = end of commit hash
        :local slash3 [:find $urlPath "/" ($slash2 + 1)]
        :local slash4 [:find $urlPath "/" ($slash3 + 1)]

        :if ([:type $slash1] != "num" || [:type $slash2] != "num" || [:type $slash3] != "num" || [:type $slash4] != "num") do={
            :log error "$prefix Failed to parse GitHub URL $listUrl"
            $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> Failed to parse GitHub URL $listUrl")
            :return false
        }

        :set lastCommitHash [:pick $urlPath ($slash3 + 1) $slash4]
        :set filePath [:pick $urlPath ($slash4 + 1) [:len $urlPath]]
    }

    :if ([:len $lastCommitHash] = 0) do={
        $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> Empty commit hash extracted from $listUrl")
        :return false
    }

    # Validate that lastCommitHash is non-empty and contains valid hex characters
    :if (!($lastCommitHash ~ "^[0-9a-fA-F]+\$")) do={
        :log error "$prefix Invalid commit hash ($lastCommitHash) extracted from $listUrl"
        $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> Invalid commit hash ($lastCommitHash) extracted from $listUrl")
        :return false
    }

    :local lastCommitGlobalVarName ([$GetSha1Sum $listUrl] . "-last-commit")
    :local storedLastCommitHash [$GetGlobalVarOrDefault $lastCommitGlobalVarName ""]

    :if ($storedLastCommitHash = $lastCommitHash) do={
        :log info "$prefix scripts are up to date. Do nothing"
        :return true
    }

    :local result [$DownloadAndImportScriptsFromList $listUrl $runScripts]

    :if ($result->"error" = false) do={
        :if ($result->"failed" = 0) do={
            $SetGlobalVar $lastCommitGlobalVarName $lastCommitHash
            $SendPrivateTelegramMessage ("<b>$deviceName:</b>%0A$successEmoji All " . ($result->"success") . " scripts updated successfully from $filePath")
        } else={
            :if ($result->"success" = 0) do={
                $SendPrivateTelegramMessage ("<b>$deviceName:</b>%0A$failEmoji All " . ($result->"failed") . " scripts failed to update from $filePath")
            } else={
                $SendPrivateTelegramMessage ("<b>$deviceName:</b>%0A$successEmoji " . ($result->"success") . " scripts updated successfully from $filePath%0A$failEmoji " . ($result->"failed") . " scripts failed to update from $filePath")
            }
        }
    } else={
        $SendPrivateTelegramMessage ("$failEmoji <b>$deviceName:</b> Failed to update scripts from $filePath")
    }

    :return result
}
