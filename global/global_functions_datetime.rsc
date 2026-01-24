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
# Add script named global_functions_datetime and then add call to startup script:
# /system script run global_functions_datetime
#
# Sources and original authors:
# https://github.com/eworm-de/routeros-scripts.git
# https://github.com/osamahfarhan/mikrotik.git
# https://forum.mikrotik.com/
# and many others...
#

# global functions
:global GetCurrentDateTime
:global ParseDateTime
:global ToUnixTimestamp
:global GetUnixTimestamp
:global FromUnixTimestamp
:global GetWeekday
:global FormatSecondsLong
:global FormatSecondsShort

# Purpose: Retrieve the current system date and time, formatted as "YYYY-MM-DD HH:MM:SS"
# Parameters: None
# Returns: Formatted date-time string
:set GetCurrentDateTime do={
    :global ParseDateTime

    # Get current date and time from system clock
    :local currentDate [/system clock get date]; # Example: "aug/17/2025"
    :local currentTime [/system clock get time]; # Example: "14:32:07"
    # Return parsed date and time
    :return [$ParseDateTime ($currentDate . " " . $currentTime)]
}

# Purpose: Parse RouterOS date-time string like "aug/22/2025 12:03:04"
# Parameters:
#   $1 - Input date-time string
# Returns: Formatted date-time string "YYYY-MM-DD HH:MM:SS"
:set ParseDateTime do={
    :local input $1

    # Extract month short name (first 3 chars)
    :local month [:pick $input 0 3]              ; # "aug"
    # Extract day (characters 4-6, may be 1 or 2 digits)
    :local day [:pick $input 4 6]                ; # "17"
    # Extract year (characters 7-11)
    :local year [:pick $input 7 11]              ; # "2025"
    # Extract time part (characters after space, starting at pos 12)
    :local time [:pick $input 12 [:len $input]]  ; # "14:32:07"

    # Convert month short name to numeric string
    :local months {"jan"="01"; "feb"="02"; "mar"="03"; "apr"="04"; "may"="05"; "jun"="06"; "jul"="07"; "aug"="08"; "sep"="09"; "oct"="10"; "nov"="11"; "dec"="12"}
    :local monthNum ($months->$month)

    # Ensure day is always 2 digits (prefix with 0 if needed)
    :if ([:len $day] = 1) do={ :set day ("0" . $day) }

    # Build final formatted datetime string
    :local formattedDateTime ($year . "-" . $monthNum . "-" . $day . " " . $time)

    :return $formattedDateTime
}


# Purpose: Convert a date-time string in "YYYY-MM-DD HH:MM:SS" format to Unix timestamp.
# Parameters:
#   $1 - Date-time string "YYYY-MM-DD HH:MM:SS"
# Returns: Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
:set ToUnixTimestamp do={
    :local dt [:tostr $1]

    # Extract year, month, day, hour, minute, second
    :local year [:tonum [:pick $dt 0 4]]
    :local month [:tonum [:pick $dt 5 7]]
    :local day [:tonum [:pick $dt 8 10]]
    :local hour [:tonum [:pick $dt 11 13]]
    :local min [:tonum [:pick $dt 14 16]]
    :local sec [:tonum [:pick $dt 17 19]]

    # Days in months
    :local monthDays {31;28;31;30;31;30;31;31;30;31;30;31}
    # Leap year adjustment
    :if (($year % 4 = 0 && $year % 100 != 0) || ($year % 400 = 0)) do={ :set ($monthDays->1) 29 }

    # Count total days from 1970 to previous year
    :local days 0
    :for y from=1970 to=($year - 1) do={
        :set days ($days + 365)
        :if (($y % 4 = 0 && $y % 100 != 0) || ($y % 400 = 0)) do={ :set days ($days + 1) }
    }

    # Count days in previous months of current year
    :if ($month > 1) do={
        :for i from=1 to=($month - 1) do={
            :set days ($days + ($monthDays->($i - 1)))
        }
    }

    # Add days in current month
    :set days ($days + $day - 1)

    # Convert total days + hours, minutes, seconds to seconds
    :local timestamp ($days * 86400 + $hour * 3600 + $min * 60 + $sec)

    :return $timestamp
}

