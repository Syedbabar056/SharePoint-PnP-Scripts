# SharePoint-PnP-Scripts
PnP PowerShell scripts to automate SharePoint Online permissions and governance.
PowerShell version - 7.5.2 // Can Run in VS CODE using Powershell Extension -- Terminal 

**First Script**
# CopySPModernPagefromSourcetoDestination
## This is a simple PowerShell script I have written using PnP PowerShell to **export a modern SharePoint page** from one site and **import it into another**.
## Purpose - On day to day basis i need to copy news/media modern pages from a source site to a destination using this script it will automatically create avoiding manual process.
## How It Works - Connects to the source site / Exports the specified `.aspx` modern page / Connects to the destination site / Imports the page using the extracted template

**Second Script**
# Bulk Delete SharePoint Groups Across Multiple Sites
This PowerShell script uses PnP PowerShell to **connect to multiple SharePoint Online sites** and **delete all SharePoint groups** in each site.
## ⚙️ What It Does
- Loops through a list of site URLs
- Connects to each site using `-Interactive` login or you can use -UseWebLogin
- Retrieves all SharePoint groups
- Deletes them using `Remove-PnPGroup -Force`
## Reason for building this
Though to have a quick way to remove all groups from a site before resetting permission models or rebuilding group structures. Helpful in cleanup process on dev sites.
# Writehost for understanding what each action item does.
