# My **Mikrotik** Scripts

My huge collection of **Mikrotik** scripts. All global scripts are completely tested on **RouterOS 6.49.17** and **RouterOS 7.21.5**.

The code features comprehensive test coverage, ensuring reliable, stable operation and preventing runtime errors across execution environments.

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

### Global Settings

#### Telegram Notifications

The following global settings are required to configure Telegram integration. These variables must be defined for the **Notifications** module (`SendPublicTelegramMessage` and `SendPrivateTelegramMessage`) to successfully send alerts to public or private channels.

- **telegramBotToken**: Stores the token for the Telegram bot used to send messages.
- **telegramPublicChatID**: Stores the Telegram public chat ID where messages will be sent.
- **telegramPrivateChatID**: Stores the Telegram private chat ID where messages will be sent.

### Global Predefined Constants

- **globalFunctionsReady**: Boolean flag indicating global functions readiness (`false` by default, set to `true` at the end of `global_functions.rsc`).
- **backhandIndexPointingLeftEmoji**: Stores the URL-encoded left-pointing backhand index emoji (`👈`) used to highlight or draw attention to preceding text or values.
- **largeGreenCircleEmoji**: Stores the URL-encoded green circle emoji (`🟢`) used for successful status updates.
- **largeRedCircleEmoji**: Stores the URL-encoded red circle emoji (`🔴`) used for failed status updates.
- **largeYellowCircleEmoji**: Stores the URL-encoded yellow circle emoji (`🟡`) used for warning, in-progress, or pending status indicators.
- **squaredUpWithExclamationMark**: Stores the URL-encoded “squared up” emoji (`🆙`) with exclamation mark.
- **warningSignEmoji**: Stores the URL-encoded warning emoji (`⚠️`) used for alert messages.
- **whiteCircleEmoji**: Stores the URL-encoded white circle emoji (`⚪`) used for neutral list markers, inactive states, or toggled-off option indicators.
- **nbsp**: Stores the UTF-8 URL-encoded byte sequence representing a non-breaking space character.

## Features

### Network Utilities & Status Checks

- **DNSIsResolving / WaitDNSResolving**: Check or wait for DNS resolution.
- **DefaultRouteIsReachable / WaitDefaultRouteReachable**: Check or wait for default route availability.
- **GetDhcpClientAddress**: Retrieves the assigned IPv4 address (without CIDR prefix) from a bound DHCP client on a specified interface.
- **GetDhcpClientGateway**: Retrieves the default gateway IPv4 address provided by a bound DHCP client on a specified interface.
- **GetHttpFileContent**: Downloads file content from an HTTP URL into memory, enforcing a 64 KB size limit.
- **GetHttpFileContentWithRetry**: Fetches HTTP file content with automatic retries and incremental backoff delays between attempts.
- **GetRouterOSVersion**: Retrieves the system RouterOS version string, automatically stripping release channels or build suffixes (e.g., returning `"7.21.5"`).
- **SilentPing**: Perform silent pings to a single host or multiple hosts in parallel.  
- **TimeIsSync / WaitTimeSync**: Check or wait for NTP time synchronization.
- **WaitFullyConnected**: Wait until network is fully ready (default route reachable, DNS resolving, and NTP synced).

### Logging & Error Handling

- **LogAndExit**: Logs messages with severity (`info`, `warning`, `error`, `debug`) and stops execution if necessary.

### Argument & Configuration Handling

- **GetArgOrDefault**: Retrieves a parameter or returns a default value.  
- **GetArgOrExit**: Retrieves a required parameter and exits if missing.

### Array & String Utilities

- **CleanStr**: Filter a string to keep only allowed characters.
- **CompareStr**: Compare two strings lexicographically using ASCII character codes.
- **ContainsStr**: Check if a substring exists within a string.
- **ExtractFileName**: Extract and return the file name from a path (with optional extension retention).
- **IsPrintableStr**: Check whether a string contains only printable characters.
- **JoinArray**: Join array elements into a single string with a separator.
- **MapArray**: Apply a transformation function to each array element.
- **ParseKeyValueStore**: Convert key-value pairs or space-separated strings into associative arrays (maps).
- **ReplaceStr**: Replace substrings in a string.
- **ReverseStr**: Reverse characters in a string.
- **SplitStr**: Split strings into arrays by delimiter.
- **StartsWithStr / EndsWithStr**: Verify string prefixes or suffixes.
- **ToUpperCase / ToLowerCase**: Convert strings to uppercase or lowercase.
- **TrimStr, TrimStrLeft, TrimStrRight**: Trim characters from strings.

