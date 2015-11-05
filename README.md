# Powershell Baseline Script
This is a work in progress. The goal is to create a script that will take a snapshot of interesting data (processes, services, etc) of a machine and have the ability to do a comparison of the snapshot in the future. 

It does the following: 
-Creates a folder with all of the data in seperate text documents
-Contains two switches (baseline and persistence)
-The persistence options conducts some searches that would help identify persistence
-It was built using powershell v2 (will update it once I quit working in a V2 environment)

The dllfun script does the following: 
-Creates a hashtable of .dlls and hashes, sorts them, and reports any .dlls with the same name and a different hash
-There is also a fileversion switch that creates a hashtable with .dlls with the same name and different fileversions
-Both of these produces a lot of results and I am not sure where else to take this (I guess updates and a running system changes the state and file version of .dlls)

