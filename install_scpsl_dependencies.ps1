[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

$result = [System.Windows.Forms.MessageBox]::Show('������������� ���������� Cloudflare DNS ������� �� ������� ������� ���������. ����������?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	$PrimaryDNS = '1.1.1.1'
	$SecondaryDNS = '1.0.0.1'
	$PhysAdapter = Get-NetAdapter -Physical
	$PhysAdapter | Get-DnsClientServerAddress -AddressFamily IPv4 | Set-DnsClientServerAddress -ServerAddresses ($PrimaryDNS, $SecondaryDNS)
	Clear-DnsClientCache
}

Write-Host "������������� ��������� ������� NuGet"
[void](Install-PackageProvider NuGet -Confirm:$false -Force)
[void](Set-PSRepository PSGallery -InstallationPolicy Trusted)

Write-Host "������������� Powershell ������ VcRedist"
[void](Install-Module -Name VcRedist -Confirm:$False -Force)

Write-Host "������� ��� ������ Microsoft Visual C++ Redistributable"
[void](Uninstall-VcRedist -Confirm:$false)

$temp_dir = "C:\WTH_Temp"
[void](Remove-Item $temp_dir -Recurse -Confirm:$false -Force)
[void](New-Item -Path 'C:\WTH_Temp' -ItemType Directory -Confirm:$false -Force)

Write-Host "DirectX Redist (June 2010)"
$directx = "$temp_dir\dxwebsetup.exe"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe', $directx)
cmd /c start /wait $directx /Q
del $directx

Write-Host "Microsoft Visual C++ 2005-2022"
$Redists_unsupported = Get-VcList -Export Unsupported | Where-Object { $_.Release -in "2005", "2008", "2010" } | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent
$Redists = Get-VcList -Release 2012, 2013, 2015, 2017, 2019, 2022 | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent

Write-Host "Mono 6.12.0 Stable (6.12.0.206)"
$MonoPathx86 = "$temp_dir\mono-6.12.0.206-gtksharp-2.12.45-win32-0.msi"
$MonoPathx64 = "$temp_dir\mono-6.12.0.206-x64-0.msi"
(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/6.12.0/windows-installer/mono-6.12.0.206-gtksharp-2.12.45-win32-0.msi', $MonoPathx86)
(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/6.12.0/windows-installer/mono-6.12.0.206-x64-0.msi', $MonoPathx64)
cmd /c start /wait msiexec /i "$MonoPathx86" /q
del $MonoPathx86
cmd /c start /wait msiexec /i "$MonoPathx64" /q
del $MonoPathx64
[void](Remove-Item $temp_dir -Recurse -Force -Confirm:$false)

$result = [System.Windows.Forms.MessageBox]::Show('������������� ������������. �������������?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	Restart-computer -Force -Confirm:$false
}