### Named Global Variables Utilities

- **GetGlobalVar**: Retrieves a value of a dynamically evaluated global variable by its base name.
- **GetGlobalVarOrDefault**: Retrieves a global variable's value, returning a specified default value if the variable does not exist, is uninitialized, or evaluates to `nothing`/`nil`.
- **RemoveGlobalVar**: Completely deletes a dynamic global variable from `/system script environment` by its name.
- **SetGlobalVar**: Assigns a value to a dynamically created global variable in the system environment.

### Random & Numeric Utilities

- **DivideIntAndRound**: Divide integers and round to a specified number of decimal places.
- **GetRandom20CharHex**: Generate a random 20-character hexadecimal string.
- **GetRandomNumber**: Generate a pseudo-random number within a range.
- **HexToChar / DecToChar**: Convert hexadecimal or decimal ASCII values to characters.
- **HexToNum**: Convert hexadecimal strings to numeric values.

### Sorting

- **RecursiveMergeSort**: Perform merge sort on an array of comparable items.
- **RecursiveMergeSortStr**: Perform merge sort on an array of strings in ascending lexicographical order.

### Date & Time Utilities

- **FormatSecondsLong / FormatSecondsShort**: Format duration in seconds into human-readable strings.
- **FromUnixTimestamp**: Convert a Unix timestamp back into `YYYY-MM-DD HH:MM:SS` format.
- **GetCurrentDateTime**: Retrieve current system date-time formatted as `YYYY-MM-DD HH:MM:SS`.
- **GetUnixTimestamp**: Retrieve the current system time as a Unix timestamp.
- **GetWeekday**: Calculate the weekday for a given date.
- **ParseDateTime**: Parse RouterOS-style (`mmm/DD/YYYY HH:MM:SS`) or ISO-style (`YYYY-MM-DD HH:MM:SS`) date-time strings into standard format.
- **ToUnixTimestamp**: Convert a date-time string to a Unix timestamp.

### Auto-Update & Remote Fetching Utilities

- **DownloadAndImportScript**: Download a `.rsc` script from a URL, verify its hash (CRC32 or MD5), and add/update it in RouterOS system scripts.
- **DownloadAndImportScriptsFromGitHubList**: Check a GitHub repository for new commits, download updated scripts from a list if changes are detected, and send status notifications via Telegram.
- **DownloadAndImportScriptsFromList**: Download and parse a `.txt` list file containing hashes and script URLs, then update and optionally execute them.
- **FetchWithRedirect**: Download content from a URL with support for HTTP 3xx redirects (handling RouterOS 6 & 7 differences) and in-memory payload extraction.
- **GetGitHubLastCommitHash**: Query GitHub API for the latest commit SHA hash of a branch.

### Base64 Encoding & Decoding

- **Base64Decode**: Decode a Base64-encoded string (supports standard/URL-safe alphabets, optional padding enforcement, and ignoring invalid characters).
- **Base64Encode**: Encode an input string into Base64 format according to RFC 4648 (supports optional `"url"` and `"nopad"` flags).

### URL Encoding & Decoding

- **UrlDecode**: Decode a URL-encoded string back into original characters.
- **UrlEncode**: Encode a string into URL-encoded format (`%HH`).

### Checksum Calculation

- **GetCrc32Sum**: Calculate the standard IEEE 802.3 CRC32 checksum (8-character hexadecimal string) for a given input string using lookup table computation.
- **GetMd5Sum**: Generate an MD5 hash (lowercase hexadecimal) from an input string according to RFC 1321.
- **GetSha1Sum**: Generate an SHA1 hash (lowercase hexadecimal) from an input string according to RFC 3174.

#### Checksum Benchmark on RB750Gr3

All hash algorithms are highly optimized for RouterOS. Exact benchmarks for RB750Gr3 are listed below.

- **GetCrc32Sum**: 1.0x baseline
- **GetMd5Sum**: 1.04x slower than CRC32
- **GetSha1Sum**: 1.35x slower than CRC32

### File & Script Utilities

