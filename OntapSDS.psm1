set-Location "/Users/fabian/devel/Powershell/OntapSDS"

ipmo dataontap -ErrorAction SilentlyContinue
if (!(Get-Module -Name Dataontap)){
    Write-host -ForegroundColor yellow "The Data ONTAP Powershell toolkit couldn't be found. If you want to configure ONTAP by Powershell please install the Powershell Toolkit."
}

Get-ChildItem ".\lib" | Where {$_.Name -like "*.ps1"} | ForEach {
 
    Write-Host "[Including $_]" -ForegroundColor Green
    . .\lib\$_
}


######################################### EXPORT Members
Export-ModuleMember Connect-SDSDeploy
Export-ModuleMember Disconnect-SDSDeploy
Export-ModuleMember Get-SDSASUP
Export-ModuleMember Set-SDSASUP
Export-ModuleMember Get-SDSASUPSiteConfig
Export-ModuleMember Get-SDSCluster
Export-ModuleMember Get-SDSHosts
Export-ModuleMember Get-SDSSystemInfo
Export-ModuleMember New-SDSCluster
Export-ModuleMember Remove-SDSCluster
Export-ModuleMember New-SDSHosts
Export-ModuleMember Get-SDSHostsInfo
Export-ModuleMember Add-SDSClusterParameter
Export-ModuleMember Get-SDSClusterNodes
Export-ModuleMember Add-SDSClusterHost