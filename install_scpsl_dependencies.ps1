# Disable warnings and errors output
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
function global:Write-Host() {}

$PhysAdapter = Get-NetAdapter -Physical
$DnsAddress = $PhysAdapter | Get-DnsClientServerAddress -AddressFamily IPv4
$PrimaryDNS = '1.1.1.1'
$SecondaryDNS = '1.0.0.1'

if (-Not($DnsAddress.ServerAddresses[0] -eq $PrimaryDNS -and $DnsAddress.ServerAddresses[1] -eq $SecondaryDNS))
{
	[void]([System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"))

	$result = [System.Windows.Forms.MessageBox]::Show('������������� ���������� Cloudflare DNS ������� ��� �������� �������� ����������. ����������?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
	if ($result -eq 'Yes') {
		$PhysAdapter | Get-DnsClientServerAddress -AddressFamily IPv4 | Set-DnsClientServerAddress -ServerAddresses ($PrimaryDNS, $SecondaryDNS)
		Clear-DnsClientCache
	}
}


if (-Not(Get-PackageProvider -Name "NuGet"))
{
	Write-Output "������������� ��������� ������� NuGet"
	[void](Install-PackageProvider NuGet -Confirm:$false -Force)
}

$status = Get-PSRepository -Name PSGallery

if (-not($status.InstallationPolicy -eq "Trusted"))
{
	Write-Output "���������� ���������� �������� ��������� ��� PSGallery"
	[void](Set-PSRepository PSGallery -InstallationPolicy Trusted)
}

Write-Output "������������� Powershell ������ VcRedist"
[void](Install-Module -Name VcRedist -Confirm:$False -Force)

Write-Output "������� ��� ������ Microsoft Visual C++ Redistributable"
[void](Uninstall-VcRedist -Confirm:$false)

$temp_dir = "C:\WTH_Temp"
if (test-path $temp_dir) {[void](Remove-Item $temp_dir -Recurse -Confirm:$false -Force)}
[void](New-Item -Path 'C:\WTH_Temp' -ItemType Directory -Confirm:$false -Force)

Write-Output "DirectX Redist (June 2010)"
$directx = "$temp_dir\directx_Jun2010_redist.exe"
(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe', $directx)
cmd /c start /wait $directx /Q /C /T:"$temp_dir\DirectX\"
cmd /c start /wait "$temp_dir\DirectX\DXSETUP.exe" /silent
del $directx
if (test-path $temp_dir) {[void](Remove-Item $temp_dir\DirectX -Recurse -Confirm:$false -Force)}

Write-Output "Microsoft Visual C++ 2005-2022"
[void]($Redists_unsupported = Get-VcList -Export Unsupported | Where-Object { $_.Release -in "2005", "2008", "2010" } | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent -Force)
[void]($Redists = Get-VcList -Release 2012, 2013, 2022 | Save-VcRedist -Path $temp_dir | Install-VcRedist -Silent -Force)

%ProgramFiles%\Mono\bin\

if (-Not(Test-Path -Path $env:ProgramFiles\Mono\bin\mono.exe -PathType Leaf))
{
	Write-Output "Mono Stable"
	$MonoPathx86 = "$temp_dir\mono-latest-x86-stable.msi"
	$MonoPathx64 = "$temp_dir\mono-latest-x64-stable.msi"
	(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/mono-latest-x86-stable.msi', $MonoPathx86)
	(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/mono-latest-x64-stable.msi', $MonoPathx64)
	cmd /c start /wait msiexec /i "$MonoPathx86" /q
	del $MonoPathx86
	cmd /c start /wait msiexec /i "$MonoPathx64" /q
	del $MonoPathx64
}

$result = [System.Windows.Forms.MessageBox]::Show('������������� ���������� �������������� �����������. ����������?' , "" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	Write-Output ".NET Framework 3.5 � ������� ���������� 1 (SP1)"
	[void](Dism /online /Enable-Feature /FeatureName:"NetFx3" /quiet) 
	Write-Output "DirectPlay"
	[void](dism /online /Enable-Feature /FeatureName:DirectPlay /All /quiet)
	
	$dotnetscript = "$temp_dir\dotnet-install.ps1"
	(New-Object Net.WebClient).DownloadFile('https://dot.net/v1/dotnet-install.ps1', $dotnetscript)
	Write-Output ".NET Runtime 6"
	[void](.$temp_dir/dotnet-install.ps1 -Channel 6.0 -Runtime windowsdesktop | Select-WriteHost -Quiet) 
	Write-Output ".NET Runtime 7"
	[void](.$temp_dir/dotnet-install.ps1 -Channel 7.0 -Runtime windowsdesktop | Select-WriteHost -Quiet) 
	Write-Output ".NET Runtime 8"
	[void](.$temp_dir/dotnet-install.ps1 -Channel 8.0 -Runtime windowsdesktop | Select-WriteHost -Quiet) 
	
	del $dotnetscript
}

[void](Remove-Item $temp_dir -Recurse -Force -Confirm:$false)

$result = [System.Windows.Forms.MessageBox]::Show('������������� ������������. �������������?' , "��� ����������� ������� �����������!" , [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if ($result -eq 'Yes') {
	Restart-computer -Force -Confirm:$false
}