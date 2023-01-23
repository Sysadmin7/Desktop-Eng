#requires -version 2
<#
.SYNOPSIS
	Downloads and installs SQL Server Management Studio from Microsofts site
  
.DESCRIPTION
    This script is made to provide a simple way to download and install SQL Server
    Management Studio.

.PARAMETER <Parameter_Name>
    None

.INPUTS
  None

.OUTPUTS
  Screen progress notifications

  
.EXAMPLE
  .\install-ssms.ps1
#>

Write-Host "Creating Destination Directory Structure C:\Apps\SQL" -Foreground yellow
New-Item -ItemType Directory -Path "C:\Apps" -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType Directory -Path "C:\Apps\SQL" -ErrorAction SilentlyContinue | Out-Null
Write-Host "Destination Directory Structure C:\Apps\SQL Created" -Foreground green

$uri = "https://aka.ms/ssmsfullsetup"
$destination = "C:\apps\SQL\SSMS-Setup-ENU.exe"
$file = '.\SSMS-Setup-ENU.exe'

    if (test-path $destination) 
        {
        # cleanup before download
        write-host "Deleting pre-exsisting SQL Server Management Studio Package from C:\Apps\SQL" -ForegroundColor yellow
        Remove-Item $destination
        Write-Host "Previous SQL Server Management Studio Package deleted from C:\Apps\SQL" -ForegroundColor Green
        
        write-Host "Parsing $uri for SQL Server Management Studio" -Foreground yellow
        Invoke-WebRequest -UseBasicParsing -Uri $Uri
        write-Host "$uri for SQL Server Management Studio parsed" -Foreground Green

        write-Host "Downloading SQL Server Management Studio" -Foreground yellow
        Start-BitsTransfer -Description "Downloading SQL Server Management Studio from Microsoft" -Destination $destination -Source $URI
        write-Host "SQL Server Management Studio Downloaded to C:\Apps\SQL" -Foreground Green

        cd C:\apps\SQL
        
        Write-Host "Launching SQL Server Management Studio Install, may take a minute to come up.  Please be patient." -ForegroundColor Yellow
        & $file
        Start-Sleep 15
        Write-Host "Have a nice day." -ForegroundColor Green
        }
    else {
        write-Host "Parsing $uri for SQL Server Management Studio" -Foreground yellow
        Invoke-WebRequest -UseBasicParsing -Uri $Uri
        write-Host "$uri for SQL Server Management Studio parsed" -Foreground Green

        write-Host "Downloading SQL Server Management Studio" -Foreground yellow
        Start-BitsTransfer -Description "Downloading SQL Server Management Studio from Microsoft" -Destination $destination -Source $URI
        write-Host "SQL Server Management Studio Downloaded to C:\Apps\SQL" -Foreground Green

        cd C:\apps\SQL

        Write-Host "Launching SQL Server Management Studio Install, may take a minute to come up.  Please be patient." -ForegroundColor Yellow
        
        & $file
        
        Start-Sleep 15
        Write-Host "Have a nice day." -ForegroundColor Green
        }