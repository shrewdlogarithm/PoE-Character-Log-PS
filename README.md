# PoE-Character-Log-PS #
## Path of Exile Character Log - track any PoE character as it's played ##

This is VERY much work-in-progress - sharing for feedback/ideas!

### What it Does ###
Repeatedly Download Passives, Skills and Items for any character which has been active on the Accounts you choose to monitor.  
Create a 'Build Log' showing changes to the character over-time  
Create a Path-of-Building Pastecode/XML which contains the same changes-over-time  

[PoEClog in less than 60s (YouTube Link)](https://www.youtube.com/watch?v=Mje0pl9L8sY)

### How to Use ###
Note: If you've not used Powershell before, this is a useful "Getting Started" guide  
https://www.itprotoday.com/powershell/how-run-powershell-script  
You will need to enable scripts on your system if you've not run one before.

Run "scan_all"  
This loops endlessly, tracking characters as they are played...  

The first time you run this it creates "settings.json"  
Edit that to  
Specify the account(s) you wish to monitor.  
Specify short (between API accesses) and long (between scans or after errors) sleep times between scans

Note: settings.json is read every time the scanner loops - no-need to restart!

## What it creates ##
In the 'data' directory
JSON files which are API data for Tree, Skills and Items - 1 file per character and 1 entry per scan

In the "logs" directory
LOG files - textfiles detailing changes seen during scanning

In the "pob/builds" directory
XML - a Path-of-Building-compatible savefile 


### Other Stuff ###
"rebuildlogxml" re-creates log/html/xml files  
This can be useful to update older characters when changes are made to the parsing/output

### Notes ###
I made this in Powershell because almost everyone playing PoE has Powershell  
There is also a Python version at https://github.com/shrewdlogarithm/PoE-Character-Log-Python   
A version of that is tracking major PoE Streamers here>>> https://poeclog.pythonanywhere.com
