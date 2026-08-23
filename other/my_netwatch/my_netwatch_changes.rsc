:global GetGlobalVar
:global SetGlobalVar
:global ReplaceStr
:global IsFullyConnected
:global SendPrivateTelegramMessage
:global ToUpperCase

:global largeGreenCircleEmoji
:global largeRedCircleEmoji
:global largeYellowCircleEmoji
:global whiteCircleEmoji
:global backhandIndexPointingLeftEmoji
:global nbsp

:local scriptName "my_netwatch_changes"
:local deviceName [/system identity get name]

# Check for fully connected
if ([$IsFullyConnected] = false) do={
    :log warning "$scriptName: skip processing because system is not fully connected"
    :return 0
}

# --- Initialize message list for Telegram ---
# Start the message with deviceName on a separate line
:local messageText ("<b>$deviceName</b> state changed:")

:local upEmoji $largeGreenCircleEmoji
:local downEmoji $largeRedCircleEmoji
:local unstableEmoji $largeYellowCircleEmoji
:local unknownEmoji $whiteCircleEmoji
:local leftHandEmoji $backhandIndexPointingLeftEmoji

# --- Counter for updated states ---
# This counter will be used to track how many hosts had non-empty -upd-state
# If the counter remains 0, no message will be sent to Telegram
:local updCount 0

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

        # --- Read state ---
        :local state "unknown"
        :local isUpd false

        # --- First check -upd-state ---
        # If it is not empty -> use this state, then clear the data and mark as update
        # If it is empty -> fallback to -state
        # If it does not exist -> also fallback to -state
        :local hostStr [$ReplaceStr $host "." "-"]
        :local updStateVarName ($hostStr . "-upd-state")
        :local updContent [$GetGlobalVar $updStateVarName ""]

        :if ([:len $updContent] > 0) do={
            # Use updated state
            :set state $updContent
            # Clear content after reading so it won't be reused
            $SetGlobalVar $updStateVarName ""
            # Mark that this came from -upd-state
            :set isUpd true
            # Increase counter of updated hosts
            :set updCount ($updCount + 1)
        } else={
            # If -upd-state exists but is empty, fallback to normal -state
            :local stateVarName ($hostStr . "-state")
            :set state [$GetGlobalVar $stateVarName ""]
        }

        # --- Build Telegram message for this host ---
        :local hostMessage ""

        # Normal message construction with emoji
        :if ($state = "up") do={
            :set hostMessage ("$upEmoji%20$hostName $host is $state")
        } else={
            :if ($state = "down") do={
                :set hostMessage ("$downEmoji%20$hostName $host is $state")
            } else={
                # Only set unstable if state string is exactly "unstable"
                :if ($state = "unstable") do={
                    :set hostMessage ("$unstableEmoji%20$hostName $host is $state")
                } else={
                    :set hostMessage ("$unknownEmoji%20$hostName $host state is unknown")
                }
            }
        }

        # --- Wrap in bold if state was from -upd-state ---
        # This makes the entire message visually stand out in Telegram
        :if ($isUpd) do={
            :set hostMessage ("<b>" . [$ToUpperCase $hostMessage] . "</b>$nbsp$leftHandEmoji")
        }

        # --- Append this host's message to overall Telegram message ---
        # Messages are concatenated with "%0A" (newline for Telegram)
        :if ([:len $messageText] > 0) do={ :set messageText ($messageText . "%0A") }
        :set messageText ($messageText . $hostMessage)
    }
}

# --- Send one Telegram message containing all hosts ---
# Only send if at least one host had a non-empty -upd-state
:if ($updCount > 0) do={
    $SendPrivateTelegramMessage $messageText
}
