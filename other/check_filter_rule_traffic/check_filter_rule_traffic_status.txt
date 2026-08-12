# --- Script to print status of packet count of a specific bridge filter rule ---

:global SilentPing
:global JoinArray
:global SplitStr
:global JoinArray
:global ReplaceStr
:global ContainsStr
:global StartsWithStr
:global GetArgOrDefault
:global GetArgOrExit
:global ParseKeyValueStore
:global DivideIntAndRound
:global GetCurrentDateTime
:global GetUnixTimestamp
:global ToUnixTimestamp
:global ParseDateTime
:global FormatSecondsShort
:global GetGlobalVarOrDefault
:global SetGlobalVar
:global SendPrivateTelegramMessage

:global largeGreenCircleEmoji
:global largeRedCircleEmoji
:global largeYellowCircleEmoji
:global whiteCircleEmoji
:global nbsp

:local upEmoji $largeGreenCircleEmoji
:local downEmoji $largeRedCircleEmoji
:local unstableEmoji $largeYellowCircleEmoji
:local unknownEmoji $whiteCircleEmoji

:local scriptName "check_filter_rule_traffic_status"

:local argsToParse {$1;$2;$3;$4;$5;$6;$7}
:local args [$ParseKeyValueStore $argsToParse]

:local printToConsole [$GetArgOrDefault $args "printToConsole" false]

:local itemDelimiter "-"

# Initialize a message with a header
:local deviceName [/system identity get name]

:local suffix "-check.txt"

:local suffixLen [:len $suffix]

# Initialize an empty array to store results
:local filterCommentSubstrings []

# Get the initial output of the bridge filter statistics as key-value pairs
:local output1 [/interface bridge filter print stats as-value where disabled=no]

# Loop through the output to find the comment and then get BYTES from the next item
:foreach rule in=$output1 do={
    # Check if current item has a comment and if it matches the target
    :local comment ($rule->"comment")
    :if ([:typeof $comment] != "nil") do={
        :if ([$ContainsStr $comment "CAMERA-"] = true) do={
            :local words [$SplitStr $comment " "]
            :foreach w in=$words do={
                :if ([$StartsWithStr $w "CAMERA-"] = true) do={
                     :set filterCommentSubstrings ($filterCommentSubstrings, $w)
                }
            }
        }
    }
}

:local message ""

:for i from=0 to=([:len $filterCommentSubstrings] - 1) do={
    :local filterCommentSubstring ($filterCommentSubstrings->$i)
    :local ruleVarName ($filterCommentSubstring . "-name")
    :local stateVarName ($filterCommentSubstring . "-state")
    :local bytesVarName ($filterCommentSubstring . "-bytes")
    :local lastUpdateVarName ($filterCommentSubstring . "-last-update")

    :local ruleName "Unknown"
    :local ruleNameContent [$GetGlobalVarOrDefault $ruleVarName ""]
    :if ([:len $ruleNameContent] > 0) do={
        :set ruleName $ruleNameContent
    }

    :local state "unknown"
    :local stateContent [$GetGlobalVarOrDefault $stateVarName ""]
    :if ([:len $stateContent] > 0) do={
        :set state $stateContent
    }

    :local bytesArr []
    :local lastUpdateTimestamp 0

    :local bytesContent [$GetGlobalVarOrDefault $bytesVarName ""]
    :if ([:len $bytesContent] > 0) do={
        :set bytesArr [$SplitStr $bytesContent $itemDelimiter]
        :set lastUpdateTimestamp [$GetGlobalVarOrDefault $lastUpdateVarName 0]
    }

    :local totalBytesCount [:len $bytesArr]
    :local totalTrafficSpeed 0
    :foreach v in=$bytesArr do={
        :set totalTrafficSpeed ($totalTrafficSpeed + [:tonum $v])
    }

    :local currentTimestamp [$GetUnixTimestamp]
    :local lastUpdateSeconds ($currentTimestamp - $lastUpdateTimestamp)

    # Skip old records
    if ($lastUpdateSeconds < 300) do={
        :local lastUpdateSecondsText ("<i>Last update: " . [$FormatSecondsShort $lastUpdateSeconds] . " ago</i>")

        :set totalTrafficSpeed [$DivideIntAndRound ($totalTrafficSpeed * 8) ($totalBytesCount * 1024 * 1024) 1]

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
       
        # Function to perform 3 pings and return true if any is successful
        :local pingSuccess do={
            :global SilentPing
            :local ip $1
            :for i from=1 to=3 do={
                :if ([$SilentPing $ip 1] > 0) do={
                    :return true
                }
            }
            :return false
        }
       
        :local topEmoji $unknownEmoji
        :local srcIPText ""
        :local dstIPText ""
        :local stateText "maybe works."
       
        if ($state = "up") do={
            :set topEmoji $upEmoji
            :set stateText "works properly."
        } else={
            if ($state = "down") do={
                :set topEmoji $downEmoji
                :set stateText "doesn't work."
            } else={
                if ($state = "unstable") do={
                    :set topEmoji $unstableEmoji
                    :set stateText "works unstable."
                } 
            }
        }
       
        # If both addresses were not found at all - exit early
        :if (($srcIP != "") && ($dstIP != "")) do={
            # Strip /32 if present
            :set srcIP [$ReplaceStr $srcIP "/32" ""]
            :set dstIP [$ReplaceStr $dstIP "/32" ""]
       
            # Test srcIP
            :if ([$pingSuccess $srcIP]) do={
                :set srcIPText "$upEmoji $srcIP is up"
            } else={
                :set srcIPText "$downEmoji $srcIP is down"
            }
       
            # Test dstIP
            :if ([$pingSuccess $dstIP]) do={
                :set dstIPText "$upEmoji $dstIP is up"
            } else={
                :set dstIPText "$downEmoji $dstIP is down"
            }

            :set message "$topEmoji $deviceName: seems registrator for <b>$ruleName</b> $stateText"
            :set message ($message . " Traffic between $srcIP and $dstIP is $state ($totalTrafficSpeed" . $nbsp . "Mbit/s)%0A")
            :set message ($message . "$srcIPText%0A")
            :set message ($message . "$dstIPText%0A")
            :set message ($message . $lastUpdateSecondsText)
        }
    }
}

:if ($printToConsole = true) do={
  # Print message to console
  :put $message
} else={
  # --- Send one Telegram message containing all hosts ---
  $SendPrivateTelegramMessage $message
}
