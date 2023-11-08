# Change the working directory to C:\Windows\SysWOW64
Set-Location -Path 'C:\Windows\SysWOW64'

# Unregister msxml4.dll
$regsvr32 = Join-Path -Path $env:SystemRoot -ChildPath 'SysWOW64\regsvr32.exe'
Start-Process -FilePath $regsvr32 -ArgumentList '/u', '/s', 'msxml4.dll' -Wait

# Rename msxml4.dll to msxml4.save
Rename-Item -Path 'msxml4.dll' -NewName 'msxml4.save'

# Rename msxml4r.dll to msxml4r.save
Rename-Item -Path 'msxml4r.dll' -NewName 'msxml4r.save'
