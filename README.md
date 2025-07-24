# SharePoint-PnP-Scripts
PnP PowerShell scripts to automate SharePoint Online permissions and governance.
PowerShell version - 7.5.2 // Can Run in VS CODE using Powershell Extension -- Terminal 

#CopySPModernPagefromSourcetoDestination
This is a simple PowerShell script I have written using PnP PowerShell to **export a modern SharePoint page** from one site and **import it into another**.
Purpose - On day to day basis i need to copy news/media modern pages from a source site to a destination using this script it will automatically create avoiding manual process.
How It Works - Connects to the source site / Exports the specified `.aspx` modern page / Connects to the destination site / Imports the page using the extracted template
