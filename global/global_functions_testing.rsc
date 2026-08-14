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
# Add script named global_functions_testing and then add call to startup script:
# /system script run global_functions_testing
#
# global functions
:global RunGenericTestCase

:set RunGenericTestCase do={
    :global IsPrintableStr

    # Workaround for the MikroTik RouterOS interpreter bug (phantom execution)
    :if ([:len $0] = 0) do={
        :return $1
    }

    :local state [:toarray $1]
    :local func $2
    :local arg1 $3
    :local arg2 $4
    :local arg3 $5
    :local expected $6
    :local testName [:tostr $7]

    :local input [:tostr $3]
    :local actual

    :local inputDisplay $input
    :if (![$IsPrintableStr $inputDisplay]) do={
        :set inputDisplay "<binary string>"
    } else={
        :if ([:len $input] > 30) do={
            :set inputDisplay ([:pick $input 0 30] . "<truncated>")
        }
    }

    # Safe execution container to handle internal script :error actions
    :do {
        # Adaptive argument dispatching based on variable types and presence
        :if ($arg3 != "nothing") do={
            :set actual [$func $arg1 $arg2 $arg3]
        } else={
            :if ($arg2 != "nothing") do={
                :set actual [$func $arg1 $arg2]
            } else={
                :if ($arg1 != "nothing") do={
                    :set actual [$func $arg1]
                } else={
                    :set actual [$func]
                }
            }
        }

        # Normalize values for safe comparison in RouterOS
        :local actualStr [:tostr $actual]
        :local expectedStr [:tostr $expected]

        :local actualDisplay $actualStr
        :if (![$IsPrintableStr $actualDisplay]) do={
            :set actualDisplay "<binary string>"
        } else={
            :if ([:len $actualStr] > 64) do={
                :set actualDisplay ([:pick $actualStr 0 64] . "<truncated>")
            }
        }

        :local expectedDisplay $expectedStr
        :if (![$IsPrintableStr $expectedDisplay]) do={
            :set expectedDisplay "<binary string>"
        } else={
            :if ([:len $expectedStr] > 64) do={
                :set expectedDisplay ([:pick $expectedStr 0 64] . "<truncated>")
            }
        }

        :if ([:typeof $actual] = "nil") do={
            :set actualStr "nil"
        }

        :if ($actualStr = $expectedStr) do={
            :put ("  \1B[32m[PASS]\1B[0m " . $testName . ": '" . $inputDisplay . "' -> '" . $actualDisplay . "'")
            :set ($state->"passed") (($state->"passed") + 1)
        } else={
            :put ("  \1B[31m[FAIL]\1B[0m " . $testName . ": '" . $inputDisplay . "' | Expected: '" . $expectedDisplay . "', Got: '" . $actualDisplay . "'")
            :set ($state->"failed") (($state->"failed") + 1)
        }
    } on-error={
        :if ($expected = "error") do={
            :set ($state->"passed") (($state->"passed") + 1)
            :put ("  \1B[32m[PASS]\1B[0m " . $testName . ": Checked invalid input '" . $inputDisplay . "' threw error successfully")
        } else={
            :set ($state->"failed") (($state->"failed") + 1)
            :put ("  \1B[31m[FAIL]\1B[0m " . $testName . ": Unexpected crash on input '" . $inputDisplay . "'")
        }
    }

    :return $state
}
