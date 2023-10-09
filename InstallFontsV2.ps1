# Install fonts from a remote share using elevated permissions.
# Script can be run locally or deployed via GPO or SCCM.
# Fonts will be available in C:\Windows\Fonts after reboot.
# Brandon Todd - lotusvictim@gmail.com

# Define the remote share path where fonts exist.
$remoteSharePath = "\\path\to\your\fonts"

# Get a list of font files in the remote share
$fontFiles = Get-ChildItem -Path $remoteSharePath -Filter "*.ttf" -File

# Loop through each font file and install it using this thing
foreach ($fontFile in $fontFiles) {
    $fontFileName = $fontFile.Name
    $fontFilePath = Join-Path -Path $remoteSharePath -ChildPath $fontFileName
    
    # Install the font using Add-FontResource cmdlet
    Add-FontResource -LiteralPath $fontFilePath
    
    # Register the font with Windows
    $fontRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $fontRegistryKey = [System.IO.Path]::GetFileNameWithoutExtension($fontFileName)
    $fontRegistryValue = $fontFileName
    
    Set-ItemProperty -Path $fontRegistryPath -Name $fontRegistryKey -Value $fontRegistryValue -Force
}

# Refresh the font cache
Write-Host "Refreshing font cache..."
$fontCachePath = Join-Path -Path $env:SystemRoot -ChildPath "System32\FNTCACHE.DAT"
Remove-Item -Path $fontCachePath -Force

# Log the installation
Write-Host "Fonts installed successfully from $remoteSharePath"
