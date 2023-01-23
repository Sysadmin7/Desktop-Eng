<#
.Synopsis
   Automates the process of installing SonicWALL netextender client
.DESCRIPTION
   This script was designed to automate SSLVPN client installs. Can be used to install VPN client only or can be used to install VPN client w/ server and domain fields populated.
   Running script will install VPN client for all users. However, when you define the -SSLSERVER and -SSLDOMAIN parameters those only get set for the user that is running the script.
   If you only define one parameter the script will skip the profile creation. Both parameters must be set to create the VPN profile.
.EXAMPLE
   .\install-netextender
   This is the minimum required to run the script. The result of this command will be the installation of the netextender client
.EXAMPLE
   .\install-netextender -SSLSERVER 1.1.1.1:4433 -SSLDOMAIN LocalDomain
   Installs netextender for all users and creates a VPN profile for the user running script (must click the drop down arrow in VPN client to use profile)
.INPUTS
   -SSLSERVER
   Defines the hostname or public IP address to be used by VPN client. Make sure to include the : and the port number afterwards. Default value in the SonicWALL will be 4433

   -SSLDOMAIN
   Defines the Domain name to be used by the VPN client. This must match the configured domain for the SSLVPN. Default value in the SonicWALL will be LocalDomain

.OUTPUTS
   -SSLSERVER AND/OR -SSLDOMAIN NOT DEFINED SKIPPING PROFILE CREATION
   The above string gets outputted as a warning if -SSLSERVER and/or -SSLDOMAIN values are not defined.
.NOTES
   Would like to make the VPN profile installed for all users or a specfic user in the future. This way you could run the script silently w/o user interaction. Or bother user.
.COMPONENT
   ???
.ROLE
   ???
.FUNCTIONALITY
   Automates install of SonicWALL SSLVPN client.
#>

param(
    
    [string]$SSLSERVER,
    [string]$SSLDOMAIN
    
    )


#NOTES: out-null keeps powershell from running the next line of code until the previous line has finished all its work.
#VARIABLES
$ToolDownload = "https://software.sonicwall.com/NetExtender/NXSetupU-x64-10.2.324.exe"
$OutFile = "c:\netextender.exe"
$containsTest = 'netextender.exe'
$InstallCommand = "c:\netextender.exe"
$Arguments = "/Q", "/S"
$NETCLI = "C:\Program Files (x86)\SonicWAll\SSL-VPN\NetExtender\NECLI.exe"
$NETCLIARG = "addprofile -s $SSLSERVER -d $SSLDOMAIN"

#Test Variables
$ToolTest = get-childitem C:\

if($ToolTest.name -contains $containsTest ){
    
    
    Remove-Item $OutFile -Recurse -force
    
    }


#Downloads netextender MSI
Invoke-WebRequest -Uri $ToolDownload  -OutFile $OutFile | Out-Null

#Installs netextender
start-process $InstallCommand -ArgumentList $Arguments -wait

#checks contents of $sslserver and $ssldomain
if($SSLSERVER -eq "" -or $SSLDOMAIN -eq ""){
    
    
    Write-warning '-SSLSERVER AND/OR -SSLDOMAIN NOT DEFINED SKIPPING PROFILE CREATION'
    
    }

#Creates netextender profile if $ssldomain and $sslserver have values
else{
    
    start-process $NETCLI -ArgumentList $NETCLIARG
    
    }