- **EnsureFileWithIdExists**: Ensure a file exists and return its ID.  
- **ExportConfiguration**: Export RouterOS configuration with a standardized filename.
- **RunScript**: Execute another RouterOS script with optional parameters.  

### Notifications

- **SendPrivateTelegramMessage**: Send messages via Telegram to private chat (requires bot token and chat ID).
- **SendPublicTelegramMessage**: Send messages via Telegram to public chat (requires bot token and chat ID).

### Auto-Update & Remote Fetching Utilities

- **DownloadAndImportScript**: Fetches an individual `.rsc` script file from a URL, validates its integrity against a provided expected hash (supporting 8-character CRC32 or 32-character MD5 checksums), and creates or updates the entry in `/system script`.
- **DownloadAndImportScriptsFromGitHubList**: Parses a GitHub raw list URL to automatically determine the repository owner, name, and branch. Compares the current commit SHA hash against the stored state in global variables to detect remote repository changes. If new commits exist, it triggers `DownloadAndImportScriptsFromList` and dispatches status alerts (success or failure) via Telegram. See list.txt files in this repo for example.
- **DownloadAndImportScriptsFromList**: Fetches and parses a remote text file (`.txt`) containing space-separated checksums and script URLs line-by-line (ignoring comments and empty lines). Automatically downloads, validates, and imports each script, tracks performance execution time, and optionally executes all updated scripts sequentially. See list.txt files in this repo for example.
- **FetchWithRedirect**: Downloads content from a specified URL using `/tool fetch` with full support for HTTP 3xx redirects across both RouterOS v6 and v7 environments. Captures errors via temporary output logs and returns the downloaded content directly in memory without writing the final payload to disk.
- **GetGitHubLastCommitHash**: Queries the GitHub REST API (`/repos/{owner}/{repo}/git/ref/heads/{branch}`) to retrieve the 40-character SHA commit hash of the latest commit. Uses custom HTTP headers for API versioning and parses JSON response inline.

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

## Automatic Script Updates

The framework provides built-in mechanisms for automatically downloading, importing, and updating global scripts directly from remote repositories. 

You can perform simple updates using plain file manifests or utilize GitHub-aware functions that verify commit hashes to prevent unnecessary re-downloads when script sources remain unchanged.

```routeros
# Standard download and import from remote list manifest
:global DownloadAndImportScriptsFromList
$DownloadAndImportScriptsFromList https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/list.txt true

# GitHub-aware update checking commit hash before re-downloading
:global DownloadAndImportScriptsFromGitHubList
$DownloadAndImportScriptsFromGitHubList https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/list.txt true
```

#### Parameters & Behavior

Both update functions accept a boolean parameter (`true` or `false`) following the manifest URL:

- **`true` (Import & Execute)**: Downloads, imports the scripts into the system script store, and **automatically executes** them immediately after loading to populate the global environment.
- **`false` (Import only)**: Downloads and imports the scripts into the system script store without executing them.

## Function Usage Examples

Below are practical examples demonstrating how to execute common library functions directly within RouterOS.

### 1. Hashing and Checksums

Generate MD5 hashes or CRC32 checksums for strings or binary payloads:

```routeros
:global GetMd5Sum
:global GetSha1Sum
:global GetCrc32Sum

# Generate an MD5 hash
:local md5 [$GetMd5Sum "admin"]
:put ("MD5: " . $md5)
# Output: MD5: 21232f297a57a5a743894a0e4a801fc3

# Generate a SHA1 hash
:local sha1 [$GetSha1Sum "nimda"]
:put ("SHA1: " . $sha1)
# Output: SHA1: a4cbb2f3933c5016da7e83fd135ab8a48b67bf61

# Generate a CRC32 checksum
:local crc32 [$GetCrc32Sum "123456789"]
:put ("CRC32: " . $crc32)
# Output: CRC32: cbf43926
```

### 2. Base64 and URL Encoding / Decoding

Encode and decode strings using Standard/URL-safe Base64 alphabets or URL percent-encoding:

```routeros
:global Base64Encode
:global Base64Decode
:global UrlEncode
:global UrlDecode

# Standard Base64 Encoding
:local b64 [$Base64Encode "Hello World"]
:put ("Base64 Encoded: " . $b64)
# Output: Base64 Encoded: SGVsbG8gV29ybGQ=

# URL-Safe Base64 Encoding without padding
:local b64Url [$Base64Encode "subjects?" "url" "nopad"]
:put ("Base64 URL-Safe: " . $b64Url)
# Output: Base64 URL-Safe: c3ViamVjdHM_

# Base64 Decoding
:local plain [$Base64Decode "SGVsbG8gV29ybGQ="]
:put ("Base64 Decoded: " . $plain)
# Output: Base64 Decoded: Hello World

# URL Percent Encoding
:local urlEnc [$UrlEncode "search?q=test&a=1"]
:put ("URL Encoded: " . $urlEnc)
# Output: URL Encoded: search%3Fq%3Dtest%26a%3D1

# URL Percent Decoding
:local urlDec [$UrlDecode "search%3Fq%3Dtest%26a%3D1"]
:put ("URL Decoded: " . $urlDec)
# Output: URL Decoded: search?q=test&a=1
```

### 3. Network and Utility Functions (SilentPing, GetArgOrDefault, GetArgOrExit)

```routeros
:global SilentPing
:global GetArgOrDefault
:global GetArgOrExit

# --- Silent Ping Examples ---

# Ping a single host (returns successful packet count integer)
:local pingsPassed [$SilentPing "127.0.0.1" 3]
:put ("Localhost replies: " . $pingsPassed)

# Ping multiple hosts in parallel (returns dictionary with results)
:local targets {
    "gateway"="172.17.17.1";
    "dns"="8.8.8.8";
    "deadHost"="198.51.100.254"
}

:local pingResults [$SilentPing $targets 5]
:put ("Gateway replies: " . ($pingResults->"gateway"))
:put ("DNS replies: " . ($pingResults->"dns"))
:put ("Dead host replies: " . ($pingResults->"deadHost"))

# Output:
Localhost replies: 3
Gateway replies: 5
DNS replies: 5
Dead host replies: 0

# --- Argument Extraction Examples ---

:local config {
    "host"="10.0.0.1";
    "enabled"="true";
    "port"=8080
}

# Safely fetch an optional parameter with fallback default
:local timeout [$GetArgOrDefault $config "timeout" 30]
:put ("Timeout: " . $timeout)
# Output: Timeout: 30

# String "true"/"false" values are automatically parsed into boolean primitives
:local isEnabled [$GetArgOrDefault $config "enabled" false]
:put ("Enabled type: " . [:typeof $isEnabled] . ", value: " . [:tostr $isEnabled])
# Output: Enabled type: bool, value: true

# Extract a mandatory parameter (will log and exit script execution if missing)
:local host [$GetArgOrExit $config "host" "API Configuration"]
:put ("Host: " . $host)
# Output: Host: 10.0.0.1
```

### 4. Named Global Variable Utility Management

Set, get, fallback, and remove global variables without polluting runtime scope:

```routeros
:global SetGlobalVar
:global GetGlobalVar
:global GetGlobalVarOrDefault
:global RemoveGlobalVar

# Set global variables (supports primitives, IP addresses, subnets, and arrays)
$SetGlobalVar "myServerIp" 192.168.88.1

# Retrieve a global variable value
:local ip [$GetGlobalVar "myServerIp"]
:put ("Server IP: " . $ip)
# Output: Server IP: 192.168.88.1

# Retrieve variable with fallback default if non-existent
:local port [$GetGlobalVarOrDefault "myServerPort" 8080]
:put ("Server Port: " . $port)
# Output: Server Port: 8080

# Remove a global variable
$RemoveGlobalVar "myServerIp"
```

### 5. Date and Time Functions

Convert timestamps, format duration strings, or parse RouterOS/ISO date-time formats:

```routeros
:global GetCurrentDateTime
:global FromUnixTimestamp
:global ToUnixTimestamp
:global FormatSecondsLong
:global FormatSecondsShort

# Get current normalized system date-time
:put ("Current Date Time: " . [$GetCurrentDateTime])
# Output: Current Date Time: 2026-08-05 20:33:25

# Convert Unix timestamp to ISO formatted string
:local isoDate [$FromUnixTimestamp 1700000000]
:put ("ISO Date: " . $isoDate)
# Output: ISO Date: 2023-11-14 22:13:20

# Convert ISO date-time string back to Unix timestamp
:local ts [$ToUnixTimestamp "2023-11-14 22:13:20"]
:put ("Unix Timestamp: " . $ts)
# Output: Unix Timestamp: 1700000000

# Format duration seconds into human-readable detailed string
:local detailedDuration [$FormatSecondsLong 90184]
:put ("Detailed Duration: " . $detailedDuration)
# Output: Detailed Duration: 1d 1h 3m 4s

# Format duration seconds into scaled short units
:local shortDuration [$FormatSecondsShort 90184]
:put ("Short Duration: " . $shortDuration)
# Output: Short Duration: 1 days
```

