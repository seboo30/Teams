Import-Module SkypeOnlineConnector
$sfboSession = New-CsOnlineSession -Credential $credential
Import-PSSession $sfboSession

$users = Import-Csv "C:\Users\wise\OneDrive - Sebastian Wild\Desktop\rooms.csv"
$number = "+43555221577"
$policyname = "Carrier"

foreach ($user in $users){

    $personalnumber = "tel:" + $number.ToString() + $user.DW.toString()
    $sip = "sip:" + $user.UserPrincipalName.ToString()

    Set-CsUser `
        -Identity $user.UserPrincipalName `
        -EnterpriseVoiceEnabled $true `
        -HostedVoiceMail $true `
        -OnPremLineURI $personalnumber
    
    Write-Host $user.UserPrincipalName "is Enterprise Voice enabled and the Phonenumber" $personalnumber "is configured"  -ForegroundColor Green

    Grant-CsOnlineVoiceRoutingPolicy `
        -Identity $sip `
        -PolicyName $policyname

    Write-Host $user.UserPrincipalName "has the Voiceroutingpolicy" $policyname "enabled"   -ForegroundColor Green    

}