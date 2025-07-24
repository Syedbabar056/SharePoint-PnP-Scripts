#copying modern page in SharePoint Online using Pnp Powershell script.

$SourceSiteURL = "https://abc.sharepoint.com/sites/test1" #Change abc to Tennat Name and Test1 to actual Site collection name
$DestinationSiteURL = "https://abc.sharepoint.com/sites/test2" #Change abc to Tennat Name and Test2 to actual Site collection name
$PageName = "TestPage.aspx"

Write-Host "Connecting to source site: $SourceSiteURL..." -ForegroundColor Cyan
Connect-PnPOnline -Url $SourceSiteURL -UseWebLogin

Write-Host "Exporting page '$PageName' from source site..." -ForegroundColor Yellow
$TempFile = [System.IO.Path]::GetTempFileName()
Export-PnPPage -Force -Identity $PageName -Out $TempFile
Write-Host "Page exported to temporary file: $TempFile" -ForegroundColor Green

Write-Host "Connecting to destination site: $DestinationSiteURL..." -ForegroundColor Cyan
Connect-PnPOnline -Url $DestinationSiteURL -UseWebLogin

Write-Host "Importing the page to destination site..." -ForegroundColor Yellow
Invoke-PnPSiteTemplate -Path $TempFile
Write-Host "Page import completed successfully." -ForegroundColor Green
