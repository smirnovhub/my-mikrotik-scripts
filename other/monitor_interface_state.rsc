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
# This script automatically monitors the status of a selected network port on a MikroTik router
# and instantly reacts to link failures. As soon as a cable is disconnected or the connection
# drops, the system immediately registers the event. The script keeps track of exactly how many
# times the interface has gone down during the current day. This counter automatically resets to
# zero at midnight, starting a fresh count for the next day. If the number of drops within a
# single day exceeds your defined limit, the script immediately sends a critical alert message
# to your Telegram. It runs entirely in the background, does not overload the router's CPU, and
# is protected against duplicate tasks. You can run it simultaneously to monitor multiple different
# ports at the same time.
#
# YOU CAN'T RUN THIS SCRIPT DIRECTLY WITHOUT PASSING PARAMETERS!
# BEFORE RE-RUN YOU NEED TO KILL PREVIOUS TASK JOBS FROM SYSTEM -> SCRIPTS -> JOBS!!!
#
# Parameters:
# $1 - interface
# The name of the specific network port that needs to be monitored around the clock.
#
# $2 - max_drop_count
# The daily limit for connection drops. If the port drops more times than this number
# in a single day, you will receive a Telegram notification.
#
# Usage example:
# [$RunScript monitor_interface_state ("interface=ether5") ("max_drop_count=3")]
#
# The script must be run once at system startup to launch the background monitoring job.
# As an optional step for added reliability, you can add it to the system scheduler.
# This ensures the monitor automatically restarts if the background process is accidentally closed.

:global GetArgOrExit
:global GetArgOrDefault
:global ParseKeyValueStore
:global SendPrivateTelegramMessage
:global GetGlobalVar
:global SetGlobalVar

:global largeRedCircleEmoji

:local scriptName "monitor_interface_state"

:local argsToParse {$1;$2;$3;$4;$5;$6;$7}
:local args [$ParseKeyValueStore $argsToParse]

:local interface [$GetArgOrExit $args "interface" $scriptName]
:local maxDropCount [$GetArgOrDefault $args "max_drop_count" 0]
:local ignoredTimeStart [$GetArgOrDefault $args "ignoredTimeStart" "00:00:00"]
:local ignoredTimeEnd [$GetArgOrDefault $args "ignoredTimeEnd" "00:00:00"]

# Construct unique global variable names based on the interface argument
:local jobVarName ($interface . "-state-job-id")
:local stateVarName ($interface . "-running-state")
:local countVarName ($interface . "-down-count")
:local dateVarName ($interface . "-last-down-date")
:local thresholdVarName ($interface . "-max-drop-count")
:local ignoredTimeStartVarName ($interface . "-ignored-time-start")
:local ignoredTimeEndVarName ($interface . "-ignored-time-end")

# Read the existing job ID from the dynamic global variable
:local currentJobID [$GetGlobalVar $jobVarName ""]

# Check if the monitoring job is currently active
:local isJobActive [/system script job find where .id=$currentJobID]

# If the job already exists, exit the script immediately to avoid duplicate processes and log errors
:if ([:len $isJobActive] > 0) do={
  :return 0
}

/log info "Running interface monitoring job for $interface..."

# Reset the specific job ID variable to default empty value (*0)
$SetGlobalVar $jobVarName *0

# Initialize the state variable on script start
:local currentActualState [/interface ethernet get [find name=$interface] running]
$SetGlobalVar $stateVarName $currentActualState

$SetGlobalVar $thresholdVarName $maxDropCount
$SetGlobalVar $ignoredTimeStartVarName $ignoredTimeStart
$SetGlobalVar $ignoredTimeEndVarName $ignoredTimeEnd

