$host.ui.RawUI.WindowTitle = "Welcome To Hell SCP:SL Dependencies downloader and installer"
Write-Host "Загрузчик и инсталлятор зависимостей для SCP:SL от " -ForegroundColor white -nonewline
Write-Host "Welcome To Hell" -ForegroundColor red
Write-Host "https://discord.scpsl.ru" -ForegroundColor white -BackgroundColor darkred
Write-Host ""

# Disable warnings and errors output
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
function global:Write-Host() {}

# Do not prompt for confirmations
Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global

[void]([System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"))

# Checking if NTP time sync is enabled. If not, ask to enable and sync time.

Write-Output "Проверяем, включена ли синхронизация времени по сети"

$ntp_status = w32tm /query /configuration

if ($ntp_status -Match "The following error occurred")
{
	$result = [System.Windows.Forms.MessageBox]::Show('Не включена синхронизация времени через интернет.' + [System.Environment]::NewLine + 'Без этого невозможно установить SSL соединение с центральным сервером SCP:SL.' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Включить?' , "Синхронизация времени" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
	if ($result -eq 'Yes') {
		[void](w32tm /unregister)
		[void](w32tm /register)
		[void](net start w32time)
		[void](w32tm /resync /rediscover)
	}
}

# Checking if recommended Russian NTP server is set. If not, ask to set.

Write-Output "Проверяем, выставлен ли рекомендуемый NTP сервер"

$ntp_server = w32tm /query /source

if (-Not($ntp_server -Match 'ru.pool.ntp.org'))
{
	$result = [System.Windows.Forms.MessageBox]::Show('Рекомендуется изменить NTP сервер.' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Задать NTP сервер ru.pool.ntp.org?' , "Синхронизация времени" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
	if ($result -eq 'Yes') {
		$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers'
		[void](New-ItemProperty -Path $RegistryPath -Name '3' -Value 'ru.pool.ntp.org' -PropertyType String -Force)	
		[void](New-ItemProperty -Path $RegistryPath -Name '(Default)' -Value '3' -PropertyType String -Force)
		[void](w32tm /config /manualpeerlist:"ru.pool.ntp.org" /syncfromflags:manual /reliable:yes /update)
		
		# Bypass time resync max difference
		[void]($origMaxNegPhaseCorrection = Get-ItemPropertyValue 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config' 'MaxNegPhaseCorrection')
		[void]($origMaxPosPhaseCorrection = Get-ItemPropertyValue 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config' 'MaxPosPhaseCorrection')
		[void](New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config' -Name 'MaxNegPhaseCorrection' -Value 4294967295 -PropertyType DWORD -Force)
		[void](New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config' -Name 'MaxPosPhaseCorrection' -Value 4294967295 -PropertyType DWORD -Force)
		
		[void](w32tm /resync /rediscover)
		
		# Restore original registry values
		[void](New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config' -Name 'MaxNegPhaseCorrection' -Value $origMaxNegPhaseCorrection -PropertyType DWORD -Force)
		[void](New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Config' -Name 'MaxPosPhaseCorrection' -Value $origMaxPosPhaseCorrection -PropertyType DWORD -Force)
	}
}

# Checking if DNS servers are 1.1.1.1 and 1.0.0.1 for active network adapter with internet connection

Write-Output "Проверяем, установлены ли рекомендованные DNS серверы на физическом сетевом интерфейсе, подключенному к интернету"

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

# Checking if internet connection to download websites is working

Write-Output "Проверяем возможность установить соединение с сайтами для дальнейшего скачивания зависимостей SCP:SL"

$ProgressPreference = 'SilentlyContinue'

try {
    [void](Invoke-WebRequest -URI "https://download.microsoft.com" -UseBasicParsing)
} catch {
	[System.Windows.Forms.MessageBox]::Show('Невозможно установить соединение с сайтом download.microsoft.com' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Проверьте ваше интернет-соединение.' , "Ошибка" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	exit
}

try {
    [void](Invoke-WebRequest -URI "https://download.mono-project.com" -UseBasicParsing)
} catch {
	[System.Windows.Forms.MessageBox]::Show('Невозможно установить соединение с сайтом download.mono-project.com' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Проверьте ваше интернет-соединение.' , "Ошибка" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	exit
}

try {
    [void](Invoke-WebRequest -URI "https://dot.net" -UseBasicParsing)
} catch {
	[System.Windows.Forms.MessageBox]::Show('Невозможно установить соединение с сайтом dot.net' + [System.Environment]::NewLine + [System.Environment]::NewLine + 'Проверьте ваше интернет-соединение.' , "Ошибка" , [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	exit
}

$ProgressPreference = 'Continue'

Write-Output "Устанавливаем диспетчер пакетов NuGet"
[void](Get-PackageProvider -Name "NuGet" -ErrorAction SilentlyContinue -ForceBootstrap)

Write-Output "Проверяем политику установки для PSGallery"
$policy = Get-PSRepository -Name PSGallery

if ($policy)
{
	if (-not($policy.InstallationPolicy -eq 'Trusted'))
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

Remove-Module -Name VcRedist
Uninstall-Module -Name VcRedist -AllVersions -Force

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