$TenantName='<Tenant>'
$JobUser='AzureTask@<Tenant>.onmicrosoft.com' # Need SPO Admin
$cred = Get-Credential -Message $TenantName -UserName $JobUser # Use Get-AutomationPSCredential for Azure Runbook
Connect-AzureAD -Credential $cred
$TenantAdminSite="https://$TenantName-admin.sharepoint.com"
Connect-PnPOnline $TenantAdminSite -Credentials $cred
Connect-SPOService -Url $TenantAdminSite -Credential $cred
$Members = Get-SPOUser -Site "https://$TenantName.sharepoint.com" | Where-Object {$_.UserType -eq 'Member'} | select -Property LoginName
Write-Host "Total SPO Members:"$Members.Count -ForegroundColor Yellow
foreach($Member in $Members)
{
  Write-Host "User SPO Check:"$Member.LoginName -ForegroundColor Yellow
  Try
  {
    $User=Get-SPOUser -LoginName $Member.LoginName -Site "https://$TenantName.sharepoint.com"
    $UserProfile=Get-PnPUserProfileProperty -Account $Member.LoginName
    $SPOProperty=$UserProfile.UserProfileProperties.Company
  }
  Catch
  {
    # Write-Host "Error on SPO user :"$Member.LoginName -ForegroundColor Red
  }
  Write "SPO Company:$SPOProperty"

  # Write-Host "User AAD Check:"$Member.LoginName -ForegroundColor Yellow
  Try
  {
    $ADUser=Get-AzureADUser -ObjectId $Member.LoginName
    $ADProperty=$ADUser.CompanyName
  }
  Catch
  {
    # Write-Host "Error on AAD user :"$Member.LoginName -ForegroundColor Red
  }
  Write "AAD Company:$ADProperty"

  If ($ADProperty -eq $null)
  {
    if($SPOProperty)
    {
        Write-Host "Delete SPO Company" -ForegroundColor Green
        Set-PnPUserProfileProperty -Account $Member.LoginName -Property 'Company' -Value ""
    }
    else
    {
        Write-Host "No AD Company" -ForegroundColor Green
    }
  }
  else
  {
    if($ADProperty -eq $SPOProperty)
    {
        Write-Host "Update not needed" -ForegroundColor Green
    }
    else
    {
        Write-Host "Update SPO Company to:$ADProperty" -ForegroundColor Green
        Set-PnPUserProfileProperty -Account $Member.LoginName -Property 'Company' -Value $ADProperty
    }
  }
} 