# Purpose: Retrieve the current system date and time and convert it to a Unix timestamp.
# Parameters: None
# Returns: Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
:set GetUnixTimestamp do={
    # Get current system date in format "aug/17/2025"
    :local date [/system clock get date]    

    # Get current system time in format "22:10:45"
    :local time [/system clock get time]    

    # Extract the month as a string (first 3 letters of date, e.g. "aug")
    :local monthStr [:pick $date 0 3]

    # Extract the day part (characters 4-6, e.g. "17") and convert to number
    :local day [:tonum [:pick $date 4 6]]

    # Extract the year part (characters 7-11, e.g. "2025") and convert to number
    :local year [:tonum [:pick $date 7 11]]

    # Mapping of month abbreviations to numeric values
    :local months {"jan"=1;"feb"=2;"mar"=3;"apr"=4;"may"=5;"jun"=6;"jul"=7;"aug"=8;"sep"=9;"oct"=10;"nov"=11;"dec"=12}

    # Get numeric month value using the mapping
    :local month ($months->$monthStr)

    # Extract the hour part from time string and convert to number
    :local hour [:tonum [:pick $time 0 2]]

    # Extract the minute part from time string and convert to number
    :local minute [:tonum [:pick $time 3 5]]

    # Extract the second part from time string and convert to number
    :local second [:tonum [:pick $time 6 8]]

    # Create local copies for year, month, and day
    :local y $year
    :local m $month
    :local d $day

    # Initialize days counter (number of days since 1970-01-01)
    :local days (0)

    # Add days for all full years since 1970
    :for i from=1970 to=($y - 1) do={
        # Add 365 days for each year
        :set days ($days + 365)

        # If year is leap year, add one extra day
        :if (($i % 4 = 0 && $i % 100 != 0) || ($i % 400 = 0)) do={ 
            :set days ($days + 1) 
        }
    }

    # Number of days in each month for a regular year
    :local monthDays {31;28;31;30;31;30;31;31;30;31;30;31}

    # If current year is leap year, adjust February to 29 days
    :if (($y % 4 = 0 && $y % 100 != 0) || ($y % 400 = 0)) do={
        :set ($monthDays->1) 29
    }

    # Add days from previous months of the current year
    :if ($m > 1) do={
        :for i from=1 to=($m - 1) do={
            :set days ($days + ($monthDays->($i - 1)))
        }
    }

    # Add days from the current month (subtract 1 because day count starts at 0)
    :set days ($days + $d - 1)

    # Convert total days + time into seconds (Unix timestamp)
    :local timestamp ($days * 86400 + $hour * 3600 + $minute * 60 + $second)

    # Return calculated Unix timestamp
    :return $timestamp
}

# Purpose: Convert a Unix timestamp (seconds since 1970-01-01 00:00:00 UTC) to a formatted date-time string "YYYY-MM-DD HH:MM:SS"
# Parameters:
#   $1 - Unix timestamp
# Returns: Formatted date-time string
:set FromUnixTimestamp do={
    # Input parameter: Unix timestamp (seconds since 1970-01-01 00:00:00 UTC)
    :local ts [:tonum $1]

    # Extract seconds part (remaining after dividing by 60)
    :local sec ($ts % 60)

    # Convert timestamp from seconds to minutes
    :set ts ($ts / 60)

    # Extract minutes part (remaining after dividing by 60)
    :local min ($ts % 60)

    # Convert timestamp from minutes to hours
    :set ts ($ts / 60)

    # Extract hours part (remaining after dividing by 24)
    :local hour ($ts % 24)

    # Convert timestamp from hours to days
    :set ts ($ts / 24)

    # Now "ts" contains number of full days since 1970-01-01
    :local year 1970

    # Determine year by subtracting full years from "ts" (no break)
    :while ($ts >= 365) do={

        # Default number of days in the current year
        :local daysInYear 365

        # If year is a leap year, adjust days to 366
        :if (($year % 4 = 0 && $year % 100 != 0) || ($year % 400 = 0)) do={
            :set daysInYear 366
        }

        # Only subtract if ts is still greater or equal to daysInYear
        :if ($ts >= $daysInYear) do={
            :set ts ($ts - $daysInYear)
            :set year ($year + 1)
        }
    }

    # Array with number of days in each month for a regular year
    :local monthDays {31;28;31;30;31;30;31;31;30;31;30;31}

    # Adjust February to 29 days if current year is a leap year
    :if (($year % 4 = 0 && $year % 100 != 0) || ($year % 400 = 0)) do={
        :set ($monthDays->1) 29
    }

    # Initialize month counter
    :local month 1

    # Determine month by subtracting full months from "ts" (no break)
    :local i 0
    :while ($i < 12 && $ts >= ($monthDays->$i)) do={
        :set ts ($ts - ($monthDays->$i))
        :set month ($month + 1)
        :set i ($i + 1)
    }

    # Day is the remainder + 1 (since counting starts from 0)
    :local day ($ts + 1)

    # Format result as "YYYY-MM-DD"
    :local result ([:tostr $year] . "-" . \
                   [:pick ("0" . $month) ([:len ("0" . $month)] - 2) [:len ("0" . $month)]] . "-" . \
                   [:pick ("0" . $day) ([:len ("0" . $day)] - 2) [:len ("0" . $day)]])

    # Append "HH:MM:SS" to result string
    :set result ($result . " " . \
                 [:pick ("0" . $hour) ([:len ("0" . $hour)] - 2) [:len ("0" . $hour)]] . ":" . \
                 [:pick ("0" . $min) ([:len ("0" . $min)] - 2) [:len ("0" . $min)]] . ":" . \
                 [:pick ("0" . $sec) ([:len ("0" . $sec)] - 2) [:len ("0" . $sec)]])

    # Return formatted date-time string
    :return $result
}

