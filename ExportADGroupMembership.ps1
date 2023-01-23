# Writes out Group Membership

#Add Active Directory Modules
Import-Module ActiveDirectory

Write-Host "Shows Group Membership"
$groupName = Read-Host -Prompt "Please enter the AD or Distribution Group"

try {$groupMembers = Get-ADGroupMember -Identity $groupName | Select name}
catch {Write-Host "Group not found" -ForegroundColor Red
    pause
    Exit}

Write-Host ' '
Write-Host ' '

Write-Host $groupName
Write-Host "----"
$groupMembers.Name

Write-Host ' '
Write-Host ' '
$exportCSV = Read-Host -Prompt "Do you want to export to CSV? (Yes/No)"

if($exportCSV -eq 'Yes'){
    $csvName = $groupName + "-Members.csv"
    try {Get-ADGroupMember -Identity $groupName | Select Name | Export-CSV $csvName -NoTypeInformation
        Write-Host "CSV successfully saved to" $csvName -ForegroundColor Green
        }
    catch {Write-Host "CSV failed to save" -ForegroundColor Red}
}

pause
Exit