# Tests

## Files list

* [`global_functions_array_str_tests_1.rsc`](global/tests/global_functions_array_str_tests_1.rsc)
* [`global_functions_array_str_tests_2.rsc`](global/tests/global_functions_array_str_tests_2.rsc)
* [`global_functions_datetime_tests_1.rsc`](global/tests/global_functions_datetime_tests_1.rsc)
* [`global_functions_datetime_tests_2.rsc`](global/tests/global_functions_datetime_tests_2.rsc)
* [`global_functions_encoding_tests.rsc`](global/tests/global_functions_encoding_tests.rsc)
* [`global_functions_global_vars_tests.rsc`](global/tests/global_functions_global_vars_tests.rsc)
* [`global_functions_hashes_tests.rsc`](global/tests/global_functions_hashes_tests.rsc)
* [`global_functions_utils_tests.rsc`](global/tests/global_functions_utils_tests.rsc)

### Array and String Functions Tests

- **RunAllArrayStrTests1**: Executes the first suite of array and string utility tests, covering string operations, case transformations, trim logic, array manipulation, and formatting functions.
- **RunAllArrayStrTests2**: Executes the second suite of array and string utility tests, covering search, splitting, joining, and array filtering operations.
- **CleanStrTest**: Tests string sanitization (`CleanStr`) against allowed character sets, verifying alphanumeric filtering, whitespace/control character stripping, quotes, path cleaning, and non-string parameter handling.
- **CompareStrTest**: Tests lexicographical comparison of two strings (`CompareStr`), validating ASCII ordering (uppercase vs lowercase), length variations, prefix matching, and special characters.
- **ContainsStrTest**: Tests substring existence checks (`ContainsStr`), covering middle/start/end matches, case sensitivity, empty search targets, and special character handling.
- **DecToCharTest**: Tests conversion of decimal ASCII codes to characters, covering standard printable ranges, digits, whitespace control characters, and boundary byte values.
- **DivideIntAndRoundTest**: Tests integer division with precise decimal rounding and zero-padding, verifying round down/up/half-up cases, trailing zeros, division by zero guards, and small fraction handling.
- **EndsWithStrTest**: Tests suffix matching (`EndsWithStr`), validating file extension checks, trailing slashes/spaces, case sensitivity, and numeric/IP object parameters.
- **ExtractFileNameTest**: Tests file name extraction from path strings (`ExtractFileName`), validating extension stripping/retention, hidden files (`.env`), multiple dots, directory slashes, and trailing spaces.
- **HexToCharTest**: Tests conversion of 2-digit hex codes to ASCII characters, validating printable characters, spaces, control characters (`\t`, `\n`, `\r`), and boundary bytes.
- **HexToNumTest**: Tests conversion of hexadecimal strings to numeric values, covering single/multi-digit inputs, case insensitivity, leading zeros, 32/64-bit boundaries, and invalid character handling.
- **IsPrintableStrTest**: Tests printable character validation (`IsPrintableStr`), verifying standard text and symbols while rejecting control characters (`0x00`-`0x1F`, DEL) and extended ASCII range values.
- **JoinArrayTest**: Tests array joining into delimited strings, validating custom single/multi-character separators, empty elements, single-item arrays, and special escape sequences.
- **MapArrayTest**: Tests array mapping transformations, verifying operations on indexed and associative arrays, key/value combinations, boolean inversions, type conversions, and numeric key preservation.
- **ParseKeyValueStoreTest**: Tests key-value pair parsing from strings or arrays into associative maps, validating custom delimiters, flag-only keys, boolean casting, duplicate overwrites, and empty element filtering.
- **RandomTest**: Validates random generation utilities, checking string length, character printability, uniqueness, hexadecimal constraints, 32-bit integer boundaries, and uniform distribution across custom ranges.
- **RecursiveMergeSortStrTest**: Tests recursive merge sort for string arrays, validating alphabetical order, prefix length variations, ASCII case sensitivity, numbers as strings, and special characters.
- **RecursiveMergeSortTest**: Tests recursive merge sort logic for numeric arrays, validating unsorted sequences, duplicates, reverse order, zeros, and boundary numbers.
- **ReplaceStrTest**: Tests substring replacement, checking single and global matches, empty string edge cases, overlapping patterns, and special character replacements.
- **ReverseStrTest**: Tests string reversal (`ReverseStr`), covering standard words, multi-word strings, palindromes, file paths, control characters, and non-string type inputs.
- **SplitStrTest**: Tests string splitting into arrays by single or multi-character delimiters, verifying maximum split limit constraints, empty tokens, and special character handling.
- **StartsWithStrTest**: Tests prefix matching (`StartsWithStr`), verifying exact prefixes, case sensitivity, empty inputs, path separators, and non-string type handling.
- **ToLowerCaseTest**: Tests string conversion to lowercase, ensuring uppercase letters are transformed while preserving non-alphabetic characters.
- **ToUpperCaseTest**: Tests string conversion to uppercase, ensuring lowercase letters are transformed while numbers, spaces, and special symbols remain intact.
- **TrimStrTest**: Tests trimming functions (`TrimStrLeft`, `TrimStrRight`, `TrimStr`), verifying removal of whitespace, custom character sets, control characters, and slashes from string edges.

