# all servers with *DC* in name...
$domainControllers = (Get-ADcomputer -filter {Name -like "*DC*"} ).name


foreach ($i in $domainControllers) {

    Write-Verbose "Scopes on server $i`:" -Verbose


    Get-DhcpServerv4Scope -ComputerName $i | Get-DhcpServerv4Lease -ComputerName $i -AllLeases   | ft Hostname,IPaddress
    Get-DhcpServerv6Scope -ComputerName $i | Get-DhcpServerv6Lease -ComputerName $i              | ft Hostname,IPaddress
}