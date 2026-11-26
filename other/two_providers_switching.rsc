#  .d8888b.  888       888 8888888 88888888888 .d8888b.  888    888 
# d88P  Y88b 888   o   888   888       888    d88P  Y88b 888    888 
# Y88b.      888  d8b  888   888       888    888    888 888    888 
#  "Y888b.   888 d888b 888   888       888    888        8888888888 
#     "Y88b. 888d88888b888   888       888    888        888    888 
#       "888 88888P Y88888   888       888    888    888 888    888 
# Y88b  d88P 8888P   Y8888   888       888    Y88b  d88P 888    888 
#  "Y8888P"  888P     Y888 8888888     888     "Y8888P"  888    888 
                                                              
:global GetDhcpClientAddress
:global SendPrivateTelegramMessage
:global GetGlobalVar
:global SetGlobalVar
:global ReplaceStr
:global ToLowerCase
:global ParseKeyValueStore
:global GetArgOrExit
:global GetArgOrDefault

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
            /ip dhcp-client set $isp1Interface use-peer-dns=no
            /ip dhcp-client set $isp2Interface use-peer-dns=yes

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

            :local downMessage "$largeRedCircleEmoji $deviceName: Internet from <b>$isp1Name</b> is down. Switched to <b>$isp2Name</b>"
            $SendPrivateTelegramMessage $downMessage
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

            :local upMessage "$largeGreenCircleEmoji $deviceName: Internet from <b>$isp1Name</b> is alive. Switched back to <b>$isp1Name</b>"
            $SendPrivateTelegramMessage $upMessage
        } else={
            :log warning "$scriptName: not all confirmation pings succeeded ($okPings/$confirmPingCount), keeping state '$currentState'"
        }
    }
}
