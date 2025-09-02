# Clone SharePoint User Permissions (V2)

🔹 **What’s new in Version2?**
- Script handles inactive/deleted users (`Get-PnPUser` returns null).  
- Skips gracefully instead of failing.  
- Clear warnings shown in console.  

🔹 **Use case**  
Copy permissions of one user to another across multiple site collections with a single script. Helpful when onboarding new users or replacing someone who left the organization.  

🔹 **How to run**  
1. Update `$SiteCollections` with your site collection URLs.  
2. Update `$SourceUserEmail` and `$TargetUserEmail`.  
3. Run in PowerShell with PnP.PowerShell module installed.  

