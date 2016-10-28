<#
.EXAMPLE
    This module will check the disk free space. The disk that will 
    be checked in this scenario is the disk C with the percentage 25.
#>

Configuration Example 
{
    param()
    Import-DscResource -ModuleName FileAdvancedDsc

    node localhost {
        AFFreeSpace MIDDLEWARE_DriveC_FreeSpace
        {
            DriveLetter = "C"
            FreePercent = 25
        }
    }
}
