#enable mitigations for Intel® Transactional Synchronization Extensions (Intel® TSX) Transaction Asynchronous Abort vulnerability (CVE-2019-11135) and Microarchitectural Data Sampling ( CVE-2018-11091 , CVE-2018-12126 , CVE-2018-12127 , CVE-2018-12130 ) 
#along with Spectre (CVE-2017-5753 & CVE-2017-5715) and Meltdown (CVE-2017-5754) variants, including Speculative Store Bypass Disable (SSBD) (CVE-2018-3639) 
#as well as L1 Terminal Fault (L1TF) (CVE-2018-3615, CVE-2018-3620, and CVE-2018-3646) without disabling Hyper-Threading


If (-Not (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management')) {
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Force | Out-Null
}
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'FeatureSettingsOverrideMask' -value '3' -PropertyType 'DWord' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'FeatureSettingsOverride' -value '72' -PropertyType 'DWord' -Force | Out-Null