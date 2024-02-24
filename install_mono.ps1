# install mono
Write-Host "Downloading..."
$msiPathx86 = "$($env:TEMP)\mono-4.2.3.4-gtksharp-2.12.30-win32-0.msi"
$msiPathx64 = "$($env:TEMP)\mono-4.2.3.4-gtksharp-2.12.30-win32-0.msi"
(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/6.12.0/windows-installer/mono-6.12.0.206-gtksharp-2.12.45-win32-0.msi', $msiPathx86)
(New-Object Net.WebClient).DownloadFile('https://download.mono-project.com/archive/6.12.0/windows-installer/mono-6.12.0.206-x64-0.msi', $msiPathx64)

Write-Host "Installing..."
cmd /c start /wait msiexec /i "$msiPathx86" /q
cmd /c start /wait msiexec /i "$msiPathx64" /q
del $msiPathx86
del $msiPathx64