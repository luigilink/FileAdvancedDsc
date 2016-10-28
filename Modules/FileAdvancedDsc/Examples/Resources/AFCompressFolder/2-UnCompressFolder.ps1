<#
.EXAMPLE
    This module will uncompress a folder. The full path of the folder
    that will be uncompressed in this scenario are stored in C:\ToUnCompress.
#>

Configuration Example 
{
    param()
    Import-DscResource -ModuleName FileAdvancedDsc

    node localhost {
        AFCompressFolder MIDDLEWARE_UnCompress_Logs
        {
            Ensure = 'Absent'
            Path = "C:\ToUnCompress"
        }
    }
}
