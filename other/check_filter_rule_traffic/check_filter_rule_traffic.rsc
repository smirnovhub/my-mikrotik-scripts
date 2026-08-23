# 8888888b.   .d88888b.  888b    888 d8b 88888888888      8888888b.  888     888 888b    888
# 888  "Y88b d88P" "Y88b 8888b   888 88P     888          888   Y88b 888     888 8888b   888
# 888    888 888     888 88888b  888 8P      888          888    888 888     888 88888b  888
# 888    888 888     888 888Y88b 888 "       888          888   d88P 888     888 888Y88b 888
# 888    888 888     888 888 Y88b888         888          8888888P"  888     888 888 Y88b888
# 888    888 888     888 888  Y88888         888          888 T88b   888     888 888  Y88888
# 888  .d88P Y88b. .d88P 888   Y8888         888          888  T88b  Y88b. .d88P 888   Y8888
# 8888888P"   "Y88888P"  888    Y888         888          888   T88b  "Y88888P"  888    Y888
#
#    8888888b. 8888888 8888888b.  8888888888 .d8888b. 88888888888 888    Y88b   d88P 888
#    888  "Y88b  888   888   Y88b 888       d88P  Y88b    888     888     Y88b d88P  888
#    888    888  888   888    888 888       888    888    888     888      Y88o88P   888
#    888    888  888   888   d88P 8888888   888           888     888       Y888P    888
#    888    888  888   8888888P"  888       888           888     888        888     888
#    888    888  888   888 T88b   888       888    888    888     888        888     Y8P
#    888  .d88P  888   888  T88b  888       Y88b  d88P    888     888        888      " 
#    8888888P" 8888888 888   T88b 8888888888 "Y8888P"     888     88888888   888     888
#
# YOU CAN'T RUN THIS SCRIPT DIRECTLY WITHOUT PASSING PARAMETERS!
# USE SCHEDULER TO RUN THIS SCRIPT WITH PARAMETERS BY TIME!

# --- Script to monitor packet count of a specific bridge filter rule ---

# Parameters:
# $1 - filterCommentSubstring
# $2 - ruleName
# $3 - hasUnstable (optional, default true)
# $4 - printLog (optional, default false)

:global JoinArray
:global SplitStr
:global ReplaceStr
:global GetArgOrDefault
:global GetArgOrExit
:global ParseDateTime
:global ParseKeyValueStore
:global DivideIntAndRound
:global GetUnixTimestamp
:global FormatSecondsShort
:global GetGlobalVar
:global SetGlobalVar
:global IsFullyConnected
:global SendPrivateTelegramMessage

:global largeGreenCircleEmoji
:global largeRedCircleEmoji
:global largeYellowCircleEmoji

:local upEmoji $largeGreenCircleEmoji
:local downEmoji $largeRedCircleEmoji
:local unstableEmoji $largeYellowCircleEmoji

:local scriptName "check_filter_rule_traffic"

:local argsToParse {$1;$2;$3;$4;$5;$6;$7}
:local args [$ParseKeyValueStore $argsToParse]

# Get parameters from positional arguments
:local filterCommentSubstring [$GetArgOrExit $args "id" $scriptName]
:local ruleName [$GetArgOrExit $args "name" $scriptName]

:local hasUnstable [$GetArgOrDefault $args "hasUnstable" true]
:local printLog [$GetArgOrDefault $args "printLog" false]

# ===== SETTINGS =====
:local checksCount 10; # How many last values to check
:local upThresholdPercent 70; # High threshold (percent)
:local downThresholdPercent 30; # Low threshold (percent)
:local measureDelay 3; # Delay between two measures of traffic (seconds)
:local noTrafficThreshold 1024; # Threshold to detect no traffic (bytes/s)
:local notificationInterval (3600 * 6); # Send notifications every (seconds)
:local itemDelimiter "-"

# Initialize a message with a header
:local deviceName [/system identity get name]

