# 8888888b.  888     888 888b    888             d8888 88888888888
# 888   Y88b 888     888 8888b   888            d88888     888
# 888    888 888     888 88888b  888           d88P888     888
# 888   d88P 888     888 888Y88b 888          d88P 888     888
# 8888888P"  888     888 888 Y88b888         d88P  888     888
# 888 T88b   888     888 888  Y88888        d88P   888     888
# 888  T88b  Y88b. .d88P 888   Y8888       d8888888888     888
# 888   T88b  "Y88888P"  888    Y888      d88P     888     888
#
#  .d8888b. 88888888888     d8888 8888888b. 88888888888 888
# d88P  Y88b    888        d88888 888   Y88b    888     888
# Y88b.         888       d88P888 888    888    888     888
#  "Y888b.      888      d88P 888 888   d88P    888     888
#     "Y88b.    888     d88P  888 8888888P"     888     888
#       "888    888    d88P   888 888 T88b      888     Y8P
# Y88b  d88P    888   d8888888888 888  T88b     888      " 
#  "Y8888P"     888  d88P     888 888   T88b    888     888
#
# YOU NEED TO RUN THIS SCRIPT AT SYSTEM START!
# OR IF YOU CHANGED SOMETHING IN THIS FILE!
#
# Add script named global_functions and then add call to startup script:
# /system script run global_functions
# RUN THIS SCRIPT LAST, AFTER ALL OTHER GLOBAL SCRIPTS!
#
# Sources and original authors:
# https://github.com/eworm-de/routeros-scripts.git
# https://github.com/osamahfarhan/mikrotik.git
# https://forum.mikrotik.com/
# and many others...
#

# global variables not to be changed by user
:global globalFunctionsReady false

# global functions
:global DNSIsResolving
:global WaitDNSResolving
:global DefaultRouteIsReachable
:global WaitDefaultRouteReachable
:global TimeIsSync
:global WaitTimeSync
:global WaitFullyConnected
:global GetRouterOSVersion

# check if DNS is resolving
:set DNSIsResolving do={
  :do {
    :resolve "dns.google"
  } on-error={
    :return false
  }
  :return true
}

# wait for DNS to resolve
:set WaitDNSResolving do={
  :global DNSIsResolving

  :local delay 1s
  :local attempts 0

  :while ([$DNSIsResolving] = false) do={
    :delay $delay
    :set attempts ($attempts + 1)
  }

  # return total wait time
  :return ($attempts * $delay)
}

# default route is reachable
:set DefaultRouteIsReachable do={
  :if ([:len [/ip route find where dst-address=0.0.0.0/0 active !blackhole !routing-mark !unreachable gateway!=loopback]] > 0) do={
    :return true
  }
  :return false
}

# wait for default route to be reachable
:set WaitDefaultRouteReachable do={
  :global DefaultRouteIsReachable

  :local delay 1s
  :local attempts 0

  :while ([$DefaultRouteIsReachable] = false) do={
    :delay $delay
    :set attempts ($attempts + 1)
  }

  # return total wait time
  :return ($attempts * $delay)
}

# check if system time is sync
:set TimeIsSync do={
  :if ([/system ntp client get enabled] = true) do={
    :do {
        # RouterOS 6.x
        :if ([:typeof [/system ntp client get last-adjustment]] = "time") do={
            :return true
        }

        :return false
    } on-error={
      # RouterOS 7.x
      :if ([/system ntp client get status] = "synchronized") do={
        :return true
      }

      :return false
    }
  }

  :log error "TimeIsSync: NTP client is not enabled!"
  :return true
}

# wait for time to become synced
:set WaitTimeSync do={
  :global TimeIsSync

  :local delay 1s
  :local attempts 0

  :while ([$TimeIsSync] = false) do={
    :delay $delay
    :set attempts ($attempts + 1)
  }

  # return total wait time
  :return ($attempts * $delay)
}

# wait to be fully connected (default route is reachable, time is sync, DNS resolves)
:set WaitFullyConnected do={
  :global WaitDefaultRouteReachable
  :global WaitDNSResolving
  :global WaitTimeSync

  :local totalTime 0

  :set totalTime ($totalTime + [$WaitDefaultRouteReachable])
  :set totalTime ($totalTime + [$WaitDNSResolving])
  :set totalTime ($totalTime + [$WaitTimeSync])

  :return $totalTime
}

# Function to get RouterOS version like 7.21.5
:set GetRouterOSVersion do={
    # Get the raw version string from system resources
    :local rawVersion [/system resource get version]

    # Find the position of the first space
    :local spacePos [:find $rawVersion " "]

    # Strip everything after the space if it exists
    :if ($spacePos >= 0) do={
        :return [:pick $rawVersion 0 $spacePos]
    }

    :return $rawVersion
}

# Signal we are ready
:set globalFunctionsReady true
