$TenantSite="https://<TenantName>.sharepoint.com"
$cred = Get-AutomationPSCredential -Name '<CredentialName>' # Need SPO Admin
Connect-PnPOnline $TenantSite -Credentials $cred
Connect-AzureAD -Credential $cred
$users=Get-AzureADUser | ? {$_.ObjectType -eq 'User' -and $_.DirSyncEnabled}
$usercount = $users.Count
Write-Output "TOTAL USER TO CHECK:$usercount"
Foreach ($user in $users)
{
    $UserPrincipalName = $user.UserPrincipalName
    Write-Output "CHECK USERPRINCIPALNAME:$UserPrincipalName"
    $UserProfile=Get-PnPUserProfileProperty -Account $user.UserPrincipalName
    $AAD_Property = $user.CompanyName
    $SPO_Property = $UserProfile.UserProfileProperties.Company
    Write-Output "AAD_PROPERTY:$AAD_Property - SPO_PROPERTY Property:$SPO_Property"
    If ($user.CompanyName -eq $null)
    {
        If ($UserProfile.UserProfileProperties.Company)
        {
            Write-Warning "Update User: $UserPrincipalName, remove SPO Company"
            Set-PnPUserProfileProperty -Account $user.UserPrincipalName -Property 'Company' -Value ""
            Write-Output "Removed."
        }
    }
    else
    {
        If ($user.CompanyName -ne $UserProfile.UserProfileProperties.Company)
        {
            Write-Warning "Update User: $UserPrincipalName, SPO Property Company to: $AAD_Property"
            Set-PnPUserProfileProperty -Account $user.UserPrincipalName -Property 'Company' -Value $user.CompanyName
            Write-Output "Updated."
        }
    }
    Write "--------------------------------"
}