# Check for fully connected
if ([$IsFullyConnected] = false) do={
    :log warning "$scriptName: skip processing because system is not fully connected"
    :return 0
}

# Get the initial output of the bridge filter statistics as key-value pairs
:local output1 [/interface bridge filter print stats as-value where disabled=no]

# Variable to store the first PACKETS count
:local bytes1 0

# Helper flags
:local found false

# Loop through the output to find the comment and then get BYTES from the next item
:foreach rule in=$output1 do={
    # Check if current item has a comment and if it matches the target
    :if ([:typeof ($rule->"comment")] != "nil") do={
        :local foundIndex [:find ($rule->"comment") $filterCommentSubstring]
        :if ([:typeof $foundIndex] != "nil") do={
            :set bytes1 ($rule->"bytes")
            :set found true
        }
    }
}

# If the comment was not found at all - exit early
:if ( !$found ) do={
    :log error ("[Bridge Monitor] Target comment $filterCommentSubstring not found in bridge filter list")
    :return ""
}

# Variables to hold IP addresses
:local srcIP ""
:local dstIP ""

# Retrieve terse bridge filter rules as key-value objects
:local terseOutput [/interface bridge filter print terse as-value where disabled=no]

# Search for the same comment substring in terse output
:foreach rule in=$terseOutput do={
    :if ([:typeof ($rule->"comment")] != "nil") do={
        :local foundIndex [:find ($rule->"comment") $filterCommentSubstring]
        :if ([:typeof $foundIndex] != "nil") do={
            # Extract src-address and dst-address if present
            :if ([:typeof ($rule->"src-address")] != "nil") do={
                :set srcIP ($rule->"src-address")
            }
            :if ([:typeof ($rule->"dst-address")] != "nil") do={
                :set dstIP ($rule->"dst-address")
            }
        }
    }
}

# If both addresses were not found at all - exit early
:if (($srcIP = "") || ($dstIP = "")) do={
    :log error ("[Bridge Monitor] Src IP and/or Dst IP for $filterCommentSubstring not found in bridge filter list")
    :return ""
}

# Strip /32 if present
:set srcIP [$ReplaceStr $srcIP "/32" ""]
:set dstIP [$ReplaceStr $dstIP "/32" ""]

# Wait a seconds before checking again
:delay ($measureDelay . "s")

# Get the bridge filter statistics again
:local output2 [/interface bridge filter print stats as-value where disabled=no]

# Variable to store the second PACKETS count
:local bytes2 0

# Reset flags
:set found false

# Repeat the same process to find the new BYTES value
:foreach rule in=$output2 do={
    :if ([:typeof ($rule->"comment")] != "nil") do={
        :local foundIndex [:find ($rule->"comment") $filterCommentSubstring]
        :if ([:typeof $foundIndex] != "nil") do={
            :set bytes2 ($rule->"bytes")
            :set found true
        }
    }
}

# If comment not found in second check - report and exit
:if ( !$found ) do={
    :log error ("[Bridge Monitor] Target comment $filterCommentSubstring not found during second check")
    :return ""
}

:local checksVarName ($filterCommentSubstring . "-check")
:local stateVarName ($filterCommentSubstring . "-state")
:local bytesVarName ($filterCommentSubstring . "-bytes")
:local nameVarName ($filterCommentSubstring . "-name")
:local lastUpdateVarName ($filterCommentSubstring . "-last-update")
:local lastNotificationVarName ($filterCommentSubstring . "-last-notification")

$SetGlobalVar $nameVarName $ruleName

:local tryToSendNotification do={
    :global GetUnixTimestamp
    :global SendPrivateTelegramMessage
    :global GetGlobalVar
    :global SetGlobalVar

    :local message $1
    :local varName $2
    :local notificationInterval $3

    :local lastNotificationTimestamp [$GetGlobalVar $varName 0]
    :local currentTs [$GetUnixTimestamp]

    if ($currentTs > ($lastNotificationTimestamp + $notificationInterval)) do={
        $SendPrivateTelegramMessage $message
        $SetGlobalVar $varName [$GetUnixTimestamp]
    }
}

