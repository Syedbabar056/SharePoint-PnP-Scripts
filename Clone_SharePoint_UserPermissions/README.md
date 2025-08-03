# 🔁 Clone SharePoint User Permissions Across different Site Collections

This PowerShell script uses PnP PowerShell to clone all permissions from a source user to a target user across multiple SharePoint Online site collections. It handles permissions at the site, list, and folder level with validation and terminal-friendly output.

## 🚀 Features
- Clone user permissions from site, library, and folder levels.
- Skips already existing group memberships or roles.
- Detects and assigns missing site collection admin rights.
- Optionally scans folders (document libraries only).
- Prompts per site collection to proceed with an Input (Y / N) for safe execution.

## 🧠 Use Case
A common enterprise task where one user transitions and another must inherit exact permissions across multiple site collections.

## 🛠️ Prerequisites
- [PnP PowerShell Module](https://pnp.github.io/powershell/)
- SharePoint Online Admin/Owner access

📝 Notes
- Uses Connect-PnPOnline -UseWebLogin for compatibility.
- Role-based permissions and group memberships are preserved.
- Hidden and irrelevant system lists (like "Site Assets", etc.) are excluded.

## 📦 How to Run

```powershell
# Modify these values
$SourceUserEmail = "user1@abc.com"
$TargetUserEmail = "user2@abc.com"
$SiteCollections = @("https://abc.sharepoint.com/sites/test1", "https://abc.sharepoint.com/sites/test2")

# Then run the script
      
