# Enumerate list of DCs for automatic feature removal
$daCred = Get-Credential -UserName SHMC\DA -Message "SHMC"

# Remove un-installed feature on each DC. 
# Remove all binaries
foreach ($i in (Get-ADForest).Domains) {
    
    (Get-ADComputer -server $i -filter {Name -like "*DC*" -and Enabled -eq $True } ).Name | % {
    
        Write-Verbose "Uninstall features on $_" -Verbose

        Invoke-Command -ComputerName $_ -Credential $daCred -ScriptBlock {
        
            Get-WindowsFeature | ? { ($_.Installed -eq $false) } | `
                Uninstall-WindowsFeature -Remove -WhatIf -ErrorAction Stop
        }
    }
}


<#
Get-WindowsFeature *GUI* | Uninstall-WindowsFeature -Restart

Get-WindowsFeature | ? { ($_.Installed -eq $false) } | Uninstall-WindowsFeature -Remove -ErrorAction Stop
#>