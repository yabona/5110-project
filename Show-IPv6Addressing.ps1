$daCred = Get-Credential -UserName SHMC\DA -Message "NETIPV6"

$servers = @("SHMC-DC1","SHMC-DC2","RES-DC1","SPHM-DC1","MS-DC1")

foreach ($i in $Servers) {
    Write-Verbose $i -Verbose
    Invoke-Command -ComputerName $i -ScriptBlock {
        Get-NetIPAddress -AddressFamily IPv6 -PrefixOrigin Manual `
            | fl IPaddress,InterfaceAlias,Type
    } -Credential $daCred 
}