#region WSMAN
Set-item wsman:localhost\client\trustedhosts -value * -Force
#endregion

#region cache credential
$clientcredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('Administrator', (ConvertTo-SecureString -String 'Admin123!' -AsPlainText -Force))
#endregion

#region Remote Client for DomainJoin
configuration DomainJoin
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xComputerManagement

    Node $Allnodes.NodeName
    {
        LocalConfigurationManager
        {
			RebootNodeIfNeeded             = $true
			ActionAfterReboot              = 'ContinueConfiguration'
        }

        xComputer 'JoinDomain'
        {
            Name = $Node.Nodename
            DomainName = $Node.DomainName
            Credential = $Node.DomainJoinCredentials
        }
    }
}

$Configdata = @{
    AllNodes = @(
        @{
            NodeName                        = '*'
            PSDscAllowPlainTextPassword     = $True
            PSDscAllowDomainUser            = $true
            DomainName                      = 'DEMO.local'
            DomainJoinCredentials           = Get-Credential -UserName 'DEMO\Administrator' -Message 'Domain Join Credentials'
        }

        @{
            NodeName                        = 'DEMOClient'
        }
    )
}

DomainJoin -OutputPath 'C:\DSC\Staging\JoinDomain' -ConfigurationData $Configdata
Set-DscLocalConfigurationManager -Path 'C:\DSC\Staging\JoinDomain' -ComputerName 'DEMOClient' -Credential $clientcredential -Force -Verbose
Start-DscConfiguration -Path 'C:\DSC\Staging\JoinDomain' -ComputerName 'DEMOClient' -Credential $clientcredential -Force -Verbose -Wait
#endregion

#region Copy modules to remote server
$session = New-CimSession -ComputerName DEMOCLIENT -Credential $clientcredential
Enable-NetFirewallRule -Name 'FPS-SMB-In-TCP' -CimSession $session
sleep -Seconds 2 # wait for firewall to settle - noticed that without a sleep it may fail
Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules' | Where-Object {$_.name -ne 'PackageManagement' -and $_.name -ne 'PowerShellGet'} | copy-item -Destination "\\DEMOCLIENT\C$\Program Files\WindowsPowerShell\Modules" -recurse -Force
#endregion