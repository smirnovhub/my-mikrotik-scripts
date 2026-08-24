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
:global IsFullyConnected
:global WaitFullyConnected

# Purpose: Check if DNS is successfully resolving external domains.
# Parameters: None
# Returns: True if DNS resolution succeeds, false otherwise.
:set DNSIsResolving do={
  :do {
    :resolve "dns.google"
  } on-error={
    :return false
  }
  :return true
}

# Purpose: Wait in a loop until DNS resolution becomes successful.
# Parameters: None
# Returns: Total time spent waiting for DNS to resolve.
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

# Purpose: Check if the default network route is active and reachable.
# Parameters: None
# Returns: True if an active default route exists, false otherwise.
:set DefaultRouteIsReachable do={
  :if ([:len [/ip route find where dst-address=0.0.0.0/0 active !blackhole !routing-mark !unreachable gateway!=loopback]] > 0) do={
    :return true
  }
  :return false
}

# Purpose: Wait until the default network route becomes reachable.
# Parameters: None
# Returns: Total time spent waiting for the default route.
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

# Purpose: Check if the system time is synchronized via NTP.
# Parameters: None
# Returns: True if NTP is synchronized, false or logs an error if not enabled.
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

# Purpose: Wait until the system time is successfully synchronized.
# Parameters: None
# Returns: Total time spent waiting for time synchronization.
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

# Purpose: Check if the router has full connectivity (default route, DNS, and time sync).
# Parameters: None
# Returns: True if all connectivity checks pass, false otherwise.
:set IsFullyConnected do={
    :global DNSIsResolving
    :global DefaultRouteIsReachable
    :global TimeIsSync

    :return ([$DefaultRouteIsReachable] = true && \
             [$DNSIsResolving] = true && \
             [$TimeIsSync] = true)
}

# Purpose: Wait until the router is fully connected with route, DNS, and time sync.
# Parameters: None
# Returns: Total cumulative time spent waiting for all services to be ready.
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

# Signal we are ready
:set globalFunctionsReady true
