function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $false)]
        [String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Checking if the path $Path exists"

    if (Test-Path -Path $Path)
    {
        # Replace \ with \\ for WMI
        $cimPath = $Path.Replace("\","\\")
        $cimDirectory = Get-CimInstance -ClassName Win32_Directory -Namespace root/CIMV2 -Filter "Name='$cimPath'"

        # Check if folder is already compressed
        if ($cimDirectory.Compressed)
        {
            $localEnsure = 'Present'
            Write-Verbose -Message "$Path is compressed"
        }
        else
        {
            Write-Verbose -Message "$Path is not compressed."
            $localEnsure = 'Absent'
        }
    }
    else
    {
        Throw "Failed getting current path $Path"
        $localEnsure = 'Absent'
    }

    return @{
        Path = $Path
        Ensure = $localEnsure
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $false)]
        [String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Setting the compressed property for $Path"
    $currentValues = Get-TargetResource @PSBoundParameters
    
    Write-Verbose -Message "Checking if the path $Path exists"    
    if (Test-Path -Path $Path)
    {
        # Replace \ with \\ for WMI
        $wmiPath = $Path.Replace("\","\\")
        $wmiDirectory = Get-WmiObject -Class "Win32_Directory" -Namespace "root\cimv2" -ComputerName $env:COMPUTERNAME -Filter "Name='$wmiPath'"

        if ($Ensure -eq 'Absent')
        {
            try
            {
                # Check if folder is already not compressed
                if ($wmiDirectory.Compressed)
                {
                    $compress = $wmiDirectory.UnCompressEx("","True")
                    Write-Verbose -Message "$Path is now uncompressed"
                }
            }
            catch
            {
                Throw "Ensure Absent - Failed configuring path $Path"
            }
        }
        else
        {
            try
            {
                # Check if folder is already compressed
                if (!($wmiDirectory.Compressed))
                {
                    $compress = $wmiDirectory.CompressEx("","True")
                    Write-Verbose -Message "$Path is now compressed"
                }
            }
            catch
            {
                Throw "Ensure Present - Failed configuring path $Path"
            }
        }
    }
    else
    {
        Throw "Failed checking current path $Path"
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $false)]
        [String]
        [ValidateSet("Present","Absent")]
        $Ensure = "Present"
    )

    Write-Verbose -Message "Testing for compression of path $Path"

    $currentValues = Get-TargetResource @PSBoundParameters
    return Test-AFDscParameterState -CurrentValues $currentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Ensure")
}

Export-ModuleMember -Function *-TargetResource
