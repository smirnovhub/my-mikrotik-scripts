# my-mikrotik-scripts
My collection of **Mikrotik** scripts. All scripts are tested on **RouterOS 6.49.17**

Thanks for original scripts and ideas to its authors:

* https://github.com/eworm-de/routeros-scripts.git
* https://github.com/osamahfarhan/mikrotik.git
* https://forum.mikrotik.com/

and many others...

Also thanks to ChatGPT. He can do something valuable somewhere in the 10th attempt)

## [`check_dhcp_dynamic_leases.rsc`](check_dhcp_dynamic_leases.rsc)

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

## [`on_startup.rsc`](on_startup.rsc)

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

## [`reboot.rsc`](reboot.rsc)

**Purpose:**  
Send a warning message via Telegram before rebooting the MikroTik device

**Description:**  
This simple script notifies users that the system is going down for reboot. After sending the notification, it waits 3 seconds and performs the system reboot

**Globals required:**
- `SendTelegramMessage` – function to send messages via Telegram Bot API
- `warningSignEmoji` – emoji prefix for the notification message

# Global Functions List

## Files list
* [`global_config.rsc`](global/global_config.rsc)
* [`global_functions.rsc`](global/global_functions.rsc)
* [`global_functions_encoding.rsc`](global/global_functions_encoding.rsc)
* [`global_functions_hashes.rsc`](global/global_functions_hashes.rsc)

## Overview
This scripts are a comprehensive collection of global functions and utilities for RouterOS. It provides reusable functions for string manipulation, date-time conversion, networking checks, random number generation, and more.  
The scripts are intended to be run at system startup or whenever modifications are made.

### Global Variables

- **warningSignEmoji**: Stores the URL-encoded warning emoji (`⚠️`) used for alert messages
- **squaredUpWithExclamationMark**: Stores the URL-encoded “squared up” emoji (`🆙`) with exclamation mark
- **telegramBotToken**: Stores the token for the Telegram bot used to send messages
- **telegramChatID**: Stores the Telegram chat ID where messages will be sent

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

### Base64 Encoding & Decoding
- **Base64Encode**: Encode an input string into Base64 format according to RFC 4648.  
  - Supports optional URL-safe variant (`"url"`) and optional padding removal (`"nopad"`).  
  - **Parameters:**  
    1. Input string to encode  
    2. Optional `"url"` flag for URL-safe Base64  
    3. Optional `"nopad"` flag to remove padding (`=`)  
  - **Returns:** Base64 encoded string

- **Base64Decode**: Decode a Base64-encoded string into its original representation.  
  - Supports standard and URL-safe alphabets, optional padding enforcement, and ignoring invalid characters.  
  - **Parameters:**  
    1. Base64 input string  
    2. Optional `"url"` flag for URL-safe Base64  
    3. Optional `"mustpad"` flag to enforce padding  
    4. Optional `"ignoreotherchr"` flag to skip invalid characters  
  - **Returns:** Decoded plain string

### URL Encoding & Decoding
- **UrlEncode**: Encode a string into URL-encoded format, replacing non-alphanumeric characters with `%HH` codes.  
  - **Parameters:**  
    1. Input string  
  - **Returns:** URL-encoded string

- **UrlDecode**: Decode a URL-encoded string, converting `%HH` codes back into their original characters.  
  - **Parameters:**  
    1. URL-encoded input string  
  - **Returns:** Decoded string

### External Dependencies
- **HexToNum**: Converts a hexadecimal string to a numeric value (used internally by UrlDecode).

### Checksum calculation

- **GetMd5Sum**: Generates an MD5 hash from a given input string using the MD5 Message-Digest Algorithm as specified in RFC 1321.  
  - This function converts the input string into a series of 512-bit blocks, processes each block through 4 rounds of nonlinear functions, and produces a 128-bit hash value.  
  - The output is represented as a lowercase hexadecimal string.  
  - Note: MD5 is not collision-resistant and should not be used for cryptographic security purposes.  

  - **Parameters:**  
    1. Input string to hash  

  - **Returns:**  
    - MD5 hash as a lowercase hexadecimal string

## Installation
1. Save the scripts as `global_config`, `global_functions`, `global_functions_encoding` and `global_functions_hashes`.  
2. Add the following line to your startup script to execute it at system boot:
```
/system script run global_config
/system script run global_functions
/system script run global_functions_encoding
/system script run global_functions_hashes
```

