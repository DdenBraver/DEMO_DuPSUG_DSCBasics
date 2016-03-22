# Find and Install DSC Modules using psget
Find-Module -Repository psgallery -Name x* # | Where-Object {$psitem.name -ne 'xSharePoint'} | Install-Module -Force -Verbose

# Get built-in DSC Resources
Get-DscResource -Module PSDesiredStateConfiguration | FT -AutoSize

# Get all available DSC Resources
Get-DSCResource | FT name, modulename, version -AutoSize

#region invoke-dsc example
# Get File Resource Properties
(Get-DscResource -Module PSDesiredStateConfiguration -Name File).Properties

# Invoke-DSCResource File (Test)
Invoke-DscResource -Name File -ModuleName PSDesiredStateConfiguration -Method Test -Verbose -Property `
@{
    Ensure = 'Present'
    DestinationPath = 'C:\Temp'
    Type = 'Directory'
}

# Invoke-DSCResource File (Set)
Invoke-DscResource -Name File -ModuleName PSDesiredStateConfiguration -Method Set -Verbose -Property `
@{
    Ensure = 'Present'
    DestinationPath = 'C:\Temp'
    Type = 'Directory'
}

# Invoke-DSCResource File (Get)
Invoke-DscResource -Name File -ModuleName PSDesiredStateConfiguration -Method Get -Verbose -Property `
@{
    Ensure = 'Present'
    DestinationPath = 'C:\Temp'
    Type = 'Directory'
}
#endregion