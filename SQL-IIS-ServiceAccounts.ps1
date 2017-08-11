Get-ADServiceAccount -Filter * | Remove-ADServiceAccount

Install-WindowsFeature RSAT-AD-Powershell
Import-Module ActiveDirectory
Install-ADServiceAccount 

foreach ($i in (Get-ADForest).Domains) {
    
    (Get-ADComputer -server $i -filter {Name -like "*DC*" -and Enabled -eq $True } ).Name | % {
        $_; Get-ADServiceAccount -server $_ -filter * | ft -AutoSize Name,Enabled,ObjectClass,DistinguishedName
    }
}

# IIS for MS1
New-ADServiceAccount -name MSA-WEB -DNSHostName RES-MS1 -server res-dc1.res.shmc.ca 
Add-ADComputerServiceAccount -Identity RES-MS1 -ServiceAccount MSA-WEB -Server res-dc1.res.shmc.ca
Set-ADServiceAccount -Identity MSA-WEB -PrincipalsAllowedToRetrieveManagedPassword RES-MS1$ -Server res-dc1.res.shmc.ca


# MSA for SQL
New-ADServiceAccount -name MSA-SQL -DNSHostName RES-SQL1 -server res-dc1.res.shmc.ca 
Add-ADComputerServiceAccount -Identity RES-SQL1 -ServiceAccount MSA-SQL -Server res-dc1.res.shmc.ca
Set-ADServiceAccount -Identity MSA-SQL -PrincipalsAllowedToRetrieveManagedPassword RES-SQL1$ -Server res-dc1.res.shmc.ca


Get-ADServiceAccount -filter * -server res-dc1.res.shmc.ca