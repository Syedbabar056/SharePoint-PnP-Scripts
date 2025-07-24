$SourceSiteURL = "https://abc.sharepoint.com/sites/test1"
$DestinationSiteURL = "https://abc.sharepoint.com/sites/test2"
$PageName =  "DemoTestPage.aspx"
 
#Connect to Source Site
Connect-PnPOnline -Url $SourceSiteURL -UseWebLogin
 
#Export the Source page
$TempFile = [System.IO.Path]::GetTempFileName()
Export-PnPPage -Force -Identity $PageName -Out $TempFile
 
#Import the page to the destination site
Connect-PnPOnline -Url $DestinationSiteURL -UseWebLogin
Invoke-PnPSiteTemplate -Path $TempFile
