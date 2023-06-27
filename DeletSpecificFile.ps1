# PS Script for removing specific files from machines.
# Script path and filename can be changed to reflect your environment.
# Brandon Todd - btoddr22@outlook.com 

# Define the file path to delete
$filePath = "<C:\Windows\System32\MpSigStub.exe>"

# Check if the file exists
if (Test-Path $filePath) {
    # Delete the file
    Remove-Item -Path $filePath -Force
}