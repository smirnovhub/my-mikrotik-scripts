# my-mikrotik-scripts
My collection of **Mikrotik** scripts. All global scripts are tested on **RouterOS 6.49.17** and **RouterOS 7.21.5**

# Global Functions List

## Files list
* [`global_config.rsc`](global/global_config.rsc)
* [`global_functions.rsc`](global/global_functions.rsc)
* [`global_functions_array_str.rsc`](global/global_functions_array_str.rsc)
* [`global_functions_auto_update.rsc`](global/global_functions_auto_update.rsc)
* [`global_functions_datetime.rsc`](global/global_functions_datetime.rsc)
* [`global_functions_encoding.rsc`](global/global_functions_encoding.rsc)
* [`global_functions_global_vars.rsc`](global/global_functions_global_vars.rsc)
* [`global_functions_hashes.rsc`](global/global_functions_hashes.rsc)
* [`global_functions_utils.rsc`](global/global_functions_utils.rsc)

## Overview
These scripts are a comprehensive collection of global functions and utilities for RouterOS. They provide reusable functions for string manipulation, date-time conversion, networking checks, random number generation, external script auto-updates, and more.  
The scripts are intended to be run at system startup or whenever modifications are made.

### Global Variables

- **globalFunctionsReady**: Boolean flag indicating global functions readiness (`false` by default, set to `true` at the end of `global_functions.rsc`)
- **largeGreenCircleEmoji**: Stores the URL-encoded green circle emoji (`🟢`) used for successful status updates
- **largeRedCircleEmoji**: Stores the URL-encoded red circle emoji (`🔴`) used for failed status updates
- **largeYellowCircleEmoji**: Stores the URL-encoded yellow circle emoji (`🟡`) used for warning, in-progress, or pending status indicators
- **whiteCircleEmoji**: Stores the URL-encoded white circle emoji (`⚪`) used for neutral list markers, inactive states, or toggled-off option indicators
- **backhandIndexPointingLeftEmoji**: Stores the URL-encoded left-pointing backhand index emoji (`👈`) used to highlight or draw attention to preceding text or values
- **warningSignEmoji**: Stores the URL-encoded warning emoji (`⚠️`) used for alert messages
- **squaredUpWithExclamationMark**: Stores the URL-encoded “squared up” emoji (`🆙`) with exclamation mark
- **telegramBotToken**: Stores the token for the Telegram bot used to send messages
- **telegramPublicChatID**: Stores the Telegram public chat ID where messages will be sent
- **telegramPrivateChatID**: Stores the Telegram private chat ID where messages will be sent

## Features

### Network Utilities & Status Checks
- **DNSIsResolving / WaitDNSResolving**: Check or wait for DNS resolution.
- **DefaultRouteIsReachable / WaitDefaultRouteReachable**: Check or wait for default route availability.
- **TimeIsSync / WaitTimeSync**: Check or wait for NTP time synchronization.
- **WaitFullyConnected**: Wait until network is fully ready (default route reachable, DNS resolving, and NTP synced).
- **SilentPing**: Perform silent pings to a single host or multiple hosts in parallel.  

### Logging & Error Handling
- **LogAndExit**: Logs messages with severity (`info`, `warning`, `error`, `debug`) and stops execution if necessary.

### Argument & Configuration Handling
- **GetArgOrDefault**: Retrieves a parameter or returns a default value.  
- **GetArgOrExit**: Retrieves a required parameter and exits if missing.

### Array & String Utilities
- **ParseKeyValueStore**: Convert key-value pairs or space-separated strings into associative arrays (maps).
- **MapArray**: Apply a transformation function to each array element.
- **JoinArray**: Join array elements into a single string with a separator.
- **SplitStr**: Split strings into arrays by delimiter.
- **TrimStr, TrimStrLeft, TrimStrRight**: Trim characters from strings.
- **ReplaceStr**: Replace substrings in a string.
- **ContainsStr**: Check if a substring exists within a string.
- **StartsWithStr / EndsWithStr**: Verify string prefixes or suffixes.
- **CleanStr**: Filter a string to keep only allowed characters.
- **ReverseStr**: Reverse characters in a string.
- **ToUpperCase / ToLowerCase**: Convert strings to uppercase or lowercase.
- **CompareStr**: Compare two strings lexicographically using ASCII character codes.
- **IsPrintableStr**: Check whether a string contains only printable characters.
- **ExtractFileName**: Extract and return the file name from a path (with optional extension retention).

### Random & Numeric Utilities
- **GetRandom20CharHex**: Generate a random 20-character hexadecimal string.
- **GetRandomNumber**: Generate a pseudo-random number within a range.
- **HexToNum**: Convert hexadecimal strings to numeric values.
- **DivideIntAndRound**: Divide integers and round to a specified number of decimal places.
- **HexToChar / DecToChar**: Convert hexadecimal or decimal ASCII values to characters.

### Sorting
- **RecursiveMergeSort**: Perform merge sort on an array of comparable items.
- **RecursiveMergeSortStr**: Perform merge sort on an array of strings in ascending lexicographical order.

