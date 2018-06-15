function Get-SDSCluster{
###############################
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
            $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
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

function New-SDSCluster{
    ###############################
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
            [string]$ClusterName,
            [Parameter(Mandatory=$true)]
            [int]$NodeCount,
            [Parameter(Mandatory=$false)][string]$adminpasswd,
            [Parameter(Mandatory=$false)][string]$availability,
            [Parameter(Mandatory=$false)][string]$gateway,
            [Parameter(Mandatory=$false)][string]$ip,
            [Parameter(Mandatory=$false)][string]$netmask
            ) 
        # actual code for the function goes here see the end of the topic for the complete code sample
        $valid = $false
        $valid = switch ( $NodeCount )
        {
            1 { $true }
            2 { $true }
            4 { $true }
            6 { $true }
            8 { $true }
            default { $false }
        }
        if ($valid -eq $true){
            if ($global:SDSDeploy){
                $DeployServer = $variable:SDSDeploy.DeployServer
        
                $Credential = $variable:SDSDeploy.Credential
                $json_tmp = New-Object System.Collections.ArrayList



                try {
                    $json_request = "{ `n"
                   $json_request +=   """name"": ""$($ClusterName)"" `n"

                    $json_request += "}`n"
                    write-host $json_request
                    $_request_ = New-Object PSObject
                    $_request_ = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters?node_count=$($NodeCount)" -SkipCertificateCheck -Method POST -ContentType "application/json" -Credential $Credential -body $($json_request))

                    write-host $_request_
                }
                catch {
                    write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
                }
                try {
                    write-host "Additional Configuration: "
                    $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
                    $json_tmp = New-Object System.Collections.ArrayList

                    if ($adminpasswd){ $json_tmp.add("""admin_password"" : ""$($adminpasswd)""") > $null}
                    if ($availability){ $json_tmp.add("""availability"" : ""$($availability)""" ) > $null }
                     if ($gateway){ $json_tmp.add("""gateway"" : ""$($gateway)""") > $null }
                    if ($ip){ $json_tmp.add("""ip"" : ""$($ip)""") > $null}
                    if ($netmask){ $json_tmp.add("""netmask"" : ""$($netmask)""") > $null}

                    $json_request = "{ `n"
                    $i=0;while($i -lt ($json_tmp).count){ 
                        if($i -eq (($json_tmp).count-1)){
                            $json_request += $json_tmp[$i] + "`n"
                        }else{
                                $json_request += $json_tmp[$i] + ",`n"
                        }
                        $i++
                    } 
                    $json_request += "} `n"
                    write-host $json_request
                    $_request_ = New-Object PSObject
                    $_request_ = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)" -SkipCertificateCheck -Method PATCH -ContentType "application/json" -Credential $Credential -body $($json_request))
                    write-host $_request_
                }
                catch {
                    write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
                }
                
                
            }else{
                write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
            }
        
        }else{
            write-host -foregroundcolor red  "Error: Node Count not supported. Error Message: $($_.Exception.Message)"  
        }
}

function Remove-SDSCluster{
<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER DeployServer
Parameter description

.PARAMETER ClusterName
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
    
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer,
            [Parameter(Mandatory=$true)]
            [string]$ClusterName
            ) 
        # actual code for the function goes here see the end of the topic for the complete code sample
            if ($global:SDSDeploy){
                $DeployServer = $variable:SDSDeploy.DeployServer
        
                $Credential = $variable:SDSDeploy.Credential

                if (!($_findcluster_ = Get-SDSCluster | ? {$_.name -eq "$($ClusterName)"})){
                    write-host -foregroundcolor red  "Error: No Cluster found!. Error Message: $($_.Exception.Message)"     
                }else{
                
                    try {


                        $_request_ = New-Object PSObject
                        $_request_ = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($_findcluster_.id)" -SkipCertificateCheck -Method DELETE -ContentType "application/json" -Credential $Credential) 
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

function Get-SDSClusterNodeNetWork{
    <#
    .SYNOPSIS
    
    
    .DESCRIPTION
    Long description
    
    .PARAMETER DeployServer
    Parameter description
    
    .PARAMETER ClusterName
    Parameter description
    
    .PARAMETER parent
    Parameter description
    
    .PARAMETER Object
    Parameter description
    
    .PARAMETER Value
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>#
        
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer,
            [Parameter(Mandatory=$true)]
            [string]$ClusterName,
            [Parameter(Mandatory=$true)]
            [string]$NodeName,
            [Parameter(Mandatory=$false)]
            [switch]$isArray
        )
    
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer
        
            $Credential = $variable:SDSDeploy.Credential

            try {
                $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
                $noid = (Get-SDSClusterNodes -clusterName $($clusterName) | ?{$_.name -eq "$($NodeName)"}).id
                ## write-host "$json_request `n $($noid) `n $($clid)"
                $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)/nodes/$($noid)/networks?fields=*" -SkipCertificateCheck -Method GET -ContentType "application/json" -Credential $Credential ) | convertfrom-json
               
                return $_r.records
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
            }
                
        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
    }


function Add-SDSClusterNodeParameter{
    <#
    .SYNOPSIS
    
    
    .DESCRIPTION
    Long description
    
    .PARAMETER DeployServer
    Parameter description
    
    .PARAMETER ClusterName
    Parameter description
    
    .PARAMETER parent
    Parameter description
    
    .PARAMETER Object
    Parameter description
    
    .PARAMETER Value
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>#
        
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer,
            [Parameter(Mandatory=$true)]
            [string]$ClusterName,
            [Parameter(Mandatory=$true)]
            [string]$NodeName,
            [Parameter(Mandatory=$false)]
            [string]$parent,
            [Parameter(Mandatory=$true)]
            [string]$Object,
            [Parameter(Mandatory=$true)]
            [string]$Value,
            [Parameter(Mandatory=$false)]
            [switch]$isArray
        )
    
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer
        
            $Credential = $variable:SDSDeploy.Credential
            
            if (($Value.split(",")).count -gt 2){
                $isArray = $true
            }
            $json_request ="{`n"
            if ($parent){   $json_request += """$($parent)"" : { `n" }
            if ($object){   $json_request += """$($object)"" : " }
            if ($isArray){ 
                $json_request += " [`n"
                write-host ((($value).split(",")).length)
                $i=0;while($i -lt ((($value).split(",")).length)){ 
                    
                    if($i -eq ((($value).split(",")).length-1)){
                        $json_request +=  " ""$(($value).split(",")[$i])""`n"
                    }else{
                            $json_request += """$(($value).split(",")[$i])"",`n"
                    }   
                    
                    $i++
                }
                $json_request += " ]`n"
                if ($parent){   $json_request += "}`n" }
            }else{
             #   $json_request += " {`n"
                $json_request += " ""$($value)"" `n"
                if ($parent){   $json_request += "}`n" }
            }
            $json_request += " }`n"
            try {
                $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
                $noid = (Get-SDSClusterNodes -clusterName $($clusterName) | ?{$_.name -eq "$($NodeName)"}).id
                write-host "$json_request `n $($noid) `n $($clid)"
                $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)/nodes/$($noid)" -SkipCertificateCheck -Method PATCH -ContentType "application/json" -Credential $Credential -body $($json_request))
               
                return $_r
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
            }
                
        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
    }
    
 
    
    function Add-SDSClusterParameter{
        <#
        .SYNOPSIS
        
        
        .DESCRIPTION
        Long description
        
        .PARAMETER DeployServer
        Parameter description
        
        .PARAMETER ClusterName
        Parameter description
        
        .PARAMETER parent
        Parameter description
        
        .PARAMETER Object
        Parameter description
        
        .PARAMETER Value
        Parameter description
        
        .EXAMPLE
        An example
        
        .NOTES
        General notes
        #>#
            
            param(
                [Parameter(Mandatory=$false)]
                [string]$DeployServer,
                [Parameter(Mandatory=$true)]
                [string]$ClusterName,
                [Parameter(Mandatory=$false)]
                [string]$parent,
                [Parameter(Mandatory=$true)]
                [string]$Object,
                [Parameter(Mandatory=$true)]
                [string]$Value,
                [Parameter(Mandatory=$false)]
                [switch]$isArray
            )
        
            if ($global:SDSDeploy){
                $DeployServer = $variable:SDSDeploy.DeployServer
            
                $Credential = $variable:SDSDeploy.Credential
                
                if (($Value.split(",")).count -gt 2){
                    $isArray = $true
                }
                $json_request ="{`n"
                if ($parent){   $json_request += """$($parent)"" : { `n" }
                if ($object){   $json_request += """$($object)"" : " }
                if ($isArray){ 
                    $json_request += " [`n"
                    write-host ((($value).split(",")).length)
                    $i=0;while($i -lt ((($value).split(",")).length)){ 
                        
                        if($i -eq ((($value).split(",")).length-1)){
                            $json_request +=  " ""$(($value).split(",")[$i])""`n"
                        }else{
                                $json_request += """$(($value).split(",")[$i])"",`n"
                        }   
                        
                        $i++
                    }
                    $json_request += " ]`n"
                    if ($parent){   $json_request += "}`n" }
                }else{
                 #   $json_request += " {`n"
                    $json_request += " ""$($value)"" `n"
                    if ($parent){   $json_request += "}`n" }
                }
                $json_request += " }`n"
                try {
                    $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
                    $noid = (Get-SDSClusterNodes -clusterName $($clusterName) | ?{$_.name -eq "$($NodeName)"}).id
                    write-host "$json_request `n $($noid) `n $($clid)"
                    $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)" -SkipCertificateCheck -Method PATCH -ContentType "application/json" -Credential $Credential -body $($json_request))
                   
                    return $_r
                }
                catch {
                    write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
                }
                    
            }else{
                write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
            }
        }
    
function Add-SDSClusterHost{
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer,
            [Parameter(Mandatory=$true)]
            [string]$ClusterName,
            [Parameter(Mandatory=$false)]
            [string]$parent,
            [Parameter(Mandatory=$true)]
            [string]$NodeName
            )
        
            if ($global:SDSDeploy){
                $DeployServer = $variable:SDSDeploy.DeployServer 
                $Credential = $variable:SDSDeploy.Credential
                $_host = (Get-SDSHosts | ?{$_.name -eq "$($NodeName)"})
                $_cluster= (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"})
                if (($_cluster) -and ($_host)){
                    $json_request = "
                    "
                    try {
                        $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
                        write-host $json_request
                        $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)" -SkipCertificateCheck -Method PATCH -ContentType "application/json" -Credential $Credential -body $($json_request))
                       
                        return $_r
                    }
                    catch {
                        write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
                    }
                }else{
                    write-host -foregroundcolor yellow "Host or Cluster not found. Please verify with Get-SDSCluster or Get-SDSHosts!"
                }
    
            }else{
                write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
            }
    }
    

function Get-SDSClusterNodes{
    param(
        [Parameter(Mandatory=$false)]
        [string]$DeployServer,
        [Parameter(Mandatory=$false)]
        [string]$ClusterName
        )
    
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer 
            $Credential = $variable:SDSDeploy.Credential
            if ($ClusterName){
                $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
            
            
            try {
                $_request_ = New-Object PSObject
                $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)/nodes" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
                $_request_ = $_r.records
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

function Get-SDSClusterNodeSettings{
    param(
        [Parameter(Mandatory=$false)]
        [string]$DeployServer,
        [Parameter(Mandatory=$false)]
        [string]$ClusterName,
        [Parameter(Mandatory=$false)]
        [string]$NodeName
        )
    
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer 
            $Credential = $variable:SDSDeploy.Credential
            if ($ClusterName){
                $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
                $noid = (Get-SDSClusterNodes -clusterName $($clusterName) | ?{$_.name -eq "$($NodeName)"}).id
                
            try {
                $_request_ = New-Object PSObject
                $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)/nodes/$($noid)/networks" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content | ConvertFrom-Json
                $_request_ = $_r.records
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


function Set-SDSClusterNodeNetWork{
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer,
            [Parameter(Mandatory=$true)]
            [string]$ClusterName,
            [Parameter(Mandatory=$true)]
            [string]$NodeName,
            [Parameter(Mandatory=$true)]
            [string]$NetworkType,
            [Parameter(Mandatory=$true)]
            [string]$NetworkName,
            [Parameter(Mandatory=$false)]
            [switch]$isArray
        )
    
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer
        
            $Credential = $variable:SDSDeploy.Credential
            
            switch($Networktype){
                "mgmt" { 
                        $networkinfo =  Get-SDSClusterNodeNetWork -ClusterName $($clusterName) -NodeName $($NodeName) | ?{$_.purpose -eq "mgmt"} 
                       }
                "data" { 
                        $networkinfo =  Get-SDSClusterNodeNetWork -ClusterName $($clusterName) -NodeName $($NodeName) | ?{$_.purpose -eq "data"} 
                       }
                default { write-host "Nothing found" ; break}
            }
            
 
            try {
                $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
                $noid = (Get-SDSClusterNodes -clusterName $($clusterName) | ?{$_.name -eq "$($NodeName)"}).id
                $netid = $networkinfo.id
                $json_request = "{`n"
                $json_request += " ""name"": ""$($NetworkName)"" `n"
                $json_request += "}"
                write-host "$json_request `n $($noid) `n $($clid) `n $($netid)"
                $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)/nodes/$($noid)/networks/$($netid)" -SkipCertificateCheck -Method PATCH -ContentType "application/json" -Credential $Credential -body $($json_request))
               
                return $_r
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
            }
                
        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
    }

    function Get-SDSHostStoragePool{
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer,
            [Parameter(Mandatory=$true)]
            [string]$HostName
    
            ) 
        # actual code for the function goes here see the end of the topic for the complete code sample
        
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer
    
            $Credential = $variable:SDSDeploy.Credential
            $hostid = ( Get-SDSHosts | ?{$_.name -eq "$($Hostname)"}).id
            try {
                $_request_ = New-Object PSObject
                $_r = (((Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/hosts/$($hostid)/storage/pools?fields=*" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content) | convertfrom-json ).records
    
                return $_r  
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)"  
            } 
        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
    
    }
    
    function Get-SDSHostStorageDisk{
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer,
            [Parameter(Mandatory=$true)]
            [string]$HostName
    
            ) 
        # actual code for the function goes here see the end of the topic for the complete code sample
        
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer
    
            $Credential = $variable:SDSDeploy.Credential
            $hostid = ( Get-SDSHosts | ?{$_.name -eq "$($Hostname)"}).id
            try {
                $_request_ = New-Object PSObject
                $_r = (((Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/hosts/$($hostid)/storage/disks?fields=*" -SkipCertificateCheck -Method GET -ContentType JSON -Credential $Credential).content) | convertfrom-json).records
                
                
                return $_r   
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)"  
            } 
        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
    
    }

    function Set-SDSClusterNodeStoragePool{
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer,
            [Parameter(Mandatory=$true)]
            [string]$ClusterName,
            [Parameter(Mandatory=$true)]
            [string]$HostName,
            [Parameter(Mandatory=$true)]
            [string]$StoragePool,
            [Parameter(Mandatory=$true)]
            [int]$Size,
            [Parameter(Mandatory=$false)]
            [switch]$isArray
        )
    
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer
        
            $Credential = $variable:SDSDeploy.Credential
            
            $storage_pool = Get-SDSHostStoragePool -hostname $($HostName) | ? {$_.name -eq "$($StoragePool)"} 
            $stoid= $storage_pool.id
            $stoname= $storage_pool.name
            #                   MB      GB
            $newsize = $size * 1024 * 1024 * 1024
            ## check free capacity
            if (($newsize-1) -gt $storage_pool.available_capacity){
                write-host "capacity is bigger than available_capacity"
                break
            }
            try {
                $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
                $noid = (Get-SDSClusterNodes -clusterName $($clusterName) | ?{$_.name -eq "$($NodeName)"}).id
                $storagename = $networkinfo.id
                
                $json_request = "
                {
                    ""pool_array"": [
                        {
                        ""capacity"": $newsize,
                        ""name"": ""$($stoname)""
                        }
                    ]
                }
                "
            
                $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)/nodes/$($noid)/storage/pools" -SkipCertificateCheck -Method POST -ContentType "application/json" -Credential $Credential -body $($json_request))
               
                return $_r
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
            }
                
        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
    }

function Invoke-SDSClusterDeploy{
        param(
            [Parameter(Mandatory=$false)]
            [string]$DeployServer,
            [Parameter(Mandatory=$true)]
            [string]$ClusterName
        )
    
        if ($global:SDSDeploy){
            $DeployServer = $variable:SDSDeploy.DeployServer
        
            $Credential = $variable:SDSDeploy.Credential
            
            try {
                $clid = (Get-SDSCluster | ?{$_.name -eq "$($ClusterName)"}).id
                
                $json_request = "
                {
                
                }
                "
            
                $_r = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters/$($clid)/deploy" -SkipCertificateCheck -Method POST -ContentType "application/json" -Credential $Credential -body $($json_request))
               
                return $_r
            }
            catch {
                write-host -foregroundcolor red  "Error connecting to ONTAP Select Deployment. Error Message: $($_.Exception.Message)" 
            }
                
        }else{
            write-host -foregroundcolor yellow "Not Connected to the Deployment Server. Please run ""Connect-SDSDeploy"" !`n"
        }
    }