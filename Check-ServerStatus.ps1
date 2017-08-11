foreach ($i in (Get-ADForest).Domains) {
    foreach ($j in (Get-ADComputer -server $i -filter {Enabled -eq $true}).dnsHostName ) {
        if (Test-Connection $j -Count 2 -ErrorAction SilentlyContinue) {
            write-host "Server $j is UP!" -ForegroundColor Green
        }else{ Write-Host "Server $j is DOWN!" -ForegroundColor Red
        }
    }
}
