# Uninstall multiple versions of BlueBeam
# Additional versions can be added to the array, following the same format.
# Be sure to Set-ExecutionPolicy and ensure script is running with elevated permissions.
# Brandon Todd - lotusvictim@gmail.com

# Terminate the "BBPrint.exe" process
Stop-Process -Name "BBPrint" -Force

# Define various environment variables - Taken from original batch script.
$INSTALLDIR = "${env:ProgramFiles}\Bluebeam Software\Bluebeam Revu"
$ADMINPATH = "Pushbutton PDF\PbMngr5.exe"
$VUADMINPATH = "Bluebeam Vu Admin.exe"

$WCV = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield"
$WCV64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\InstallShield"
$WCVF = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders"
$WGF = "${env:WINDIR}\Installer"
$ISII = "${env:ProgramFiles}\InstallShield Installation Information"
$ISII64 = "${env:ProgramFiles(x86)}\InstallShield Installation Information"

$UNINSTALLKEY = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"

# Define a function to uninstall a specific version
function Uninstall-BluebeamVersion {
    param (
        [string]$GUID
    )

    if (Test-Path "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\$GUID") {
        Write-Host "Uninstalling Bluebeam version with GUID: $GUID"
        Start-Process "msiexec.exe" -ArgumentList "/x $GUID /qn" -Wait # QN Switch for silent uninstall.
    } else {
        Write-Host "Bluebeam version with GUID $GUID is not installed."
    }
}

# List of Bluebeam versions to uninstall based on GUID
$VersionsToUninstall = @(
    "{66294273-86AD-4C47-91D5-9E7CC3C868B9}",
    "{72C7C3DC-A002-40D3-BBD9-2876F358CBE2}",
    "{5DBD4D93-F6C5-491A-A5B3-E88DA96568CB}"
    # Add more versions here as needed
)

# Loop through the versions and uninstall them
foreach ($GUID in $VersionsToUninstall) {
    Uninstall-BluebeamVersion -GUID $GUID
}

