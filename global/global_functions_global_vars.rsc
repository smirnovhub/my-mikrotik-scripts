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
# Add script named global_functions_global_vars and then add call to startup script:
# /system script run global_functions_global_vars

# global functions
:global DeclareGlobalVar
:global GetGlobalVar
:global GetGlobalVarOrDefault
:global SetGlobalVar
:global RemoveGlobalVar

# Global dependencies:
#   global_functions_array_str:
#       :global ReplaceStr

# Purpose: Declare a global variable in the RouterOS environment.
# Parameters:
#   $1 - Global variable name
# Returns: Nothing
:set DeclareGlobalVar do={
  :if ([:len $0] = 0 or [:len $1] = 0) do={
    :return 0
  }

  :local varName ($1 . "GlobalVar")
  :execute (":global " . $varName)
}

# Purpose: Get the value of a global variable.
# Parameters:
#   $1 - Global variable name
# Returns: The value of the global variable
:set GetGlobalVar do={
  :if ([:len $0] = 0 or [:len $1] = 0) do={
    :return 0
  }

  :local varName ($1 . "GlobalVar")

  # Check if the variable exists in the environment
  :if ([:len [/system script environment find name=$varName]] = 0) do={
    :return ""
  }

  :local get [:parse ":global $varName; :return \$$varName"]
  :return [$get]
}

# Purpose: Get the value of a global variable or return a default value
# if the variable does not exist or is uninitialized.
# Parameters:
#   $1 - Global variable name
#   $2 - Default value
# Returns: The global variable value or the default value
:set GetGlobalVarOrDefault do={
  :if ([:len $0] = 0 or [:len $1] = 0) do={
    :return 0
  }

  :local varName ($1 . "GlobalVar")
  :local defaultValue $2

  # Check if the variable exists in the environment
  :if ([:len [/system script environment find name=$varName]] = 0) do={
    :return $defaultValue
  }

  :local get [:parse ":global $varName; :return \$$varName"]
  :local value [$get]

  :local t [:typeof $value]
  :if ($t = "nothing" or $t = "nil") do={
    :return $defaultValue
  }

  :return $value
}

# Purpose: Set the value of a global variable.
# Automatically escapes double quotes for string values.
# Parameters:
#   $1 - Global variable name
#   $2 - Value to assign
# Returns: Nothing
:set SetGlobalVar do={
  :global ReplaceStr

  :if ([:len $0] = 0 or [:len $1] = 0) do={
    :return 0
  }

  :local varName ($1 . "GlobalVar")
  :local value $2

  :if ([:typeof $value] = "str") do={
    :local escaped [$ReplaceStr $value ("\"") ("\\\"")]
    :execute (":global " . $varName . "; :set " . $varName . " \"" . $escaped . "\"")
  } else={
    if ([:typeof $value] = "array") do={
      :execute (":global " . $varName . "; :set " . $varName . " \"" . [:tostr $value] . "\"")
    } else={
      :execute (":global " . $varName . "; :set " . $varName . " " . $value)
    }
  }
}

# Purpose: Find a global variable by name in the Environment and completely remove it.
# Parameters:
#    $1 - Global variable name
# Returns: Nothing
:set RemoveGlobalVar do={
  :if ([:len $0] = 0 or [:len $1] = 0) do={
    :return 0
  }

  :local varName ($1 . "GlobalVar")
  
  /system script environment remove [find name=$varName]
}
