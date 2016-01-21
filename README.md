# Powershell Baseline Script
This is a work in progress. The goal is to create a script that will take a snapshot of interesting data (processes, services, etc) of a machine and have the ability to do a comparison of the snapshot in the future. 

**It does the following:** 
- Creates a folder with all of the data in seperate text documents
- Contains two switches (baseline and persistence)
- The persistence options conducts some searches that would help identify persistence
- It was built using powershell v2 (will update it once I quit working in a V2 environment)
- Recently added a hash switch that will take a hash of c:\windows and c:\windows\system32 -recursively (cant run with powershell v2)
- I found the scheduled tasks portion on a stackoverflow forum (thank you stackoverflow) http://stackoverflow.com/questions/15439542/how-to-use-powershell-to-inventory-scheduled-tasks 

**has_compare does the following:**
- Opens a file of unknown hashes
- Opens a file of bad hashes
- Checks if any unknown hashes are found in the bad hashes
- Create a text document of all the bad hashes

**The dllfun script does the following:** 
- Creates a hashtable of .dlls and hashes, sorts them, and reports any .dlls with the same name and a different hash
- There is also a fileversion switch that creates a hashtable with .dlls with the same name and different fileversions
- Both of these produces a lot of results and I am not sure where else to take this (I guess updates and a running system changes the state and file version of .dlls)

