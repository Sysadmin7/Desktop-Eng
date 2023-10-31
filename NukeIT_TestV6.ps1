# NukeIT v0.06 - Disk Space Cleanup
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
    [int]$ProfileAge = 150, # Define the number of days a profile has been inactive

    [Parameter(Mandatory=$false)]
    [int]$DiskSpaceThresholdGB = 3 # Define the disk space threshold in GB
)

$AppName = "NukeIT - v0.06"

# Define the remote share path and log file name
$RemoteLogPath = "\\path\to\your\folder"
$LogName = "$($env:COMPUTERNAME).log"
$Log = Join-Path $RemoteLogPath $LogName

# Function to perform a longer more thorough disk clean
function Clean-System-Full {
    # Configure Disk Cleanup (Set Reg flags for removal of corresponding directories. This is a more streamlined method.)
    $CleanMgrKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    $cleanupItems = @(
        'Active Setup Temp Folders',
        'BranchCache',
        'Content Indexer Cleaner',
        'Device Driver Packages',
        'Downloaded Program Files',
        'GameNewsFiles',
        'GameStatisticsFiles',
        'GameUpdateFiles',
        'Internet Cache Files',
        'Memory Dump Files',
        'Offline Pages Files',
        'Old ChkDsk Files',
        'Previous Installations',
        'Recycle Bin',
        'Service Pack Cleanup',
        'Setup Log Files',
        'System error memory dump files',
        'System error minidump files',
        'Temporary Files',
        'Temporary Setup Files',
        'Temporary Sync Files',
        'Thumbnail Cache',
        'Update Cleanup',
        'Upgrade Discarded Files',
        'User file versions',
        'Windows Defender',
        'Windows Error Reporting Archive Files',
        'Windows Error Reporting Queue Files',
        'Windows Error Reporting System Archive Files',
        'Windows Error Reporting System Queue Files',
        'Windows ESD installation files',
        'Windows Upgrade Log Files'
    )

    $cleanupItems | ForEach-Object {
        Set-ItemProperty -Path "$CleanMgrKey\$_" -Name StateFlags0001 -Type DWORD -Value 2 -ErrorAction SilentlyContinue
    }
    # Clean other items
    Write-Output "Starting DISM Cleanup (might take a while)..."
    if ([Environment]::OSVersion.Version -lt (New-Object 'Version' 6, 2)) {
        Invoke-Expression "Dism.exe /online /Cleanup-Image /SpSuperseded"
    } else {
        Invoke-Expression "Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase"
    }

    # Run Disk Cleanup
    Write-Output "Starting Cleanmgr with a full set of checkmarks (might take a while)..."
    $process = Start-Process -FilePath "$env:systemroot\system32\cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait -PassThru
    Write-Output "Process ended with exit code $($process.ExitCode)"
}

