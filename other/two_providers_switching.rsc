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
# This script automatically monitors reachability of a target host and handles automatic
# failover and failback between two WAN providers on a MikroTik router. It starts with a
# single probe ping and, when a state change is possible, runs a multi-packet confirmation
# sequence with a fixed interval before switching. On failover to the secondary ISP, it
# disables the default route and peer DNS on the primary DHCP client, enables peer DNS on
# the secondary DHCP client, clears active firewall connections for the primary ISP IP,
# and sends a Telegram notification. When the primary ISP recovers, it restores the default
# route and peer DNS settings, clears firewall connections for the secondary ISP IP, and
# sends a recovery notification, including a distinct message on the initial run when no
# saved state exists yet.
#
# YOU CAN'T RUN THIS SCRIPT DIRECTLY WITHOUT PASSING PARAMETERS!
# USE SCHEDULER TO RUN THIS SCRIPT WITH PARAMETERS!
#
# Parameters:
# $1 - isp1Name
# Friendly name of the primary ISP used in logs and Telegram notifications.
#
# $2 - isp1Ip
# Public IP address of the primary ISP whose active firewall connections are flushed
# when switching to the backup ISP.
#
# $3 - isp1Interface
# Interface name of the DHCP client belonging to the primary ISP.
#
# $4 - isp2Name
# Friendly name of the backup ISP used in logs and Telegram notifications.
#
# $5 - isp2Interface
# Interface name of the DHCP client belonging to the backup ISP, also used to verify
# that a valid DHCP address is available before switching over.
#
# $6 - hostToPing
# Target IP address or host probed via ping to determine primary link health.
# This host must always be pinged exclusively through the primary ISP.
#
# $7 - confirmPingCount (optional, default 5)
# Number of confirmation pings sent in a single command after the initial probe. All
# confirmation pings must fail to switch to DOWN, or all must succeed to switch to UP.
#
# $8 - confirmPingInterval (optional, default 1s)
# Interval between packets during the confirmation ping sequence.
#
# Usage example:
# :global RunScript
# [$RunScript two_providers_switching ("isp1Name=Kyivstar") ("isp1Ip=1.2.3.4") ("isp1Interface=ether1") ("isp2Name=Triolan") ("isp2Interface=ether2") ("hostToPing=1.0.0.1") ("confirmPingCount=5") ("confirmPingInterval=1s")]

:global GetGlobalVar
:global SetGlobalVar
:global ToLowerCase
:global ParseKeyValueStore
:global GetArgOrExit
:global GetArgOrDefault
:global GetDhcpClientAddress
:global SendPrivateTelegramMessage

:global largeGreenCircleEmoji
:global largeRedCircleEmoji

:local scriptName "two_providers_switching"

:local argsToParse {$1;$2;$3;$4;$5;$6;$7;$8;$9}
:local args [$ParseKeyValueStore $argsToParse]

# Required parameters
:local isp1Name [$GetArgOrExit $args "isp1Name" $scriptName]
:local isp1Ip [$GetArgOrExit $args "isp1Ip" $scriptName]
:local isp1Interface [$GetArgOrExit $args "isp1Interface" $scriptName]
:local isp2Name [$GetArgOrExit $args "isp2Name" $scriptName]
:local isp2Interface [$GetArgOrExit $args "isp2Interface" $scriptName]
:local hostToPing [$GetArgOrExit $args "hostToPing" $scriptName]

# Optional parameters with defaults
:local confirmPingCount [$GetArgOrDefault $args "confirmPingCount" 5]
:local confirmPingInterval [$GetArgOrDefault $args "confirmPingInterval" 1s]

:local isp1NameStr [$ToLowerCase $isp1Name]
:local stateVarName ($isp1NameStr . "-provider-state")
:local deviceName [/system identity get name]
:local currentState [$GetGlobalVar $stateVarName "empty"]
:local isEmpty ($currentState = "empty")

# Perform initial probe
:local initialPing [/ping $hostToPing count=1]