# Purpose: Return the day of the week as a full English word (e.g., "monday", "tuesday")
#          for a given UNIX timestamp.
# Parameters:
#   $1 - UNIX timestamp (number of seconds since 1970-01-01 00:00:00 UTC)
# Returns:
#   - String with the full English name of the weekday
#     ("sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday").
# Notes:
#   - UNIX epoch (1970-01-01) started on a Thursday, so a +4 day offset is applied
#     when calculating the weekday number.
#   - Indexing: 0 = Sunday, 1 = Monday, ..., 6 = Saturday.
#   - To get the current weekday, pass [$GetUnixTimestamp] as the parameter.
# Example usage:
#   :put [$GetWeekday [$GetUnixTimestamp]]
:set GetWeekday do={
    # Read function argument: UNIX timestamp
    :local ts $1

    # Convert timestamp into total number of days since 1970-01-01
    :local days ($ts / 86400)

    # Calculate weekday number with offset (0=Sunday, …, 6=Saturday)
    :local weekday (($days + 4) % 7)

    # Define lookup table with weekday names
    :local weekdays {"sunday";"monday";"tuesday";"wednesday";"thursday";"friday";"saturday"}

    # Return the weekday name as a string
    :return ($weekdays->$weekday)
}

# Purpose: Convert a total number of seconds into a human-readable string with days, hours, minutes, and seconds.
# Parameters:
#   $1 - Total seconds (integer)
# Returns: Formatted string, e.g., "2d 3h 15m 10s", skipping any zero components
:set FormatSecondsLong do={
    # Input parameter: total seconds
    :local totalSec [:tonum $1]

    # Calculate total days
    :local days ($totalSec / 86400)
    :set totalSec ($totalSec % 86400)

    # Calculate hours
    :local hours ($totalSec / 3600)
    :set totalSec ($totalSec % 3600)

    # Calculate minutes
    :local minutes ($totalSec / 60)

    # Remaining seconds
    :local seconds ($totalSec % 60)

    # Build result string, skipping zeros
    :local result ""
    :if ($days > 0) do={ :set result ($result . $days . "d ") }
    :if ($hours > 0) do={ :set result ($result . $hours . "h ") }
    :if ($minutes > 0) do={ :set result ($result . $minutes . "m ") }
    :if ($seconds > 0) do={ :set result ($result . $seconds . "s") }

    # Trim any trailing space
    :set result [:pick $result 0 [:len $result]]

    # Return result
    :return $result
}

# Purpose: Convert total seconds into a short, human-readable format using the largest unit only.
# Parameters:
#   $1 - Total seconds (integer)
# Returns: Formatted string, e.g., "3 days", "5 hrs", "12 min", or "30 sec"
:set FormatSecondsShort do={
    # Input parameter: total seconds
    :local sec [:tonum $1]

    # Prepare an empty formattedTime variable (string)
    :local formattedTime ""

    # Calculate how many full days are in the total seconds
    :local days ($sec / 86400)
    # Remove the number of seconds that are already counted as days
    :set sec ($sec % 86400)

    # Calculate how many full hours are left after removing days
    :local hours ($sec / 3600)
    # Remove the number of seconds that are already counted as hours
    :set sec ($sec % 3600)

    # Calculate how many full minutes are left after removing hours
    :local minutes ($sec / 60)
    # Remaining seconds after removing minutes
    :set sec ($sec % 60)

    # Decide which time unit to return:
    # If there are one or more days, return only days
    :if ($days > 0) do={
        :set formattedTime ($days . " days")
    } else={
        # Otherwise, if there are one or more hours, return only hours
        :if ($hours > 0) do={
            :set formattedTime ($hours . " hrs")
        } else={
            # Otherwise, if there are one or more minutes, return only minutes
            :if ($minutes > 0) do={
                :set formattedTime ($minutes . " min")
            } else={
                # If none of the above, return only seconds
                :set formattedTime ($sec . " sec")
            }
        }
    }

    # Return result
    :return $formattedTime
}
