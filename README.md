# PoE-Character-Log-PS #
## Path of Exile Character Log - track any PoE character as it's played ##

This is VERY much work-in-progress - sharing for feedback/ideas!

### How to Use ###
Note: If you've not used Powershell before, this is a useful "Getting Started" guide
https://www.itprotoday.com/powershell/how-run-powershell-script
You will need to enable scripts on your system if you've not run one before.

*To scan one-or-more entire account(s)*
Edit run_accounts.ps1 to include the account name(s) you wish to scan
Execute run_accounts.ps1 to scan those accounts
Note: only characters which are created or gain XP AFTER the script begins will be logged

*To scan one-or-more character(s)*
Edit run_chars.ps1 to include the account/character name(s) you wish to scan
Execute run_chars.ps1 to scan those characters

### What it creates ###
In the 'data' directory you will find - for each character scanned
JSON - a complete dump of API data for Tree, Skills and Items - 1 entry per scan
LOG - a textfile detailing changes made to a character (intended to run as a Twitch overlay or just to show a quick build guide)
XML - a PoB-compatible savefile (move to the 'Builds' folder under the PoB executable) which details each change made to passive tree/gear (does not currently support skills - I'm working on that)
The code can also produce Passive Tree Build Codes compatible with the official GGG Tree - not really sure what to do with those yet, but it can do it!

### Notes ###
I made this in Powershell because almost everyone playing PoE has Powershell - I also have a Python version which I will share once it's cleaned-up a bit.
Scripts obviously have to run continuously to track a character as-it's played - currently they check every 60s tho you may wish to increase/reduce that according to your needs

### Examples ###
My Python version is monitoring some of the better-known PoE streamers at http://poeclog.pythonanywhere.com - you can see logs/download PoBs from there too!
