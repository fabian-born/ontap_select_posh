function Connect-SDSDeploy{
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
#.PARAMETER APIPort
#Parameter description
#
#.PARAMETER ssl
#Parameter description
#
#.PARAMETER Credential
#Parameter description
#
#.EXAMPLE
#An example
#
#.NOTES
#General notes
##############################
    param(
        [Parameter(Mandatory=$true)]
        [string]$DeployServer,
        [Parameter(Mandatory=$false)]
        [int]$APIPort,
        [Parameter(Mandatory=$false)]
        [string]$ssl,
        [Parameter(Mandatory=$false)]
        $Credential = [System.Management.Automation.PSCredential]::Empty 
        ) 
    # actual code for the function goes here see the end of the topic for the complete code sample
    
    switch ($ssl){
        ""          {   $ssl_parameter = "https"}
        "enabled"   {   $ssl_parameter = "https"; }
        "disabled"  {   $ssl_parameter = "http"}
    }
    if (!$APIPort) {
        $APIPort = 443
    }

    if (!$Credential){
        $cred_parameter = ""
    }else{ $cred_parameter = " -Credential $($Credential) " }

    $parameter = ""
    try {
        $_request_ = New-Object PSObject
        $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/deploy" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
        $_request_ | Add-Member Hostname $_r.record.hostname
        $_request_ | Add-Member SystemID $_r.record.system_id 
        $_request_ | Add-Member Credential $Credential
        $_request_ | Add-Member DeployServer $DeployServer
        return $global:SDSDeploy = $_request_ 
    }
    catch {
        write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)"   
    }

}

function Disconnect-SDSDeploy{

    Return $global:SDSDeploy = ""
}


function Get-SDSSystemInfoV2{
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
###############################
    param(
        [Parameter(Mandatory=$false)]
        [string]$DeployServer

        ) 
    # actual code for the function goes here see the end of the topic for the complete code sample
    
    if ($global:SDSDeploy){
        $DeployServer = $variable:SDSDeploy.DeployServer

        $Credential = $variable:SDSDeploy.Credential
        try {
            $_request_ = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v2/system" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
            return $_request_ 
        }
        catch {
            write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)"   
        }
        
    }else{
        write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
    }

}


function Get-SDSASUPV2{
    param(
        [Parameter(Mandatory=$false)]
        [string]$DeployServer

        ) 
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.deploy_ipv4
    
            $Credential = $variable:SDSDeploy.Credential

            try {
                $_request_ = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v2/autosupport/configuration" -SkipCertificateCheck -Method GET -ContentType "HAL+JSON" -Credential $Credential).content | ConvertFrom-Json
                return $_request_.asup_static                
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
            }

        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
        
}

function Get-SDSASUPSiteConfigV2{
    param(
        [Parameter(Mandatory=$false)]
        [string]$DeployServer

        ) 
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.deploy_ipv4
    
            $Credential = $variable:SDSDeploy.Credential
            try {
                $_request_ = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v2/autosupport/configuration" -SkipCertificateCheck -Method GET -ContentType "HAL+JSON" -Credential $Credential).content | ConvertFrom-Json
                return $_request_.asup_mutable
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)"
            }
            
        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
        
}

function Set-SDSASUPV2{
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
    [Parameter(Mandatory=$false)][string]$ASUPEnabled, 
    [Parameter(Mandatory=$false)][int]$chunksize,
    [Parameter(Mandatory=$false)][string]$destinationurl,
    [Parameter(Mandatory=$false)][string]$local_collection,
    [Parameter(Mandatory=$false)][string]$productcompany,
    [Parameter(Mandatory=$false)][string]$productsite,
    [Parameter(Mandatory=$false)][string]$proxyurl,
    [Parameter(Mandatory=$false)][int]$retrysendcount,
    [Parameter(Mandatory=$false)][int]$retrysendinterval,
    [Parameter(Mandatory=$false)][int]$senderthreads,
    [Parameter(Mandatory=$false)][string]$ValidateDigitalCertificate
    ) 
    if (!($global:SDSDeploy)){
        write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
    } else {
        $DeployServer = $variable:SDSDeploy.deploy_ipv4
        $Credential = $variable:SDSDeploy.Credential
        $json_tmp = New-Object System.Collections.ArrayList
        
        if ($ASUPEnabled){ $json_tmp.add("""asup_enabled"" : $($ASUPEnabled)" ) > $null }
        if ($chunksize){ $json_tmp.add("""chunk_size"" : $($chunksize)") > $null }
        if ($destinationurl){ $json_tmp.add("""destination_url"" : ""$($destinationurl)""") > $null}
        if ($localcollection){ $json_tmp.add("""local_collection"" : ""$($localcollection)""") > $null}
        if ($productcompany){ $json_tmp.add("""product_company"" : ""$($productcompany)""") > $null}
        if ($productsite){ $json_tmp.add("""product_site"" : ""$($productsite)""" ) > $null}
        if ($proxyurl){ $json_tmp.add("""proxy_url"" : ""$($proxyurl)""" ) > $null}
        if ($retrysendcount){ $json_tmp.add("""retry_send_count"" :  $($retrysendcount)") > $null}
        if ($retrysendinterval){ $json_tmp.add("""retry_send_interval"" : $($retrysendinterval)") > $null }
        if ($senderthreads){ $json_tmp.add("""sender_threads"" : $($senderthreads)") > $null}
        if ($ValidateDigitalCertificate){ $json_tmp.add("""validate_digital_certificate"" : $($ValidateDigitalCertificate)" )> $null}
        
        if(($json_tmp.count) -gt 0){
            $json_request = "{ `n"
            $i=0;while($i -lt ($json_tmp).count){ 
                    if($i -eq (($json_tmp).count-1)){
                        $json_request += $json_tmp[$i] + "`n"
                    }else{
                            $json_request += $json_tmp[$i] + ",`n"
                    }
                    $i++
                } 
            $json_request += "}"
            write-host "$($json_request)"
            try {
                $_request_ = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v2/autosupport/configuration" -SkipCertificateCheck -Method PUT -ContentType "application/json" -Credential $Credential -body $($json_request))
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

