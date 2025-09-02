## 🙋‍♂️ Author
**Syed Babar**  
Power Platform & SharePoint Enthusiast  
🔗 https://www.linkedin.com/in/syedbabar056
📫 https://github.com/Syedbabar056

## 🤝 Contributions
Feel free to fork, suggest improvements, or share how you used it in your org!

# SharePoint-PnP-Scripts
PnP PowerShell scripts to automate SharePoint Online permissions and governance.
PowerShell version - 7.5.2 // Can Run in VS CODE using Powershell Extension -- Terminal 

# **First Script**
**CopySPModernPagefromSourcetoDestination**
 This is a simple PowerShell script I have written using PnP PowerShell to **export a modern SharePoint page** from one site and **import it into another**.
## Purpose 
On day to day basis i need to copy news/media modern pages from a source site to a destination using this script it will automatically create avoiding manual process.
## How It Works 
Connects to the source site / Exports the specified `.aspx` modern page / Connects to the destination site / Imports the page using the extracted template

# **Second Script**
# Bulk Delete SharePoint Groups Across Multiple Sites
This PowerShell script uses PnP PowerShell to **connect to multiple SharePoint Online sites** and **delete all SharePoint groups** in each site.
## ⚙️ What It Does
- Loops through a list of site URLs
- Connects to each site using `-Interactive` login or you can use -UseWebLogin
- Retrieves all SharePoint groups
- Deletes them using `Remove-PnPGroup -Force`
## Reason for building this
Though to have a quick way to remove all groups from a site before resetting permission models or rebuilding group structures. Helpful in cleanup process on dev sites.
Writehost for understanding what each action item does.
## Latest Version
This PowerShell script helps SharePoint administrators safely clean up unwanted SharePoint groups from multiple sites using PnP PowerShell. It includes options to delete groups **individually** or **all at once**, with safeguards and visibility on what will be skipped. 
## Customization
Update the $Sites list with your site URLs (Tenant Name, Site collection name)
Modify $ExcludedGroupPatterns if you want to protect different groups

# **Third Script**
**Clone SharePoint User Permissions Across Different Site Collections**
This PowerShell script allows you to clone user permissions from one site collection to another using PnP PowerShell. It scans the selected scope (site, library, or folder), checks if users already exist in the destination site, and adds them if not.
##⚙️ What It Does
- Accepts multiple site collections for cloning
- Prompts for confirmation before scanning each site
- Scans site, list, and folder levels to capture permissions
- Ensures users are added to the correct SharePoint groups if missing
- Logs in the terminal where users are being added
- Skips duplicate additions if the user already exists

# **Third Script – v2**
**Enhanced Cloning with Inactive User Handling**
This is the updated version of the Clone Permissions script. It includes all functionality from v1, plus enhanced handling for inactive or departed users.

## ⚙️ What’s New in v2
- Detects inactive or departed users (null user objects from Get-PnPUser)
- Skips adding those users to the destination site (with a clean message in the terminal)
- More informative Write-Host logs so you know exactly which object is being processed
- Refined terminal output for easier tracking during large migrations