:if ($initialPing = 0) do={
    # Initial ping failed; verify for DOWN transition if not already down
    :if ($currentState != "down") do={
        :log warning "$scriptName: initial ping to $hostToPing failed, running $confirmPingCount confirmation pings..."

        :local okPings [/ping $hostToPing count=$confirmPingCount interval=$confirmPingInterval]
        :local isp2Ip [$GetDhcpClientAddress $isp2Interface]

        :if ($okPings = 0 && [:len $isp2Ip] > 0) do={
            :log warning "$scriptName: all $confirmPingCount confirmation pings failed. Switching to $isp2Name..."

            /ip dhcp-client set $isp1Interface add-default-route=no
            /ip dhcp-client set $isp2Interface use-peer-dns=yes
            /ip dhcp-client set $isp1Interface use-peer-dns=no

            :log warning "$scriptName: removing connections for $isp1Name IP $isp1Ip..."

            /ip firewall connection
            :foreach idc in=[find where timeout>60 and reply-dst-address~$isp1Ip] do={
                remove [find where .id=$idc]
            }

            :foreach idc in=[find where timeout>10 and reply-dst-address~$isp1Ip] do={
                remove [find where .id=$idc]
            }

            :foreach idc in=[find where timeout>3 and reply-dst-address~$isp1Ip] do={
                remove [find where .id=$idc]
            }

            $SetGlobalVar $stateVarName "down"

            :if ($isEmpty) do={
                $SendPrivateTelegramMessage ("$largeRedCircleEmoji $deviceName: Initial state is <b>DOWN</b> for <b>$isp1Name</b>. Active ISP: <b>$isp2Name</b>")
            } else={
                $SendPrivateTelegramMessage ("$largeRedCircleEmoji $deviceName: Internet from <b>$isp1Name</b> is down. Switched to <b>$isp2Name</b>")
            }
        } else={
            :if ($okPings > 0) do={
                :log warning "$scriptName: not all confirmation pings failed ($okPings/$confirmPingCount), keeping state '$currentState'"
            } else={
                :log error "$scriptName: cannot switch to $isp2Name because no DHCP IP found for $isp2Interface"
            }
        }
    }
} else={
    # Initial ping succeeded; verify for UP transition if not already up
    :if ($currentState != "up") do={
        :log warning "$scriptName: initial ping to $hostToPing succeeded, running $confirmPingCount confirmation pings..."

        :local okPings [/ping $hostToPing count=$confirmPingCount interval=$confirmPingInterval]

        :if ($okPings = $confirmPingCount) do={
            :log warning "$scriptName: all $confirmPingCount confirmation pings succeeded. Switching back to $isp1Name..."

            /ip dhcp-client set $isp1Interface add-default-route=yes
            /ip dhcp-client set $isp1Interface use-peer-dns=yes
            /ip dhcp-client set $isp2Interface use-peer-dns=no

            :local isp2Ip [$GetDhcpClientAddress $isp2Interface]
            :if ([:len $isp2Ip] > 0) do={
                :log warning "$scriptName: removing connections for $isp2Name IP $isp2Ip..."

                /ip firewall connection
                :foreach idc in=[find where timeout>60 and reply-dst-address~$isp2Ip] do={
                    remove [find where .id=$idc]
                }

                :foreach idc in=[find where timeout>10 and reply-dst-address~$isp2Ip] do={
                    remove [find where .id=$idc]
                }

                :foreach idc in=[find where timeout>3 and reply-dst-address~$isp2Ip] do={
                    remove [find where .id=$idc]
                }
            } else={
                :log error "$scriptName: cannot remove connections because no DHCP IP found for $isp2Interface"
            }

            $SetGlobalVar $stateVarName "up"

            :if ($isEmpty) do={
                $SendPrivateTelegramMessage ("$largeGreenCircleEmoji $deviceName: Initial state is <b>UP</b> for <b>$isp1Name</b>. Active ISP: <b>$isp1Name</b>")
            } else={
                $SendPrivateTelegramMessage ("$largeGreenCircleEmoji $deviceName: Internet from <b>$isp1Name</b> is alive. Switched back to <b>$isp1Name</b>")
            }
        } else={
            :log warning "$scriptName: not all confirmation pings succeeded ($okPings/$confirmPingCount), keeping state '$currentState'"
        }
    }
}
