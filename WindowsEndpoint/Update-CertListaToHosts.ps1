# Update the list of malicious domains in the windows hosts file.
# See also: https://raw.githubusercontent.com/CERT-Polska/warning-list-tools/
# This script is based on https://github.com/gtworek/PSBits/blob/master/CERTPL2Hosts/Update-CERTHosts.ps1 by Grzegorz Tworek.

$HoleCertURL = "https://hole.cert.pl/domains/v2/domains_hosts.txt"
$HostsFile = $env:windir+"\System32\drivers\etc\hosts"
$BackupFile = $env:windir+"\System32\drivers\etc\hosts_holecert.bak"

# Intentionally kept compatible with Update-CERTHosts.ps1
$HoleCertStart = "### Start of "+$HoleCertURL+" content ###" # znacznik początku danych z CERT
$HoleCertEnd = "### End of "+$HoleCertURL+" content ###" # znacznik końca danych z CERT

# Mutex to ensure only one copy of the script runs at the same time.
$MutexName = "CertListaToHosts" 
$mtx = New-Object System.Threading.Mutex($false, $MutexName)
[void]$mtx.WaitOne()

# Backup. Created only once.
if (!(Test-Path -LiteralPath $BackupFile)) {
    Copy-Item -LiteralPath $HostsFile -Destination $BackupFile
}

# Download a new version of the CERT.PL list
$HoleCertResponse = Invoke-WebRequest -Uri $HoleCertURL -UseBasicParsing
if ($HoleCertResponse.StatusCode -ne 200)  {
    Write-Error "Pobranie listy nie powiodło się"
    [void]$mtx.ReleaseMutex()
    $mtx.Dispose()
    exit  
}

# Get the response and replace LF with CRLF
$HoleCertContent = $HoleCertResponse.Content.Replace("`n","`r`n")

# Get the current content
$HostsFileContent = Get-Content -LiteralPath $HostsFile

# Znajdź w pliku hosts początek i koniec sekcji z CERT. 
$HoleCertStartLine = ($HostsFileContent | Select-String  -Pattern $HoleCertStart -SimpleMatch).LineNumber
$HoleCertEndLine = ($HostsFileContent | Select-String  -Pattern $HoleCertEnd -SimpleMatch).LineNumber


# Przypadek 1: Mamy obie linie - wymieniamy zawartość między nimi.
if (($HoleCertStartLine -ne $null) -and ($HoleCertEndLine -ne $null)) {
    $NewHostsContent = $HostsFileContent[0..($HoleCertStartLine-1)] + $HoleCertContent + $HostsFileContent[($HoleCertEndLine-1)..($HostsFileContent.Count-1)]
}

# Przypadek 2: Nie mamy żadnej - dodajemy na końcu pliku start, zawartość i end.
if (($HoleCertStartLine -eq $null) -and ($HoleCertEndLine -eq $null)) {
    $NewHostsContent = $HostsFileContent + $HoleCertStart + $HoleCertContent + $HoleCertEnd
}

# Przypadek 3: Mamy tylko start - zostawiamy początek, dodajemy zawartość i end i resztę pliku.
if (($HoleCertStartLine -ne $null) -and ($HoleCertEndLine -eq $null)) {
    $NewHostsContent = $HostsFileContent[0..($HoleCertStartLine-1)] + $HoleCertContent + $HoleCertEnd + $HostsFileContent[($HoleCertStartLine)..($HostsFileContent.Count-1)]
}

# Przypadek 4: Mamy tylko end - wstawiamy start i zawartość przed end.
if (($HoleCertStartLine -eq $null) -and ($HoleCertEndLine -ne $null)) {
    $NewHostsContent = $HostsFileContent[0..($HoleCertEndLine-2)] + $HoleCertStart +  $HoleCertContent + $HostsFileContent[($HoleCertEndLine-1)..($HostsFileContent.Count-1)]
}

# nadpisujemy plik hosts
$NewHostsContent | Out-File $HostsFile -Force

# zwalniamy mutex
[void]$mtx.ReleaseMutex()
$mtx.Dispose()
