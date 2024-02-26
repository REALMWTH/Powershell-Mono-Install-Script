$host.ui.RawUI.WindowTitle = "Welcome To Hell SCP:SL Dependencies downloader and installer"

Write-Output "Загрузчик и инсталлятор зависимостей для SCP:SL от Welcome To Hell (https://discord.scpsl.ru)"

# Disable warnings and errors output
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
function global:Write-Host() {}

[void]([System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"))

$PhysAdapter = Get-NetAdapter -Physical
$DnsAddress = $PhysAdapter | Get-DnsClientServerAddress -AddressFamily IPv4
$PrimaryDNS = '1.1.1.1'
$SecondaryDNS = '1.0.0.1'

if (-Not($DnsAddress.ServerAddresses[0] -eq $PrimaryDNS -and $DnsAddress.ServerAddresses[1] -eq $SecondaryDNS))
{
	$result = [System.Windows.Forms.MessageBox]::Show('Рекомендуется установить Cloudflare DNS серверы для текущего сетевого интерфейса. Установить?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
	if ($result -eq 'Yes') {
		$PhysAdapter | Get-DnsClientServerAddress -AddressFamily IPv4 | Set-DnsClientServerAddress -ServerAddresses ($PrimaryDNS, $SecondaryDNS)
		Clear-DnsClientCache
	}
}


if (-Not(Get-PackageProvider -Name "NuGet"))
{
	Write-Output "Устанавливаем диспетчер пакетов NuGet"
	[void](Install-PackageProvider NuGet -Confirm:$false -Force)
}

Write-Output "Проверяем политику установки для PSGallery"
$policy = Get-PSRepository -Name PSGallery

if ($policy)
{
	if (-not($policy.InstallationPolicy -eq "Trusted"))
	{
		Write-Output "Выставляем доверенную политику установки для PSGallery"
		[void](Set-PSRepository PSGallery -InstallationPolicy Trusted)
	}
	else
	{
		Write-Output "Политика установки для PSGallery уже была установлена как доверенная"
	}
}

Write-Output "Устанавливаем Powershell модуль VcRedist"
[void](Install-Module -Name VcRedist -Confirm:$False -Force)

Write-Output "Удаляем все версии Microsoft Visual C++ Redistributable"
[void](Uninstall-VcRedist -Confirm:$false)

$temp_dir = "C:\WTH_Temp"
if (test-path $temp_dir) {[void](Remove-Item $temp_dir -Recurse -Confirm:$false -Force)}
[void](New-Item -Path 'C:\WTH_Temp' -ItemType Directory -Confirm:$false -Force)

Write-Output "DirectX Redist (June 2010)"
$directx = "$temp_dir\directx_Jun2010_redist.exe"
Start-BitsTransfer -Source 'https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe' -Destination $directx
cmd /c start /wait $directx /Q /C /T:"$temp_dir\DirectX\"
cmd /c start /wait "$temp_dir\DirectX\DXSETUP.exe" /silent
del $directx
if (test-path $temp_dir) {[void](Remove-Item $temp_dir\DirectX -Recurse -Confirm:$false -Force)}

Write-Output "Microsoft Visual C++ 2005-2022"
$Redists_unsupported = Get-VcList -Export Unsupported | Where-Object { $_.Release -in "2005", "2008", "2010" } | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent -Force
$Redists = Get-VcList -Release 2012, 2013, 2022 | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent -Force

if (-Not(Test-Path -Path $env:ProgramFiles\Mono\bin\mono.exe -PathType Leaf))
{
	Write-Output "Mono Stable"
	$MonoPathx86 = "$temp_dir\mono-latest-x86-stable.msi"
	$MonoPathx64 = "$temp_dir\mono-latest-x64-stable.msi"
	Start-BitsTransfer -Source 'https://download.mono-project.com/archive/mono-latest-x86-stable.msi' -Destination $MonoPathx86
	Start-BitsTransfer -Source 'https://download.mono-project.com/archive/mono-latest-x64-stable.msi' -Destination $MonoPathx64
	cmd /c start /wait msiexec /i "$MonoPathx86" /q
	del $MonoPathx86
	cmd /c start /wait msiexec /i "$MonoPathx64" /q
	del $MonoPathx64
}

$result = [System.Windows.Forms.MessageBox]::Show('Рекомендуется установить дополнительные зависимости. Установить?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	Write-Output ".NET Framework 3.5 с пакетом обновления 1 (SP1)"
	[void](Dism /online /Enable-Feature /FeatureName:"NetFx3" /quiet) 
	Write-Output "DirectPlay"
	[void](dism /online /Enable-Feature /FeatureName:DirectPlay /All /quiet)
	
	$dotnetscript = "$temp_dir\dotnet-install.ps1"
	Start-BitsTransfer -Source 'https://dot.net/v1/dotnet-install.ps1' -Destination $dotnetscript
	Write-Output ".NET Runtime 6"
	[void](.$temp_dir/dotnet-install.ps1 -Channel 6.0 -Runtime windowsdesktop) 
	Write-Output ".NET Runtime 7"
	[void](.$temp_dir/dotnet-install.ps1 -Channel 7.0 -Runtime windowsdesktop) 
	Write-Output ".NET Runtime 8"
	[void](.$temp_dir/dotnet-install.ps1 -Channel 8.0 -Runtime windowsdesktop) 
	
	del $dotnetscript
}

[void](Remove-Item $temp_dir -Recurse -Force -Confirm:$false)

$result = [System.Windows.Forms.MessageBox]::Show('Рекомендуется перезагрузка. Перезагрузить?' , "Все зависимости успешно установлены!" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	Restart-computer -Force -Confirm:$false
}