:local traffic (($bytes2 - $bytes1) / $measureDelay)

# ===== UPDATE COUNTERS =====
# If bytes are changed set line to "1"
# Otherwise, set line to "0"
:local line "0"
:if ($traffic > $noTrafficThreshold) do={
    :set line "1"
}

# ===== LOAD, APPEND AND TRIM =====
# Read current content
:local currentChecks [$GetGlobalVar $checksVarName ""]
:local currentBytes [$GetGlobalVar $bytesVarName ""]
:local lastUpdateTime [$GetGlobalVar $lastUpdateVarName 0]

:local currentTimestamp [$GetUnixTimestamp]
:local lastUpdateTimestamp [:tonum $lastUpdateTime]
:local lastUpdateSeconds ($currentTimestamp - $lastUpdateTimestamp)

# Append new check result (1 or 0) followed by newline
:set currentChecks ($currentChecks . $itemDelimiter . $line)

# Append bytes
:set currentBytes ($currentBytes . $itemDelimiter . $traffic)

# Parse vars into arrays
:local checksArr [$SplitStr $currentChecks $itemDelimiter]
:local bytesArr [$SplitStr $currentBytes $itemDelimiter]

# Keep only the last $checksCount elements
:local totalChecksCount [:len $checksArr]
:if ($totalChecksCount > $checksCount) do={
    :local startIndex ($totalChecksCount - $checksCount)
    :set checksArr [:pick $checksArr $startIndex $totalChecksCount]
}

:local totalBytesCount [:len $bytesArr]
:if ($totalBytesCount > $checksCount) do={
    :local startIndex ($totalBytesCount - $checksCount)
    :set bytesArr [:pick $bytesArr $startIndex $totalBytesCount]
}

# ===== COUNT ONES AND CALCULATE PERCENTAGE =====
:set totalChecksCount [:len $checksArr]
:local onesCount 0
:foreach v in=$checksArr do={
    :if ($v = "1") do={ :set onesCount ($onesCount + 1) }
}

:local percent (($onesCount * 100) / $totalChecksCount)

:set totalBytesCount [:len $bytesArr]
:local totalTrafficSpeed 0
:foreach v in=$bytesArr do={
    :set totalTrafficSpeed ($totalTrafficSpeed + [:tonum $v])
}

:set totalTrafficSpeed [$DivideIntAndRound ($totalTrafficSpeed * 8) ($totalBytesCount * 1024 * 1024) 1]

# ===== REBUILD DATA =====
:set currentChecks [$JoinArray $checksArr $itemDelimiter]
$SetGlobalVar $checksVarName $currentChecks

:set currentBytes [$JoinArray $bytesArr $itemDelimiter]
$SetGlobalVar $bytesVarName $currentBytes
$SetGlobalVar $lastUpdateVarName [$GetUnixTimestamp]

# Load state
:local state [$GetGlobalVar $stateVarName "empty"]

:local upMessageText "$upEmoji $deviceName: seems registrator for <b>$ruleName</b> works properly."
:local downMessageText "$downEmoji $deviceName: seems registrator for <b>$ruleName</b> doesn't work."
:local unstableMessageText "$unstableEmoji $deviceName: seems registrator for <b>$ruleName</b> works unstable."

:set upMessageText "$upMessageText Traffic between $srcIP and $dstIP is stable ($totalTrafficSpeed Mbit/s)"
:set downMessageText "$downMessageText No traffic between $srcIP and $dstIP ($totalTrafficSpeed Mbit/s)"
:set unstableMessageText "$unstableMessageText Traffic between $srcIP and $dstIP is unstable ($totalTrafficSpeed Mbit/s)"

:local getPingStatus do={
    :global SilentPing
    :local ip $1
    :local upEmoji $2
    :local downEmoji $3
    :for i from=1 to=3 do={
        :if ([$SilentPing $ip] > 0) do={
            :return "$upEmoji $ip is up"
        }
    }
    :return "$downEmoji $ip is down"
}

