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

# Beep to monitoring calls
#:beep frequency=1500 length=100ms

:global JoinArray
:global SplitStr
:global ReplaceStr
:global GetWeekday
:global GetArgOrDefault
:global GetArgOrExit
:global ParseKeyValueStore
:global GetUnixTimestamp
:global SendPrivateTelegramMessage
:global GetGlobalVarOrDefault
:global SetGlobalVar

:global largeGreenCircleEmoji
:global largeRedCircleEmoji
:global largeYellowCircleEmoji

# Parameters:
# $1 - host
# $2 - name
# $3 - hasUnstable (optional, default true)
# $4 - printLog (optional, default false)

:local scriptName "my_netwatch"

:local argsToParse {$1;$2;$3;$4;$5;$6;$7}
:local args [$ParseKeyValueStore $argsToParse]

:local host [$GetArgOrExit $args "host" $scriptName]

:local hostName [$GetArgOrExit $args "name" $scriptName]

:local hasUnstable [$GetArgOrDefault $args "hasUnstable" true]
:local printLog [$GetArgOrDefault $args "printLog" false]

:local ignoredWeekday [$GetArgOrDefault $args "ignoredWeekday" "friday"]
:local ignoredTimeStart [$GetArgOrDefault $args "ignoredTimeStart" "00:00:00"]
:local ignoredTimeEnd [$GetArgOrDefault $args "ignoredTimeEnd" "00:00:00"]

# ===== SETTINGS =====
:local pingsCount 10; # How many last values to check
:local hostUpThresholdPercent 70; # High threshold (percent)
:local hostDownThresholdPercent 30; # Low threshold (percent)
:local itemDelimiter "-"

:local upEmoji $largeGreenCircleEmoji
:local downEmoji $largeRedCircleEmoji
:local unstableEmoji $largeYellowCircleEmoji

:local deviceName [/system identity get name]
:local upMessageText "$upEmoji $deviceName: <b>$hostName</b> $host is up"
:local downMessageText "$downEmoji $deviceName: <b>$hostName</b> $host is down"
:local unstableMessageText "$unstableEmoji $deviceName: <b>$hostName</b> $host is unstable"

# Check ignoring time
:local weekday [$GetWeekday [$GetUnixTimestamp]]
if ($weekday = $ignoredWeekday) do={
    :local currentTime [/system clock get time]
    if ($currentTime > $ignoredTimeStart && $currentTime < $ignoredTimeEnd) do={
        :log warning "$scriptName: skip processing for $hostName $host because time is ignored ($weekday, $ignoredTimeStart - $ignoredTimeEnd)"
        :return 0
    }
}

# Define variable names
:local hostStr [$ReplaceStr $host "." "-"]
:local pingsVarName ($hostStr . "-ping")
:local stateVarname ($hostStr . "-state")
:local updStateVarName ($hostStr . "-upd-state")
:local pingSuccessVarName ($hostStr . "-ping-success-count")
:local pingFailVarName ($hostStr . "-ping-fail-count")
:local lastPingTimeVarName ($hostStr . "-last-ping-time")

# Perform a single ping to the specified host
# The /ping command returns the number of successful replies (0 if none)
:local result [/ping $host count=1]

# If the ping was successful (result > 0), set line to "1"
# Otherwise, set line to "0"
:local line "0"
:if ($result > 0) do={
    :set line "1"
}

$SetGlobalVar $lastPingTimeVarName [$GetUnixTimestamp]

# ===== UPDATE COUNTERS =====
:if ($line = "1") do={
    # --- SUCCESS CASE ---
    # Read current success counter value
    :local successCount [$GetGlobalVarOrDefault $pingSuccessVarName ""]
    :if ([:len $successCount] = 0) do={ :set successCount "0" }
    :set successCount ($successCount + 1)
    $SetGlobalVar $pingSuccessVarName $successCount
} else={
    # --- FAIL CASE ---
    # Read current fail counter value
    :local failCount [$GetGlobalVarOrDefault $pingFailVarName ""]
    :if ([:len $failCount] = 0) do={ :set failCount "0" }
    :set failCount ($failCount + 1)
    $SetGlobalVar $pingFailVarName $failCount
}

# ===== LOAD, APPEND AND TRIM =====
:local current [$GetGlobalVarOrDefault $pingsVarName ""]

# Append new ping result (1 or 0) followed by newline
:set current ($current . $itemDelimiter . $line)

# Parse data into array of values (0/1 only)
:local arr [$SplitStr $current $itemDelimiter]

# Keep only the last $pingsCount elements
:local total [:len $arr]
:if ($total > $pingsCount) do={
    :local startIndex ($total - $pingsCount)
    :set arr [:pick $arr $startIndex $total]
}

# ===== COUNT ONES AND CALCULATE PERCENTAGE =====
:local count [:len $arr]
:local onesCount 0
:foreach v in=$arr do={
    :if ($v = "1") do={ :set onesCount ($onesCount + 1) }
}

:local percent (($onesCount * 100) / $count)

# ===== REBUILD DATA =====
:set current [$JoinArray $arr $itemDelimiter]
$SetGlobalVar $pingsVarName $current

# Load state
:local state [$GetGlobalVarOrDefault $stateVarname ""]

# ===== DECISION =====
:if ($percent >= $hostUpThresholdPercent) do={
    # ===== UP ACTION =====
    :if ($printLog = true) do={
        :log info ($scriptName . ": " . $hostName . " " . $host . " ping success rate high: " . $percent . "% - performing UP action")
    }

    # Check state and update if needed
    :if ($state = "up") do={
        :if ($printLog = true) do={
            :log info ($scriptName . ": " . $hostName . " " . $host . " is already $state")
        }
    } else={
        :log info ($scriptName . ": " . $hostName . " " . $host . " is up")
        #$SendPrivateTelegramMessage $upMessageText
        # Save up state
        $SetGlobalVar $stateVarname "up"
        $SetGlobalVar $updStateVarName "up"
    }
} else={
    :if ($percent < $hostDownThresholdPercent) do={
        # ===== DOWN ACTION =====
        :if ($printLog = true) do={
            :log info ($scriptName . ": " . $hostName . " " . $host . " ping success rate low: " . $percent . "% - performing DOWN action")
        }

        # Check state and update if needed
        :if ($state = "down") do={
            :if ($printLog = true) do={
                :log info ($scriptName . ": " . $hostName . " " . $host . " is already $state")
            }
        } else={
            :log info ($scriptName . ": " . $hostName . " " . $host . " is down")
            #$SendPrivateTelegramMessage $downMessageText
            # Save down state
            $SetGlobalVar $stateVarname "down"
            $SetGlobalVar $updStateVarName "down"
        }
    } else={
        # ===== UNSTABLE ACTION =====
        :if ($printLog = true) do={
            :log info ($scriptName . ": " . $hostName . " " . $host . " ping success rate unstable: " . $percent . "% - performing UNSTABLE action")
        }

        # Check state and update if needed
        :if ($hasUnstable = true) do={
            :if ($state = "unstable") do={
                :if ($printLog = true) do={
                    :log info ($scriptName . ": " . $hostName . " " . $host . " is already $state")
                }
            } else={
                :log info ($scriptName . ": " . $hostName . " " . $host . " is unstable")
                #$SendPrivateTelegramMessage $unstableMessageText
                # Save unstable state
                $SetGlobalVar $stateVarname "unstable"
                $SetGlobalVar $updStateVarName "unstable"
            }
        } else={
            :if ($printLog = true) do={
                :log info ($scriptName . ": " . $hostName . " " . $host . " is unstable, but in state $state")
            }
        }
    }
}
