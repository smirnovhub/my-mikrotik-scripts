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


