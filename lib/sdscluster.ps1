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
            [int]$NodeCount
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
                try {
                    $json_request = "{ `n"
                    $json_request +=   """name"": ""$($ClusterName)"" `n"
                    $json_request += "}`n"

                    $_request_ = New-Object PSObject
                    $_request_ = (Invoke-WebRequest -Uri "https://$($DeployServer)/api/v3/clusters?node_count=$($NodeCount)" -SkipCertificateCheck -Method POST -ContentType "application/json" -Credential $Credential -body $($json_request))
                    if(($_request_.StatusCode) -eq "201"){

                    }
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