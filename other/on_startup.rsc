# Author: Dmitry Smirnov 2025

:global WaitFullyConnected
:global SendPrivateTelegramMessage

:global globalFunctionsReady
:global largeGreenCircleEmoji

:local attempts 0
:local maxAttempts 30
:local delay 500ms

:log info "Wait for global functions ready..."

:while ($globalFunctionsReady != true && $attempts < $maxAttempts) do={
    :delay $delay
    :set attempts ($attempts + 1)
}

:local totalTime ($attempts * $delay)

:if ($globalFunctionsReady != true) do={
    :log error ("globalFunctionsReady not set after " . $maxAttempts . " attempts (" . $totalTime . ")")
    :error "Initialization failed"
}

:log info ("globalFunctionsReady=true after " . $attempts . " attempts (" . $totalTime . ")")

:log info "Wait for fully connected..."
:local waitTime [$WaitFullyConnected]
:log info ("Wait for fully connected... done in " . $waitTime)

:log info "Sending startup message..."
:local deviceName [/system identity get name]
$SendPrivateTelegramMessage ("$largeGreenCircleEmoji <b>$deviceName:</b> The system is started up")
