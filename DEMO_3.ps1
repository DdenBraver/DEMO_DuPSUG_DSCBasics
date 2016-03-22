#region New DSC-Configuration example
configuration DomainController
{
    Import-DscResource -ModuleName xActiveDirectory

    Node 'localhost'
    {
        WindowsFeature ADDomainServices
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }
        xADDomain DomainController
        {
            DomainName = 'DEMO.local'
            DomainAdministratorCredential = (get-credential -UserName 'DEMO\Administrator' -Message 'Domain Administrator Credential')
            SafemodeAdministratorPassword = (get-credential -UserName 'safemode_credential' -Message 'Safemode credential')
            DependsOn = "[WindowsFeature]ADDomainServices"
        }
    }
}

DomainController -OutputPath 'C:\DSC\Staging\DomainController'

Start-DscConfiguration -Path 'C:\DSC\Staging\DomainController' -Verbose -Wait

#endregion

#region New DSC-Configuration with ConfigData example
configuration DomainController
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory

    Node $Allnodes.nodename
    {
        WindowsFeature ADDomainServices
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }
        xADDomain DomainController
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $Node.DomainAdminCredentials
            SafemodeAdministratorPassword = $Node.SafemodeAdministratorCredential
            DependsOn = "[WindowsFeature]ADDomainServices"
        }
    }
}

$Configdata = @{
    AllNodes = @(
        @{
            NodeName                        = 'localhost'
            PSDscAllowPlainTextPassword     = $True
            PSDscAllowDomainUser            = $true
            DomainName                      = 'DEMO.local'
            SafemodeAdministratorCredential = Get-Credential -UserName 'safemode' -Message 'Domain Safe Mode Admin Password'
            DomainAdminCredentials          = Get-Credential -UserName 'DEMO\Administrator' -Message 'Domain Admin Credentials'
        }
    )
}

DomainController -ConfigurationData $Configdata -OutputPath 'C:\DSC\Staging\DomainController'

Start-DscConfiguration -Path 'C:\DSC\Staging\DomainController' -Verbose -Wait -Force

#endregion

#region Change LocalConfigurationManager example
[DscLocalConfigurationManager()]
Configuration LocalConfigurationManager
{
	Node 'localhost'
	{
		Settings
        {
			RefreshMode                    = 'PUSH'
			RebootNodeIfNeeded             = $true
			ActionAfterReboot              = 'ContinueConfiguration'
			RefreshFrequencyMins           = 30
			ConfigurationMode              = 'ApplyAndAutoCorrect'
		}
    }
}

LocalConfigurationManager -OutputPath 'C:\DSC\Staging\DomainController'

Set-DscLocalConfigurationManager -Path 'C:\DSC\Staging\DomainController' -Verbose
#endregion