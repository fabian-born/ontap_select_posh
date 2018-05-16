set-Location "/Users/fabian/devel/Powershell/OntapSDS"
 
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
