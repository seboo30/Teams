Import-Module SkypeOnlineConnector
$sfboSession = New-CsOnlineSession -Credential $credential
Import-PSSession $sfboSession

$cred = Get-Credential
Import-Module MSOnline
Connect-MsolService -Credential $cred
$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $cred -Authentication Basic -AllowRedirection
$importresults = Import-PSSession $s

$import = Import-CSV "C:\Users\wise\OneDrive - Sebastian Wild\Desktop\RessourceAccounts.csv" -Delimiter ";"
$policyname = "Carrier"

foreach ($user in $import){

    $sip = "sip:" + $user.UserPrincipalName.ToString()

    Set-CsUser `
        -Identity $user.UserPrincipalName `
        -EnterpriseVoiceEnabled $true `
        -HostedVoiceMail $true `
        -OnPremLineURI $user.User_PhoneNumber
    
    Write-Host $user.UserPrincipalName "is Enterprise Voice enabled and the Phonenumber" $user.User_PhoneNumber "is configured"  -ForegroundColor Green

    Grant-CsOnlineVoiceRoutingPolicy `
        -Identity $sip `
        -PolicyName $policyname

    Write-Host $user.UserPrincipalName "has the Voiceroutingpolicy" $policyname "enabled"   -ForegroundColor Green    

    # Create Ressource Account

    New-CsOnlineApplicationInstance -UserPrincipalName $user.Ressource_UserPrincipalName -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName $user.Ressource_DisplayName
    Start-Sleep -s 20

    # Set Usage Location on Ressource Account

    Set-MsolUser -UserPrincipalName $user.Ressource_UserPrincipalName -UsageLocation AT
    Start-Sleep -s 20

    # Set License on Ressource Account

    Set-MsolUserLicense -UserPrincipalName $user.Ressource_UserPrincipalName  -AddLicenses "dynabcs:PHONESYSTEM_VIRTUALUSER"

    # Set Phone Number on Ressource Account

    Set-CsOnlineVoiceApplicationInstance -Identity $user.Ressource_UserPrincipalName -TelephoneNumber $user.Ressource_PhoneNumber
    Start-Sleep -s 20

    # Get Call Queue Members from CSV Import

    $cqmembers = get-msoluser -UserPrincipalName $user.Member | Select -Expand ObjectId

    # Create Call Queue / add Members
    
    New-CsCallQueue -Name $user.CallQueue_Name -Users $cqmembers
    
    # Get the relevant ID`s

    $applicationInstanceId = (Get-CsOnlineUser $user.Ressource_UserPrincipalName)[-1].ObjectId
    $callQueueId = (Get-CsCallQueue -NameFilter $user.CallQueue_Name).Identity

    # Assign Ressource Account to Call Queue
    New-CsOnlineApplicationInstanceAssociation -Identities @($applicationInstanceId) -ConfigurationId $callQueueId -ConfigurationType CallQueue
}

