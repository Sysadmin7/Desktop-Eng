$Mylist = Get-Content D:\scripts\list.txt #this is where you put your list of computers
Clear-Host
[System.Collections.ArrayList]$GoodArrayList = @()
[System.Collections.ArrayList]$BadArrayList = @()
foreach ($name in $Mylist){
if (Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue){
#Write-Host $name -ForegroundColor Cyan
$GoodArrayList.Add($name)
}
else{
#Write-Host $name "down" -ForegroundColor Red
$BAdArrayList.Add($name)
}
}
Write-Host -ForegroundColor Cyan "Good Computers :)"
$GoodArrayList
Write-Host -ForegroundColor Red "Bad Computers :("
$BadArrayList