# Function to perform cleanup
function Clean-System {
    param (
        [int]$ProfileAge,
        [switch]$CleanCCMCache
    )

    # Calculate disk space before cleanup
    $FreespaceBefore = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty FreeSpace)

    Write-Output "Disk C:\ has $([math]::Round($FreespaceBefore / 1GB, 2)) GB available."

    # Clean CCM Cache
    if ($CleanCCMCache) {
        if (Get-WmiObject -Namespace "root\ccm" -Class "SMS_Client" -ErrorAction SilentlyContinue) {
            Write-Output "Starting CCM cache Cleanup..."
            $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
            $Cache = $UIResourceMgr.GetCacheInfo()
            $CacheElements = $Cache.GetCacheElements()

            foreach ($Element in $CacheElements) {
                Write-Output "Deleting PackageID $($Element.ContentID) in folder $($Element.Location)"
                $Cache.DeleteCacheElement($Element.CacheElementID)
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
            $LastUsed = $Profile.ConvertToDateTime($Profile.LastUseTime)
        }
        catch {
            Write-Output "Orphaned record found: $($Profile.Localpath) - $($Profile.SID)"
            $Profile.Delete()
        }
        finally {
            if ($LastUsed -lt (Get-Date).AddDays(-$ProfileAge)) {
                Write-Output "Deleting: $($Profile.LocalPath) - Last used on $LastUsed"
                $Profile.Delete()
            } else {
                Write-Output "Skipping: $($Profile.LocalPath) - Last used on $LastUsed"
            }
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

    Remove-Item -Path "$env:SystemRoot\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue

    if ($wuaService.Status -ne "Running") {
        Write-Output "Starting 'Windows Update' service..."
        $wuaService | Start-Service
    }

    # Clean Windows Temp folder
    Write-Output "Starting Windows Temp folder Cleanup..."
    Remove-Item -Path "$env:SystemRoot\TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

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
        Write-Output "Cleaning directory: $_"
        Get-ChildItem -ErrorAction SilentlyContinue -Path $_ -Include * | Remove-Item -Recurse -ErrorAction SilentlyContinue
    }

    # Clean .dmp files within user profiles
    Write-Output "Cleaning DMP and TMP Files..."
    $process = Start-Process -FilePath "$env:systemroot\system32\cmd.exe" -ArgumentList "/c DEL /S /Q C:\Users\*.dmp" -Wait -PassThru
    $process = Start-Process -FilePath "$env:systemroot\system32\cmd.exe" -ArgumentList "/c DEL /S /Q C:\Users\*.tmp" -Wait -PassThru
    $process = Start-Process -FilePath "$env:systemroot\system32\cmd.exe" -ArgumentList "/c DEL /S /Q C:\ProgramData\*.dmp" -Wait -PassThru

    # Turn off hibernation to eliminate hiberfil.sys
    powercfg -h off
    Write-Host "Hibernation Disabled"

    # Calculate disk space after cleanup (Messy method but works for now.)
    $FreespaceAfter = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty FreeSpace)

    Write-Output "Disk C:\ now has $([math]::Round($FreespaceAfter / 1GB, 2)) GB available."
    $freedSpace = [math]::Round(($FreespaceBefore - $FreespaceAfter) / 1GB, 2)
    Write-Output "$freedSpace GB has been Nuked on C:\."
}

# ----------------------------END OF CLEAN SYSTEM---------------------------- #

# Start transcript logging to the remote share
Start-Transcript -Path $Log

# Detect Elevation:
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$userPrincipal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$isAdmin = $userPrincipal.IsInRole($adminRole)

if ($isAdmin) {
    Write-Output "Script is running elevated."
} else {
    throw "Script is not running elevated, which is required. Restart the script from an elevated prompt."
}

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
        if ($Computer -eq $env:ComputerName) {
            # Check available disk space before running Clean-System-Full
            $FreespaceBefore = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty FreeSpace)
            if ($FreespaceBefore -lt ($DiskSpaceThresholdGB * 1GB)) {
                Write-Output "Disk space is below the threshold. Running full cleanup..."
                Clean-System-Full
            } else {
                Write-Output "Disk space is above the threshold. Skipping full cleanup."
                Clean-System -ProfileAge $ProfileAge -CleanCCMCache:$CleanCCMCache
            }
        } else {
            Invoke-Command -ComputerName $Computer -ScriptBlock {
                param($ProfileAge, $CleanCCMCache, $DiskSpaceThresholdGB)
                # Check available disk space before running Clean-System-Full
                $FreespaceBefore = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty FreeSpace)
                if ($FreespaceBefore -lt ($DiskSpaceThresholdGB * 1GB)) {
                    Write-Output "Disk space is below the threshold. Running full cleanup..."
                    Clean-System -ProfileAge $ProfileAge -CleanCCMCache:$CleanCCMCache
                } else {
                    Write-Output "Disk space is above the threshold. Skipping full cleanup."
                }
            } -ArgumentList $ProfileAge, $CleanCCMCache, $DiskSpaceThresholdGB
        }
    } catch {
        Write-Error "Unable to clean $Computer because $($_.Exception.Message)"
    } Finally {
        $End = Get-Date
        $TimeSpan = New-TimeSpan -Start $Start -End $End
        "---- $(Get-Date) - $Computer cleaned in: $($TimeSpan.Hours) hours $($TimeSpan.Minutes) minutes and $($TimeSpan.Seconds) seconds."
    }
}

Write-Output "Script completed successfully."

# Stop the transcript logging
Stop-Transcript
