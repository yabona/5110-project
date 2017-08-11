<#

OUimport.ps1
July 2nd, 2017
Noah Bailey
Lets see if this son of a bitch even works.
Fuck it mode engage.

#>

Import-Module ActiveDirectory

# import data file
$csvStructure = Import-Csv -Delimiter ',' -Path .\OrganizationalStructure.csv

# enumerate departments:
# $Departments = New-Object -TypeName System.Collections.ArrayList
[System.Collections.ArrayList]$Departments = (($csvStructure | gm -MemberType NoteProperty).Name)
$Departments.Remove("Domain")
$Departments.Remove("DomainControllerFQDN")
$Departments.Remove("BusinessName")

# show list of departments available
Write-Output $Departments


    # don't run this it'll break powershell unless you're on a domain! fuckin idiot!
# create base OUs to each domain first...
New-ADOrganizationalUnit -Name Accounts -Server SHMC-DC1 -Path "dc=shmc,dc=ca" -ProtectedFromAccidentalDeletion:$false -ErrorAction Continue
New-ADOrganizationalUnit -Name Accounts -Server RES-DC1 -Path "dc=res,dc=shmc,dc=ca" -ProtectedFromAccidentalDeletion:$false -ErrorAction Continue
New-ADOrganizationalUnit -Name Accounts -Server SPHM-DC1 -Path "dc=sphm,dc=shmc,dc=ca" -ProtectedFromAccidentalDeletion:$false -ErrorAction Continue
New-ADOrganizationalUnit -Name Accounts -Server MS-DC1 -Path "dc=massageandspa,dc=ca" -ProtectedFromAccidentalDeletion:$false -ErrorAction Continue


# Each business Unit gets an OU:
foreach ($BusinessUnit in $csvStructure) {

    Write-Host "`n`nBusiness Unit: $($BusinessUnit.BusinessName)" -ForegroundColor Cyan

    # construct DN
    $BusinessUnitDN = "ou=Accounts"
    $dnpath = $BusinessUnit.domain.split('.')
    $dnpath | foreach { $BusinessUnitDN += ",dc=$_" }

    # OU base
    Write-Output $BusinessUnitDN
    New-ADOrganizationalUnit -name $businessUnit.BusinessName -Path $BusinessUnitDN -server $BusinessUnit.DomainControllerFQDN `
      -ProtectedFromAccidentalDeletion:$false -ErrorAction Continue

    #add new directory to stack:
    $BusinessUnitDN = "ou=$($BusinessUnit.businessName),$BusinessUnitDN"

    # Create security group for organization:
    New-ADGroup -Name "$($BusinessUnit.BusinessName)" -Path $businessUnitDN -GroupCategory Security `
      -GroupScope DomainLocal -Server $BusinessUnit.DomainControllerFQDN

    # Each Unit's Department's OU:
    Foreach ($businessDepartment in $Departments ) {

        # Only add sub-OUs for occupied departments:
        if($businessUnit.$businessDepartment -ne 0) {

            # Business unit sub-OU path
            $BusinessDepartmentDN = "ou=$businessDepartment,$BusinessUnitDN"

            write-host "`t$BusinessDepartmentDN "

            # create business unit OU
            New-ADOrganizationalUnit -name $businessDepartment -Path $businessUnitDN -Server $businessUnit.DomainControllerFQDN `
              -ProtectedFromAccidentalDeletion:$false -ErrorAction Continue

            # verbose: FQDN of container object
            Write-Host "`t`tou=UserAccounts,$BusinessDepartmentDN"
            Write-Host "`t`tou=Workstations,$BusinessDepartmentDN"

            # create Sub-OUs for user accounts and workstations
            New-ADOrganizationalUnit -name "UserAccounts" -path $BusinessDepartmentDN -server $businessUnit.DomainControllerFQDN `
              -ProtectedFromAccidentalDeletion:$false -ErrorAction Continue
            New-ADOrganizationalUnit -name "Workstations" -path $BusinessDepartmentDN -server $businessUnit.DomainControllerFQDN `
              -ProtectedFromAccidentalDeletion:$false -ErrorAction Continue

            # security groups and mappings

            New-ADGroup -name "$($businessUnit.BusinessName)-$businessDepartment" -path "$BusinessDepartmentDN" `
              -GroupCategory Security -GroupScope DomainLocal -server $businessUnit.DomainControllerFQDN
            Add-ADGroupMember -Identity "cn=$($BusinessUnit.BusinessName),$BusinessUnitDN" `
              -Members "cn=$($businessUnit.BusinessName)-$businessDepartment,$BusinessDepartmentDN" `
              -Server $BusinessUnit.DomainControllerFQDN
        }

    }

    # verbose status message:
    Write-Verbose "DONE: $($businessUnit.BusinessName)" -Verbose

}


# lock OUs
Get-ADOrganizationalUnit -server SHMC-DC1 -filter {Name -eq "Accounts"} | `
  Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$True
Get-ADOrganizationalUnit -server RES-DC1 -filter {Name -eq "Accounts"} | `
  Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$True
Get-ADOrganizationalUnit -server SPHM-DC1 -filter {Name -eq "Accounts"} | `
  Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$True
Get-ADOrganizationalUnit -server MS-DC1 -filter {Name -eq "Accounts"} | `
  Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$True

#if you fuck up:
<#

#unlock OUs:
    Get-ADOrganizationalUnit -server SHMC-DC1 -filter {Name -eq "Accounts"} | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$False
    Get-ADOrganizationalUnit -server RES-DC1 -filter {Name -eq "Accounts"} | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$False
    Get-ADOrganizationalUnit -server SPHM-DC1 -filter {Name -eq "Accounts"} | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$False
    Get-ADOrganizationalUnit -server MS-DC1 -filter {Name -eq "Accounts"} | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$False

# Remove OUs:
    Remove-ADOrganizationalUnit -identity "ou=Accounts,dc=shmc,dc=ca" -server shmc-dc1 -Recursive -Confirm
    Remove-ADOrganizationalUnit -identity "ou=Accounts,dc=res,dc=shmc,dc=ca" -server res-dc1 -Recursive -Confirm
    Remove-ADOrganizationalUnit -identity "ou=Accounts,dc=sphm,dc=shmc,dc=ca" -server sphm-dc1 -Recursive -Confirm
    Remove-ADOrganizationalUnit -identity "ou=Accounts,dc=massageandspa,dc=ca" -server ms-dc1 -Recursive -Confirm

#>
