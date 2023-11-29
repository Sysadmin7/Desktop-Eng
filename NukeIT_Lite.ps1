# NukeIT_Lite v0.05 - Disk Space Cleanup with Improved Error Handling
# This script is designed for system maintenance and cleanup on Windows machines.
# It includes clearing the Configuration Manager cache, removing old user profiles, and running various cleanup operations to free up disk space.
# Please refer to the corresponding document detailing how the script works and definition of functions.
# Brandon Todd - lotusvictim@gmail.com

[CmdletBinding()]
param (
    [Alias("ComputerNames")]
    [Parameter(Mandatory=$false)]
    [string[]]$ComputerName,

    [Parameter(Mandatory=$false)]
    [switch]$CleanCCMCache = $true,

    [Parameter(Mandatory=$false)]
    [int]$ProfileAge = 150 # Define the number of days a profile has been inactive
)

$AppName = "NukeIT_Lite - v0.05"

# Detect Elevation:
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$userPrincipal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$isAdmin = $userPrincipal.IsInRole($adminRole)

if (-not $isAdmin) {
    throw "Script is not running elevated, which is required. Restart the script from an elevated prompt."
}

# Define the remote share path and log file name
$RemoteLogPath = "\\path\to\your\logs"
$LogName = "$($env:COMPUTERNAME).log"
$Log = Join-Path $RemoteLogPath $LogName

