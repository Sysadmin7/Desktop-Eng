#This powershell script will check the uptime details from a list of machine names that are contained wwithin the "computers.txt" file.
#Originally written to help enforce reboot of machines after the deadline has been exceeded..
#The Computers.txt file should exist either locally when execured, or on a share with proper permissions for read access.
#For questions email Brandon at btoddr22@outlook.com

function get-uptime { 
    param( 
    $computername =$env:computername 
    ) 
    $osname = Get-WmiObject win32_operatingsystem -ComputerName $computername -ea silentlycontinue 
    if($osname)
    { 
    $lastbootuptime =$osname.ConvertTodateTime($osname.LastBootUpTime) 
    $LocalDateTime =$osname.ConvertTodateTime($osname.LocalDateTime) 
    $up =$LocalDateTime - $lastbootuptime 
    $uptime ="$($up.Days) days, $($up.Hours)h, $($up.Minutes)mins" 
    $output =new-object psobject 
    $output |Add-Member noteproperty LastBootUptime $LastBootuptime 
    $output |Add-Member noteproperty ComputerName $computername 
    $output |Add-Member noteproperty uptime $uptime 
    $output | Select-Object computername,LastBootuptime,Uptime 
    } 
    else  
    { 
    $output =New-Object psobject 
    $output =new-object psobject 
    $output |Add-Member noteproperty LastBootUptime "Not Available" 
    $output |Add-Member noteproperty ComputerName $computername 
    $output |Add-Member noteproperty uptime "Not Available"  
    $output | Select-Object computername,LastBootUptime,Uptime 
    } 
    } 
    get-uptime
   $multiplemachines =@()  
   $allserver =Get-Content -Path "\\yourdomain\PCScripts\computers.txt" #Retrieve machine names to check uptime from this list.
   foreach($oneserver in $allserver)
   { 
   $multiplemachines += get-uptime $oneserver 
   } 
   $multiplemachines |ft -AutoSize