### Date and Time Functions Tests

- **RunAllDateTimeTests1**: Executes date and time conversion and parsing tests (`GetWeekdayTest`, `GetCurrentDateTimeTest`, `ParseDateTimeTest`, `FromUnixTimestampTest`, `ToUnixTimestampTest`, `GetUnixTimestampTest`).
- **RunAllDateTimeTests2**: Executes duration formatting tests (`FormatSecondsShortTest`, `FormatSecondsLongTest`).
- **FormatSecondsLongTest**: Tests formatting of raw durations in seconds into multi-component detailed duration strings (`1d 2h 3m 4s`), validating single-unit boundaries, omitted zero components, double-digit days, and multi-thousand day durations.
- **FormatSecondsShortTest**: Tests dynamic scaling of duration values into single short units (`sec`, `min`, `hrs`, `days`), checking boundary transitions, truncation rules, and multi-day thresholds.
- **FromUnixTimestampTest**: Tests conversion of numeric Unix timestamps to formatted ISO date-time strings across all epoch boundaries, 32-bit limits, month end transitions, leap years, and leap century rules.
- **GetCurrentDateTimeTest**: Validates live runtime fetches, confirming that real-time system date-time strings and timestamps are correctly structured and mutually convertible.
- **GetUnixTimestampTest**: Verifies live runtime generation of current Unix timestamps and ensures round-trip conversion accuracy through intermediate date-time string representations.
- **GetWeekdayTest**: Validates the conversion of Unix timestamps to day-of-week strings (`thursday` through `wednesday`), covering epoch baselines, leap day transitions, 400-year Gregorian cycle alignments, far-future boundaries, and intra-day seconds shifts.
- **ParseDateTimeTest**: Tests parsing and conversion of RouterOS format strings (`mmm/dd/yyyy hh:mm:ss`, case-insensitive) and standard ISO strings into normalized YYYY-MM-DD HH:MM:SS format, including error rejection for malformed layout structures.
- **ToUnixTimestampTest**: Tests conversion of ISO and RouterOS date-time strings into Unix timestamp integers, verifying accuracy across time-of-day edge cases, leap days, non-leap century boundaries, and 32-bit integer limits.

### Encoding and Decoding Functions Tests

- **RunAllEncodingTests**: Executes string and binary encoding/decoding tests (`Base64EncodeTest`, `Base64DecodeTest`, `UrlEncodeTest`, `UrlDecodeTest`).
- **Base64DecodeTest**: Tests Base64 decoding operations, validating standard padding rules, missing padding tolerance, strict padding enforcement (`mustpad`), URL-safe character set decoding, invalid character filtering (`ignoreotherchr`), error throwing on malformed inputs, and complete 256-byte binary round-trip conversion.
- **Base64EncodeTest**: Tests Base64 encoding functionality, verifying standard RFC 4648 test vectors, URL-safe alphabet substitution (`+`/`/` to `-`/`_`), padding elimination (`nopad`), whitespace preservation, and multi-block text encoding.
- **UrlDecodeTest**: Tests URL percent-decoding logic, verifying uppercase/lowercase hexadecimal sequence resolution, unreserved character pass-through, binary output safety checks via `IsPrintableStr`, and a complete 256-byte round-trip decoding test.
- **UrlEncodeTest**: Tests URL percent-encoding according to RFC 3986, verifying pass-through of unreserved alphanumeric characters and proper hex-encoding for spaces (`%20`), delimiters, brackets, arithmetic symbols, and reserved punctuation.

