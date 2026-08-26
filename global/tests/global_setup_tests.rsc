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
# Add script named global_setup_tests and then add call to startup script:
# /system script run global_setup_tests

# Define the list of startup scripts
:local startupScripts {
    "global_functions_all_tests";
    "global_functions_array_str_tests_1";
    "global_functions_array_str_tests_2";
    "global_functions_array_str_tests_3";
    "global_functions_auto_update_tests";
    "global_functions_big_int_tests_1";
    "global_functions_big_int_tests_2";
    "global_functions_big_int_tests_3";
    "global_functions_datetime_tests_1";
    "global_functions_datetime_tests_2";
    "global_functions_encoding_tests";
    "global_functions_global_vars_tests";
    "global_functions_hashes_tests_1";
    "global_functions_hashes_tests_2";
    "global_functions_utils_tests"
}

# Iterate through the array and run each script with error handling
:foreach scriptName in=$startupScripts do={
    :do {
        :if ([:len [/system script find name=$scriptName]] > 0) do={
            /system script run $scriptName
            :log info "Script $scriptName runned successfully"
        } else={
            :log error "Script $scriptName not found"
        }
    } on-error={
        :log error "Failed to execute script: $scriptName"
    }
}
