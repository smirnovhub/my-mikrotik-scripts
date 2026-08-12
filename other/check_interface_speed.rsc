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

# This RouterOS script checks the actual link speed of specified Ethernet
# interfaces against expected values passed as key–value parameters.
# For each interface, it reads the current Ethernet link speed and compares
# it with the expected speed.
# If a mismatch is detected, the script builds an alert message and sends
# a private Telegram notification with the device name and details of all
# interfaces with incorrect speeds.
#
# Usage example:
# [$RunScript check_interface_speed ("ether1=1Gbps") ("ether2=1Gbps") ("ether3=1Gbps")]

:global ParseKeyValueStore
:global SendPrivateTelegramMessage

:global largeRedCircleEmoji

:local scriptName "check_interface_speed"

:local argsToParse {$1;$2;$3;$4;$5;$6;$7}
:local interfaces [$ParseKeyValueStore $argsToParse]

:local message ""

:foreach iface,speed in=$interfaces do={
    :local actualSpeed ""

    # Try Ethernet (ether, sfp, sfp+)
    :if ([:len [/interface ethernet find name=$iface]] > 0) do={
        :set actualSpeed [/interface ethernet get $iface speed]
    }

    # If not Ethernet or speed empty
    :if ([:len $actualSpeed] = 0) do={
        :set actualSpeed "N/A"
    }

    # Check speed condition
    :if ($speed != $actualSpeed) do={
        :set message ($message . "$largeRedCircleEmoji <b>$iface</b> speed is not $speed ($actualSpeed)%0A")
    }
}

# Send message if needed
:if ([:len $message] > 0) do={
    :local deviceName [/system identity get name]
    $SendPrivateTelegramMessage ("<b>$deviceName:</b> wrong interface speed detected!%0A" . $message)
}
