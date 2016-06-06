# Powershell Scripts
Below is a list of powershell scripts that I have started and work on as I learn more about powershell. My goal is to find ways to improve and automate some of the tasks that I do often. 

**baseline does the following:** 
- Creates a folder with all of the data in seperate text documents
- Contains two switches (baseline and persistence)
- The persistence options conducts some searches that would help identify persistence
- It was built using powershell v2 (will update it once I quit working in a V2 environment)
- Recently added a hash switch that will take a hash of c:\windows and c:\windows\system32 -recursively (cant run with powershell v2)
- I found the scheduled tasks portion on a stackoverflow forum (thank you stackoverflow) http://stackoverflow.com/questions/15439542/how-to-use-powershell-to-inventory-scheduled-tasks 

**pswinevent does the following:**
- parses out all the event logs based on selected event ids
- contains a status bar to provide feedback on progress
- stores the output in a folder on the user's desktop called eventlogs
- contains two swtiches that defines the output format for the results (-csv and -txt)
- format is .\pswinevent.ps1 -<csv or txt> <filepath to security.evtx>


**hash_compare does the following:**
- Opens a file of unknown hashes
- Opens a file of bad hashes
- Checks if any unknown hashes are found in the bad hashes
- Create a text document of all the bad hashes

**The dllfun script does the following:** 
- Creates a hashtable of .dlls and hashes, sorts them, and reports any .dlls with the same name and a different hash
- There is also a fileversion switch that creates a hashtable with .dlls with the same name and different fileversions
- Both of these produces a lot of results and I am not sure where else to take this (I guess updates and a running system changes the state and file version of .dlls)

**The psgmail script does the following:**
- The -pull switch prompts the user for their gmail credentials and downloads emails that contain a certain string in the body
- The -filter switch parses through the emails and removes email addresses
- This will probably not be usefull for anyone, but it showcases the gmail.ps capabilities

