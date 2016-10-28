<#
.EXAMPLE
    This module will compress a folder. The full path of the folder
    that will be compressed in this scenario are stored in C:\ToCompress.
#>

Configuration Example 
{
    param()
    Import-DscResource -ModuleName FileAdvancedDsc

    node localhost {
        AFCompressFolder MIDDLEWARE_Compress_Logs
        {
            Ensure = 'Present'
            Path = "C:\ToCompress"
        }
    }
}
