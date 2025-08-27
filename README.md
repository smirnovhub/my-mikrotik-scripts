# my-mikrotik-scripts
My collection of **Mikrotik** scripts. All scripts are tested on **RouterOS 6.49.17**

Thanks for original scripts and ideas to its authors:

* https://github.com/eworm-de/routeros-scripts.git
* https://github.com/osamahfarhan/mikrotik.git
* https://forum.mikrotik.com/

and many others...

Also thanks to ChatGPT. He can do something valuable somewhere in the 10th attempt)

## `check_dhcp_dynamic_leases.rsc`

**Purpose:**  
Detect dynamic (unapproved) DHCP leases on the network and send an alert via Telegram

**Description:**  
This script iterates through all DHCP leases on the MikroTik device and identifies dynamic leases (i.e., those not marked as static). For each dynamic lease, it collects the IP, MAC address, and hostname (defaulting to "Unknown" if the hostname is empty). If any dynamic leases are detected, it sends a formatted Telegram message and writes a log entry. Alerts are rate-limited to avoid spamming

**Globals required:**
- `SendTelegramMessage` – function to send messages via Telegram Bot API
- `GetUnixTimestamp` – function returning the current UNIX timestamp in seconds
- `warningSignEmoji` – emoji prefix for Telegram messages

**Constants:**
- `warningSendPeriodSec` – minimum interval (seconds) between repeated alerts

**Usage:**
- Add the script to the scheduler to run every N minutes

---

## `on_startup.rsc`

**Purpose:**  
Ensure all required global functions are ready on system startup, wait until the system is fully connected, and send a startup notification via Telegram

**Description:**  
This script is intended to run during system startup. It waits for the global variable `globalFunctionsReady` to become true, retrying up to `maxAttempts` with a delay of 500ms each. Once ready, it waits for full connectivity as defined by the `WaitFullyConnected` global, then sends a startup notification message via Telegram

**Globals required:**
- `WaitFullyConnected` – function waiting until system is fully connected and retuns total wait time
- `SendTelegramMessage` – function to send Telegram messages
- `globalFunctionsReady` – indicates if required functions are initialize
- `squaredUpWithExclamationMark` – emoji or symbol used in the Telegram startup message

**Parameters:**
- `maxAttempts` – maximum number of retries for global functions readiness check
- `delay` – delay between retries

---

## `reboot.rsc`

**Purpose:**  
Send a warning message via Telegram before rebooting the MikroTik device

**Description:**  
This simple script notifies users that the system is going down for reboot. After sending the notification, it waits 3 seconds and performs the system reboot

**Globals required:**
- `SendTelegramMessage` – function to send messages via Telegram Bot API
- `warningSignEmoji` – emoji prefix for the notification message

# Global Functions List

## Files list
* `global_functions.rsc`
* `global_functions_encoding.rsc`
* `global_functions_hashes.rsc`

## Overview
This script is a comprehensive collection of global functions and utilities for RouterOS. It provides reusable functions for string manipulation, date-time conversion, networking checks, random number generation, and more.  
The script is intended to be run at system startup or whenever modifications are made.

## Features

### Logging & Error Handling
- **LogAndExit**: Logs messages with severity (`info`, `warning`, `error`, `debug`) and stops execution if necessary.

### Argument & Configuration Handling
- **ParseKeyValueStore**: Converts key-value pairs or space-separated strings into associative arrays (maps).  
- **GetArgOrDefault**: Retrieves a parameter or returns a default value.  
- **GetArgOrExit**: Retrieves a required parameter and exits if missing.

### Network Utilities
- **SilentPing**: Perform silent pings to a single host or multiple hosts in parallel.  
- **DNSIsResolving / WaitDNSResolving**: Check or wait for DNS resolution.  
- **DefaultRouteIsReachable / WaitDefaultRouteReachable**: Check or wait for default route availability.  
- **TimeIsSync / WaitTimeSync**: Check or wait for NTP time synchronization.  
- **WaitFullyConnected**: Wait until network is fully ready (DNS, route, and time synced).

### Random & Numeric Utilities
- **GetRandom20CharHex**: Generate a random 20-character hexadecimal string.  
- **GetRandomNumber**: Generate a pseudo-random number within a range.  
- **HexToNum**: Convert hexadecimal strings to numeric values.  
- **DivideIntAndRound**: Divide integers and round to a specified precision.

### Array & String Utilities
- **MapArray**: Apply a transformation function to each array element.  
- **JoinArray**: Join array elements into a single string with a separator.  
- **SplitStr**: Split strings into arrays.  
- **TrimStr, TrimStrLeft, TrimStrRight**: Trim characters from strings.  
- **ReplaceStr**: Replace substrings in a string.

### Date & Time Utilities
- **GetCurrentDateTime**: Retrieve the current system date-time in `YYYY-MM-DD HH:MM:SS` format.  
- **ParseDateTime**: Convert RouterOS-style date strings to standard format.  
- **ToUnixTimestamp / FromUnixTimestamp**: Convert between date-time strings and Unix timestamps.  
- **GetWeekday**: Get the weekday from a date.

### File & Script Utilities
- **EnsureFileWithIdExists**: Ensure a file exists and return its ID.  
- **RunScript**: Execute another RouterOS script with optional parameters.  
- **ExportConfiguration**: Export RouterOS configuration with a standardized filename.

### Case Conversion
- **ToUpperCase / ToLowerCase**: Convert strings to uppercase or lowercase.

### Sorting
- **RecursiveMergeSort**: Perform merge sort on an array of comparable items.

### Notifications
- **SendTelegramMessage**: Send messages via Telegram (requires bot token and chat ID).

## Installation
1. Save the script as `global_functions`.  
2. Add the following line to your startup script to execute it at system boot:
```
/system script run global_functions
```

