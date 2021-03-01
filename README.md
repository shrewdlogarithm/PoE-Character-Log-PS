# PoE-Character-Log-PS #
## Path of Exile Character Log - track any PoE character as it's played ##

This is VERY much work-in-progress - sharing for feedback/ideas!

### How to Use ###
Note: If you've not used Powershell before, this is a useful "Getting Started" guide  
https://www.itprotoday.com/powershell/how-run-powershell-script  
You will need to enable scripts on your system if you've not run one before.

Run "scan_all.ps1"  
This runs endlessly (Ctrl-C to stop it) tracking characters as they are played...

The first time you run this it creates "settings.json" - edit that to specify the account(s) you wish to scan. 
You may also edit the short (between API accesses) and long (between scans or after errors) sleep times - remember that shorter times mean MORE DATA and you may trigger the API 'rate limit' if you scan too-frequently.

### What it creates ###
In the 'data' directory you will find - for each character scanned  
JSON - API data for Tree, Skills and Items - 1 entry per scan  
LOG -  all changes made to a character (intended to run as a Twitch overlay or just to show a quick build guide)  
XML - PoB-compatible savefile (move to PoB's 'Builds' folder) which shows changes made to passive tree/gear/skills per-level

### Other Stuff ###
The script "rebuildlogxml.ps1" re-creates all log/html/xml files - this can be useful after changes are made in the code to refresh older builds

### Notes ###
I made this in Powershell because almost everyone playing PoE has Powershell  
There is also a Python version at https://github.com/shrewdlogarithm/PoE-Character-Log-Python   
A version of that is tracking major PoE Streamers here>>> https://poeclog.pythonanywhere.com
