# Utility script that updates DNS Zone policy in Active Directory

function Read-UrlText {
    # Read URL data and decode it as UTF8.
    $rawdata = (Invoke-Webrequest -URI $URL).RawContentStream.ToArray()
    [Text.Encoding]::UTF8.GetString($rawdata)
}

function Read-TxtList {
    # Read a newline-separated list of URLs from provided URL.
    param ($Url)
    $lines = (Read-UrlText $Url) -split "\n"
    $starlines = $lines | Foreach-Object { $($_, "*.$_") }
    @($starlines | Foreach-Object {$_})
}

function Read-Rpz {
    # Read a RPZ file from provided URL and return a list of URLs to block.
    # Currently unused, but may be useful for some people I guess?
    param ($Url)
    $lines = (Read-UrlText $Url) -split "\n"
    $cnames = $lines | Where-Object {$_ -match "CNAME" }
    $cnames | Foreach-Object { return ($_ -split " ")[0] }
}

function Convert-Hex {
    # Necessary, because Format-Hex is just dumb.
    # Unfortunately this is unrolled and ugly, because powershell is slow as heck.
    param ($Data)
    $out = ""
    foreach ($c in $Data.ToCharArray()) {
       # Quadratic complexity, but in practice this is ORDERS of magnitude faster than join.
       $out += [System.String]::Format('{0:x2}', [int]$c)
    }
    $out
}

function Block-Domains {
    # The main function here - sync system DNS Policy with provided $DomList.
    param ($Prefix, $DomHash)

    Write-Output "[.] Getting current DNS policies"
    $existing = Get-DnsServerQueryResolutionPolicy |
        Where-Object { $_.Name.StartsWith($Prefix) } |
        Foreach-Object { return $_.Name }
    # Why do I have to
    if ($existing -eq $null) { $existing = @()}

    Write-Output "[.] Computing differences"
    $comp = Compare-Object ($DomHash.Keys | %{$_}) $existing

    Write-Output "[.] Adding new rules"
    $comp | Where-Object { $_.SideIndicator -eq "<=" } |
        Foreach-Object { $_.InputObject } | 
        Foreach-Object {
            $domName = $DomHash[$_]
            Add-DnsServerQueryResolutionPolicy -Name $_ -Action DENY -FQDN "EQ,$domName"
        }

    # https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/why-is-it-so-ridiculously-slow-to-remove-my-query-resolution/ba-p/1851087
    $toRemove = $comp | Where-Object { $_.SideIndicator -eq "=>" } |
        Foreach-Object { $_.InputObject } |
        Foreach-Object { Get-DnsServerQueryResolutionPolicy -Name $_ }
    Write-Output "[.] Dropping $($toRemove.Count) obsolete rules"
    $toRemove |
        Sort-Object ProcessingOrder -Descending |
        Remove-DnsServerQueryResolutionPolicy -Force -ThrottleLimit 1

    Write-Output "[.] Finished successfully"
}

function Main {
    param ($Prefix, $Url)
    
    Write-Output "[.] Fetching a domain blacklist"
    $domains = Read-TxtList $Url
    if ($domains.Count -lt 1000) {
        # This is very sus
        Write-Output "Only $($domains.Count) domains parsed from $Url, refusing to continue"
        return
    }

    Write-Output "[.] Parsing new domain blacklist"
    $wantedHash = @{}
    $domains | Foreach-Object { $wantedHash.Add("$($Prefix)_$(Convert-Hex $_)", $_) }

    Block-Domains $Prefix $wantedHash
}

Main "CERTPL" "https://hole.cert.pl/domains/v2/domains.txt"
