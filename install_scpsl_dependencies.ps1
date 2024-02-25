Write-Host "Устанавливаем Powershell модуль VcRedist"
[void](Install-Module -Name VcRedist)

Write-Host "Удаляем все версии Microsoft Visual C++ Redistributable"
[void](Uninstall-VcRedist -Confirm:$false)

[void](New-Item -Path 'C:\TestTemp' -ItemType Directory)
$temp_dir = "C:\TestTemp"

Write-Host "DirectX Redist (June 2010)"
$directx = "$temp_dir\dxwebsetup.exe"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe', $directx)
cmd /c start /wait $directx /Q
del $directx

Write-Host "Microsoft Visual C++ 2005 Service Pack 1"
$vcredist2005_x64 = "$temp_dir\vcredist2005_x64.exe"
$vcredist2005_x86 = "$temp_dir\vcredist2005_x86.msi"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x64.EXE', $vcredist2005_x64)
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE', $vcredist2005_x86)
cmd /c start /wait $vcredist2005_x64 /q
del $vcredist2005_x64
cmd /c start /wait $vcredist2005_x86 /q
del $vcredist2005_x86

Write-Host "Microsoft Visual C++ 2008 Service Pack 1"
$vcredist2008_x64 = "$temp_dir\vcredist2008_x64.exe"
$vcredist2008_x86 = "$temp_dir\vcredist2008_x86.msi"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe', $vcredist2008_x64)
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe', $vcredist2008_x86)
cmd /c start /wait $vcredist2008_x64 /q
del $vcredist2008_x64
cmd /c start /wait $vcredist2008_x86 /q
del $vcredist2008_x86

Write-Host "Microsoft Visual C++ 2010 Service Pack 1"
$vcredist2010_x64 = "$temp_dir\vcredist2010_x64.exe"
$vcredist2010_x86 = "$temp_dir\vcredist2010_x86.msi"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe', $vcredist2010_x64)
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe', $vcredist2010_x86)
cmd /c start /wait $vcredist2010_x64 /q /norestart
del $vcredist2010_x64
cmd /c start /wait $vcredist2010_x86 /q /norestart
del $vcredist2010_x86

Write-Host "Microsoft Visual C++ 2012 Update 4"
$vcredist2012_x64 = "$temp_dir\vcredist2012_x64.exe"
$vcredist2012_x86 = "$temp_dir\vcredist2012_x86.msi"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe', $vcredist2012_x64)
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe', $vcredist2012_x86)
cmd /c start /wait $vcredist2012_x64 /q /norestart
del $vcredist2012_x64
cmd /c start /wait $vcredist2012_x86 /q /norestart
del $vcredist2012_x86

Write-Host "Microsoft Visual C++ 2013"
$vcredist2013_x64 = "$temp_dir\vcredist2013_x64.exe"
$vcredist2013_x86 = "$temp_dir\vcredist2013_x86.msi"
(New-Object Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/10912041/cee5d6bca2ddbcd039da727bf4acb48a/vcredist_x64.exe', $vcredist2013_x64)
(New-Object Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe', $vcredist2013_x86)
cmd /c start /wait $vcredist2013_x64 /install /quiet /norestart
del $vcredist2013_x64
cmd /c start /wait $vcredist2013_x86 /install /quiet /norestart
del $vcredist2013_x86

Write-Host "Microsoft Visual C++ 2015-2022"
$vcredist2015_2017_2019_2022_x64 = "$temp_dir\vcredist2015_2017_2019_2022_x64.exe"
$vcredist2015_2017_2019_2022_x86 = "$temp_dir\vcredist2015_2017_2019_2022_x86.msi"
(New-Object Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/c7707d68-d6ce-4479-973e-e2a3dc4341fe/1AD7988C17663CC742B01BEF1A6DF2ED1741173009579AD50A94434E54F56073/VC_redist.x64.exe', $vcredist2015_2017_2019_2022_x64)
(New-Object Net.WebClient).DownloadFile('https://download.visualstudio.microsoft.com/download/pr/71c6392f-8df5-4b61-8d50-dba6a525fb9d/510FC8C2112E2BC544FB29A72191EABCC68D3A5A7468D35D7694493BC8593A79/VC_redist.x86.exe', $vcredist2015_2017_2019_2022_x86)
cmd /c start /wait $vcredist2015_2017_2019_2022_x64 /install /quiet /norestart
del $vcredist2015_2017_2019_2022_x64
cmd /c start /wait $vcredist2015_2017_2019_2022_x86 /install /quiet /norestart
del $vcredist2015_2017_2019_2022_x86

Write-Host "Mono 6.12.0 Stable (6.12.0.206)"
$MonoPathx86 = "$temp_dir\mono-6.12.0.206-gtksharp-2.12.45-win32-0.msi"
$MonoPathx64 = "$temp_dir\mono-6.12.0.206-x64-0.msi"
(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/6.12.0/windows-installer/mono-6.12.0.206-gtksharp-2.12.45-win32-0.msi', $MonoPathx86)
(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/6.12.0/windows-installer/mono-6.12.0.206-x64-0.msi', $MonoPathx64)
cmd /c start /wait msiexec /i "$MonoPathx86" /q
del $MonoPathx86
cmd /c start /wait msiexec /i "$MonoPathx64" /q
del $MonoPathx64
Remove-Item $temp_dir

$input = Read-Host "Рекомендуется перезагрузка. Перезагрузить? [y/n]"
switch($input){
          y{Restart-computer -Force -Confirm:$false}
          n{exit}
    default{write-warning "Введите y или n"}
}