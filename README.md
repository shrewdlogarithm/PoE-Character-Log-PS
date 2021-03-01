# PoE-Character-Log-PS #
## Path of Exile Character Log - track any PoE character as it's played ##

This is VERY much work-in-progress - sharing for feedback/ideas!

### How to Use ###
Note: If you've not used Powershell before, this is a useful "Getting Started" guide  
https://www.itprotoday.com/powershell/how-run-powershell-script  
You will need to enable scripts on your system if you've not run one before.

Run "scan_all.ps1"  
This runs endlessly, tracking characters as they are played...  

The first time you run this it creates "settings.json"  
Edit that to  
Specify the account(s) you wish to scan.  
Specify short (between API accesses) and long (between scans or after errors) sleep times  

Note: settings.json is read every time the scanner loops - no-need to restart!

## What it creates ##
In the 'data' directory you will find  
JSON files which are a complete dump of API data for Tree, Skills and Items - 1 entry per scan

In the "logs" directory you will find  
LOG files - textfiles detailing changes made to a character (intended to run as a Twitch overlay or just to show a quick build guide)  

In the "pob/builds" directory you will find  
XML - a Path-of-Building-compatible savefile 


### Other Stuff ###
rebuildlogxml re-creates log/html/xml files  
This can be useful to update older characters when changes are made to the parsing/output

### Notes ###
I made this in Powershell because almost everyone playing PoE has Powershell  
There is also a Python version at https://github.com/shrewdlogarithm/PoE-Character-Log-Python   
A version of that is tracking major PoE Streamers here>>> https://poeclog.pythonanywhere.com