### Named Global Variable Utility Functions Tests

- **RunAllGlobalVarTests**: Executes global variable management and state persistence tests (`GlobalVarTest`).
- **GlobalVarTest**: Validates global variable lifecycle management (`SetGlobalVar`, `GetGlobalVar`, `GetGlobalVarOrDefault`, `RemoveGlobalVar`), covering primitive type persistence (strings, integers, floats, booleans, IP addresses, subnets, time values), structured arrays (indexed and associative), fallback default resolution for non-existent variables without side-effect creation, variable isolation, repeat updates, type overwriting, idempotent removal, complex string escape sequences, and complete 256-byte binary payload persistence.

### Hashing Functions Tests

- **RunAllHashesTests**: Executes hashing and checksum tests (`GetMd5SumTest`, `GetCrc32SumTest`).
- **GetCrc32SumTest**: Tests CRC32 checksum calculation (`GetCrc32Sum`), verifying canonical test vectors (including `123456789`), empty inputs, single/multi-byte sequences, pangrams, numeric boundaries, case sensitivity, character ordering, null bytes, control whitespace, byte-range patterns, and length boundaries up to 257+ bytes.
- **GetMd5SumTest**: Tests MD5 hash generation (`GetMd5Sum`), validating standard RFC 1321 test vectors, empty string boundaries, single/multi-character strings, case sensitivity, whitespace preservation, 55/56/64/128-byte multi-block message boundaries, and a complete 256-byte binary payload hash.

### Utility Functions Tests

- **RunAllUtilsTests**: Executes system and framework utility tests (`GetArgOrDefaultTest`, `GetArgOrExitTest`, `SilentPingTest`, `RunScriptTest`, `ExportConfigurationTest`, `GetRouterOSVersionTest`).
- **ExportConfigurationTest**: Validates automated configuration backups (`ExportConfiguration`), testing physical file creation on storage, root export operations, and graceful error handling (returning empty string) when attempting to export to non-existent directory paths.
- **GetArgOrDefaultTest**: Validates fallback option retrieval (`GetArgOrDefault`), checking default assignment for missing keys or empty strings, case-sensitive boolean conversion (`true`/`false`), native type retention (booleans, integers, zero values, empty keys), side-effect isolation on source maps, and exception assertions on invalid default parameters.
- **GetArgOrExitTest**: Tests mandatory argument extraction (`GetArgOrExit`), verifying string-to-boolean parsing, preservation of native types (integers, booleans, zero values), custom/default context handling, map modification immutability, and controlled script exit traps (`LogAndExit`) when required parameters or maps are missing or empty.
- **GetRouterOSVersionTest**: Validates system version parsing (`GetRouterOSVersion`), verifying non-empty string extraction, stripping of channel/build suffix metadata (e.g., removing spaces and `(stable)` flags), and exact alignment with sliced system resource queries.
- **RunScriptTest**: Tests system script invocation wrappers (`RunScript`), verifying positional parameter passing up to 6 arguments, partial parameter truncation, non-existent script handling without system crashes, and internal syntax compilation error trapping.
- **SilentPingTest**: Tests ICMP ping utility behavior (`SilentPing`), checking single-host ping packet counts, default parameter fallback, unreachable host zero-reply tracking, parallel execution over host dictionary maps, empty input handling, and environment state cleanliness.

## Installation

1. Save the scripts into your RouterOS environment using their respective module names (
`global_functions_array_str_tests_1`,
`global_functions_array_str_tests_2`,
`global_functions_datetime_tests_1`,
`global_functions_datetime_tests_2`,
`global_functions_encoding_tests`,
`global_functions_global_vars_tests`,
`global_functions_hashes_tests`,
`global_functions_utils_tests`).
2. Add the following execution commands to your startup script to load all test suites at system boot:
```routeros
/system script run global_functions_array_str_tests_1
/system script run global_functions_array_str_tests_2
/system script run global_functions_datetime_tests_1
/system script run global_functions_datetime_tests_2
/system script run global_functions_encoding_tests
/system script run global_functions_global_vars_tests
/system script run global_functions_hashes_tests
/system script run global_functions_utils_tests
```
## Automatic Test Suite Updates