:global InterfaceStateEventHandler do={
  :global SendPrivateTelegramMessage
  :global GetGlobalVar
  :global SetGlobalVar
  :global largeRedCircleEmoji

  :local scriptName "monitor_interface_state"

  :local ifaceName $1
  :local dynamicStateVar ($ifaceName . "-running-state")
  :local dynamicCountVar ($ifaceName . "-down-count")
  :local dynamicDateVar ($ifaceName . "-last-down-date")
  :local thresholdVar ($ifaceName . "-max-drop-count")
  :local ignoredTimeStartVar ($ifaceName . "-ignored-time-start")
  :local ignoredTimeEndVar ($ifaceName . "-ignored-time-end")

  :local deviceName [/system identity get name]
  :local currentDate [/system clock get date]

  :local threshold [$GetGlobalVar $thresholdVar 0]
  :local ignoredTimeStart [$GetGlobalVar $ignoredTimeStartVar "00:00:00"]
  :local ignoredTimeEnd [$GetGlobalVar $ignoredTimeEndVar "00:00:00"]

  # Check ignoring time
  :local currentTime [/system clock get time]
  :local ignore false

  :if ($ignoredTimeStart != $ignoredTimeEnd) do={
    # Normal interval (e.g. 08:00:00-18:00:00)
    :if ($ignoredTimeStart < $ignoredTimeEnd) do={
      :if ($currentTime >= $ignoredTimeStart && $currentTime < $ignoredTimeEnd) do={
        :set ignore true
      }
    } else={
      # Interval crossing midnight (e.g. 23:00:00-06:00:00)
      :if ($currentTime >= $ignoredTimeStart || $currentTime < $ignoredTimeEnd) do={
        :set ignore true
      }
    }
  }

  # Get the current actual 'running' status of the interface
  :local currentState [:tostr [/interface ethernet get [find name=$ifaceName] running]]
  :local lastKnownState [$GetGlobalVar $dynamicStateVar ""]
  :local lastSavedDate [$GetGlobalVar $dynamicDateVar ""]
  :local currentCount [$GetGlobalVar $dynamicCountVar 0]

  :local downEmoji $largeRedCircleEmoji

  # Reset counter if the date has changed (Midnight reset) or if the variable is empty
  :local dateType [:typeof $lastSavedDate]
  :if ($dateType = "nothing" or $dateType = "nil" or $currentDate != $lastSavedDate) do={
    :set currentCount 0
    $SetGlobalVar $dynamicDateVar $currentDate
    $SetGlobalVar $dynamicCountVar 0
    :set lastSavedDate $currentDate
  }

  # If the state has actually changed, process the event
  :if ($currentState != $lastKnownState) do={
    $SetGlobalVar $dynamicStateVar $currentState

    :if ($ignore) do={
      :log warning "$scriptName: skip processing because time is ignored ($ignoredTimeStart - $ignoredTimeEnd)"
      :return 0
    } else={
      :if ($currentState = true) do={
        /log info "$deviceName: interface $ifaceName is UP"
        # Put your UP actions here
      } else={
        # Increment the Down counter
        :set currentCount ($currentCount + 1)
        $SetGlobalVar $dynamicCountVar $currentCount

        /log warning "$deviceName: interface $ifaceName is DOWN"
        # Put your DOWN actions here

        # Check if the down count exceeds the defined threshold
        :if ($currentCount > $threshold) do={
          /log warning "Interface $ifaceName dropped $currentCount times today!"
          $SendPrivateTelegramMessage ("$downEmoji <b>$deviceName:</b> interface $ifaceName dropped $currentCount times today!")
        }
      }
    }
  }
  :return 0
}

# Build the dynamic code string to pass variables cleanly inside the background execute workspace
:local executeCode (":global InterfaceStateEventHandler; /interface ethernet print follow-only where name=" . $interface . " [\$InterfaceStateEventHandler \$name ]")

# Start a non-blocking background job that infinitely monitors interface for any state updates, 
# executing the 'InterfaceStateEventHandler' function dynamically whenever a change occurs, and store the new process ID
:local newJobID [:execute $executeCode]
$SetGlobalVar $jobVarName $newJobID
