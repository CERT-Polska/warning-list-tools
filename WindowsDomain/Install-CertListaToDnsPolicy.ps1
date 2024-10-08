# Install CertListaToDnsPolicy script.
# See also: https://raw.githubusercontent.com/CERT-Polska/warning-list-tools/
# This script is based on https://github.com/gtworek/PSBits/blob/master/CERTPL2Hosts/Install-CERTHosts.ps1 by Grzegorz Tworek.

# Ensure we're running as Administrator
if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
    Write-Error "Skrypt wymaga uprawnień administratora." -ErrorAction Stop
}

# Parametry działania
$ScriptFolder = ($env:ProgramFiles)
$ScriptName = "Update-CertListaToDnsPolicy.ps1"
$ScriptURL = "https://raw.githubusercontent.com/CERT-Polska/warning-list-tools/master/WindowsDomain/Update-CertListaToDnsPolicy.ps1"
$TaskName = "CertListaToDnsPolicy"
$PathScript = "$ScriptFolder\$ScriptName"

# Sprawdzamy czy plik został już pobrany
if (!(Test-Path -LiteralPath "$PathScript")) {
    $WebRequest = Invoke-WebRequest -Uri $ScriptURL -UseBasicParsing -OutFile ($ScriptFolder+$ScriptName)
    if ($WebRequest.StatusCode -ne 200) {
        Write-Error "Pobranie pliku Update-CertListaToDnsPolicy.ps1 nieudane." -ErrorAction Stop
    }
}

# Na wszelki wypadek sprawdzamy czy nie ma już taska.
$Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction Ignore
if ($Task -ne $null) {
    Write-Error "Scheduled Task już istnieje! Nowy NIE zostanie zarejestrowany." -ErrorAction Stop
}

# Krok #3
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5)
$Action = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-NoProfile -ExecutionPolicy Bypass -File ""$PathScript"""
$Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action -Principal $Principal

Write-Host "Instalacja zakończona. Zadanie zostanie uruchomione pierwszy raz w ciągu kilku sekund."
Start-ScheduledTask -TaskName $TaskName
