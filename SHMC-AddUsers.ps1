<#

  add adusers to res.shmc.ca

  irreperable damage to schema

  Turn back... NOW!!!

  2017-07-03

#>

Import-Module ActiveDirectory

# import data files
$csvStructure = Import-Csv -Delimiter ',' -Path .\OrganizationalStructure.csv
$DB_firstNames = Import-Csv -Delimiter "`n" -Path .\FirstNameDB.csv
$DB_lastNames = Import-Csv -Delimiter "`n" -Path .\LastNameDB.csv

$password = ("KlaasStoker69" | ConvertTo-SecureString -AsPlainText -Force)

# enumerate departments:
# $Departments = New-Object -TypeName System.Collections.ArrayList
[System.Collections.ArrayList]$Departments = (($csvStructure | gm -MemberType NoteProperty).Name)
$Departments.Remove("Domain")
$Departments.Remove("DomainControllerFQDN")
$Departments.Remove("BusinessName")

# show list of departments available
Write-Output $Departments

# Each business Unit gets an OU:
foreach ($BusinessUnit in $csvStructure) {

    Write-Host "`n`nBusiness Unit: $($BusinessUnit.BusinessName)" -ForegroundColor Cyan

    # construct DN
    $BusinessUnitDN = "ou=Accounts"
    $dnpath = $BusinessUnit.domain.split('.')
    $dnpath | foreach { $BusinessUnitDN += ",dc=$_" }

    # OU base
    Write-Output $BusinessUnitDN

    #add new directory to stack:
    $BusinessUnitDN = "ou=$($BusinessUnit.businessName),$BusinessUnitDN"

    # Each Unit's Department's OU:
    Foreach ($businessDepartment in $Departments ) {

        # Only add sub-OUs for occupied departments:
        if($businessUnit.$businessDepartment -ne 0) {

            # Business unit sub-OU path
            $BusinessDepartmentDN = "ou=$businessDepartment,$BusinessUnitDN"

            # Verbose output: show the current FQDN of business department 
            write-host "`t$BusinessDepartmentDN "

            # Add new directory to stack:
            $usersPath = "ou=UserAccounts,$BusinessDepartmentDN"

            Write-Host "`t`t$usersPath"
            # Write-Host "`t`tou=Workstations,$BusinessDepartmentDN"
            Write-Host "`t`t$businessDepartment`: $($BusinessUnit.$businessDepartment)"


            # iterate loop to create users in group with random names...
            1..$BusinessUnit.$businessDepartment|Foreach {

                # create nessicary number of users for each group:
                # noah you suck at spelling
                $firstName = ($DB_firstNames.FirstName | Get-Random)
                $lastName = ($DB_lastNames.LastName | Get-Random)
                $userPrincipalName = "$firstname.$lastname@$($businessUnit.Domain)"
                $groupName = "cn=$($businessUnit.BusinessName)-$businessDepartment"

                # verbose output: write to console the name of user beign created
                Write-Output "`t`t`t$lastName, $firstName"

                # add user
                New-ADUser -GivenName "$firstname" -Surname "$lastName" -Name "$firstname $lastname" -AccountPassword:$password -Enabled:$true -PasswordNeverExpires:$true `
                    -Path $usersPath -UserPrincipalName $userPrincipalName -Server $businessUnit.DomainControllerFQDN

                # add user to group
                $userID = Get-ADUser "cn=$firstName $lastName,$usersPath" -server $businessunit.DomainControllerFQDN
                $groupID = Get-ADGroup "$groupName,$BusinessDepartmentDN" -Server $businessUnit.DomainControllerFQDN
                Add-ADGroupMember -Identity $groupID  -Members $userID -server $businessUnit.domainControllerFQDN
            }

        }

    }

    Write-Verbose "DONE: $($businessUnit.BusinessName)" -Verbose

}
