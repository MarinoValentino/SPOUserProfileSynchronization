# SPO User Profile Synchronization with an Azure Automation Account
Since SPO AD-Import is limited to a defined set of properties, this sample use an Azure Automation Runbook to Import a desired additional Property (i.e. CompanyName from AzureAD). See also [Information about user profile synchronization in SharePoint Online](https://support.office.com/en-ie/article/information-about-user-profile-synchronization-in-sharepoint-online-177eb196-5887-43c9-84c3-b98a43d35129)

### Prerequisites
The Script need to run as SPO Admin user.

### Installing

#### Create an Azure Automation Account
![Image1](images/p1.png)

#### Create a Schedule
![Image2](images/p2.png)

#### Import Modules
* AzureAD
* SharePointPnPPowerShellOnline
![Image3](images/p3.png)

#### Add credentials to use in script
![Image4](images/p4.png)

#### Create a Runbook of Type PowerShell and link it to the scheduler
![Image5](images/p5.png)

#### Edit, adjust and Publish the Runbook
Adjust <TenantName> and <CredentialName>
```
$TenantSite="https://<TenantName>.sharepoint.com"
$cred = Get-AutomationPSCredential -Name '<CredentialName>'
```
![Image6](images/p6.png)

#### Run the Runbook
For a better reading, Changes will be logged also as Warnings
