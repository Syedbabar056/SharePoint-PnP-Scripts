# Function to copy user permissions with detailed terminal output
Function Copy-PnPUserPermission {
    Param (
        [Parameter(Mandatory)] $SourceUser,
        [Parameter(Mandatory)] $TargetUser,
        [Parameter(Mandatory)] [Microsoft.SharePoint.Client.SecurableObject] $Object
    )

    $ObjectType = $Object.TypedObject.ToString()
    Switch ($ObjectType) {
        "Microsoft.SharePoint.Client.Web" {
            $ObjectType = "Site"
            $ObjectURL = $Object.URL
            $ObjectTitle = $Object.Title
        }
        "Microsoft.SharePoint.Client.ListItem" {
            if ($Object.FileSystemObjectType -eq "Folder") {
                $ObjectType = "Folder"
                $ObjectURL = $Object.FieldValues.FileRef
                $ObjectTitle = $Object.FieldValues.FileLeafRef
            } elseif ($Object.FileSystemObjectType -eq "File") {
                $ObjectType = "File"
                $ObjectURL = $Object.FieldValues.FileRef
                $ObjectTitle = $Object.FieldValues.FileLeafRef
            } else {
                $ObjectType = "List Item"
                $ObjectURL = $Object.FieldValues.FileRef
                $ObjectTitle = $Object.FieldValues.Title
            }
        }
        Default {
            $ObjectType = $Object.BaseType #List, DocumentLibrary, etc
            $ObjectTitle = $Object.Title
            #Get the URL of the List or Library
            $RootFolder = Get-PnPProperty -ClientObject $Object -Property RootFolder
            $ObjectURL = $Object.RootFolder.ServerRelativeUrl
        }
    }

    Write-Host "🔍 Processing $ObjectType ":" '${ObjectTitle}' at '${ObjectURL}'" -ForegroundColor Magenta


    $RoleAssignments = Get-PnPProperty -ClientObject $Object -Property RoleAssignments
    $TargetUserPermissions = @()

    foreach ($RoleAssignment in $RoleAssignments) {
        Get-PnPProperty -ClientObject $RoleAssignment -Property RoleDefinitionBindings, Member
        if ($RoleAssignment.Member.PrincipalType -eq "User" -and $RoleAssignment.Member.LoginName -eq $TargetUser.LoginName) {
            $TargetUserPermissions = $RoleAssignment.RoleDefinitionBindings | Select-Object -ExpandProperty Name
        }
    }

    foreach ($SourceRoleAssignment in $RoleAssignments) {
        Get-PnPProperty -ClientObject $SourceRoleAssignment -Property RoleDefinitionBindings, Member
        if (-not $SourceRoleAssignment.Member.IsHiddenInUI) {
            $SourceUserPermissions = $SourceRoleAssignment.RoleDefinitionBindings | Select-Object -ExpandProperty Name
            if ($SourceUserPermissions.Count -eq 0) { continue }

            if ($SourceRoleAssignment.Member.PrincipalType -eq "SharePointGroup") {
                $GroupName = $SourceRoleAssignment.Member.LoginName
                if ($GroupName -notmatch "limited access|SharingLinks|tenant") {
                    $SourceUserIsGroupMember = Get-PnPGroupMember -Identity $GroupName | Where-Object { $_.LoginName -eq $SourceUser.LoginName }
                    if ($SourceUserIsGroupMember) {
                        $TargetUserIsGroupMember = Get-PnPGroupMember -Identity $GroupName | Where-Object { $_.LoginName -eq $TargetUser.LoginName }
                        if (-not $TargetUserIsGroupMember) {
                            Add-PnPGroupMember -LoginName $TargetUser.LoginName -Identity $GroupName
                            Write-Host "✅ Added user to Group '$GroupName'" -ForegroundColor Green
                        } else {
                            Write-Host "ℹ️ User already in Group '$GroupName'" -ForegroundColor Yellow
                        }
                    }
                }
            } elseif ($SourceRoleAssignment.Member.PrincipalType -eq "User" -and $SourceRoleAssignment.Member.LoginName -eq $SourceUser.LoginName) {
                foreach ($Permission in $SourceUserPermissions) {
                    $RoleDefinition = Get-PnPRoleDefinition -Identity $Permission
                    if ($RoleDefinition.Hidden -eq $false -and $TargetUserPermissions -notcontains $RoleDefinition.Name) {
                        $RoleDefBinding = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Object.Context)
                        $RoleDefBinding.Add($RoleDefinition)
                        $Object.RoleAssignments.Add($TargetUser, $RoleDefBinding)
                        $Object.Update()
                        Invoke-PnPQuery
                        Write-Host "🔓 Granted '$($RoleDefinition.Name)' on $ObjectType '$ObjectTitle'" -ForegroundColor Green
                    } else {
                        Write-Host "✔️ Already has '$($RoleDefinition.Name)' on $ObjectType '$ObjectTitle'" -ForegroundColor Yellow
                    }
                }
            }
        }
    }
}