:local srcPingStatus [$getPingStatus $srcIP $upEmoji $downEmoji]
:local dstPingStatus [$getPingStatus $dstIP $upEmoji $downEmoji]
:local lastUpdateSecondsText ("<i>Last update: " . [$FormatSecondsShort $lastUpdateSeconds] . " ago</i>")

# ===== DECISION =====
:if ($percent >= $upThresholdPercent) do={
    # ===== UP ACTION =====
    :if ($printLog = true) do={
        :log info ($ruleName . ": " . $srcIP . " <-> " . $dstIP . " check success rate high: " . $percent . "% speed: $totalTrafficSpeed Mbit/s - performing UP action")
    }

    # Check state and update if needed
    :if ($state = "up") do={
        :if ($printLog = true) do={
            :log info ("Traffic between " . $srcIP . " <-> " . $dstIP . " is already $state")
        }
    } else={
        :log info ("Traffic between " . $srcIP . " <-> " . $dstIP . " is up")

        :if ($state != "empty") do={
            $SendPrivateTelegramMessage ($upMessageText . "%0A" . $srcPingStatus . "%0A" . $dstPingStatus . "%0A" . $lastUpdateSecondsText)
        }

        # Save up state
        $SetGlobalVar $stateVarName "up"
        $SetGlobalVar $lastNotificationVarName [$GetUnixTimestamp]
    }
} else={
    :if ($percent < $downThresholdPercent) do={
        # ===== DOWN ACTION =====
        :if ($printLog = true) do={
            :log info ($ruleName . ": " . $srcIP . " <-> " . $dstIP . " check success rate low: " . $percent . "% speed: $totalTrafficSpeed Mbit/s - performing DOWN action")
        }

        :local message ($downMessageText . "%0A" . $srcPingStatus . "%0A" . $dstPingStatus . "%0A" . $lastUpdateSecondsText)

        # Check state and update if needed
        :if ($state = "down") do={
            :if ($printLog = true) do={
                :log info ("Traffic between " . $srcIP . " <-> " . $dstIP . " is already $state")
            }
            $tryToSendNotification $message $lastNotificationVarName $notificationInterval
        } else={
            :log info ("Traffic between " . $srcIP . " <-> " . $dstIP . " is down")

            :if ($state != "empty") do={
                $SendPrivateTelegramMessage $message
            }

            # Save down state
            $SetGlobalVar $stateVarName "down"
            $SetGlobalVar $lastNotificationVarName [$GetUnixTimestamp]
        }
    } else={
        # ===== UNSTABLE ACTION =====
        :if ($printLog = true) do={
            :log info ($ruleName . ": " . $srcIP . " <-> " . $dstIP . " check success rate unstable: " . $percent . "% speed: $totalTrafficSpeed Mbit/s - performing UNSTABLE action")
        }

        :local message ($unstableMessageText . "%0A" . $srcPingStatus . "%0A" . $dstPingStatus . "%0A" . $lastUpdateSecondsText)

        # Check state and update if needed
        :if ($hasUnstable = true) do={
            :if ($state = "unstable") do={
                :if ($printLog = true) do={
                    :log info ("Traffic between " . $srcIP . " <-> " . $dstIP . " is already $state")
                }
                $tryToSendNotification $message $lastNotificationVarName $notificationInterval
            } else={
                :log info ("Traffic between " . $srcIP . " <-> " . $dstIP . " is unstable")

                :if ($state != "empty") do={
                    $SendPrivateTelegramMessage $message
                }

                # Save unstable state
                $SetGlobalVar $stateVarName "unstable"
                $SetGlobalVar $lastNotificationVarName [$GetUnixTimestamp]
            }
        } else={
            :log info ("Traffic between " . $srcIP . " <-> " . $dstIP . " is $state")
        }
    }
}
