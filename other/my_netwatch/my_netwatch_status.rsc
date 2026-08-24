:global GetGlobalVar
:global SetGlobalVar
:global ReplaceStr
:global DivideIntAndRound
:global GetCurrentDateTime
:global GetUnixTimestamp
:global ToUnixTimestamp
:global FormatSecondsShort
:global SendPrivateTelegramMessage
:global ParseDateTime
:global ParseKeyValueStore
:global GetArgOrDefault

:global largeGreenCircleEmoji
:global largeRedCircleEmoji
:global largeYellowCircleEmoji
:global whiteCircleEmoji

# Parameters:
# reset - (optional, default false)
#      Reset all statistics
# printToConsole - (optional, default false)
#      Put everything to console

:local scriptName "my_netwatch_status"

:local argsToParse {$1;$2;$3;$4;$5;$6;$7}
:local args [$ParseKeyValueStore $argsToParse]

:local resetStatistics [$GetArgOrDefault $args "reset" false]
:local printToConsole [$GetArgOrDefault $args "printToConsole" false]

:local deviceName [/system identity get name]

# --- Initialize message list for Telegram ---
# Start the message with deviceName on a separate line
:local messageText ("<b>$deviceName</b> current status:")

:local pingDateVarName "my-netwatch-ping-start-date"

:local upEmoji $largeGreenCircleEmoji
:local downEmoji $largeRedCircleEmoji
:local unstableEmoji $largeYellowCircleEmoji
:local unknownEmoji $whiteCircleEmoji

:local pingDateText [$GetGlobalVar $pingDateVarName ""]

:if ([:len $pingDateText] = 0 || $resetStatistics = true) do={
    $SetGlobalVar $pingDateVarName [$GetUnixTimestamp]
}

:foreach i in=[/system scheduler find where disabled=no] do={
    # --- Check if scheduler name contains at least 1 dot (position >= 0) ---
    # Using :find returns the position of the first "." in the scheduler name.
    # If a dot exists (position >= 0), we consider this scheduler as containing an IP.
    :if ([:find [/system scheduler get $i name] "."] >= 0) do={
        # --- Get scheduler name and comment ---
        # schedName: The name of the scheduler task, used here as the host.
        # schedComment: The comment associated with the scheduler, used to extract hostName.
        :local schedName [/system scheduler get $i name]
        :local schedComment [/system scheduler get $i comment]

        # --- Set host variable ---
        # Host is taken directly from the scheduler name.
        :local host $schedName
        :local hostStr [$ReplaceStr $host "." "-"]

        # --- Extract hostName from comment ---
        :local hostName ""
        # If a comment exists, use it as hostName
        :if ([:len $schedComment] > 0) do={
            :set hostName $schedComment
            # Remove the prefix "check " from the hostName if it exists
            :if ([:pick $hostName 0 6] = "check ") do={
                :set hostName [:pick $hostName 6 [:len $hostName]]
            }
        }

        # Get last update time
        :local pingAge -1

        :local lastPingTimeVarName ($hostStr . "-last-ping-time")
        :local lastPingTimeContent [$GetGlobalVar $lastPingTimeVarName ""]
        :if ([:len $lastPingTimeContent] > 0) do={
            :local lastupdateUnixTimestamp [:tonum $lastPingTimeContent]
            :local currentUnixTimestamp [$GetUnixTimestamp]
            :set pingAge ($currentUnixTimestamp - $lastupdateUnixTimestamp)
        }

        # --- Read state ---
        :local stateVarName ($hostStr . "-state")
        :local state "unknown"
        :local stateContent [$GetGlobalVar $stateVarName ""]
        :if ([:len $stateContent] > 0) do={
            :set state $stateContent
        }

        # ===== NEW: CALCULATE PERCENTAGE FROM SUCCESS/FAIL =====
        # we now use two separate vars:
        # - host-ping-success-count : number of successful pings
        # - host-ping-fail-count    : number of failed pings
        #
        # The success percentage is calculated as:
        # successPercent = (successCount / (successCount + failCount)) * 100
        #
        # If both vars are empty or contain 0, percentage is considered 0.
        :local pingSuccessVarName ($hostStr . "-ping-success-count")
        :local pingFailVarName ($hostStr . "-ping-fail-count")

        :local pingSuccessContent [$GetGlobalVar $pingSuccessVarName ""]
        :local pingFailContent [$GetGlobalVar $pingFailVarName ""]

        :local successCount 0
        :local failCount 0

        # Read success count
        :if ([:len $pingSuccessContent] > 0) do={
            :set successCount [:tonum $pingSuccessContent]
        }

        # Read fail count
        :if ([:len $pingFailContent] > 0) do={
            :set failCount [:tonum $pingFailContent]
        }

        :local total ($successCount + $failCount)

        :local successfulPingPercent -1
        :if ($total > 0) do={
            :set successfulPingPercent [$DivideIntAndRound ($successCount * 100) $total "0"]
        }

        :local statusText ("      Ping success: $successfulPingPercent%, Ping age: " . [$FormatSecondsShort $pingAge])

        # ===== END OF SUCCESS/FAIL PERCENTAGE =====

        # ===== NEW: RESET STATISTICS IF PARAMETER IS TRUE =====
        :if ($resetStatistics = true) do={
            # Reset success and fail counters if requested
            $SetGlobalVar $pingSuccessVarName 0
            $SetGlobalVar $pingFailVarName 0
        }
        # ===== END OF RESET STATISTICS =====

        # --- Build Telegram message for this host ---
        :local hostMessage ""
        :if ($state = "up") do={
            :set hostMessage ("$upEmoji%20<b>$hostName</b> $host is $state%0A$statusText")
        } else={
            :if ($state = "down") do={
                :set hostMessage ("$downEmoji%20<b>$hostName</b> $host is $state%0A$statusText")
            } else={
                # Only set unstable if state string is exactly "unstable"
                :if ($state = "unstable") do={
                    :set hostMessage ("$unstableEmoji%20<b>$hostName</b> $host is $state%0A$statusText")
                } else={
                    :set hostMessage ("$unknownEmoji%20$hostName $host state is unknown")
                }
            }
        }

        # --- Append this host's message to overall Telegram message ---
        :if ([:len $messageText] > 0) do={ :set messageText ($messageText . "%0A") }
        :set messageText ($messageText . $hostMessage)
    }
}

:if ($resetStatistics = true) do={
    :return 0
}

:if ([:len $pingDateText] > 0) do={
    :local currentTs [$GetUnixTimestamp]
    :local dateTs [:tonum $pingDateText]
    :local sec ($currentTs - $dateTs)
    :local formattedTime [$FormatSecondsShort $sec]
    :set messageText ($messageText . "%0A<i>Ping statistics for last " . $formattedTime . "</i>")
}

:if ($printToConsole = true) do={
  # Print message to console
  :put $messageText
} else={
  # --- Send one Telegram message containing all hosts ---
  $SendPrivateTelegramMessage $messageText
}
