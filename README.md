# PoE-Character-Log-PS #
## Path of Exile Character Log - track any PoE character as it's played ##

This is VERY much work-in-progress - sharing for feedback/ideas!

### How to Use ###
Note: If you've not used Powershell before, this is a useful "Getting Started" guide  
https://www.itprotoday.com/powershell/how-run-powershell-script  
You will need to enable scripts on your system if you've not run one before.

*To scan one-or-more entire account(s)*  
Edit run_accounts.ps1 to include the account name(s) you wish to scan and run it

*To scan one-or-more character(s)*  
Edit run_chars.ps1 to include the account/character name(s) you wish to scan and run it

Note: the "sleep 60" command in those scripts is the delay between scans (in seconds) - adjust as you see-fit but bear-in-mind that the API contains a LOT of data and is rate-limited 

Important Note: only characters which are created or levelled AFTER the script begins will be logged and the script must continue to run to see changes, obviously!

### What it creates ###
In the 'data' directory you will find - for each character scanned  
JSON - API data for Tree, Skills and Items - 1 entry per scan  
LOG -  textfile detailing changes made to a character (intended to run as a Twitch overlay or just to show a quick build guide)  
XML - PoB-compatible savefile (move to the 'Builds' folder under the PoB executable) which details changes made to passive tree/gear/skills as the char levels-up

The code can also produce Official GGG Passive Tree Build Links and PoB Pastecodes 

### Other Stuff ###
The rebuildlogxml.ps script will re-create all log/html/xml files - this can be useful to update older characters when changes are made to the parsing/output


### Notes ###
I made this in Powershell because almost everyone playing PoE has Powershell  

There is also a Python version here   
https://github.com/shrewdlogarithm/PoE-Character-Log-Python

A version of that is tracking major PoE Streamers as an example here  
https://poeclog.pythonanywhere.com
