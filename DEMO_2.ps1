# If upgraded from WMF5 preview to WMF5 RTM run this to fix MOF compiling issues
# mofcomp $env:windir\\system32\\wbem\\DscCoreConfProv.mof

#region example
configuration Service_W32Time
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node ("Localhost")
    {
        Service 'W32Time'
        {
            Name = 'W32Time'
            Ensure = 'Present'
        }
    }
}

Service_W32Time -OutputPath 'C:\DSC\Staging\Service_W32Time'

Start-DscConfiguration -Path 'C:\DSC\Staging\Service_W32Time' -Verbose -Wait
#endregion