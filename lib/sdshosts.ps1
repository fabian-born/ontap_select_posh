function Get-SDSHosts{
##############################
#.SYNOPSIS
#Short description
#
#.DESCRIPTION
#Long description
#
#.PARAMETER DeployServer
#Parameter description
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
    param(
        [Parameter(Mandatory=$false)]
        [string]$DeployServer

        ) 
    # actual code for the function goes here see the end of the topic for the complete code sample
    
    if ($global:SDSDeploy){
        $DeployServer = $variable:SDSDeploy.DeployServer

        $Credential = $variable:SDSDeploy.Credential
        try {
            $_request_ = New-Object PSObject
            $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/hosts" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
            $_request_ = $_r.records
            return $_request_     
        }
        catch {
            write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)"  
        } 
    }else{
        write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
    }

}

function New-SDSHosts{
    ##############################
    #.SYNOPSIS
    #
    #
    #.DESCRIPTION
    #Long description
    #
    #.PARAMETER DeployServer
    #Parameter description
    #
    #.PARAMETER ASUPEnabled
    #Parameter description
    #
    #.PARAMETER chunksize
    #Parameter description
    #
    #.PARAMETER destinationurl
    #Parameter description
    #
    #.PARAMETER local_collection
    #Parameter description
    #
    #.PARAMETER productcompany
    #Parameter description
    #
    #.PARAMETER productsite
    #Parameter description
    #
    #.PARAMETER proxyurl
    #Parameter description
    #
    #.PARAMETER retrysendcount
    #Parameter description
    #
    #.PARAMETER retrysendinterval
    #Parameter description
    #
    #.PARAMETER senderthreads
    #Parameter description
    #
    #.PARAMETER ValidateDigitalCertificate
    #Parameter description
    #
    #.EXAMPLE
    #An example
    #
    #.NOTES
    #General notes
    ##############################
    param(
        [Parameter(Mandatory=$false)][string]$DeployServer,
        [Parameter(Mandatory=$false)][string]$type, 
        [Parameter(Mandatory=$false)][string]$vcenter,
        [Parameter(Mandatory=$false)][string]$name
        ) 
        if (!($global:SDSDeploy)){
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        } else {
            $DeployServer = $variable:SDSDeploy.DeployServer
            $Credential = $variable:SDSDeploy.Credential
            $json_tmp = New-Object System.Collections.ArrayList
            
            if ($type){ $json_tmp.add("""hypervisor_type"" : ""$($type).toUpper()""" ) > $null }
            if ($vcenter){ $json_tmp.add("""management_server"" : ""$($vcenter)""") > $null }
            if ($name){ $json_tmp.add("""name"" : ""$($name)""") > $null}
            
            
            if(($json_tmp.count) -gt 0){
                $json_request = "{ `n"
                $json_request += """hosts"": [`n"
                $json_request += "     {`n"
                $i=0;while($i -lt ($json_tmp).count){ 
                        if($i -eq (($json_tmp).count-1)){
                            $json_request += $json_tmp[$i] + "`n"
                        }else{
                                $json_request += $json_tmp[$i] + ",`n"
                        }
                        $i++
                    } 
                $json_request += "  }`n"
                $json_request += " ]`n"
                $json_request += "}`n"
                write-host "$($json_request)"
                try {
                    $_request_ = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/hosts" -SkipCertificateCheck -Method POST -ContentType "application/json" -Credential $Credential -body $($json_request))
                    return $_request_               
                }
                catch {
                    write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
                }
    
            }else{
                write-host -foregroundcolor yellow "Nothing to change!"
            }
        }
    }
    
    


    function Get-SDSHostsInfo{
        ##############################
        #.SYNOPSIS
        #Short description
        #
        #.DESCRIPTION
        #Long description
        #
        #.PARAMETER DeployServer
        #Parameter description
        #
        #.EXAMPLE
        #An example
        #
        #.NOTES
        #General notes
        ##############################
            param(
                [Parameter(Mandatory=$false)]
                [string]$DeployServer,
                [Parameter(Mandatory=$true)]
                [string]$Hostname
                ) 
            # actual code for the function goes here see the end of the topic for the complete code sample
            
            if ($global:SDSDeploy){
                $DeployServer = $variable:SDSDeploy.DeployServer
        
                $Credential = $variable:SDSDeploy.Credential
                if (!($_hosts_ = Get-SDSHosts | ? {$_.name -eq "$($Hostname)"})){
                    write-host -foregroundcolor red  "Error: Host not found. Error Message: $($_.Exception.Message)" 
                }else{
                    try {
                        write-host "Found ID: $($_hosts_.id)"
                        $_request_ = New-Object PSObject
                        $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/hosts/$($_hosts_.id)/networks" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
                        $_network_info = New-Object PSObject
##                        foreach ($n in $_r.records.name){
##                            write-host $n
##                            $_nsettings = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/hosts/$($_hosts_.id)/networks/$($n)" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
##                            write-host $_nsettings.record
##                            $_network_info 
##                        }
                        $_request_ | Add-Member Network $_r.records.name
                        $_request_ | Add-Member HostID $_hosts_.id
                        return $_request_     
                    }
                    catch {
                        write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)"  
                    }
                }
            }else{
                write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
            }
        
        }

function Get-SDSHosts{
##############################
#.SYNOPSIS
#Short description
#
#.DESCRIPTION
#Long description
#
#.PARAMETER DeployServer
#Parameter description
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
    param(
        [Parameter(Mandatory=$false)]
        [string]$DeployServer

        ) 
    # actual code for the function goes here see the end of the topic for the complete code sample
    
    if ($global:SDSDeploy){
        $DeployServer = $variable:SDSDeploy.DeployServer

        $Credential = $variable:SDSDeploy.Credential
        try {
            $_request_ = New-Object PSObject
            $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/hosts?fields=*" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
            $_request_ = $_r.records
            return $_request_     
        }
        catch {
            write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)"  
        } 
    }else{
        write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
    }

}

function Get-SDSLicenses{
    ##############################
    #.SYNOPSIS
    #Short description
    #
    #.DESCRIPTION
    #Long description
    #
    #.PARAMETER DeployServer
    #Parameter description
    #
    #.EXAMPLE
    #An example
    #
    #.NOTES
    #General notes
    ##############################
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer
    
            ) 
        # actual code for the function goes here see the end of the topic for the complete code sample
        
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer
    
            $Credential = $variable:SDSDeploy.Credential
            try {
                $_request_ = New-Object PSObject
                $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/licensing/licenses" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
                $_request_ = $_r.records
                return $_request_     
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)"  
            } 
        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
    
    }