The framework provides built-in mechanisms for automatically downloading, importing, and updating test suites directly from remote repositories. 

You can perform simple updates using plain file manifests or utilize GitHub-aware functions that verify commit hashes to prevent unnecessary re-downloads when script sources remain unchanged.

```routeros
# Standard download and import from remote list manifest
:global DownloadAndImportScriptsFromList
$DownloadAndImportScriptsFromList https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/list.txt true

# GitHub-aware update checking commit hash before re-downloading
:global DownloadAndImportScriptsFromGitHubList
$DownloadAndImportScriptsFromGitHubList https://github.com/smirnovhub/my-mikrotik-scripts/raw/refs/heads/master/global/tests/list.txt true
```

#### Parameters & Behavior

Both update functions accept a boolean parameter (`true` or `false`) following the manifest URL:

- **`true` (Import & Execute)**: Downloads, imports the scripts into the system script store, and **automatically executes** them immediately after loading to populate the global environment.
- **`false` (Import only)**: Downloads and imports the scripts into the system script store without executing them.

## Test Execution Examples

Below are practical examples demonstrating how to run test suites in RouterOS, ranging from executing individual test cases to running entire packages and chaining them into a full pipeline.

### 1. Running Individual Test Functions

Run a specific test function when debugging a single component:

```routeros
# Run Base64 encoding tests
:global Base64EncodeTest
:put [$Base64EncodeTest]

# Run MD5 hash generation tests
:global GetMd5SumTest
:put [$GetMd5SumTest]

# Run argument extraction utility tests
:global GetArgOrDefaultTest
:put [$GetArgOrDefaultTest]
```
### 2. Running Full Package Suites

Execute all tests in a specific module using its corresponding RunAll entry point:

```routeros
# Run all encoding and decoding tests
:global RunAllEncodingTests
:put [$RunAllEncodingTests]

# Run all global variable utility tests
:global RunAllGlobalVarTests
:put [$RunAllGlobalVarTests]

# Run all hash and checksum tests
:global RunAllHashesTests
:put [$RunAllHashesTests]

# Run all utility tests
:global RunAllUtilsTests
:put [$RunAllUtilsTests]
```

### 3. Chaining Multiple Packages (Continuous Integration Pipeline)

Aggregate results across multiple test suites into a single execution pass to inspect cumulative passed and failed counters:

```routeros
:global RunAllArrayStrTests1
:global RunAllArrayStrTests2
:global RunAllDateTimeTests1
:global RunAllDateTimeTests2
:global RunAllEncodingTests
:global RunAllGlobalVarTests
:global RunAllHashesTests
:global RunAllUtilsTests

# Initialize result collector
:local stats [:toarray ""]

:set ($stats->"passed") 0
:set ($stats->"failed") 0

# Execute suites sequentially while passing the results map
:set stats [$RunAllArrayStrTests1 $stats]
:set stats [$RunAllArrayStrTests2 $stats]
:set stats [$RunAllDateTimeTests1 $stats]
:set stats [$RunAllDateTimeTests2 $stats]
:set stats [$RunAllEncodingTests $stats]
:set stats [$RunAllGlobalVarTests $stats]
:set stats [$RunAllHashesTests $stats]
:set stats [$RunAllUtilsTests $stats]

# Output global execution summary
:put ("\1B[35m=== FINAL TEST RESULTS ===\1B[0m")
:put ("  Passed: " . ($stats->"passed"))
:put ("  Failed: " . ($stats->"failed"))
```

## Disclaimer

This software and associated scripts are provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.

**Use at your own risk.**

## Acknowledgments

Special thanks to the authors and community members whose scripts, ideas, and open-source solutions served as a foundation and inspiration for this project:

* **[routeros-scripts](https://github.com/eworm-de/routeros-scripts.git)** by eworm-de
* **[mikrotik](https://github.com/osamahfarhan/mikrotik.git)** by osamahfarhan
* **[MikroTik Community Forum](https://forum.mikrotik.com/)** and its vibrant community of engineers and enthusiasts
* ...and many others across the open-source ecosystem.
