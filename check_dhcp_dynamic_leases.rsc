:global SendTelegramMessage
:global GetUnixTimestamp
:global lastDhcpDynamicLeaseWarningTime
:global warningSignEmoji

# Author: Dmitry Smirnov 2025
# Purpose: Detect dynamic (unapproved) DHCP leases and send an alert via Telegram.
# Parameters:
#   (none) - Works directly with the DHCP lease table.
# Globals:
#   SendTelegramMessage              - Function to send messages through the Telegram Bot API.
#   GetUnixTimestamp                 - Function returning the current UNIX timestamp (seconds since 1970).
#   lastDhcpDynamicLeaseWarningTime  - Timestamp of the last sent warning (used for rate limiting).
#   warningSignEmoji                 - Emoji used as a prefix in the Telegram message.
# Constants:
#   warningSendPeriodSec = 900  (minimum interval in seconds between repeated alerts)
# Returns:
#   (none) - Logs a warning and sends a Telegram notification if dynamic leases are detected.
# Notes:
#   - Iterates through all DHCP leases and checks if "dynamic=true".
#   - Collects IP, MAC, and hostname (uses "Unknown" if hostname is empty).
#   - Builds a formatted Telegram message and a plain-text log entry.
#   - Sends an alert only if at least one dynamic lease is found AND the last alert was sent more
#     than warningSendPeriodSec seconds ago.
#
# Add this script to scheduler to run every N minutes

# Send repeated warnings every N seconds
:local warningSendPeriodSec 900

# Initialize a variable to track if any dynamic lease exists
:local foundDynamic false

# Initialize a message with a header
:local deviceName [/system identity get name]
:local message "$warningSignEmoji $deviceName: <b>Dynamic DHCP leases detected!</b>"

# Also prepare a plain-text version for logging
:local logMessage "$deviceName: Dynamic DHCP leases detected!"

# Iterate over all DHCP leases
:foreach lease in=[/ip dhcp-server lease find] do={

    # Check if the lease is dynamic (i.e., not static)
    :local isDynamic [/ip dhcp-server lease get $lease dynamic]

    # If it's dynamic, process it
    :if ($isDynamic) do={

        :set foundDynamic true

        # Collect info about the lease
        :local ip [/ip dhcp-server lease get $lease address]
        :local mac [/ip dhcp-server lease get $lease mac-address]
        :local hostname [/ip dhcp-server lease get $lease host-name]

        # Fallback if hostname is empty
        :if ([:len $hostname] = 0) do={
            :set hostname "Unknown"
        }

        # Append lease info to the message
        :set message ($message . "%0A" . $hostname . " (" . $ip . ", " . $mac . ")")
        :set logMessage ($logMessage . " " . $hostname . " (" . $ip . ", " . $mac . ")")
    }
}

# --- Send Telegram Notification and Log if Needed ---

:if ($foundDynamic) do={
  :local needSendMessage false
  :if ([:len [$lastDhcpDynamicLeaseWarningTime]] > 0) do={
    :local curTime [$GetUnixTimestamp]
    :local diff ($curTime - $lastDhcpDynamicLeaseWarningTime)
    :if ($diff > $warningSendPeriodSec) do={
      :set needSendMessage true
    }
  } else={
    :set needSendMessage true
  }

  :if ($needSendMessage) do={
    # Write to log
    :log info $logMessage

    # Send message using Telegram Bot API
    $SendTelegramMessage $message

    # Update time
    :set lastDhcpDynamicLeaseWarningTime [$GetUnixTimestamp]
  }
}
