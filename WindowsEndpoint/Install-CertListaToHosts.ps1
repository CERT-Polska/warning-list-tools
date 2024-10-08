# Install CertListaToHosts script.
# See also: https://raw.githubusercontent.com/CERT-Polska/warning-list-tools/
# This script is based on https://github.com/gtworek/PSBits/blob/master/CERTPL2Hosts/Install-CERTHosts.ps1 by Grzegorz Tworek.

# Ensure we're running as Administrator
if (!([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
    Write-Error "Skrypt wymaga uprawnień administratora." -ErrorAction Stop
}

# Parametry działania
$ScriptFolder = ($env:Program Files)
$ScriptName = "Update-CertListaToHosts.ps1"
$ScriptURL = "https://raw.githubusercontent.com/CERT-Polska/warning-list-tools/master/WindowsEndpoint/Update-CertListaToHosts.ps1"
$TaskName = "CertListaToHosts"
$PathScript = "$ScriptFolder\$ScriptName"

$ScriptName3rdparty = "Update-CERTHosts.ps1"
$TaskName3rdparty = "CERT.PL do hosts"
$Path3rdparty = "$ScriptFolder\$ScriptName3rdparty"

# Sprawdzamy czy CERTPL2Hosts nie jest już zainstalowany
$Task3rdparty = Get-ScheduledTask -TaskName $TaskName3rdparty -ErrorAction Ignore
if ((Test-Path -LiteralPath $Path3rdparty) -or ($Task3rdparty -ne $null)) {
    Write-Host "Wygląda na to, że na tym komputerze działa już zewnętrzny skrypt CERTPL2Hosts ze strony https://github.com/gtworek/PSBits/tree/master/CERTPL2Hosts."
    Write-Host "Skrypt dostarczany przez CERT Polska oraz skrypt CERTPL2Hosts nie powinny być instalowane jednocześnie."
    Write-Host "Rekomendowanym rozwiązaniem jest odinstalowanie CERTPL2Hosts przez usunięcie pliku $Path3rdparty oraz Scheduled Taska $TaskName3rdparty."
    Write-Host "Można zrobić to za pomocą instrukcji pod adresem https://github.com/gtworek/PSBits/tree/master/CERTPL2Hosts."
    Write-Error "Wykryto konflikujący skrypt CERTPL2Hosts. Instalacja nie może zostać kontynuowana" -ErrorAction Stop
}

# Sprawdzamy czy plik został już pobrany
if (!(Test-Path -LiteralPath "$PathScript")) {
    $WebRequest = Invoke-WebRequest -Uri $ScriptURL -UseBasicParsing -OutFile ($ScriptFolder+$ScriptName)
    if ($WebRequest.StatusCode -ne 200) {
        Write-Error "Pobranie pliku Update-CertListaToHosts.ps1 nieudane." -ErrorAction Stop
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
