# PoE-Character-Log-PS #
## Path of Exile Character Log - track any PoE character as it's played ##

This is VERY much work-in-progress - sharing for feedback/ideas!

### How to Use ###
To scan one-or-more entire account(s) 
Edit scan_accounts.ps1 and add the account names you wish to scan - then run run_accounts.bat

To scan one-or-more character(s)
Edit scan_chars.ps1 - enter the account/character names you wish to scan - then run run_chars.bat

### What it creates ###
In the 'data' directory you will find - for each character scanned
JSON - a complete dump of API data for Tree, Skills and Items - 1 entry per scan
LOG - a TXT file detailing changes made to a character (intended to run as a Twitch overlay or just to show a quick build guide)
XML - a PoB-compatible save which details each step of tree/equipment (does not currently support skills - I'm working on that)
The code can also produce Passive Tree Build Codes compatible with the official GGG Tree - see the code for details

### Notes ###
I made this in Powershell because almost everyone playing PoE has Powershell - I also have a Python version which I will share once it's cleaned-up a bit.
Scripts have to run continuously to track a character - currently they check every 60s - you may wish to increase/reduce that according to your needs

### Examples ###
My Python version is monitoring some of the better-known PoE streamers at http://trjp.pythonanywhere.com - you can see logs/download PoBs from there too!
