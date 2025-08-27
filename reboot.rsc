# Author: Dmitry Smirnov 2025

:global SendTelegramMessage
:global warningSignEmoji

:local deviceName [/system identity get name]
:local message "$warningSignEmoji $deviceName: The system is going down for reboot now"
$SendTelegramMessage $message

delay 3s

/system reboot
