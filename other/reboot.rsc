# Author: Dmitry Smirnov 2025

:global SendPrivateTelegramMessage
:global warningSignEmoji

:local deviceName [/system identity get name]
$SendPrivateTelegramMessage ("$warningSignEmoji <b>$deviceName:</b> The system is going down for reboot now")

delay 1s

/system reboot
