# BitLocker Status Monitor
Simple batch file that keeps track of Windows Bitlocker's Encryption, because the Settings progress bar shows no useful information at all.

I conceived this batch script in an internship where clients computers disks needs to be tested on a separate machine, needing to decrypt each disk of the client's machine.
This process takes a long. Time. A long time. And I needed to know which disks could already be tested while the others are still decrypting. This info is not shown on the regular Windows Settings app.

---

## Features

* **Bitlocker status:** Shows the bitlocker encryption status using  `manage-bde -status`.
* **Progress visualization:** Features a dynamic progress bar built natively using clean UTF-8 (`██░░`) graphics.
* **Global encryption average:** Displays a calculated mathematical average of encryption/decryption progress across all system volumes in the header.
* **Data metrics:** Turns `manage-bde` drive sizes into Megabytes to show exactly how much data has been processed.

---

## Preview

```text
┌──────────────────────────────────────────────────────────────────┐
│                    BITLOCKER STATUS MONITOR                      │
│    Time: 14:18:52       │       Global Encryption Avg: 25%       │
└──────────────────────────────────────────────────────────────────┘

 ► Volume C: []
     Conversion Status:    Decryption in Progress
     Percentage Encrypted: 34.6%
     Progress: [██████░░░░░░░░░░░░░░]
     Size Encrypted: 332126 MB / 976844 MB

 ► Volume D: [Games Drive]
     Conversion Status:    Fully Decrypted
     Percentage Encrypted: 0.0%
     Progress: [░░░░░░░░░░░░░░░░░░░░]
     Size Encrypted: 0 MB / 486881 MB

────────────────────────────────────────────────────────────────────
 [Ctrl+C] to Exit

```

---

## How to run

1. Clone or Download this repository and save it anywhere. 
2. **Right-click** `BitlockerSM.bat` and select **Run as Administrator** (Since administrative privileges are required for `manage-bde` to fetch bitlocker's status).

---

## Changable Configurations

By default, it waits 3 seconds between each update because `manage-bde` prints everything line by line and the batch file buffers everything into a variable and this takes a fraction of time. You'd want to adjust this depending on how many drives you have, but you won't need more than 3 seconds.
To adjust the frequency of the screen to your likings open `BitlockerSM.bat` in any text editor and change the `REFRESH_RATE` value at the very top of the file to your liking:

```batch
:: Config
set "REFRESH_RATE=3"

```

## License

This project is open-source and available under the [MIT License](https://www.google.com/search?q=LICENSE).

```

```