### Date & Time Utilities
- **GetCurrentDateTime**: Retrieve current system date-time formatted as `YYYY-MM-DD HH:MM:SS`.
- **ParseDateTime**: Parse RouterOS-style (`mmm/DD/YYYY HH:MM:SS`) or ISO-style (`YYYY-MM-DD HH:MM:SS`) date-time strings into standard format.
- **ToUnixTimestamp**: Convert a date-time string to a Unix timestamp.
- **GetUnixTimestamp**: Retrieve the current system time as a Unix timestamp.
- **FromUnixTimestamp**: Convert a Unix timestamp back into `YYYY-MM-DD HH:MM:SS` format.
- **GetWeekday**: Calculate the weekday for a given date.
- **FormatSecondsLong / FormatSecondsShort**: Format duration in seconds into human-readable strings.

### Auto-Update & Remote Fetching Utilities
- **FetchWithRedirect**: Download content from a URL with support for HTTP 3xx redirects (handling RouterOS 6 & 7 differences) and in-memory payload extraction.
- **GetGitHubLastCommitHash**: Query GitHub API for the latest commit SHA hash of a branch.
- **DownloadAndImportScript**: Download a `.rsc` script from a URL, verify its hash (CRC32 or MD5), and add/update it in RouterOS system scripts.
- **DownloadAndImportScriptsFromList**: Download and parse a `.txt` list file containing hashes and script URLs, then update and optionally execute them.
- **DownloadAndImportScriptsFromGitHubList**: Check a GitHub repository for new commits, download updated scripts from a list if changes are detected, and send status notifications via Telegram.

### Base64 Encoding & Decoding
- **Base64Encode**: Encode an input string into Base64 format according to RFC 4648 (supports optional `"url"` and `"nopad"` flags).
- **Base64Decode**: Decode a Base64-encoded string (supports standard/URL-safe alphabets, optional padding enforcement, and ignoring invalid characters).

### URL Encoding & Decoding
- **UrlEncode**: Encode a string into URL-encoded format (`%HH`).
- **UrlDecode**: Decode a URL-encoded string back into original characters.

### Checksum Calculation
- **GetMd5Sum**: Generate an MD5 hash (lowercase hexadecimal) from an input string according to RFC 1321.
- **GetCrc32Sum**: Calculate the standard IEEE 802.3 CRC32 checksum (8-character hexadecimal string) for a given input string using lookup table computation.

### File & Script Utilities
- **EnsureFileWithIdExists**: Ensure a file exists and return its ID.  
- **RunScript**: Execute another RouterOS script with optional parameters.  
- **ExportConfiguration**: Export RouterOS configuration with a standardized filename.

### Notifications
- **SendPublicTelegramMessage**: Send messages via Telegram to public chat (requires bot token and chat ID).
- **SendPrivateTelegramMessage**: Send messages via Telegram to private chat (requires bot token and chat ID).

### Auto-Update & Remote Fetching Utilities

- **FetchWithRedirect**: Downloads content from a specified URL using `/tool fetch` with full support for HTTP 3xx redirects across both RouterOS v6 and v7 environments. Captures errors via temporary output logs and returns the downloaded content directly in memory without writing the final payload to disk.
- **GetGitHubLastCommitHash**: Queries the GitHub REST API (`/repos/{owner}/{repo}/git/ref/heads/{branch}`) to retrieve the 40-character SHA commit hash of the latest commit. Uses custom HTTP headers for API versioning and parses JSON response inline.
- **DownloadAndImportScript**: Fetches an individual `.rsc` script file from a URL, validates its integrity against a provided expected hash (supporting 8-character CRC32 or 32-character MD5 checksums), and creates or updates the entry in `/system script`.
- **DownloadAndImportScriptsFromList**: Fetches and parses a remote text file (`.txt`) containing space-separated checksums and script URLs line-by-line (ignoring comments and empty lines). Automatically downloads, validates, and imports each script, tracks performance execution time, and optionally executes all updated scripts sequentially. See list.txt files in this repo for example.
- **DownloadAndImportScriptsFromGitHubList**: Parses a GitHub raw list URL to automatically determine the repository owner, name, and branch. Compares the current commit SHA hash against the stored state in global variables to detect remote repository changes. If new commits exist, it triggers `DownloadAndImportScriptsFromList` and dispatches status alerts (success or failure) via Telegram. See list.txt files in this repo for example.

## Installation
1. Save the scripts into your RouterOS environment using their respective module names (
`global_config`,
`global_functions`,
`global_functions_array_str`,
`global_functions_auto_update`,
`global_functions_datetime`,
`global_functions_encoding`,
`global_functions_global_vars`,
`global_functions_hashes`,
`global_functions_utils`).
2. Add the following execution commands to your startup script to load all global functions at system boot:
```routeros
/system script run global_config
/system script run global_functions
/system script run global_functions_array_str
/system script run global_functions_auto_update
/system script run global_functions_datetime
/system script run global_functions_encoding
/system script run global_functions_global_vars
/system script run global_functions_hashes
/system script run global_functions_utils
```
Thanks for original scripts and ideas to its authors:

* https://github.com/eworm-de/routeros-scripts.git
* https://github.com/osamahfarhan/mikrotik.git
* https://forum.mikrotik.com/

and many others...
