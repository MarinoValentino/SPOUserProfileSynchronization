$TenantSite="https://<tenant>.sharepoint.com"
$JobUser="AzureTask@<tenant>.onmicrosoft.com" # Need SPO Administrator
$cred = Get-AutomationPSCredential -Name 'AzureTask@mvlab.onmicrosoft.com'
Connect-PnPOnline $TenantSite -Credentials $cred
Connect-AzureAD -Credential $cred
$users=Get-AzureADUser | ? {$_.ObjectType -eq 'User' -and $_.DirSyncEnabled}
Write-Output "Total Users to Check:" $users.Count
Foreach ($user in $users)
{
    Write "USERPRINCIPALNAME:"$user.UserPrincipalName
    Write "AAD Company:"$user.CompanyName
    $UserProfile=Get-PnPUserProfileProperty -Account $user.UserPrincipalName
    Write "SPO Company:"$UserProfile.UserProfileProperties.Company
    If ($user.CompanyName -eq $null)
    {
        If ($UserProfile.UserProfileProperties.Company)
        {
            Write-Warning "Remove SPO Company"
            Set-PnPUserProfileProperty -Account $user.UserPrincipalName -Property 'Company' -Value ""
        }
    }
    else
    {
        If ($user.CompanyName -ne $UserProfile.UserProfileProperties.Company)
        {
            Write-Warning "Update SPO Company"
            Set-PnPUserProfileProperty -Account $user.UserPrincipalName -Property 'Company' -Value $user.CompanyName
        }
    }
}
