[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

$result = [System.Windows.Forms.MessageBox]::Show('Рекомендуется установить Cloudflare DNS серверы на текущий сетевой интерфейс. Установить?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	$PrimaryDNS = '1.1.1.1'
	$SecondaryDNS = '1.0.0.1'
	$PhysAdapter = Get-NetAdapter -Physical
	$PhysAdapter | Get-DnsClientServerAddress -AddressFamily IPv4 | Set-DnsClientServerAddress -ServerAddresses ($PrimaryDNS, $SecondaryDNS)
	Clear-DnsClientCache
}

Write-Host "Устанавливаем диспетчер пакетов NuGet"
[void](Install-PackageProvider NuGet -Confirm:$false -Force)
[void](Set-PSRepository PSGallery -InstallationPolicy Trusted)

Write-Host "Устанавливаем Powershell модуль VcRedist"
[void](Install-Module -Name VcRedist -Confirm:$False -Force)

Write-Host "Удаляем все версии Microsoft Visual C++ Redistributable"
[void](Uninstall-VcRedist -Confirm:$false)

$temp_dir = "C:\WTH_Temp"
if (test-path $temp_dir) {[void](Remove-Item $temp_dir -Recurse -Confirm:$false -Force)}
[void](New-Item -Path 'C:\WTH_Temp' -ItemType Directory -Confirm:$false -Force)

Write-Host "DirectX Redist (June 2010)"
$directx = "$temp_dir\dxwebsetup.exe"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe', $directx)
cmd /c start /wait $directx /Q
del $directx

Write-Host "Microsoft Visual C++ 2005-2022"
$Redists_unsupported = Get-VcList -Export Unsupported | Where-Object { $_.Release -in "2005", "2008", "2010" } | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent
$Redists = Get-VcList -Release 2012, 2013, 2015, 2017, 2019, 2022 | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent

Write-Host "Mono 6.12.0 Stable (6.12.0.206)"
$MonoPathx86 = "$temp_dir\mono-latest-x86-stable.msi"
$MonoPathx64 = "$temp_dir\mono-latest-x64-stable.msi"
(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/mono-latest-x86-stable.msi', $MonoPathx86)
(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/mono-latest-x64-stable.msi', $MonoPathx64)
cmd /c start /wait msiexec /i "$MonoPathx86" /q
del $MonoPathx86
cmd /c start /wait msiexec /i "$MonoPathx64" /q
del $MonoPathx64
[void](Remove-Item $temp_dir -Recurse -Force -Confirm:$false)

$result = [System.Windows.Forms.MessageBox]::Show('Рекомендуется перезагрузка. Перезагрузить?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	Restart-computer -Force -Confirm:$false
}