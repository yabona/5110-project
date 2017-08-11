# DHCP setup




########################
# SHMC.ca

Get-DhcpServerv4Scope | Remove-DhcpServerv4Scope
Get-DhcpServerv6Scope | Remove-DhcpServerv6Scope

$shmc_v4Addr = @("172.30.1.",  "172.30.2.",   "172.30.5.",   "172.30.6.",   "172.30.20.",  "172.30.28.")
$shmc_v6Addr = @("CC10",       "CC11",        "CC14",        "CC19",        "DD29",        "DD39")
$shmc_Names =@("Reception",    "Security",    "Facilities",  "Visitor(1)",  "Visitor(2)",  "Visitor(3)")

#loop, add scopes
for ($i = 0; $i -lt $shmc_Names.Length ; $i++ ) {
    
    Write-Verbose -Message $shmc_Names[$i] -Verbose

    Add-DhcpServerv4Scope -StartRange "$($shmc_v4Addr[$i])50" -EndRange "$($shmc_v4Addr[$i])200" -Name $shmc_Names[$i] `
        -SubnetMask 255.255.255.0 
    $scopeID = (Get-DhcpServerv4Scope | Where-Object { ( $_.Name -eq $shmc_Names[$i]) } ).ScopeId
    Set-DhcpServerv4OptionValue -ScopeId $scopeID -DnsDomain "shmc.ca" `
         -DnsServer 172.30.10.10,172.30.10.11 -force -Router "$($shmc_v4Addr[$i])1" 


    Add-DhcpServerv6Scope -Name $shmc_Names[$i] -Prefix 2001:cafe:bead:$($shmc_v6Addr[$i])::
    $scopeID = (Get-DhcpServerv6Scope | Where-Object { ( $_.Name -eq $shmc_Names[$i]) } ).ScopeId
    Set-DhcpServerv6OptionValue -DnsServer 2001:Cafe:bead:cc00::dc10,2001:cafe:bead:cc00::dc11 -force -DomainSearchList "shmc.ca" 
}

Add-DhcpServerv4Failover -Name "SHMC-FAILOVER" -ScopeId 172.30.1.0,172.30.2.0,172.30.5.0,172.30.6.0,172.30.20.0,172.30.28.0 `
     -PartnerServer shmc-dc2.shmc.ca -ComputerName shmc-dc1.shmc.ca -AutoStateTransition:$true -ReservePercent 10 


###########################
# res.shmc.ca

Get-DhcpServerv4Scope | Remove-DhcpServerv4Scope
Get-DhcpServerv6Scope | Remove-DhcpServerv6Scope

$res_v4Addr = @("172.30.3.",  "172.30.4.",  "172.30.16.",   "172.30.17.",      "172.30.24.",   "172.30.25.", "172.30.26.",  "172.30.27.")
$res_v6Addr = @("CC12",        "CC13",      "DD20",         "DD21",            "EE30",         "EE31",       "EE32",        "EE33")
$res_Names = @("PharmaPlus",  "DynaLabs",   "CoolidgeLab",  "ChildrensHealth", "DentalOffice", "ENT",        "Allergist",   "Physiotherapy")

# loop, add scopes... 
for ($i = 0; $i -lt $res_Names.Length ; $i++ ) {
    
    Write-Verbose -Message $res_Names[$i] -Verbose

    Add-DhcpServerv4Scope -StartRange "$($res_v4Addr[$i])50" -EndRange "$($res_v4Addr[$i])200" -Name $res_Names[$i] `
        -SubnetMask 255.255.255.0 
    $scopeID = (Get-DhcpServerv4Scope | Where-Object { ( $_.Name -eq $res_Names[$i]) } ).ScopeId
    Set-DhcpServerv4OptionValue -ScopeId $scopeID -DnsDomain "res.shmc.ca" `
         -DnsServer 172.30.10.20 -force -Router "$($res_v4Addr[$i])1" 


    Add-DhcpServerv6Scope -Name $res_Names[$i] -Prefix 2001:cafe:bead:$($res_v6Addr[$i])::
    $scopeID = (Get-DhcpServerv6Scope | Where-Object { ( $_.Name -eq $res_Names[$i]) } ).ScopeId
    Set-DhcpServerv6OptionValue -DnsServer 2001:Cafe:bead:cc00::dc20 -force -DomainSearchList "res.shmc.ca" 
}

###########################
# sphm

Get-DhcpServerv4Scope | Remove-DhcpServerv4Scope
Get-DhcpServerv6Scope | Remove-DhcpServerv6Scope

# add scopes... 

Add-DhcpServerv4Scope -StartRange 172.30.19.50 -EndRange 172.30.19.200 -name "Physicians" -SubnetMask 255.255.255.0
Get-DHCPserverV4scope | Set-DhcpServerv4OptionValue -DnsDomain "sphm.shmc.ca" -DnsServer 172.30.10.40 -Force -Router 172.30.19.1

Add-DhcpServerv6Scope -Prefix 2001:cafe:bead:dd22:: -name "Physicians"
Get-DhcpServerv6Scope | Set-DhcpServerv6OptionValue -DnsServer 2001:cafe:bead:cc00::dc40 -DomainSearchList "sphm.shmc.ca" -Force

##########################
# MS
Get-DhcpServerv4Scope | Remove-DhcpServerv4Scope
Get-DhcpServerv6Scope | Remove-DhcpServerv6Scope

# add scopes

Add-DhcpServerv4Scope -StartRange 172.30.19.50 -EndRange 172.30.19.200 -name "Massage&Spa" -SubnetMask 255.255.255.0
Get-DHCPserverV4scope | Set-DhcpServerv4OptionValue -DnsDomain "massageandspa.ca" -DnsServer 172.30.10.40 -Force -Router 172.30.19.1

Add-DhcpServerv6Scope -Prefix 2001:cafe:bead:dd23:: -name "Massage&Spa"
Get-DhcpServerv6Scope | Set-DhcpServerv6OptionValue -DnsServer 2001:cafe:bead:cc00::dc40 -DomainSearchList "massageandspa.ca" -Force


##############################
# show-commands...

$servers = @("SHMC-DC1","SHMC-DC2","RES-DC1","SPHM-DC1","MS-DC1")

foreach ($i in $servers) {
    Write-Verbose "SCOPES ON $i`:" -Verbose
    
    Get-DhcpServerv4Scope -ComputerName $i | `
        ft Name,State,ScopeID,StartRange,EndRange
}
# view IPV6 scopes...
$servers = @("SHMC-DC1","SHMC-DC2","RES-DC1","SPHM-DC1","MS-DC1")

 foreach ($i in $servers) {
    
    Write-Verbose "SCOPES ON $i`:" -Verbose

     Get-DhcpServerv6Scope -ComputerName $i  | `
         ft Name,Prefix,State
}


# view failover relations...
$failoverConfig = Get-DhcpServerv4Failover -ComputerName SHMC-DC1
$failoverConfig | fl Name,PartnerServer,Mode,ServerRole
Write-Verbose "Failover-Enabled scopes:" -Verbose
$failoverConfig.ScopeId | fl IPAddressToString


#########################
# misc

<# holy shit man stop drinking and go to bed you've done enough damage!


but back up pls.

#>