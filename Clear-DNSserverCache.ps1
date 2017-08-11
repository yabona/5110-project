# list of servers

foreach ($i in (Get-ADForest).Domains) {
    
    (Get-ADComputer -server $i -filter {Name -like "*DC*" -and Enabled -eq $True } ).Name | % {

         Clear-DnsServerCache -force -ComputerName $_ -Verbose
    }
}
