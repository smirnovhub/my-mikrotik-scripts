# Author: Dmitry Smirnov 2025

:global SendPrivateTelegramMessage
:global warningSignEmoji

:local deviceName [/system identity get name]
:local message "$warningSignEmoji $deviceName: The system is going down for reboot now"
$SendPrivateTelegramMessage $message

delay 3s

/system reboot
