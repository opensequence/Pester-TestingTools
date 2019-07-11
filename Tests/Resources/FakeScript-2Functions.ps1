<#
.SYNOPSIS


.DESCRIPTION



.NOTES
AUTHOR  : Mitchell Gill
CREATED : 12/02/2019
VERSION : 12/02/2019
			1.0 - Initial Revision

.INPUTS
None. This script does not accept input parameters or pipelines

.OUTPUTS
None. This script does not output parameters

.EXAMPLE


#>
#====================================================================================================
#                                             Parameters
#====================================================================================================
#region Parameters

[CmdletBinding()]
Param(

    [Parameter(Mandatory = $false)]
    [string]$InstanceID,

    [Parameter(Mandatory = $false)]
    [string]$RegionID,

    [Parameter(Mandatory = $false)]
    [string[]]$AMIID

)

#Set the error action preference to stop to handle errors as they occur
$ErrorActionPreference = "Stop"

#Override the verbose preference
$VerbosePreference = "SilentlyContinue"

#endregion Parameters

#====================================================================================================
#                                             Functions
#====================================================================================================
#region Functions

#region Find-MeInstance

function Find-MeInstance {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $True, Position = 1)]
        [string]
        $InstanceID,
        [parameter(Mandatory = $True, Position = 2)]
        [string]
        $Region,
        [parameter(Mandatory = $True, Position = 3)]
        [string[]]
        $AMIID
    )
    # retrieve EC2Instance Details
    try {
        Write-Verbose "START: Retrieving EC2 Details for Instance: $($InstanceID)"
        $EC2InstanceDetail = Get-EC2Instance -InstanceID $InstanceID -Region $Region
        Write-Verbose "SUCCESS: Retrieving EC2 Details for Instance: $($InstanceID)"
    } catch {
        Throw "ERROR: Retrieving EC2 Details for Instance: $($InstanceID) ErrorMessage: $($_.Exception.Message)"
    }

    #Compare AMI ID wth provided ID
    If ($AMIID -contains $($EC2InstanceDetail.Instances.ImageId)) {
        Write-Verbose "$($EC2InstanceDetail.Instances.ImageId) Matches one of Provided AMIID: $($AMIID)"
        return $EC2InstanceDetail
    } else {
        Write-Verbose "$($EC2InstanceDetail.Instances.ImageId) does NOT Match one of Provided AMIID: $($AMIID)"
        return $null
    }

}
#endregion Find-MeInstance

Function Imafunction () {

}


#endregion Functions

#====================================================================================================
#                                          Initialize Code
#====================================================================================================
#region Initialize Code
If (-not $InstanceID) {
    Exit
}

#endregion Initialize Code
#====================================================================================================
#                                             Main Code
#====================================================================================================
#region Main Code

#retrieve the AMI ID of the Instance
try {
    Write-Output "START: Retrieving EC2 Details for Instance: $($InstanceID)"
    #TODO-NOW Can you see the mistake I've made here?
    $MatchingEC2Instance = Find-MeInstance -InstanceID "$($InstanceID)" -Region $Region -AMIID $AMIID #it's here
    Write-Output "SUCCESS: Retrieving EC2 Details for Instance: $($InstanceID)"
} catch {
    Write-Error "ERROR: Retrieving EC2 Details for Instance: $($InstanceID) ErrorMessage: $($_.Exception.Message)"
    Exit
}

If (-not $MatchingEC2Instance) {
    Write-Output "Instance does not match that AMI!"
    #Notify
    Publish-SNSMessage
} else {
    Write-Output "SUCCESS: Tagging Instance: $($InstanceID)"
    #Tag
    New-EC2Tag
}

#endregion Main Code