# Function to perform cleanup
function Clean-System {
    param (
        [int]$ProfileAge,
        [switch]$CleanCCMCache
    )

    # Calculate disk space before cleanup
    $FreespaceBefore = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty FreeSpace)
    $FreespaceBeforeGB = [math]::Round($FreespaceBefore / 1GB, 2)

    Write-Output "Disk C:\ has $FreespaceBeforeGB GB available before cleanup."

    # Clean CCM Cache.
    if ($CleanCCMCache) {
        if (Get-WmiObject -Namespace "root\ccm" -Class "SMS_Client" -ErrorAction SilentlyContinue) {
            Write-Output "Starting CCM cache Cleanup..."
            $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
            $Cache = $UIResourceMgr.GetCacheInfo()
            $CacheElements = $Cache.GetCacheElements()

            foreach ($Element in $CacheElements) {
                try {
                    Write-Output "Deleting PackageID $($Element.ContentID) in folder $($Element.Location)"
                    $Cache.DeleteCacheElement($Element.CacheElementID)
                } catch {
                    Write-Error ("Failed to delete package ${Element.ContentID} in folder ${Element.Location}. Error: $($_.Exception.Message)")
                }
            }
        } else {
            if (Test-Path "\\$ComputerName\C$\Windows\ccmcache") {
                Write-Output "No CM agent found in WMI, but a cache folder is present. Cache will NOT be cleared!"
            } else {
                Write-Output "No CM agent found in WMI, and no cache folder detected. Moving along..."
            }
        }
    }

    Write-Output "Starting User Profile Cleanup..."
    Write-Output "Checking for user profiles that are older than $ProfileAge days..."
    Get-WmiObject -Class Win32_UserProfile | Where-Object { -not $_.Special } | ForEach-Object {
        $Profile = $_
        try {
            if ($Profile.LastUseTime -ne $null) {
                $LastUsed = $Profile.ConvertToDateTime($Profile.LastUseTime)
                if ($LastUsed -lt (Get-Date).AddDays(-$ProfileAge)) {
                    Write-Output "Deleting: $($Profile.LocalPath) - Last used on $LastUsed"
                    $Profile.Delete()
                } else {
                    Write-Output "Skipping: $($Profile.LocalPath) - Last used on $LastUsed"
                }
            } else {
                Write-Output "LastUseTime is not available for $($Profile.LocalPath). Skipping..."
            }
        } catch {
            Write-Error ("Failed to process profile ${Profile.LocalPath} - Error: $($_.Exception.Message)")
        }
    }

    # Clean Windows Update
    Write-Output "Starting Windows Update Cleanup..."
    $wuaService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    if ($wuaService.Status -ne "Stopped") {
        $wuaService | Stop-Service -Force
        Write-Output "Waiting for 'Windows Update' service to stop..."
        while ($wuaService.Status -ne "Stopped") {
            Start-Sleep -Seconds 5
            $wuaService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        }
    }

    try {
        Remove-Item -Path "$env:SystemRoot\SoftwareDistribution" -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Error ("Error while cleaning Windows Update: $($_.Exception.Message)")
    }

    if ($wuaService.Status -ne "Running") {
        Write-Output "Starting 'Windows Update' service..."
        $wuaService | Start-Service
    }

    # Clean Windows Temp folder
    Write-Output "Starting Windows Temp folder Cleanup..."
    try {
        Remove-Item -Path "$env:SystemRoot\TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Error ("Error while cleaning Windows Temp folder: $($_.Exception.Message)")
    }

    # Clean Additional Directories
    $AdditionalCleanupDirectories = @(
        'C:\Windows\CCM\Logs',
        'C:\Windows\CCMCache',
        'C:\Windows\Temp',
        'C:\ProgramData\testfolder',
        'C:\Windows\SoftwareDistribution\Download',
        'C:\Windows\SoftwareDistribution\ScanFile',
        'C:\ProgramData\Microsoft\Windows Defender',
        'C:\ProgramData\SSOProvider\Logs',
        'C:\Users\autoimprivata\AppData\Local\CrashDumps',
        'C:\Users\autoimprivata\AppData\Local\Temp',
        'C:\Users\AutoHealthCastVDI',
        'C:\Windows\System32\LogFiles',
        'C:\Windows\Installer\$PatchCache$',
        'C:\$Recycle.Bin'
    )

    $AdditionalCleanupDirectories | ForEach-Object {
        $directory = $_
        Write-Output "Cleaning directory: $directory"
        try {
            Get-ChildItem -ErrorAction Stop -Path $directory -Include * | Remove-Item -Recurse -ErrorAction Stop
        } catch {
            if ($_.Exception -match "Access is denied") {
                Write-Error "Access denied while cleaning $directory. Skipping..."
            } else {
                Write-Error ("Error while cleaning ${directory}: $($_.Exception.Message)")
            }
        }
    }

    # Clean .dmp files within user profiles
    Write-Output "Cleaning DMP and TMP Files..."
    try {
        $process = Start-Process -FilePath "$env:systemroot\system32\cmd.exe" -ArgumentList "/c DEL /S /Q C:\Users\*.dmp" -Wait -PassThru
        $process = Start-Process -FilePath "$env:systemroot\system32\cmd.exe" -ArgumentList "/c DEL /S /Q C:\Users\*.tmp" -Wait -PassThru
        $process = Start-Process -FilePath "$env:systemroot\system32\cmd.exe" -ArgumentList "/c DEL /S /Q C:\ProgramData\*.dmp" -Wait -PassThru
    } catch {
        Write-Error ("Error while cleaning DMP and TMP files: $($_.Exception.Message)")
    }

    # Turn off hibernation to eliminate hiberfil.sys
    try {
        powercfg -h off
        Write-Host "Hibernation Disabled"
    } catch {
        Write-Error ("Error while disabling hibernation: $($_.Exception.Message)")
    }

    # Calculate disk space after cleanup
    $FreespaceAfter = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty FreeSpace)
    $FreespaceAfterGB = [math]::Round($FreespaceAfter / 1GB, 2)

    # Calculate the space cleaned up
    $SpaceCleanedUpGB = $FreespaceBeforeGB - $FreespaceAfterGB

    # Ensure that the space cleaned up is a positive value
    $SpaceCleanedUpGB = [math]::Abs($SpaceCleanedUpGB)

    Write-Output "Space cleaned up: $SpaceCleanedUpGB GB"
    Write-Output "Disk C:\ has $FreeSpaceAfterGB GB Free"
}

# Start transcript logging to the remote share
Start-Transcript -Path $Log

if (-not $ComputerName) {
    Write-Host "No target(s) specified, defaulting to the local machine."
    $ComputerName = $env:ComputerName
}

# Iterate through Computer Names
foreach ($Computer in $ComputerName) {
    try {
        # Measure running time (This needs improvement and optimization)
        $Start = Get-Date
        Write-Output "---- $(Get-Date) - Starting cleanup on $Computer..."
        Clean-System -ProfileAge $ProfileAge -CleanCCMCache:$CleanCCMCache
    } catch {
        Write-Error "Unable to clean $Computer because $($_.Exception.Message)"
    } Finally {
        $End = Get-Date
        $TimeSpan = New-TimeSpan -Start $Start -End $End
        "---- $(Get-Date) - $Computer cleaned in: $($TimeSpan.Hours) hours $($TimeSpan.Minutes) minutes and $($TimeSpan.Seconds) seconds."
    }
}

# Stop the transcript logging
Stop-Transcript
