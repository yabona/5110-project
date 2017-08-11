Get-ADGroup -Server res-dc1 -filter * | `
    where {$_.DistinguishedName -like "*OU=Account*"} `
    | fl Name,DistinguishedName

Get-ADUser -server RES-DC1 -filter * | `
    where {$_.DistinguishedName -like "*OU=Accounts*" } `
    | fl Name,DistinguishedName,userPrincipalName