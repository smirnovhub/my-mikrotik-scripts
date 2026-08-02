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
# Add script named global_functions_auto_update and then add call to startup script:
# /system script run global_functions_auto_update

# global functions
:global DownloadAndImportScript
:global DownloadAndImportScriptsFromList

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
                /system script set [find name=$scriptName] source=$newSource
            } else={
                /system script add name=$scriptName source=$newSource
            }
            
            :log info "DownloadAndImportScript: Script '$scriptName' updated successfully."
            
            # Execute/load the downloaded script into memory immediately
            /system script run $scriptName
            :return true
        }
    } on-error={
        :log error ("DownloadAndImportScript: Failed to download from " . $rawUrl)
        :return false
    }
}

# Purpose: Download a text file containing script URLs line-by-line, clear global
#          environment variables starting with uppercase letters, download/import
#          each script into RouterOS, and execute all downloaded scripts.
# Parameters:
#   $1 - URL to the text file ending with .txt containing list of script URLs
# Returns: true on successful list processing, or false on error
# Example: $DownloadAndImportScriptsFromList "https://example.com/scripts/list.txt"
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

    :do {
        :local content [$FetchWithRedirect $listUrl]
        :if ([:len $content] > 0) do={
            :local lines [$SplitStr $content ("\n")]
            :local successCount 0
            :local failCount 0
            :local importedScripts [:toarray ""]

            :foreach rawLine in=$lines do={
                # Remove spaces, carriage returns, line feeds, and tabs from both ends
                :local cleanUrl [$TrimStr $rawLine ("\r\n \t")]

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

            :delay 1s

            # Clean up global environment variables starting with an uppercase letter
            :local upper "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

            :foreach id in=[/system script environment find] do={
                :local envName [/system script environment get $id name]
                :if ([:len $envName] > 0) do={
                    :local firstChar [:pick $envName 0 1]
                    :if ([:type [:find $upper $firstChar]] = "num") do={
                        :log info ("Removing environment variable: " . $envName)
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

            :return true
        }
    } on-error={
        :log error ("DownloadAndImportScriptsFromList: Failed to download list from " . $listUrl)
        :return false
    }
}
