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
Export-ModuleMember Get-SDSCluster
Export-ModuleMember New-SDSCluster
Export-ModuleMember Remove-SDSCluster
Export-ModuleMember Get-SDSClusterNodeNetWork
Export-ModuleMember Add-SDSClusterNodeParameter
Export-ModuleMember Add-SDSClusterParameter
Export-ModuleMember Add-SDSClusterHost
Export-ModuleMember Get-SDSClusterNodes
Export-ModuleMember Get-SDSClusterNodeSettings
Export-ModuleMember Set-SDSClusterNodeNetWork
Export-ModuleMember Get-SDSHostStoragePool
Export-ModuleMember Get-SDSHostStorageDisk
Export-ModuleMember Connect-SDSDeploy
Export-ModuleMember Disconnect-SDSDeploy
Export-ModuleMember Get-SDSSystemInfoV2
Export-ModuleMember Get-SDSASUPV2
Export-ModuleMember Get-SDSASUPSiteConfigV2
Export-ModuleMember Set-SDSASUPV2
Export-ModuleMember Get-SDSHosts
Export-ModuleMember New-SDSHosts
Export-ModuleMember Get-SDSHostsInfo
Export-ModuleMember Get-SDSHosts
Export-ModuleMember Get-SDSLicenses
Export-ModuleMember Set-SDSClusterNodeStoragePool
Export-ModuleMember Invoke-SDSClusterDeploy
