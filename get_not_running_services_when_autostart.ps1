<#
    #https://social.technet.microsoft.com/Forums/ie/en-US/960fdc9c-2298-440c-916d-c8f8fa1e4cb3/get-stopped-service-from-system-excluding-delayed-and-triggered-services?forum=winserverpowershell

    find services not Running and  startmode = Auto,  without delayed and triggered
#>

function Get-ServiceStartInfo{
    Get-WmiObject Win32_Service -ComputerName $Env:Computername |    
        ForEach-Object{
                $keyname = "SYSTEM\CurrentControlSet\Services\$($_.Name)"
                $hive = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('localmachine',$ComputerName)
                if($subkey = $hive.OpenSubKey($keyname)){
                    $delayed = [bool]$subkey.GetValue('DelayedAutoStart')
                }
                $triggered = [bool]$subkey.OpenSubKey('TriggerInfo')

                [pscustomobject]@{
                     ComputerName = $_.PsComputerName
                    Status = $_.State
                    Name = $_.Name
                    DisplayName = $_.DisplayName
                    StartMode = $_.StartMode
                    DelayedAutoStart = $delayed
                    Triggered = $triggered
                }
            }

}


$filter = {
    $_.Status -ne 'Running' -and 
    $_.StartMode -eq 'Auto' -and 
    -not $_.Triggered -and 
    -not $_.DelayedAutoStart
}


Get-ServiceStartInfo | Where $filter
 
