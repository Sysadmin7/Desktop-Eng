<#
    .SYNOPSIS
        Allows an administrator to deploy a program on a users profile.
    .Description
        Administrators will have access to remotely deploy a piece of software on a computer using scheduled tasks. 
        This must be ran as an administrator otherwise it will not work.
    .PARAMETER Computer
        Input for the computer name to deploy to.
    .PARAMETER Program
        Insert the name of the program, and any parameters for that program in quotes.
    .PARAMETER User
        Allows for the user to be installed on to be put in. Assumes the current domain.
    .EXAMPLE
        PS> .\DeploySoftware.ps1 -Computer PC1-Loc1
    .EXAMPLE
        PS> .\DeploySoftware.ps1 -Program calc
    .EXAMPLE
        PS> .\DeploySoftware.ps1 -User myUsername
    .EXAMPLE
        PS> .\DeploySoftware.ps1 -Computer PC1-Loc1 -Program "notepad.exe test.txt" -User myUsername
#>
param (
    [Parameter()] 
    [string[]]$Computer,
    [string[]]$Program,
    [string[]]$User,
    [string[]]$url
)

$wordPath = "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
$excelPath = "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
$outlookPath = "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
$websitePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# Checks for the PC, User, and Program
if($null -eq $Computer){
    $computer_to_connect = Read-Host -Prompt "Enter Computer To Run Software"
} else {
    $computer_to_connect = $Computer
}
if($null -eq $Program){
   # $program_location = Read-Host -Prompt "Enter the Location of the program (including exe or bat)"
    if($null -eq $url){
        $program_location = Read-Host -Prompt "Enter the Location of the program (including exe or bat)"
    } else {
        $program_location = "$websitePath $url"
    }
} else {
    $program_location = $Program
}
if($null -eq $User){
    $user_to_run_on = Read-Host -Prompt "User to run this on"
} else {
    $user_to_run_on = $User
}

# Launches for Office Products 2021
if($program_location -eq "Word" -or $program_location -eq "word") {
        $program_location = $wordPath
}
if($program_location -eq "Excel" -or $program_location -eq "excel") {
        $program_location = $excelPath
}
if($program_location -eq "Outlook" -or $program_location -eq "outlook") {
        $program_location = $outlookPath
}


$currentDomain = Get-ADDomain | Select-Object -Property Name
$currentDomain = $currentDomain.Name
$task_title = "temp_task"


schtasks /create /s $computer_to_connect /tn "$task_title" /tr "$program_location" /sc once /st 00:00 /ru "$currentDomain\$user_to_run_on" /rl highest

schtasks /run /s $computer_to_connect /tn $task_title

timeout 02 > Null

schtasks /delete /s $computer_to_connect /tn $task_title /f