# Function to clone permissions at site/list/folder level with progress output
Function Clone-PnPPermission {
    Param (
        [Parameter(Mandatory)] $Web,
        [Parameter(Mandatory)] $SourceUser,
        [Parameter(Mandatory)] $TargetUser,
        [Parameter()] [bool] $ScanFolders = $false
    )

    Write-Host "🌐 Scanning Site: $($Web.Url)" -ForegroundColor Cyan
    Copy-PnPUserPermission -SourceUser $SourceUser -TargetUser $TargetUser -Object $Web

    $ExcludedLists = @("Site Assets","Preservation Hold Library","Style Library","Site Pages","Form Templates","MicroFeed","Shared Documents","Documents") #lists or libraries to be excluded goes here 
    $Lists = Get-PnPProperty -ClientObject $Web -Property Lists | Where-Object { !$_.Hidden -and $ExcludedLists -notcontains $_.Title }

    foreach ($List in $Lists) {
        if ($List.HasUniqueRoleAssignments) {
            Write-Host "`n📋 Scanning List: $($List.Title)" -ForegroundColor Cyan
            Copy-PnPUserPermission -SourceUser $SourceUser -TargetUser $TargetUser -Object $List
        }

        if ($ScanFolders -and $List.BaseTemplate -eq 101) {
            $Folders = Get-PnPListItem -List $List -PageSize 1000 | Where-Object { $_.FileSystemObjectType -eq "Folder" -and $_.HasUniqueRoleAssignments }
            foreach ($Folder in $Folders) {
                Write-Host "📂 Scanning Folder: $($Folder.FieldValues.FileLeafRef)" -ForegroundColor DarkCyan
                Copy-PnPUserPermission -SourceUser $SourceUser -TargetUser $TargetUser -Object $Folder
            }
        }
    }
}

# Function to clone user permissions for one site
Function Clone-PnPUser {
    Param (
        [Parameter(Mandatory)] [string] $SiteURL,
        [Parameter(Mandatory)] [string] $SourceUserEmail,
        [Parameter(Mandatory)] [string] $TargetUserEmail
    )

    Write-Host "`n🔗 Connecting to: $SiteURL" -ForegroundColor Yellow
    Connect-PnPOnline -Url $SiteURL -UseWebLogin #for compatibility issues using Useweblogin, also you can use -Interactive
    $Web = Get-PnPWeb
    $SourceUser = Get-PnPUser | Where-Object Email -eq $SourceUserEmail
    $TargetUser = Get-PnPUser | Where-Object Email -eq $TargetUserEmail

    if (-not $SourceUser) { $SourceUser = New-PnPUser -LoginName $SourceUserEmail }
    if (-not $TargetUser) { $TargetUser = New-PnPUser -LoginName $TargetUserEmail }

    $AdminCheck = Get-PnPSiteCollectionAdmin | Where-Object { $_.LoginName -eq $SourceUser.LoginName }
    if ($AdminCheck) {
        $TargetAdminCheck = Get-PnPSiteCollectionAdmin | Where-Object { $_.LoginName -eq $TargetUser.LoginName }
        if (-not $TargetAdminCheck) {
            Add-PnPSiteCollectionAdmin -Owners $TargetUser
            Write-Host "🛡️ Added '$TargetUserEmail' as Site Collection Admin" -ForegroundColor Green
        }
    }

    Clone-PnPPermission -Web $Web -SourceUser $SourceUser -TargetUser $TargetUser -ScanFolders $true
}

# =================== MAIN SCRIPT ===================
# Define multiple site collections
$SiteCollections = @(
    "https://tenantname.sharepoint.com/sites/sitecollection", #replace with your actual site collection url
    "https://tenantname.sharepoint.com/sites/sitecollection1" 
)

# Source and target user emails - Replace with your actual user email accounts
$SourceUserEmail = "user1@tenant.com"
$TargetUserEmail = "user2@tenant.com"

# Loop through each site collection with user confirmation
foreach ($SiteURL in $SiteCollections) {
    Write-Host "`n🚩 Ready to clone permissions on: $SiteURL" -ForegroundColor Yellow
    $confirmation = Read-Host "Do you want to continue? (Y/N)"
    if ($confirmation -eq "Y") {
        Clone-PnPUser -SiteURL $SiteURL -SourceUserEmail $SourceUserEmail -TargetUserEmail $TargetUserEmail
    } else {
        Write-Host "⏭️ Skipped: $SiteURL" -ForegroundColor DarkYellow
    }
}

Write-Host "`n🎯 Script execution completed." -ForegroundColor Green

