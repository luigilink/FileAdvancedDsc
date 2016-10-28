function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $false)]
        [System.String]
        [ValidateSet("Present", "Absent")]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DriveLetter,
                
        [Parameter(Mandatory = $false)]
        [System.Int16]
        $FreePercent = 15
    )

    Write-Verbose -Message "Checking the free space of disk $DriveLetter"

    $cimDisk = Get-CimInstance -ClassName Win32_LogicalDisk -Namespace root/CIMV2 -Filter "DeviceID ='${DriveLetter}:'"
    if ($cimDisk)
    {
        $freeSpace = [math]::round($cimDisk.FreeSpace / $cimDisk.Size * 100, 0)

        if ($freeSpace -ge $FreePercent)
        {
            Write-Verbose -Message "Free Space on disk $DriveLetter is more than $FreePercent"
            $Ensure = 'Present'
        }
        else
        {
            Write-Verboase -Message "Free Space on disk $DriveLetter is less than $FreePercent"
            $Ensure = 'Absent'
        }
    }
    else
    {
        throw "Failed to check the free space - Drive $DriveLetter does not exist"    
        $Ensure = 'Absent'
    }
    
    return @{
        Ensure = $Ensure
        DriveLetter = $DriveLetter
        FreePercent = $FreePercent
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [System.String]
        [ValidateSet("Present", "Absent")]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DriveLetter,
                
        [Parameter(Mandatory = $false)]
        [System.Int16]
        $FreePercent = 15
    )

    #Just discovery NO remdediation
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $false)]
        [System.String]
        [ValidateSet("Present", "Absent")]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DriveLetter,
                
        [Parameter(Mandatory = $false)]
        [System.Int16]
        $FreePercent = 15
    )

    Write-Verbose -Message "Testing free space of drive $DriveLetter"

    $currentValues = Get-TargetResource @PSBoundParameters
    return Test-AFDscParameterState -CurrentValues $currentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Ensure")
}

Export-ModuleMember -Function *-TargetResource
